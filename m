Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 6E3436B0027
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 22:46:34 -0400 (EDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 2 Apr 2013 08:11:48 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id D0AB51258052
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 08:17:45 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r322kND02818384
	for <linux-mm@kvack.org>; Tue, 2 Apr 2013 08:16:24 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r322kPeM003886
	for <linux-mm@kvack.org>; Tue, 2 Apr 2013 13:46:26 +1100
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v5 0/8] staging: zcache: Support zero-filled pages more efficiently
Date: Tue,  2 Apr 2013 10:46:12 +0800
Message-Id: <1364870780-16296-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, Fengguang Wu <fengguang.wu@intel.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Changelog:
 v4 -> v5: 
  * fix compile error, reported by Fengguang, Geert 
  * add check for !is_ephemeral(pool), spotted by Bob 
 v3 -> v4:
  * handle duplication in page_is_zero_filled, spotted by Bob
  * fix zcache writeback in dubugfs 
  * fix pers_pageframes|_max isn't exported in debugfs
  * fix static variable defined in debug.h but used in multiple C files 
  * rebase on Greg's staging-next
 v2 -> v3:
  * increment/decrement zcache_[eph|pers]_zpages for zero-filled pages, spotted by Dan 
  * replace "zero" or "zero page" by "zero_filled_page", spotted by Dan
 v1 -> v2:
  * avoid changing tmem.[ch] entirely, spotted by Dan.
  * don't accumulate [eph|pers]pageframe and [eph|pers]zpages for 
    zero-filled pages, spotted by Dan
  * cleanup TODO list
  * add Dan Acked-by.

Motivation:

- Seth Jennings points out compress zero-filled pages with LZO(a lossless 
  data compression algorithm) will waste memory and result in fragmentation.
  https://lkml.org/lkml/2012/8/14/347
- Dan Magenheimer add "Support zero-filled pages more efficiently" feature 
  in zcache TODO list https://lkml.org/lkml/2013/2/13/503

Design:

- For store page, capture zero-filled pages(evicted clean page cache pages and 
  swap pages), but don't compress them, set pampd which store zpage address to
  0x2(since 0x0 and 0x1 has already been ocuppied) to mark special zero-filled
  case and take advantage of tmem infrastructure to transform handle-tuple(pool
  id, object id, and an index) to a pampd. Twice compress zero-filled pages will
  contribute to one zcache_[eph|pers]_pageframes count accumulated.
- For load page, traverse tmem hierachical to transform handle-tuple to pampd 
  and identify zero-filled case by pampd equal to 0x2 when filesystem reads
  file pages or a page needs to be swapped in, then refill the page to zero
  and return.

Test:

dd if=/dev/zero of=zerofile bs=1MB count=500
vmtouch -t zerofile
vmtouch -e zerofile

formula:
- fragmentation level = (zcache_[eph|pers]_pageframes * PAGE_SIZE - zcache_[eph|pers]_zbytes) 
  * 100 / (zcache_[eph|pers]_pageframes * PAGE_SIZE)
- memory zcache occupy = zcache_[eph|pers]_zbytes 

Result:

without zero-filled awareness:
- fragmentation level: 98%
- memory zcache occupy: 238MB
with zero-filled awareness:
- fragmentation level: 0%
- memory zcache occupy: 0MB

Wanpeng Li (8):
  staging: zcache: Support zero-filled pages more efficiently
  staging: zcache: zero-filled pages awareness
  staging: zcache: handle zcache_[eph|pers]_zpages for zero-filled page
  staging: zcache: fix pers_pageframes|_max aren't exported in debugfs
  staging: zcache: fix zcache writeback in debugfs
  staging: zcache: fix static variables defined in debug.h but used in
    mutiple C files
  staging: zcache: introduce zero-filled page stat count
  staging: zcache: clean TODO list

 drivers/staging/zcache/TODO          |    3 +-
 drivers/staging/zcache/debug.c       |    5 +-
 drivers/staging/zcache/debug.h       |   77 +++++++++++--------
 drivers/staging/zcache/zcache-main.c |  141 ++++++++++++++++++++++++++++++++--
 4 files changed, 183 insertions(+), 43 deletions(-)

-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
