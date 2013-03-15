Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id A05BB6B0027
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 22:35:08 -0400 (EDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 15 Mar 2013 08:02:00 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 634F7E0050
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 08:06:25 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2F2YvxH6291462
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 08:04:59 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2F2Yxme028933
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 02:35:00 GMT
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v3 0/5] zcache: Support zero-filled pages more efficiently
Date: Fri, 15 Mar 2013 10:34:15 +0800
Message-Id: <1363314860-22731-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Changelog:
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

Wanpeng Li (5):
  introduce zero-filled pages handler
  zero-filled pages awareness
  handle zcache_[eph|pers]_zpages for zero-filled page
  introduce zero-filled page stat count
  clean TODO list

 drivers/staging/zcache/TODO          |    3 +-
 drivers/staging/zcache/zcache-main.c |  119 ++++++++++++++++++++++++++++++++--
 2 files changed, 114 insertions(+), 8 deletions(-)

-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
