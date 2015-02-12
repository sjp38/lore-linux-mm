Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
	by kanga.kvack.org (Postfix) with ESMTP id EA7CC6B0038
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 15:46:47 -0500 (EST)
Received: by mail-we0-f172.google.com with SMTP id k48so12657130wev.3
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 12:46:47 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id bw9si242396wjc.74.2015.02.12.12.46.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Feb 2015 12:46:46 -0800 (PST)
Date: Thu, 12 Feb 2015 15:46:36 -0500
From: Mike Snitzer <snitzer@redhat.com>
Subject: [PATCH] dm log userspace: split flush_entry_pool to be per dirty-log
 [was: Re: mempool.c: Replace io_schedule_timeout with io_schedule]
Message-ID: <20150212204636.GA27091@redhat.com>
References: <1418863222-25096-1-git-send-email-nefelim4ag@gmail.com>
 <20141218153709.GC2293@redhat.com>
 <20141219195327.GC8697@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141219195327.GC8697@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Timofey Titovets <nefelim4ag@gmail.com>, Heinz Mauelshagen <heinzm@redhat.com>, Jonathan Brassow <jbrassow@redhat.com>
Cc: Tejun Heo <tj@kernel.org>, dm-devel@redhat.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Fri, Dec 19 2014 at  2:53pm -0500,
Mike Snitzer <snitzer@redhat.com> wrote:

> On Thu, Dec 18 2014 at 10:37am -0500,
> Mike Snitzer <snitzer@redhat.com> wrote:
> 
> > On Wed, Dec 17 2014 at  7:40pm -0500,
> > Timofey Titovets <nefelim4ag@gmail.com> wrote:
> > 
> > > io_schedule_timeout(5*HZ);
> > > Introduced for avoidance dm bug:
> > > http://linux.derkeiler.com/Mailing-Lists/Kernel/2006-08/msg04869.html
> > > According to description must be replaced with io_schedule()
...
> > So I'll have to read the thread you linked to to understand if DM raid1
> > (or DM core) still suffers from the problem that this hack papered over.
> 
> Heinz also pointed out that the primary issue that forced the use of
> io_schedule_timeout() was that dm-log-userspace (used by dm-raid1) makes
> use of a single shared mempool for multiple devices.  Unfortunately,
> dm-log-userspace still has this shared mempool (flush_entry_pool).  So
> we'll need to fix that up to be per-device before mm/mempool.c code can
> be switched to use io_schedule().
> 
> I'll add this to my TODO.  But it'll have to wait until after the new
> year.

I finally got around to this.  Heinz and/or Jon, would you be willing to
test this?  No real rush (won't go upstream until next merge window,
3.21).  One question I have is: should FLUSH_ENTRY_POOL_SIZE be reduced
from 100 (previous default global min_nr) now that this reserve is
per-dirty-log?


From: Mike Snitzer <snitzer@redhat.com>
Date: Thu, 12 Feb 2015 15:20:35 -0500
Subject: [PATCH] dm log userspace: split flush_entry_pool to be per dirty-log

Use a single slab cache to allocate a mempool for each dirty-log.
This _should_ eliminate DM's need for io_schedule_timeout() in
mempool_alloc(); so io_schedule() should be sufficient now.

Also, rename struct flush_entry to dm_dirty_log_flush_entry to allow
KMEM_CACHE() to create a meaningful global name for the slab cache.

Also, eliminate some holes in struct log_c by rearranging members.

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 drivers/md/dm-log-userspace-base.c | 84 ++++++++++++++++++++------------------
 1 file changed, 45 insertions(+), 39 deletions(-)

diff --git a/drivers/md/dm-log-userspace-base.c b/drivers/md/dm-log-userspace-base.c
index 03177ca..266bffc 100644
--- a/drivers/md/dm-log-userspace-base.c
+++ b/drivers/md/dm-log-userspace-base.c
@@ -17,7 +17,9 @@
 
 #define DM_LOG_USERSPACE_VSN "1.3.0"
 
-struct flush_entry {
+#define FLUSH_ENTRY_POOL_SIZE 100
+
+struct dm_dirty_log_flush_entry {
 	int type;
 	region_t region;
 	struct list_head list;
@@ -34,22 +36,14 @@ struct flush_entry {
 struct log_c {
 	struct dm_target *ti;
 	struct dm_dev *log_dev;
-	uint32_t region_size;
-	region_t region_count;
-	uint64_t luid;
-	char uuid[DM_UUID_LEN];
 
 	char *usr_argv_str;
 	uint32_t usr_argc;
 
-	/*
-	 * in_sync_hint gets set when doing is_remote_recovering.  It
-	 * represents the first region that needs recovery.  IOW, the
-	 * first zero bit of sync_bits.  This can be useful for to limit
-	 * traffic for calls like is_remote_recovering and get_resync_work,
-	 * but be take care in its use for anything else.
-	 */
-	uint64_t in_sync_hint;
+	uint32_t region_size;
+	region_t region_count;
+	uint64_t luid;
+	char uuid[DM_UUID_LEN];
 
 	/*
 	 * Mark and clear requests are held until a flush is issued
@@ -62,6 +56,15 @@ struct log_c {
 	struct list_head clear_list;
 
 	/*
+	 * in_sync_hint gets set when doing is_remote_recovering.  It
+	 * represents the first region that needs recovery.  IOW, the
+	 * first zero bit of sync_bits.  This can be useful for to limit
+	 * traffic for calls like is_remote_recovering and get_resync_work,
+	 * but be take care in its use for anything else.
+	 */
+	uint64_t in_sync_hint;
+
+	/*
 	 * Workqueue for flush of clear region requests.
 	 */
 	struct workqueue_struct *dmlog_wq;
@@ -72,19 +75,11 @@ struct log_c {
 	 * Combine userspace flush and mark requests for efficiency.
 	 */
 	uint32_t integrated_flush;
-};
-
-static mempool_t *flush_entry_pool;
 
-static void *flush_entry_alloc(gfp_t gfp_mask, void *pool_data)
-{
-	return kmalloc(sizeof(struct flush_entry), gfp_mask);
-}
+	mempool_t *flush_entry_pool;
+};
 
-static void flush_entry_free(void *element, void *pool_data)
-{
-	kfree(element);
-}
+static struct kmem_cache *_flush_entry_cache;
 
 static int userspace_do_request(struct log_c *lc, const char *uuid,
 				int request_type, char *data, size_t data_size,
@@ -254,6 +249,14 @@ static int userspace_ctr(struct dm_dirty_log *log, struct dm_target *ti,
 		goto out;
 	}
 
+	lc->flush_entry_pool = mempool_create_slab_pool(FLUSH_ENTRY_POOL_SIZE,
+							_flush_entry_cache);
+	if (!lc->flush_entry_pool) {
+		DMERR("Failed to create flush_entry_pool");
+		r = -ENOMEM;
+		goto out;
+	}
+
 	/*
 	 * Send table string and get back any opened device.
 	 */
@@ -310,6 +313,8 @@ static int userspace_ctr(struct dm_dirty_log *log, struct dm_target *ti,
 out:
 	kfree(devices_rdata);
 	if (r) {
+		if (lc->flush_entry_pool)
+			mempool_destroy(lc->flush_entry_pool);
 		kfree(lc);
 		kfree(ctr_str);
 	} else {
@@ -338,6 +343,8 @@ static void userspace_dtr(struct dm_dirty_log *log)
 	if (lc->log_dev)
 		dm_put_device(lc->ti, lc->log_dev);
 
+	mempool_destroy(lc->flush_entry_pool);
+
 	kfree(lc->usr_argv_str);
 	kfree(lc);
 
@@ -461,7 +468,7 @@ static int userspace_in_sync(struct dm_dirty_log *log, region_t region,
 static int flush_one_by_one(struct log_c *lc, struct list_head *flush_list)
 {
 	int r = 0;
-	struct flush_entry *fe;
+	struct dm_dirty_log_flush_entry *fe;
 
 	list_for_each_entry(fe, flush_list, list) {
 		r = userspace_do_request(lc, lc->uuid, fe->type,
@@ -481,7 +488,7 @@ static int flush_by_group(struct log_c *lc, struct list_head *flush_list,
 	int r = 0;
 	int count;
 	uint32_t type = 0;
-	struct flush_entry *fe, *tmp_fe;
+	struct dm_dirty_log_flush_entry *fe, *tmp_fe;
 	LIST_HEAD(tmp_list);
 	uint64_t group[MAX_FLUSH_GROUP_COUNT];
 
@@ -563,7 +570,8 @@ static int userspace_flush(struct dm_dirty_log *log)
 	LIST_HEAD(clear_list);
 	int mark_list_is_empty;
 	int clear_list_is_empty;
-	struct flush_entry *fe, *tmp_fe;
+	struct dm_dirty_log_flush_entry *fe, *tmp_fe;
+	mempool_t *flush_entry_pool = lc->flush_entry_pool;
 
 	spin_lock_irqsave(&lc->flush_lock, flags);
 	list_splice_init(&lc->mark_list, &mark_list);
@@ -643,10 +651,10 @@ static void userspace_mark_region(struct dm_dirty_log *log, region_t region)
 {
 	unsigned long flags;
 	struct log_c *lc = log->context;
-	struct flush_entry *fe;
+	struct dm_dirty_log_flush_entry *fe;
 
 	/* Wait for an allocation, but _never_ fail */
-	fe = mempool_alloc(flush_entry_pool, GFP_NOIO);
+	fe = mempool_alloc(lc->flush_entry_pool, GFP_NOIO);
 	BUG_ON(!fe);
 
 	spin_lock_irqsave(&lc->flush_lock, flags);
@@ -672,7 +680,7 @@ static void userspace_clear_region(struct dm_dirty_log *log, region_t region)
 {
 	unsigned long flags;
 	struct log_c *lc = log->context;
-	struct flush_entry *fe;
+	struct dm_dirty_log_flush_entry *fe;
 
 	/*
 	 * If we fail to allocate, we skip the clearing of
@@ -680,7 +688,7 @@ static void userspace_clear_region(struct dm_dirty_log *log, region_t region)
 	 * to cause the region to be resync'ed when the
 	 * device is activated next time.
 	 */
-	fe = mempool_alloc(flush_entry_pool, GFP_ATOMIC);
+	fe = mempool_alloc(lc->flush_entry_pool, GFP_ATOMIC);
 	if (!fe) {
 		DMERR("Failed to allocate memory to clear region.");
 		return;
@@ -886,18 +894,16 @@ static int __init userspace_dirty_log_init(void)
 {
 	int r = 0;
 
-	flush_entry_pool = mempool_create(100, flush_entry_alloc,
-					  flush_entry_free, NULL);
-
-	if (!flush_entry_pool) {
-		DMWARN("Unable to create flush_entry_pool:  No memory.");
+	_flush_entry_cache = KMEM_CACHE(dm_dirty_log_flush_entry, 0);
+	if (!_flush_entry_cache) {
+		DMWARN("Unable to create flush_entry_cache: No memory.");
 		return -ENOMEM;
 	}
 
 	r = dm_ulog_tfr_init();
 	if (r) {
 		DMWARN("Unable to initialize userspace log communications");
-		mempool_destroy(flush_entry_pool);
+		kmem_cache_destroy(_flush_entry_cache);
 		return r;
 	}
 
@@ -905,7 +911,7 @@ static int __init userspace_dirty_log_init(void)
 	if (r) {
 		DMWARN("Couldn't register userspace dirty log type");
 		dm_ulog_tfr_exit();
-		mempool_destroy(flush_entry_pool);
+		kmem_cache_destroy(_flush_entry_cache);
 		return r;
 	}
 
@@ -917,7 +923,7 @@ static void __exit userspace_dirty_log_exit(void)
 {
 	dm_dirty_log_type_unregister(&_userspace_type);
 	dm_ulog_tfr_exit();
-	mempool_destroy(flush_entry_pool);
+	kmem_cache_destroy(_flush_entry_cache);
 
 	DMINFO("version " DM_LOG_USERSPACE_VSN " unloaded");
 	return;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
