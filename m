Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id DC6A06B035A
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 16:23:12 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id n68so133206013itn.4
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 13:23:12 -0800 (PST)
Received: from mail-it0-x233.google.com (mail-it0-x233.google.com. [2607:f8b0:4001:c0b::233])
        by mx.google.com with ESMTPS id e19si3608895ioj.160.2016.11.17.13.23.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Nov 2016 13:23:12 -0800 (PST)
Received: by mail-it0-x233.google.com with SMTP id l8so164071858iti.1
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 13:23:12 -0800 (PST)
From: Jens Axboe <axboe@kernel.dk>
Subject: [PATCH v4] mm: don't cap request size based on read-ahead setting
Message-ID: <e4271a04-35cf-b082-34ea-92649f5111be@kernel.dk>
Date: Thu, 17 Nov 2016 14:23:10 -0700
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

We ran into a funky issue, where someone doing 256K buffered reads saw
128K requests at the device level. Turns out it is read-ahead capping
the request size, since we use 128K as the default setting. This doesn't
make a lot of sense - if someone is issuing 256K reads, they should see
256K reads, regardless of the read-ahead setting, if the underlying
device can support a 256K read in a single command.

To make matters more confusing, there's an odd interaction with the
fadvise hint setting. If we tell the kernel we're doing sequential IO on
this file descriptor, we can get twice the read-ahead size. But if we
tell the kernel that we are doing random IO, hence disabling read-ahead,
we do get nice 256K requests at the lower level. This is because
ondemand and forced read-ahead behave differently, with the latter doing
the right thing. An application developer will be, rightfully,
scratching his head at this point, wondering wtf is going on. A good one
will dive into the kernel source, and silently weep.

This patch introduces a bdi hint, io_pages. This is the soft max IO size
for the lower level, I've hooked it up to the bdev settings here.
Read-ahead is modified to issue the maximum of the user request size,
and the read-ahead max size, but capped to the max request size on the
device side. The latter is done to avoid reading ahead too much, if the
application asks for a huge read. With this patch, the kernel behaves
like the application expects.

Signed-off-by: Jens Axboe <axboe@fb.com>

---

Changes since v3:

- Went over it with Johannes, cleaned up the the logic as a result

Changes since v2:

- Fix up the last minute typo on io_pages (Johannes/Hillf)
- Apply the same limit to force_page_cache_readahead().


diff --git a/block/blk-settings.c b/block/blk-settings.c
index f679ae1..65f16cf 100644
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
index 9cc8d7c..ea374e8 100644
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
index c357f27..b8144b2 100644
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
index c8a955b..344c1da 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -207,12 +207,17 @@ int __do_page_cache_readahead(struct address_space 
*mapping, struct file *filp,
   * memory at once.
   */
  int force_page_cache_readahead(struct address_space *mapping, struct 
file *filp,
-		pgoff_t offset, unsigned long nr_to_read)
+		               pgoff_t offset, unsigned long nr_to_read)
  {
+	struct backing_dev_info *bdi = inode_to_bdi(mapping->host);
+	struct file_ra_state *ra = &filp->f_ra;
+	unsigned long max_pages;
+
  	if (unlikely(!mapping->a_ops->readpage && !mapping->a_ops->readpages))
  		return -EINVAL;

-	nr_to_read = min(nr_to_read, inode_to_bdi(mapping->host)->ra_pages);
+	max_pages = max_t(unsigned long, bdi->io_pages, ra->ra_pages);
+	nr_to_read = min(nr_to_read, max_pages);
  	while (nr_to_read) {
  		int err;

@@ -369,10 +374,18 @@ ondemand_readahead(struct address_space *mapping,
  		   bool hit_readahead_marker, pgoff_t offset,
  		   unsigned long req_size)
  {
-	unsigned long max = ra->ra_pages;
+	struct backing_dev_info *bdi = inode_to_bdi(mapping->host);
+	unsigned long max_pages = ra->ra_pages;
  	pgoff_t prev_offset;

  	/*
+	 * If the request exceeds the readahead window, allow the read to
+	 * be up to the optimal hardware IO size
+	 */
+	if (req_size > max_pages && bdi->io_pages > max_pages)
+		max_pages = min(req_size, bdi->io_pages);
+
+	/*
  	 * start of file
  	 */
  	if (!offset)
@@ -385,7 +398,7 @@ ondemand_readahead(struct address_space *mapping,
  	if ((offset == (ra->start + ra->size - ra->async_size) ||
  	     offset == (ra->start + ra->size))) {
  		ra->start += ra->size;
-		ra->size = get_next_ra_size(ra, max);
+		ra->size = get_next_ra_size(ra, max_pages);
  		ra->async_size = ra->size;
  		goto readit;
  	}
@@ -400,16 +413,16 @@ ondemand_readahead(struct address_space *mapping,
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
@@ -417,7 +430,7 @@ ondemand_readahead(struct address_space *mapping,
  	/*
  	 * oversize read
  	 */
-	if (req_size > max)
+	if (req_size > max_pages)
  		goto initial_readahead;

  	/*
@@ -433,7 +446,7 @@ ondemand_readahead(struct address_space *mapping,
  	 * Query the page cache and look for the traces(cached history pages)
  	 * that a sequential stream would leave behind.
  	 */
-	if (try_context_readahead(mapping, ra, offset, req_size, max))
+	if (try_context_readahead(mapping, ra, offset, req_size, max_pages))
  		goto readit;

  	/*
@@ -444,7 +457,7 @@ ondemand_readahead(struct address_space *mapping,

  initial_readahead:
  	ra->start = offset;
-	ra->size = get_init_ra_size(req_size, max);
+	ra->size = get_init_ra_size(req_size, max_pages);
  	ra->async_size = ra->size > req_size ? ra->size - req_size : ra->size;

  readit:
@@ -454,7 +467,7 @@ ondemand_readahead(struct address_space *mapping,
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
