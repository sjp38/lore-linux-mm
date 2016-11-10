Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id B56E7280259
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 12:00:40 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id b132so41841853iti.5
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 09:00:40 -0800 (PST)
Received: from mail-it0-x233.google.com (mail-it0-x233.google.com. [2607:f8b0:4001:c0b::233])
        by mx.google.com with ESMTPS id j10si4023585iti.85.2016.11.10.09.00.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Nov 2016 09:00:39 -0800 (PST)
Received: by mail-it0-x233.google.com with SMTP id u205so54727148itc.0
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 09:00:39 -0800 (PST)
From: Jens Axboe <axboe@kernel.dk>
Subject: [PATCH/RFC] mm: don't cap request size based on read-ahead setting
Message-ID: <7d8739c2-09ea-8c1f-cef7-9b8b40766c6a@kernel.dk>
Date: Thu, 10 Nov 2016 10:00:37 -0700
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi,

We ran into a funky issue, where someone doing 256K buffered reads saw
128K requests at the device level. Turns out it is read-ahead capping
the request size, since we use 128K as the default setting. This doesn't
make a lot of sense - if someone is issuing 256K reads, they should see
256K reads, regardless of the read-ahead setting.

To make matters more confusing, there's an odd interaction with the
fadvise hint setting. If we tell the kernel we're doing sequential IO on
this file descriptor, we can get twice the read-ahead size. But if we
tell the kernel that we are doing random IO, hence disabling read-ahead,
we do get nice 256K requests at the lower level. An application
developer will be, rightfully, scratching his head at this point,
wondering wtf is going on. A good one will dive into the kernel source,
and silently weep.

This patch introduces a bdi hint, io_pages. This is the soft max IO size
for the lower level, I've hooked it up to the bdev settings here.
Read-ahead is modified to issue the maximum of the user request size,
and the read-ahead max size, but capped to the max request size on the
device side. The latter is done to avoid reading ahead too much, if the
application asks for a huge read. With this patch, the kernel behaves
like the application expects.


diff --git a/block/blk-settings.c b/block/blk-settings.c
index f679ae122843..65f16cf4f850 100644
--- a/block/blk-settings.c
+++ b/block/blk-settings.c
@@ -249,6 +249,7 @@ void blk_queue_max_hw_sectors(struct request_queue 
*q, unsigned int max_hw_secto
  	max_sectors = min_not_zero(max_hw_sectors, limits->max_dev_sectors);
  	max_sectors = min_t(unsigned int, max_sectors, BLK_DEF_MAX_SECTORS);
  	limits->max_sectors = max_sectors;
+	q->backing_dev_info.io_pages = max_sectors >> (PAGE_SHIFT - 9);
  }
  EXPORT_SYMBOL(blk_queue_max_hw_sectors);

diff --git a/block/blk-sysfs.c b/block/blk-sysfs.c
index 9cc8d7c5439a..ea374e820775 100644
--- a/block/blk-sysfs.c
+++ b/block/blk-sysfs.c
@@ -212,6 +212,7 @@ queue_max_sectors_store(struct request_queue *q, 
const char *page, size_t count)

  	spin_lock_irq(q->queue_lock);
  	q->limits.max_sectors = max_sectors_kb << 1;
+	q->backing_dev_info.io_pages = max_sectors_kb >> (PAGE_SHIFT - 10);
  	spin_unlock_irq(q->queue_lock);

  	return ret;
diff --git a/include/linux/backing-dev-defs.h 
b/include/linux/backing-dev-defs.h
index c357f27d5483..b8144b2d59ce 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -136,6 +136,7 @@ struct bdi_writeback {
  struct backing_dev_info {
  	struct list_head bdi_list;
  	unsigned long ra_pages;	/* max readahead in PAGE_SIZE units */
+	unsigned long io_pages;	/* max allowed IO size */
  	unsigned int capabilities; /* Device capabilities */
  	congested_fn *congested_fn; /* Function pointer if device is md/dm */
  	void *congested_data;	/* Pointer to aux data for congested func */
diff --git a/mm/readahead.c b/mm/readahead.c
index c8a955b1297e..49515238cdb1 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -369,10 +369,18 @@ ondemand_readahead(struct address_space *mapping,
  		   bool hit_readahead_marker, pgoff_t offset,
  		   unsigned long req_size)
  {
-	unsigned long max = ra->ra_pages;
+	unsigned long max_pages;
  	pgoff_t prev_offset;

  	/*
+	 * Use the max of the read-ahead pages setting and the requested IO
+	 * size, and then the min of that and the soft IO size for the
+	 * underlying device.
+	 */
+	max_pages = max_t(unsigned long, ra->ra_pages, req_size);
+	max_pages = min_not_zero(inode_to_bdi(mapping->host)->io_pages, 
max_pages);
+
+	/*
  	 * start of file
  	 */
  	if (!offset)
@@ -385,7 +393,7 @@ ondemand_readahead(struct address_space *mapping,
  	if ((offset == (ra->start + ra->size - ra->async_size) ||
  	     offset == (ra->start + ra->size))) {
  		ra->start += ra->size;
-		ra->size = get_next_ra_size(ra, max);
+		ra->size = get_next_ra_size(ra, max_pages);
  		ra->async_size = ra->size;
  		goto readit;
  	}
@@ -400,16 +408,16 @@ ondemand_readahead(struct address_space *mapping,
  		pgoff_t start;

  		rcu_read_lock();
-		start = page_cache_next_hole(mapping, offset + 1, max);
+		start = page_cache_next_hole(mapping, offset + 1, max_pages);
  		rcu_read_unlock();

-		if (!start || start - offset > max)
+		if (!start || start - offset > max_pages)
  			return 0;

  		ra->start = start;
  		ra->size = start - offset;	/* old async_size */
  		ra->size += req_size;
-		ra->size = get_next_ra_size(ra, max);
+		ra->size = get_next_ra_size(ra, max_pages);
  		ra->async_size = ra->size;
  		goto readit;
  	}
@@ -417,7 +425,7 @@ ondemand_readahead(struct address_space *mapping,
  	/*
  	 * oversize read
  	 */
-	if (req_size > max)
+	if (req_size > max_pages)
  		goto initial_readahead;

  	/*
@@ -433,7 +441,7 @@ ondemand_readahead(struct address_space *mapping,
  	 * Query the page cache and look for the traces(cached history pages)
  	 * that a sequential stream would leave behind.
  	 */
-	if (try_context_readahead(mapping, ra, offset, req_size, max))
+	if (try_context_readahead(mapping, ra, offset, req_size, max_pages))
  		goto readit;

  	/*
@@ -444,7 +452,7 @@ ondemand_readahead(struct address_space *mapping,

  initial_readahead:
  	ra->start = offset;
-	ra->size = get_init_ra_size(req_size, max);
+	ra->size = get_init_ra_size(req_size, max_pages);
  	ra->async_size = ra->size > req_size ? ra->size - req_size : ra->size;

  readit:
@@ -454,7 +462,7 @@ ondemand_readahead(struct address_space *mapping,
  	 * the resulted next readahead window into the current one.
  	 */
  	if (offset == ra->start && ra->size == ra->async_size) {
-		ra->async_size = get_next_ra_size(ra, max);
+		ra->async_size = get_next_ra_size(ra, max_pages);
  		ra->size += ra->async_size;
  	}


-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
