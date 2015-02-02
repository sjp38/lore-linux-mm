Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id B2DD56B006E
	for <linux-mm@kvack.org>; Sun,  1 Feb 2015 22:10:45 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id kq14so76570948pab.0
        for <linux-mm@kvack.org>; Sun, 01 Feb 2015 19:10:45 -0800 (PST)
Received: from fiona.linuxhacker.ru ([217.76.32.60])
        by mx.google.com with ESMTPS id z5si22097936pdm.78.2015.02.01.19.10.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Feb 2015 19:10:43 -0800 (PST)
From: green@linuxhacker.ru
Subject: [PATCH 2/2] staging/lustre: use __vmalloc_node() to avoid __GFP_FS default
Date: Sun,  1 Feb 2015 22:10:27 -0500
Message-Id: <1422846627-26890-3-git-send-email-green@linuxhacker.ru>
In-Reply-To: <1422846627-26890-1-git-send-email-green@linuxhacker.ru>
References: <1422846627-26890-1-git-send-email-green@linuxhacker.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Bruno Faccini <bruno.faccini@intel.com>, Oleg Drokin <oleg.drokin@intel.com>

From: Bruno Faccini <bruno.faccini@intel.com>

When possible, try to use of __vmalloc_node() instead of
vzalloc/vzalloc_node which allows for protection flag specification,
and particularly to not set __GFP_FS, which can cause some deadlock
situations in our code due to recursive calls.

Additionally fixed a typo in the macro name: VEROBSE->VERBOSE

Signed-off-by: Bruno Faccini <bruno.faccini@intel.com>
Signed-off-by: Oleg Drokin <oleg.drokin@intel.com>
Reviewed-on: http://review.whamcloud.com/11190
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5349
---
 drivers/staging/lustre/lustre/include/obd_support.h | 18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index 2991d2e..c90a88e 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -655,11 +655,17 @@ do {									      \
 #define OBD_CPT_ALLOC_PTR(ptr, cptab, cpt)				      \
 	OBD_CPT_ALLOC(ptr, cptab, cpt, sizeof(*(ptr)))
 
-# define __OBD_VMALLOC_VEROBSE(ptr, cptab, cpt, size)			      \
+/* Direct use of __vmalloc_node() allows for protection flag specification
+ * (and particularly to not set __GFP_FS, which is likely to cause some
+ * deadlock situations in our code).
+ */
+# define __OBD_VMALLOC_VERBOSE(ptr, cptab, cpt, size)			      \
 do {									      \
-	(ptr) = cptab == NULL ?						      \
-		vzalloc(size) :						      \
-		vzalloc_node(size, cfs_cpt_spread_node(cptab, cpt));	      \
+	(ptr) = __vmalloc_node(size, 1, GFP_NOFS | __GFP_HIGHMEM | __GFP_ZERO,\
+			       PAGE_KERNEL,				      \
+			       cptab == NULL ? NUMA_NO_NODE :		      \
+					      cfs_cpt_spread_node(cptab, cpt),\
+			       __builtin_return_address(0));		      \
 	if (unlikely((ptr) == NULL)) {					\
 		CERROR("vmalloc of '" #ptr "' (%d bytes) failed\n",	   \
 		       (int)(size));					  \
@@ -671,9 +677,9 @@ do {									      \
 } while (0)
 
 # define OBD_VMALLOC(ptr, size)						      \
-	 __OBD_VMALLOC_VEROBSE(ptr, NULL, 0, size)
+	 __OBD_VMALLOC_VERBOSE(ptr, NULL, 0, size)
 # define OBD_CPT_VMALLOC(ptr, cptab, cpt, size)				      \
-	 __OBD_VMALLOC_VEROBSE(ptr, cptab, cpt, size)
+	 __OBD_VMALLOC_VERBOSE(ptr, cptab, cpt, size)
 
 
 /* Allocations above this size are considered too big and could not be done
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
