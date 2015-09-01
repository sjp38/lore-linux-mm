Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f175.google.com (mail-qk0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id DBE946B0255
	for <linux-mm@kvack.org>; Tue,  1 Sep 2015 13:51:35 -0400 (EDT)
Received: by qkcj187 with SMTP id j187so52490090qkc.2
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 10:51:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 13si7963795qhw.45.2015.09.01.10.51.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Sep 2015 10:51:35 -0700 (PDT)
From: Mike Snitzer <snitzer@redhat.com>
Subject: [PATCH 2/2] dm: disable slab merging for all DM slabs
Date: Tue,  1 Sep 2015 13:51:30 -0400
Message-Id: <1441129890-25585-2-git-send-email-snitzer@redhat.com>
In-Reply-To: <1441129890-25585-1-git-send-email-snitzer@redhat.com>
References: <1441129890-25585-1-git-send-email-snitzer@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, riel@redhat.com, david@fromorbit.com, axboe@kernel.dk, dm-devel@redhat.com, anderson@redhat.com

It is useful to be able to observe DM's slab memory use by looking at
"dm_" named slabs in /proc/slabinfo without having to enable SLAB_DEBUG
options on production systems.

before:
$ cat /proc/slabinfo | grep dm_ | cut -d' ' -f1
dm_mpath_io
dm_uevent
dm_rq_target_io

after:
$ cat /proc/slabinfo | grep dm_ | cut -d' ' -f1
dm_thin_new_mapping
dm_mpath_io
dm_mq_policy_cache_entry
dm_cache_migration
dm_bio_prison_cell
dm_snap_pending_exception
dm_exception
dm_dirty_log_flush_entry
dm_kcopyd_job
dm_io
dm_uevent
dm_clone_request
dm_rq_target_io
dm_target_io

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 drivers/md/dm-bio-prison.c         | 2 +-
 drivers/md/dm-bufio.c              | 2 +-
 drivers/md/dm-cache-policy-mq.c    | 2 +-
 drivers/md/dm-cache-target.c       | 3 +--
 drivers/md/dm-io.c                 | 3 ++-
 drivers/md/dm-kcopyd.c             | 4 ++--
 drivers/md/dm-log-userspace-base.c | 2 +-
 drivers/md/dm-mpath.c              | 3 +--
 drivers/md/dm-snap.c               | 4 ++--
 drivers/md/dm-thin.c               | 2 +-
 drivers/md/dm-uevent.c             | 2 +-
 drivers/md/dm.c                    | 8 ++++----
 12 files changed, 18 insertions(+), 19 deletions(-)

diff --git a/drivers/md/dm-bio-prison.c b/drivers/md/dm-bio-prison.c
index cd6d1d2..d033eee 100644
--- a/drivers/md/dm-bio-prison.c
+++ b/drivers/md/dm-bio-prison.c
@@ -398,7 +398,7 @@ EXPORT_SYMBOL_GPL(dm_deferred_set_add_work);
 
 static int __init dm_bio_prison_init(void)
 {
-	_cell_cache = KMEM_CACHE(dm_bio_prison_cell, 0);
+	_cell_cache = KMEM_CACHE(dm_bio_prison_cell, SLAB_NO_MERGE);
 	if (!_cell_cache)
 		return -ENOMEM;
 
diff --git a/drivers/md/dm-bufio.c b/drivers/md/dm-bufio.c
index 86dbbc7..1187470 100644
--- a/drivers/md/dm-bufio.c
+++ b/drivers/md/dm-bufio.c
@@ -1636,7 +1636,7 @@ struct dm_bufio_client *dm_bufio_client_create(struct block_device *bdev, unsign
 		if (!DM_BUFIO_CACHE(c)) {
 			DM_BUFIO_CACHE(c) = kmem_cache_create(DM_BUFIO_CACHE_NAME(c),
 							      c->block_size,
-							      c->block_size, 0, NULL);
+							      c->block_size, SLAB_NO_MERGE, NULL);
 			if (!DM_BUFIO_CACHE(c)) {
 				r = -ENOMEM;
 				mutex_unlock(&dm_bufio_clients_lock);
diff --git a/drivers/md/dm-cache-policy-mq.c b/drivers/md/dm-cache-policy-mq.c
index aa1b41c..ecc9f7d 100644
--- a/drivers/md/dm-cache-policy-mq.c
+++ b/drivers/md/dm-cache-policy-mq.c
@@ -1444,7 +1444,7 @@ static int __init mq_init(void)
 	mq_entry_cache = kmem_cache_create("dm_mq_policy_cache_entry",
 					   sizeof(struct entry),
 					   __alignof__(struct entry),
-					   0, NULL);
+					   SLAB_NO_MERGE, NULL);
 	if (!mq_entry_cache)
 		return -ENOMEM;
 
diff --git a/drivers/md/dm-cache-target.c b/drivers/md/dm-cache-target.c
index f9d9cc6..199fa437 100644
--- a/drivers/md/dm-cache-target.c
+++ b/drivers/md/dm-cache-target.c
@@ -394,7 +394,6 @@ static void wake_worker(struct cache *cache)
 
 static struct dm_bio_prison_cell *alloc_prison_cell(struct cache *cache)
 {
-	/* FIXME: change to use a local slab. */
 	return dm_bio_prison_alloc_cell(cache->prison, GFP_NOWAIT);
 }
 
@@ -3854,7 +3853,7 @@ static int __init dm_cache_init(void)
 		return r;
 	}
 
-	migration_cache = KMEM_CACHE(dm_cache_migration, 0);
+	migration_cache = KMEM_CACHE(dm_cache_migration, SLAB_NO_MERGE);
 	if (!migration_cache) {
 		dm_unregister_target(&cache_target);
 		return -ENOMEM;
diff --git a/drivers/md/dm-io.c b/drivers/md/dm-io.c
index 74adcd2..f7efeec 100644
--- a/drivers/md/dm-io.c
+++ b/drivers/md/dm-io.c
@@ -526,7 +526,8 @@ EXPORT_SYMBOL(dm_io);
 
 int __init dm_io_init(void)
 {
-	_dm_io_cache = KMEM_CACHE(io, 0);
+	_dm_io_cache = kmem_cache_create("dm_io", sizeof(struct io),
+					 __alignof__(struct io), SLAB_NO_MERGE, NULL);
 	if (!_dm_io_cache)
 		return -ENOMEM;
 
diff --git a/drivers/md/dm-kcopyd.c b/drivers/md/dm-kcopyd.c
index 3a7cade..f2a55a8 100644
--- a/drivers/md/dm-kcopyd.c
+++ b/drivers/md/dm-kcopyd.c
@@ -364,9 +364,9 @@ static struct kmem_cache *_job_cache;
 
 int __init dm_kcopyd_init(void)
 {
-	_job_cache = kmem_cache_create("kcopyd_job",
+	_job_cache = kmem_cache_create("dm_kcopyd_job",
 				sizeof(struct kcopyd_job) * (SPLIT_COUNT + 1),
-				__alignof__(struct kcopyd_job), 0, NULL);
+				__alignof__(struct kcopyd_job), SLAB_NO_MERGE, NULL);
 	if (!_job_cache)
 		return -ENOMEM;
 
diff --git a/drivers/md/dm-log-userspace-base.c b/drivers/md/dm-log-userspace-base.c
index 058256d..358c4e7 100644
--- a/drivers/md/dm-log-userspace-base.c
+++ b/drivers/md/dm-log-userspace-base.c
@@ -893,7 +893,7 @@ static int __init userspace_dirty_log_init(void)
 {
 	int r = 0;
 
-	_flush_entry_cache = KMEM_CACHE(dm_dirty_log_flush_entry, 0);
+	_flush_entry_cache = KMEM_CACHE(dm_dirty_log_flush_entry, SLAB_NO_MERGE);
 	if (!_flush_entry_cache) {
 		DMWARN("Unable to create flush_entry_cache: No memory.");
 		return -ENOMEM;
diff --git a/drivers/md/dm-mpath.c b/drivers/md/dm-mpath.c
index eff7bdd..00c52c0 100644
--- a/drivers/md/dm-mpath.c
+++ b/drivers/md/dm-mpath.c
@@ -1727,8 +1727,7 @@ static int __init dm_multipath_init(void)
 {
 	int r;
 
-	/* allocate a slab for the dm_ios */
-	_mpio_cache = KMEM_CACHE(dm_mpath_io, 0);
+	_mpio_cache = KMEM_CACHE(dm_mpath_io, SLAB_NO_MERGE);
 	if (!_mpio_cache)
 		return -ENOMEM;
 
diff --git a/drivers/md/dm-snap.c b/drivers/md/dm-snap.c
index 3903d7a..99bb6cd 100644
--- a/drivers/md/dm-snap.c
+++ b/drivers/md/dm-snap.c
@@ -2441,14 +2441,14 @@ static int __init dm_snapshot_init(void)
 		goto bad_origin_hash;
 	}
 
-	exception_cache = KMEM_CACHE(dm_exception, 0);
+	exception_cache = KMEM_CACHE(dm_exception, SLAB_NO_MERGE);
 	if (!exception_cache) {
 		DMERR("Couldn't create exception cache.");
 		r = -ENOMEM;
 		goto bad_exception_cache;
 	}
 
-	pending_cache = KMEM_CACHE(dm_snap_pending_exception, 0);
+	pending_cache = KMEM_CACHE(dm_snap_pending_exception, SLAB_NO_MERGE);
 	if (!pending_cache) {
 		DMERR("Couldn't create pending cache.");
 		r = -ENOMEM;
diff --git a/drivers/md/dm-thin.c b/drivers/md/dm-thin.c
index 49e358a..7de7e81 100644
--- a/drivers/md/dm-thin.c
+++ b/drivers/md/dm-thin.c
@@ -4314,7 +4314,7 @@ static int __init dm_thin_init(void)
 
 	r = -ENOMEM;
 
-	_new_mapping_cache = KMEM_CACHE(dm_thin_new_mapping, 0);
+	_new_mapping_cache = KMEM_CACHE(dm_thin_new_mapping, SLAB_NO_MERGE);
 	if (!_new_mapping_cache)
 		goto bad_new_mapping_cache;
 
diff --git a/drivers/md/dm-uevent.c b/drivers/md/dm-uevent.c
index 8efe033..2db0880 100644
--- a/drivers/md/dm-uevent.c
+++ b/drivers/md/dm-uevent.c
@@ -204,7 +204,7 @@ EXPORT_SYMBOL_GPL(dm_path_uevent);
 
 int dm_uevent_init(void)
 {
-	_dm_event_cache = KMEM_CACHE(dm_uevent, 0);
+	_dm_event_cache = KMEM_CACHE(dm_uevent, SLAB_NO_MERGE);
 	if (!_dm_event_cache)
 		return -ENOMEM;
 
diff --git a/drivers/md/dm.c b/drivers/md/dm.c
index 0907d9e..88b8c16 100644
--- a/drivers/md/dm.c
+++ b/drivers/md/dm.c
@@ -314,17 +314,17 @@ static int __init local_init(void)
 {
 	int r = -ENOMEM;
 
-	/* allocate a slab for the dm_ios */
-	_io_cache = KMEM_CACHE(dm_io, 0);
+	_io_cache = kmem_cache_create("dm_target_io", sizeof(struct dm_io),
+				      __alignof__(struct dm_io), SLAB_NO_MERGE, NULL);
 	if (!_io_cache)
 		return r;
 
-	_rq_tio_cache = KMEM_CACHE(dm_rq_target_io, 0);
+	_rq_tio_cache = KMEM_CACHE(dm_rq_target_io, SLAB_NO_MERGE);
 	if (!_rq_tio_cache)
 		goto out_free_io_cache;
 
 	_rq_cache = kmem_cache_create("dm_clone_request", sizeof(struct request),
-				      __alignof__(struct request), 0, NULL);
+				      __alignof__(struct request), SLAB_NO_MERGE, NULL);
 	if (!_rq_cache)
 		goto out_free_rq_tio_cache;
 
-- 
2.3.2 (Apple Git-55)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
