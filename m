Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 259CD6B0281
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:08:21 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id c23so10879160pfl.1
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:08:21 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id u91si9080026plb.50.2017.11.22.13.08.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:08:20 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 48/62] block: Remove IDR preloading
Date: Wed, 22 Nov 2017 13:07:25 -0800
Message-Id: <20171122210739.29916-49-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

The IDR now handles its own locking, so if we remove the locking in
genhd, we can also remove the memory preloading.  The genhd needs to
protect the object retrieved from the IDR against removal until its
refcount has been elevated, so hold the IDR's lock during lookup.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 block/genhd.c | 23 +++++------------------
 1 file changed, 5 insertions(+), 18 deletions(-)

diff --git a/block/genhd.c b/block/genhd.c
index c2223f12a805..d50bd99e8ce2 100644
--- a/block/genhd.c
+++ b/block/genhd.c
@@ -30,10 +30,7 @@ struct kobject *block_depr;
 /* for extended dynamic devt allocation, currently only one major is used */
 #define NR_EXT_DEVT		(1 << MINORBITS)
 
-/* For extended devt allocation.  ext_devt_lock prevents look up
- * results from going away underneath its user.
- */
-static DEFINE_SPINLOCK(ext_devt_lock);
+/* For extended devt allocation. */
 static DEFINE_IDR(ext_devt_idr);
 
 static const struct device_type disk_type;
@@ -467,14 +464,7 @@ int blk_alloc_devt(struct hd_struct *part, dev_t *devt)
 		return 0;
 	}
 
-	/* allocate ext devt */
-	idr_preload(GFP_KERNEL);
-
-	spin_lock_bh(&ext_devt_lock);
-	idx = idr_alloc(&ext_devt_idr, part, 0, NR_EXT_DEVT, GFP_NOWAIT);
-	spin_unlock_bh(&ext_devt_lock);
-
-	idr_preload_end();
+	idx = idr_alloc(&ext_devt_idr, part, 0, NR_EXT_DEVT, GFP_KERNEL);
 	if (idx < 0)
 		return idx == -ENOSPC ? -EBUSY : idx;
 
@@ -496,11 +486,8 @@ void blk_free_devt(dev_t devt)
 	if (devt == MKDEV(0, 0))
 		return;
 
-	if (MAJOR(devt) == BLOCK_EXT_MAJOR) {
-		spin_lock_bh(&ext_devt_lock);
+	if (MAJOR(devt) == BLOCK_EXT_MAJOR)
 		idr_remove(&ext_devt_idr, blk_mangle_minor(MINOR(devt)));
-		spin_unlock_bh(&ext_devt_lock);
-	}
 }
 
 static char *bdevt_str(dev_t devt, char *buf)
@@ -789,13 +776,13 @@ struct gendisk *get_gendisk(dev_t devt, int *partno)
 	} else {
 		struct hd_struct *part;
 
-		spin_lock_bh(&ext_devt_lock);
+		idr_lock_bh(&ext_devt_idr);
 		part = idr_find(&ext_devt_idr, blk_mangle_minor(MINOR(devt)));
 		if (part && get_disk(part_to_disk(part))) {
 			*partno = part->partno;
 			disk = part_to_disk(part);
 		}
-		spin_unlock_bh(&ext_devt_lock);
+		idr_unlock_bh(&ext_devt_idr);
 	}
 
 	if (disk && unlikely(disk->flags & GENHD_FL_HIDDEN)) {
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
