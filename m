Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id 2B2C66B0253
	for <linux-mm@kvack.org>; Fri, 21 Aug 2015 13:14:06 -0400 (EDT)
Received: by lbbtg9 with SMTP id tg9so47864235lbb.1
        for <linux-mm@kvack.org>; Fri, 21 Aug 2015 10:14:05 -0700 (PDT)
Received: from forward-corp1o.mail.yandex.net (forward-corp1o.mail.yandex.net. [37.140.190.172])
        by mx.google.com with ESMTPS id o6si6703705lag.87.2015.08.21.10.14.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Aug 2015 10:14:04 -0700 (PDT)
From: Roman Gushchin <klamm@yandex-team.ru>
Subject: [PATCH] mm: use only per-device readahead limit
Date: Fri, 21 Aug 2015 20:12:01 +0300
Message-Id: <1440177121-12741-1-git-send-email-klamm@yandex-team.ru>
In-Reply-To: <CA+55aFz64=vB5vRDj0N0jukWBNnVDd5vf27GL4is6vbYrM17LQ@mail.gmail.com>
References: <CA+55aFz64=vB5vRDj0N0jukWBNnVDd5vf27GL4is6vbYrM17LQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Roman Gushchin <klamm@yandex-team.ru>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>

Maximal readahead size is limited now by two values:
1) by global 2Mb constant (MAX_READAHEAD in max_sane_readahead())
2) by configurable per-device value* (bdi->ra_pages)

There are devices, which require custom readahead limit.
For instance, for RAIDs it's calculated as number of devices
multiplied by chunk size times 2.

Readahead size can never be larger than bdi->ra_pages * 2 value
(POSIX_FADV_SEQUNTIAL doubles readahead size).

If so, why do we need two limits?
I suggest to completely remove this max_sane_readahead() stuff and
use per-device readahead limit everywhere.

Also, using right readahead size for RAID disks can significantly
increase i/o performance:

before:
dd if=/dev/md2 of=/dev/null bs=100M count=100
100+0 records in
100+0 records out
10485760000 bytes (10 GB) copied, 12.9741 s, 808 MB/s

after:
$ dd if=/dev/md2 of=/dev/null bs=100M count=100
100+0 records in
100+0 records out
10485760000 bytes (10 GB) copied, 8.91317 s, 1.2 GB/s

(It's an 8-disks RAID5 storage).

This patch doesn't change sys_readahead and madvise(MADV_WILLNEED)
behavior introduced by commit
6d2be915e589b58cb11418cbe1f22ff90732b6ac ("mm/readahead.c: fix
readahead failure for memoryless NUMA nodes and limit readahead pages").

Signed-off-by: Roman Gushchin <klamm@yandex-team.ru>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/mm.h |  2 --
 mm/filemap.c       |  8 +++-----
 mm/readahead.c     | 14 ++------------
 3 files changed, 5 insertions(+), 19 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 2e872f9..a62abdd 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1942,8 +1942,6 @@ void page_cache_async_readahead(struct address_space *mapping,
 				pgoff_t offset,
 				unsigned long size);
 
-unsigned long max_sane_readahead(unsigned long nr);
-
 /* Generic expand stack which grows the stack according to GROWS{UP,DOWN} */
 extern int expand_stack(struct vm_area_struct *vma, unsigned long address);
 
diff --git a/mm/filemap.c b/mm/filemap.c
index 1283fc8..0e1ebef 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1807,7 +1807,6 @@ static void do_sync_mmap_readahead(struct vm_area_struct *vma,
 				   struct file *file,
 				   pgoff_t offset)
 {
-	unsigned long ra_pages;
 	struct address_space *mapping = file->f_mapping;
 
 	/* If we don't want any read-ahead, don't bother */
@@ -1836,10 +1835,9 @@ static void do_sync_mmap_readahead(struct vm_area_struct *vma,
 	/*
 	 * mmap read-around
 	 */
-	ra_pages = max_sane_readahead(ra->ra_pages);
-	ra->start = max_t(long, 0, offset - ra_pages / 2);
-	ra->size = ra_pages;
-	ra->async_size = ra_pages / 4;
+	ra->start = max_t(long, 0, offset - ra->ra_pages / 2);
+	ra->size = ra->ra_pages;
+	ra->async_size = ra->ra_pages / 4;
 	ra_submit(ra, mapping, file);
 }
 
diff --git a/mm/readahead.c b/mm/readahead.c
index 60cd846..b4937a6 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -213,7 +213,7 @@ int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
 	if (unlikely(!mapping->a_ops->readpage && !mapping->a_ops->readpages))
 		return -EINVAL;
 
-	nr_to_read = max_sane_readahead(nr_to_read);
+	nr_to_read = min(nr_to_read, inode_to_bdi(mapping->host)->ra_pages);
 	while (nr_to_read) {
 		int err;
 
@@ -232,16 +232,6 @@ int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
 	return 0;
 }
 
-#define MAX_READAHEAD   ((512*4096)/PAGE_CACHE_SIZE)
-/*
- * Given a desired number of PAGE_CACHE_SIZE readahead pages, return a
- * sensible upper limit.
- */
-unsigned long max_sane_readahead(unsigned long nr)
-{
-	return min(nr, MAX_READAHEAD);
-}
-
 /*
  * Set the initial window size, round to next power of 2 and square
  * for small size, x 4 for medium, and x 2 for large
@@ -380,7 +370,7 @@ ondemand_readahead(struct address_space *mapping,
 		   bool hit_readahead_marker, pgoff_t offset,
 		   unsigned long req_size)
 {
-	unsigned long max = max_sane_readahead(ra->ra_pages);
+	unsigned long max = ra->ra_pages;
 	pgoff_t prev_offset;
 
 	/*
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
