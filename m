Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7D2DA6B027D
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:08:21 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id m4so4614390pgc.23
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:08:21 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 3si14368720plp.318.2017.11.22.13.08.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:08:20 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 54/62] scsi: Remove idr_preload in st driver
Date: Wed, 22 Nov 2017 13:07:31 -0800
Message-Id: <20171122210739.29916-55-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

The IDR now has its own locking, so remove the driver's private lock
and calls to idr_preload.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 drivers/scsi/st.c | 18 +++++-------------
 1 file changed, 5 insertions(+), 13 deletions(-)

diff --git a/drivers/scsi/st.c b/drivers/scsi/st.c
index b141d7641a2e..e8703905c94a 100644
--- a/drivers/scsi/st.c
+++ b/drivers/scsi/st.c
@@ -221,7 +221,6 @@ static void scsi_tape_release(struct kref *);
 #define to_scsi_tape(obj) container_of(obj, struct scsi_tape, kref)
 
 static DEFINE_MUTEX(st_ref_mutex);
-static DEFINE_SPINLOCK(st_index_lock);
 static DEFINE_SPINLOCK(st_use_lock);
 static DEFINE_IDR(st_index_idr);
 
@@ -242,10 +241,11 @@ static struct scsi_tape *scsi_tape_get(int dev)
 	struct scsi_tape *STp = NULL;
 
 	mutex_lock(&st_ref_mutex);
-	spin_lock(&st_index_lock);
+	idr_lock(&st_index_idr);
 
 	STp = idr_find(&st_index_idr, dev);
-	if (!STp) goto out;
+	if (!STp)
+		goto out;
 
 	kref_get(&STp->kref);
 
@@ -261,7 +261,7 @@ static struct scsi_tape *scsi_tape_get(int dev)
 	kref_put(&STp->kref, scsi_tape_release);
 	STp = NULL;
 out:
-	spin_unlock(&st_index_lock);
+	idr_unlock(&st_index_idr);
 	mutex_unlock(&st_ref_mutex);
 	return STp;
 }
@@ -4370,11 +4370,7 @@ static int st_probe(struct device *dev)
 	    tpnt->blksize_changed = 0;
 	mutex_init(&tpnt->lock);
 
-	idr_preload(GFP_KERNEL);
-	spin_lock(&st_index_lock);
-	error = idr_alloc(&st_index_idr, tpnt, 0, ST_MAX_TAPES + 1, GFP_NOWAIT);
-	spin_unlock(&st_index_lock);
-	idr_preload_end();
+	error = idr_alloc(&st_index_idr, tpnt, 0, ST_MAX_TAPES + 1, GFP_KERNEL);
 	if (error < 0) {
 		pr_warn("st: idr allocation failed: %d\n", error);
 		goto out_put_queue;
@@ -4408,9 +4404,7 @@ static int st_probe(struct device *dev)
 	remove_cdevs(tpnt);
 	kfree(tpnt->stats);
 out_idr_remove:
-	spin_lock(&st_index_lock);
 	idr_remove(&st_index_idr, tpnt->index);
-	spin_unlock(&st_index_lock);
 out_put_queue:
 	blk_put_queue(disk->queue);
 out_put_disk:
@@ -4435,9 +4429,7 @@ static int st_remove(struct device *dev)
 	mutex_lock(&st_ref_mutex);
 	kref_put(&tpnt->kref, scsi_tape_release);
 	mutex_unlock(&st_ref_mutex);
-	spin_lock(&st_index_lock);
 	idr_remove(&st_index_idr, index);
-	spin_unlock(&st_index_lock);
 	return 0;
 }
 
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
