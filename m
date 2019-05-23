Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58146C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 14:24:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 05D092081C
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 14:24:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 05D092081C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 77EB06B0003; Thu, 23 May 2019 10:24:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 72FDA6B0005; Thu, 23 May 2019 10:24:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F74E6B0006; Thu, 23 May 2019 10:24:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 357786B0003
	for <linux-mm@kvack.org>; Thu, 23 May 2019 10:24:44 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id m188so5504897ita.0
        for <linux-mm@kvack.org>; Thu, 23 May 2019 07:24:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=8PJ1UVNjXtMIvYKCC66cLGiTdJNAVd4zIy4FKi1qJKI=;
        b=qx0fKT+dcYiGe8slB6ZudtetoljWdQrDtTpO2plPO7VSdVLOrZyFyHnwEEaVctQzh7
         9DBQEdS7gxYAbxpMzs+EPkeBS4BSj/MbUN3iaq/s72AQ+c5Cy3XtdPsicZb0CthT0GNn
         3rRSFZhXClc85ZtFKxh6SBZBJznkkWGHD92+XIkx299jPfgS3I3rBvCgmdJiaPrFRmFr
         CINplAeORoPx4gobcHiUXxfbNmRSOSFtjesBijmEzJBbFP7q3YhxHxrB0L5s+lxRR/Qh
         9XWXHQXPDwDNRG6SweSwxDVSOfuIrnUYzstO8/XbkUkWDeTn/z8yMs1OjQg5kN20YTj8
         akzA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aaron.lu@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=aaron.lu@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUjA6KGhubxvzkYA4Y2qLUWP5wc1DUvY1GAIzWFi+VzPU0eAzxx
	6K781nsvm2O6Lwj576qLE+moEpwGXDqgvqdIrb/G47jpXbcG8tpsdUR9CuhTaf7GWAW8tgzvEes
	j0bHUjWYGZ3kwP4C1ALNevX2VANwgXOM6kHf4r0xUDSAF/QP9UgRB79QsTKUJujK+3w==
X-Received: by 2002:a24:47cc:: with SMTP id t195mr12890420itb.117.1558621483873;
        Thu, 23 May 2019 07:24:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwJPTCrWV6Ov9clqpkgUaXJ89taE3BIbgfAsj72Lr6MBReTdEGkE6tR48oDHxDke1WGf+D6
X-Received: by 2002:a24:47cc:: with SMTP id t195mr12890318itb.117.1558621482348;
        Thu, 23 May 2019 07:24:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558621482; cv=none;
        d=google.com; s=arc-20160816;
        b=TMjCg+R3oEpUAmZpK9+02B/8/3+hZb65CCUJhEbY5N85TzdPTf9E3ffpJd7d4jzXTS
         l9V5i0yA88CFY9AkCcBElHXFY6SJ8WHt7LkzdfbMnT9aJ/5bfNauut5+itOawMEni0r7
         fxgCszZMiAqPyOxSC4OU1GQJHzIFKXAqtsFsZmF0EkTo490e5vhOZbwF1Aa+BHLLZpy3
         nWdjd+OJoIqUHHvPQ+4iB7J6JRfOg+LTJdWJPTrU7QcmLggNivfMRoZW0QkmlnvPZ9ym
         PA26CEz6VbMurESmptx4pBu9xNZaKdkZuSvgcYPkpehcvfC0QDgmc+xyIoCnG23HQ02x
         wfqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=8PJ1UVNjXtMIvYKCC66cLGiTdJNAVd4zIy4FKi1qJKI=;
        b=h2ZuI3kxTAC50d1vW7bckuvL48FguVZ2DGDiFMTcPw7m6Sz2b1cVZ9gIwAtEkmbHHH
         sQmLcUAt3gh1fKZ8ntc1Dza7H4nFITfaD93o2L3bnnDb7S4It+9J2AjihE1aVCgjyvAv
         ZxsEf0wfe7lvlFXxoEFPt12Ysilgq6hfMU8dH+s7asUC0jkZ6VmY0Uowr6GBOUxLVqUQ
         PnUUT8aDiUKnJq+GjCArpadwuMbUSKujmYMS0A1Pm0VI1lUMjn1Azb6tVIPvFqMGs8+/
         PtBYF6q7P8Cp1Y+3h6uY8GbQj9/C8TAhp7tEBU+6sOk+GC9XEqOy8RRfEYw4G5rskQ00
         uTrw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aaron.lu@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=aaron.lu@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id m44si3410639iti.132.2019.05.23.07.24.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 May 2019 07:24:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of aaron.lu@linux.alibaba.com designates 115.124.30.133 as permitted sender) client-ip=115.124.30.133;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aaron.lu@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=aaron.lu@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R241e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04394;MF=aaron.lu@linux.alibaba.com;NM=1;PH=DS;RN=3;SR=0;TI=SMTPD_---0TSTuuDA_1558621456;
Received: from aaronlu(mailfrom:aaron.lu@linux.alibaba.com fp:SMTPD_---0TSTuuDA_1558621456)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 23 May 2019 22:24:24 +0800
Date: Thu, 23 May 2019 22:24:15 +0800
From: Aaron Lu <aaron.lu@linux.alibaba.com>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Huang Ying <ying.huang@intel.com>
Subject: [PATCH] mm, swap: use rbtree for swap_extent
Message-ID: <20190523142404.GA181@aaronlu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Aaron Lu <ziqian.lzq@antfin.com>

swap_extent is used to map swap page offset to backing device's block
offset. For a continuous block range, one swap_extent is used and all
these swap_extents are managed in a linked list.

These swap_extents are used by map_swap_entry() during swap's read and
write path. To find out the backing device's block offset for a page
offset, the swap_extent list will be traversed linearly, with
curr_swap_extent being used as a cache to speed up the search.

This works well as long as swap_extents are not huge or when the number
of processes that access swap device are few, but when the swap device
has many extents and there are a number of processes accessing the swap
device concurrently, it can be a problem. On one of our servers, the
disk's remaining size is tight:
$df -h
Filesystem      Size  Used Avail Use% Mounted on
... ...
/dev/nvme0n1p1  1.8T  1.3T  504G  72% /home/t4

When creating a 80G swapfile there, there are as many as 84656 swap
extents. The end result is, kernel spends abou 30% time in map_swap_entry()
and swap throughput is only 70MB/s. As a comparison, when I used smaller
sized swapfile, like 4G whose swap_extent dropped to 2000, swap throughput
is back to 400-500MB/s and map_swap_entry() is about 3%.

One downside of using rbtree for swap_extent is, 'struct rbtree' takes
24 bytes while 'struct list_head' takes 16 bytes, that's 8 bytes more
for each swap_extent. For a swapfile that has 80k swap_extents, that
means 625KiB more memory consumed.

Test:

Since it's not possible to reboot that server, I can not test this patch
diretly there. Instead, I tested it on another server with NVMe disk.

I created a 20G swapfile on an NVMe backed XFS fs. By default, the
filesystem is quite clean and the created swapfile has only 2 extents.
Testing vanilla and this patch shows no obvious performance difference
when swapfile is not fragmented.

To see the patch's effects, I used some tweaks to manually fragment the
swapfile by breaking the extent at 1M boundary. This made the swapfile
have 20K extents.

nr_task=4
kernel   swapout(KB/s) map_swap_entry(perf)  swapin(KB/s) map_swap_entry(perf)
vanilla  165191           90.77%             171798         90.21%
patched  858993 +420%      2.16%      	     715827 +317%    0.77%

nr_task=8
kernel   swapout(KB/s) map_swap_entry(perf)  swapin(KB/s) map_swap_entry(perf)
vanilla  306783           92.19%             318145	    87.76%
patched  954437 +211%      2.35%            1073741 +237%    1.57%

swapout: the throughput of swap out, in KB/s, higher is better
1st map_swap_entry: cpu cycles percent sampled by perf
swapin: the throughput of swap in, in KB/s, higher is better.
2nd map_swap_entry: cpu cycles percent sampled by perf

nr_task=1 doesn't show any difference, this is due to the
curr_swap_extent can be effectively used to cache the correct swap
extent for single task workload.

Signed-off-by: Aaron Lu <ziqian.lzq@antfin.com>
---
 include/linux/swap.h |   5 +-
 mm/page_io.c         |   2 +-
 mm/swapfile.c        | 137 +++++++++++++++++++++++--------------------
 3 files changed, 78 insertions(+), 66 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 4bfb5c4ac108..a229c6273781 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -148,7 +148,7 @@ struct zone;
  * We always assume that blocks are of size PAGE_SIZE.
  */
 struct swap_extent {
-	struct list_head list;
+	struct rb_node rb_node;
 	pgoff_t start_page;
 	pgoff_t nr_pages;
 	sector_t start_block;
@@ -247,8 +247,7 @@ struct swap_info_struct {
 	unsigned int cluster_next;	/* likely index for next allocation */
 	unsigned int cluster_nr;	/* countdown to next cluster search */
 	struct percpu_cluster __percpu *percpu_cluster; /* per cpu's swap location */
-	struct swap_extent *curr_swap_extent;
-	struct swap_extent first_swap_extent;
+	struct rb_root swap_extent_root;/* root of the swap extent rbtree */
 	struct block_device *bdev;	/* swap device or bdev of swap file */
 	struct file *swap_file;		/* seldom referenced */
 	unsigned int old_block_size;	/* seldom referenced */
diff --git a/mm/page_io.c b/mm/page_io.c
index 2e8019d0e048..24ad2d43c11d 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -164,7 +164,7 @@ int generic_swapfile_activate(struct swap_info_struct *sis,
 	blocks_per_page = PAGE_SIZE >> blkbits;
 
 	/*
-	 * Map all the blocks into the extent list.  This code doesn't try
+	 * Map all the blocks into the extent tree.  This code doesn't try
 	 * to be very smart.
 	 */
 	probe_block = 0;
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 596ac98051c5..82b96750ad45 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -152,6 +152,18 @@ static int __try_to_reclaim_swap(struct swap_info_struct *si,
 	return ret;
 }
 
+static inline struct swap_extent *first_se(struct swap_info_struct *sis)
+{
+	struct rb_node *rb = rb_first(&sis->swap_extent_root);
+	return rb_entry(rb, struct swap_extent, rb_node);
+}
+
+static inline struct swap_extent *next_se(struct swap_extent *se)
+{
+	struct rb_node *rb = rb_next(&se->rb_node);
+	return rb ? rb_entry(rb, struct swap_extent, rb_node) : NULL;
+}
+
 /*
  * swapon tell device that all the old swap contents can be discarded,
  * to allow the swap device to optimize its wear-levelling.
@@ -164,7 +176,7 @@ static int discard_swap(struct swap_info_struct *si)
 	int err = 0;
 
 	/* Do not discard the swap header page! */
-	se = &si->first_swap_extent;
+	se = first_se(si);
 	start_block = (se->start_block + 1) << (PAGE_SHIFT - 9);
 	nr_blocks = ((sector_t)se->nr_pages - 1) << (PAGE_SHIFT - 9);
 	if (nr_blocks) {
@@ -175,7 +187,7 @@ static int discard_swap(struct swap_info_struct *si)
 		cond_resched();
 	}
 
-	list_for_each_entry(se, &si->first_swap_extent.list, list) {
+	for (se = next_se(se); se; se = next_se(se)) {
 		start_block = se->start_block << (PAGE_SHIFT - 9);
 		nr_blocks = (sector_t)se->nr_pages << (PAGE_SHIFT - 9);
 
@@ -189,6 +201,26 @@ static int discard_swap(struct swap_info_struct *si)
 	return err;		/* That will often be -EOPNOTSUPP */
 }
 
+static struct swap_extent *
+offset_to_swap_extent(struct swap_info_struct *sis, unsigned long offset)
+{
+	struct swap_extent *se;
+	struct rb_node *rb;
+
+	rb = sis->swap_extent_root.rb_node;
+	while (rb) {
+		se = rb_entry(rb, struct swap_extent, rb_node);
+		if (offset < se->start_page)
+			rb = rb->rb_left;
+		else if (offset >= se->start_page + se->nr_pages)
+			rb = rb->rb_right;
+		else
+			return se;
+	}
+	/* It *must* be present */
+	BUG_ON(1);
+}
+
 /*
  * swap allocation tell device that a cluster of swap can now be discarded,
  * to allow the swap device to optimize its wear-levelling.
@@ -196,32 +228,25 @@ static int discard_swap(struct swap_info_struct *si)
 static void discard_swap_cluster(struct swap_info_struct *si,
 				 pgoff_t start_page, pgoff_t nr_pages)
 {
-	struct swap_extent *se = si->curr_swap_extent;
-	int found_extent = 0;
+	struct swap_extent *se = offset_to_swap_extent(si, start_page);
 
 	while (nr_pages) {
-		if (se->start_page <= start_page &&
-		    start_page < se->start_page + se->nr_pages) {
-			pgoff_t offset = start_page - se->start_page;
-			sector_t start_block = se->start_block + offset;
-			sector_t nr_blocks = se->nr_pages - offset;
-
-			if (nr_blocks > nr_pages)
-				nr_blocks = nr_pages;
-			start_page += nr_blocks;
-			nr_pages -= nr_blocks;
-
-			if (!found_extent++)
-				si->curr_swap_extent = se;
-
-			start_block <<= PAGE_SHIFT - 9;
-			nr_blocks <<= PAGE_SHIFT - 9;
-			if (blkdev_issue_discard(si->bdev, start_block,
-				    nr_blocks, GFP_NOIO, 0))
-				break;
-		}
+		pgoff_t offset = start_page - se->start_page;
+		sector_t start_block = se->start_block + offset;
+		sector_t nr_blocks = se->nr_pages - offset;
+
+		if (nr_blocks > nr_pages)
+			nr_blocks = nr_pages;
+		start_page += nr_blocks;
+		nr_pages -= nr_blocks;
+
+		start_block <<= PAGE_SHIFT - 9;
+		nr_blocks <<= PAGE_SHIFT - 9;
+		if (blkdev_issue_discard(si->bdev, start_block,
+					nr_blocks, GFP_NOIO, 0))
+			break;
 
-		se = list_next_entry(se, list);
+		se = next_se(se);
 	}
 }
 
@@ -1684,7 +1709,7 @@ int swap_type_of(dev_t device, sector_t offset, struct block_device **bdev_p)
 			return type;
 		}
 		if (bdev == sis->bdev) {
-			struct swap_extent *se = &sis->first_swap_extent;
+			struct swap_extent *se = first_se(sis);
 
 			if (se->start_block == offset) {
 				if (bdev_p)
@@ -2161,7 +2186,6 @@ static void drain_mmlist(void)
 static sector_t map_swap_entry(swp_entry_t entry, struct block_device **bdev)
 {
 	struct swap_info_struct *sis;
-	struct swap_extent *start_se;
 	struct swap_extent *se;
 	pgoff_t offset;
 
@@ -2169,18 +2193,8 @@ static sector_t map_swap_entry(swp_entry_t entry, struct block_device **bdev)
 	*bdev = sis->bdev;
 
 	offset = swp_offset(entry);
-	start_se = sis->curr_swap_extent;
-	se = start_se;
-
-	for ( ; ; ) {
-		if (se->start_page <= offset &&
-				offset < (se->start_page + se->nr_pages)) {
-			return se->start_block + (offset - se->start_page);
-		}
-		se = list_next_entry(se, list);
-		sis->curr_swap_extent = se;
-		BUG_ON(se == start_se);		/* It *must* be present */
-	}
+	se = offset_to_swap_extent(sis, offset);
+	return se->start_block + (offset - se->start_page);
 }
 
 /*
@@ -2198,12 +2212,11 @@ sector_t map_swap_page(struct page *page, struct block_device **bdev)
  */
 static void destroy_swap_extents(struct swap_info_struct *sis)
 {
-	while (!list_empty(&sis->first_swap_extent.list)) {
-		struct swap_extent *se;
+	while (!RB_EMPTY_ROOT(&sis->swap_extent_root)) {
+		struct rb_node *rb = sis->swap_extent_root.rb_node;
+		struct swap_extent *se = rb_entry(rb, struct swap_extent, rb_node);
 
-		se = list_first_entry(&sis->first_swap_extent.list,
-				struct swap_extent, list);
-		list_del(&se->list);
+		rb_erase(rb, &sis->swap_extent_root);
 		kfree(se);
 	}
 
@@ -2219,7 +2232,7 @@ static void destroy_swap_extents(struct swap_info_struct *sis)
 
 /*
  * Add a block range (and the corresponding page range) into this swapdev's
- * extent list.  The extent list is kept sorted in page order.
+ * extent tree.
  *
  * This function rather assumes that it is called in ascending page order.
  */
@@ -2227,20 +2240,21 @@ int
 add_swap_extent(struct swap_info_struct *sis, unsigned long start_page,
 		unsigned long nr_pages, sector_t start_block)
 {
+	struct rb_node **link = &sis->swap_extent_root.rb_node, *parent = NULL;
 	struct swap_extent *se;
 	struct swap_extent *new_se;
-	struct list_head *lh;
-
-	if (start_page == 0) {
-		se = &sis->first_swap_extent;
-		sis->curr_swap_extent = se;
-		se->start_page = 0;
-		se->nr_pages = nr_pages;
-		se->start_block = start_block;
-		return 1;
-	} else {
-		lh = sis->first_swap_extent.list.prev;	/* Highest extent */
-		se = list_entry(lh, struct swap_extent, list);
+
+	/*
+	 * place the new node at the right most since the
+	 * function is called in ascending page order.
+	 */
+	while (*link) {
+		parent = *link;
+		link = &parent->rb_right;
+	}
+
+	if (parent) {
+		se = rb_entry(parent, struct swap_extent, rb_node);
 		BUG_ON(se->start_page + se->nr_pages != start_page);
 		if (se->start_block + se->nr_pages == start_block) {
 			/* Merge it */
@@ -2249,9 +2263,7 @@ add_swap_extent(struct swap_info_struct *sis, unsigned long start_page,
 		}
 	}
 
-	/*
-	 * No merge.  Insert a new extent, preserving ordering.
-	 */
+	/* No merge, insert a new extent. */
 	new_se = kmalloc(sizeof(*se), GFP_KERNEL);
 	if (new_se == NULL)
 		return -ENOMEM;
@@ -2259,7 +2271,8 @@ add_swap_extent(struct swap_info_struct *sis, unsigned long start_page,
 	new_se->nr_pages = nr_pages;
 	new_se->start_block = start_block;
 
-	list_add_tail(&new_se->list, &sis->first_swap_extent.list);
+	rb_link_node(&new_se->rb_node, parent, link);
+	rb_insert_color(&new_se->rb_node, &sis->swap_extent_root);
 	return 1;
 }
 EXPORT_SYMBOL_GPL(add_swap_extent);
@@ -2749,7 +2762,7 @@ static struct swap_info_struct *alloc_swap_info(void)
 		 * would be relying on p->type to remain valid.
 		 */
 	}
-	INIT_LIST_HEAD(&p->first_swap_extent.list);
+	p->swap_extent_root = RB_ROOT;
 	plist_node_init(&p->list, 0);
 	for_each_node(i)
 		plist_node_init(&p->avail_lists[i], 0);
-- 
2.19.1.3.ge56e4f7

