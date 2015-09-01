Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f170.google.com (mail-qk0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id D52146B0254
	for <linux-mm@kvack.org>; Tue,  1 Sep 2015 13:51:34 -0400 (EDT)
Received: by qkct7 with SMTP id t7so52276080qkc.1
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 10:51:34 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 125si22265517qhy.7.2015.09.01.10.51.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Sep 2015 10:51:34 -0700 (PDT)
From: Mike Snitzer <snitzer@redhat.com>
Subject: [PATCH 1/2] mm/slab_common: add SLAB_NO_MERGE flag for use when creating slabs
Date: Tue,  1 Sep 2015 13:51:29 -0400
Message-Id: <1441129890-25585-1-git-send-email-snitzer@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, riel@redhat.com, david@fromorbit.com, axboe@kernel.dk, dm-devel@redhat.com, anderson@redhat.com

The slab aliasing/merging by default transition went unnoticed (at least
to the DM subsystem).  Add a new SLAB_NO_MERGE flag that allows
individual slabs to be created without slab merging.  This beats forcing
all slabs to be created in this fashion by specifying sl[au]b_nomerge on
the kernel commandline.

DM has historically taken care to have separate named slabs that each
devices' mempool_t are backed by.  These separate slabs are useful --
even if only to aid inspection of DM's memory use (via /proc/slabinfo)
on production systems.

I stumbled onto slab merging as a side-effect of a leak in dm-cache
being attributed to 'kmalloc-96' rather than the expected
'dm_bio_prison_cell' named slab.  Moving forward DM will disable slab
merging for all of DM's slabs by using SLAB_NO_MERGE.

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 include/linux/slab.h | 2 ++
 mm/slab.h            | 2 +-
 mm/slab_common.c     | 2 +-
 3 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index a99f0e5..d007407 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -87,6 +87,8 @@
 # define SLAB_FAILSLAB		0x00000000UL
 #endif
 
+#define SLAB_NO_MERGE		0x04000000UL	/* Do not merge with existing slab */
+
 /* The following flags affect the page allocator grouping pages by mobility */
 #define SLAB_RECLAIM_ACCOUNT	0x00020000UL		/* Objects are reclaimable */
 #define SLAB_TEMPORARY		SLAB_RECLAIM_ACCOUNT	/* Objects are short-lived */
diff --git a/mm/slab.h b/mm/slab.h
index 8da63e4..35eb6f4 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -115,7 +115,7 @@ static inline unsigned long kmem_cache_flags(unsigned long object_size,
 
 /* Legal flag mask for kmem_cache_create(), for various configurations */
 #define SLAB_CORE_FLAGS (SLAB_HWCACHE_ALIGN | SLAB_CACHE_DMA | SLAB_PANIC | \
-			 SLAB_DESTROY_BY_RCU | SLAB_DEBUG_OBJECTS )
+			 SLAB_DESTROY_BY_RCU | SLAB_DEBUG_OBJECTS | SLAB_NO_MERGE)
 
 #if defined(CONFIG_DEBUG_SLAB)
 #define SLAB_DEBUG_FLAGS (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER)
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 8683110..3a5a8ed 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -35,7 +35,7 @@ struct kmem_cache *kmem_cache;
  */
 #define SLAB_NEVER_MERGE (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER | \
 		SLAB_TRACE | SLAB_DESTROY_BY_RCU | SLAB_NOLEAKTRACE | \
-		SLAB_FAILSLAB)
+		SLAB_FAILSLAB | SLAB_NO_MERGE)
 
 #define SLAB_MERGE_SAME (SLAB_RECLAIM_ACCOUNT | SLAB_CACHE_DMA | SLAB_NOTRACK)
 
-- 
2.3.2 (Apple Git-55)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
