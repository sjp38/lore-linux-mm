From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH part2 v6 0/3] staging: zcache: Support zero-filled pages
 more efficiently
Date: Sun, 7 Apr 2013 17:03:41 +0800
Message-ID: <37183.8012514219$1365325443@news.gmane.org>
References: <1364984183-9711-1-git-send-email-liwanp@linux.vnet.ibm.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UOlVz-0003Ey-DP
	for glkm-linux-mm-2@m.gmane.org; Sun, 07 Apr 2013 11:03:55 +0200
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 9A1A36B0005
	for <linux-mm@kvack.org>; Sun,  7 Apr 2013 05:03:52 -0400 (EDT)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sun, 7 Apr 2013 18:58:16 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id C8DF92BB0023
	for <linux-mm@kvack.org>; Sun,  7 Apr 2013 19:03:44 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r378oUx66029596
	for <linux-mm@kvack.org>; Sun, 7 Apr 2013 18:50:30 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3793ikX004884
	for <linux-mm@kvack.org>; Sun, 7 Apr 2013 19:03:44 +1000
Content-Disposition: inline
In-Reply-To: <1364984183-9711-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, Fengguang Wu <fengguang.wu@intel.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Wed, Apr 03, 2013 at 06:16:20PM +0800, Wanpeng Li wrote:
>Changelog:
> v5 -> v6:
>  * shove variables in debug.c and in debug.h just have an extern, spotted by Konrad
>  * update patch description, spotted by Konrad
> v4 -> v5:
>  * fix compile error, reported by Fengguang, Geert
>  * add check for !is_ephemeral(pool), spotted by Bob
> v3 -> v4:
>  * handle duplication in page_is_zero_filled, spotted by Bob
>  * fix zcache writeback in dubugfs
>  * fix pers_pageframes|_max isn't exported in debugfs
>  * fix static variable defined in debug.h but used in multiple C files
>  * rebase on Greg's staging-next
> v2 -> v3:
>  * increment/decrement zcache_[eph|pers]_zpages for zero-filled pages, spotted by Dan
>  * replace "zero" or "zero page" by "zero_filled_page", spotted by Dan
> v1 -> v2:
>  * avoid changing tmem.[ch] entirely, spotted by Dan.
>  * don't accumulate [eph|pers]pageframe and [eph|pers]zpages for
>    zero-filled pages, spotted by Dan
>  * cleanup TODO list
>  * add Dan Acked-by.
>

Hi Dan,

Some issues against Ramster:

- Ramster who takes advantage of zcache also should support zero-filled 
  pages more efficiently, correct? It doesn't handle zero-filled pages well
  currently.
- Ramster DebugFS counters are exported in /sys/kernel/mm/, but zcache/frontswap/cleancache
  all are exported in /sys/kernel/debug/, should we unify them?
- If ramster also should move DebugFS counters to a single file like
  zcache do?

If you confirm these issues are make sense to fix, I will start coding. ;-)

Regards,
Wanpeng Li 

>Motivation:
>
>- Seth Jennings points out compress zero-filled pages with LZO(a lossless
>  data compression algorithm) will waste memory and result in fragmentation.
>  https://lkml.org/lkml/2012/8/14/347
>- Dan Magenheimer add "Support zero-filled pages more efficiently" feature
>  in zcache TODO list https://lkml.org/lkml/2013/2/13/503
>
>Design:
>
>- For store page, capture zero-filled pages(evicted clean page cache pages and
>  swap pages), but don't compress them, set pampd which store zpage address to
>  0x2(since 0x0 and 0x1 has already been ocuppied) to mark special zero-filled
>  case and take advantage of tmem infrastructure to transform handle-tuple(pool
>  id, object id, and an index) to a pampd. Twice compress zero-filled pages will
>  contribute to one zcache_[eph|pers]_pageframes count accumulated.
>- For load page, traverse tmem hierachical to transform handle-tuple to pampd
>  and identify zero-filled case by pampd equal to 0x2 when filesystem reads
>  file pages or a page needs to be swapped in, then refill the page to zero
>  and return.
>
>Test:
>
>dd if=/dev/zero of=zerofile bs=1MB count=500
>vmtouch -t zerofile
>vmtouch -e zerofile
>
>formula:
>- fragmentation level = (zcache_[eph|pers]_pageframes * PAGE_SIZE - zcache_[eph|pers]_zbytes)
>  * 100 / (zcache_[eph|pers]_pageframes * PAGE_SIZE)
>- memory zcache occupy = zcache_[eph|pers]_zbytes
>
>Result:
>
>without zero-filled awareness:
>- fragmentation level: 98%
>- memory zcache occupy: 238MB
>with zero-filled awareness:
>- fragmentation level: 0%
>- memory zcache occupy: 0MB
>
>Wanpeng Li (3):
>  staging: zcache: fix static variables defined in debug.h but used in
>    mutiple C files
>  staging: zcache: introduce zero-filled page stat count
>  staging: zcache: clean TODO list
>
> drivers/staging/zcache/TODO          |    3 +-
> drivers/staging/zcache/debug.c       |   35 +++++++++++++++
> drivers/staging/zcache/debug.h       |   79 ++++++++++++++++++++-------------
> drivers/staging/zcache/zcache-main.c |    4 ++
> 4 files changed, 88 insertions(+), 33 deletions(-)
>
>-- 
>1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
