Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 95CCF6B0253
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 17:47:54 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 17so57581967pfy.2
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 14:47:54 -0800 (PST)
Received: from mail-pf0-x229.google.com (mail-pf0-x229.google.com. [2607:f8b0:400e:c00::229])
        by mx.google.com with ESMTPS id 1si33286923pgs.211.2016.11.07.14.47.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 14:47:53 -0800 (PST)
Received: by mail-pf0-x229.google.com with SMTP id i88so96355279pfk.2
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 14:47:53 -0800 (PST)
From: Thomas Garnier <thgarnie@google.com>
Subject: [PATCH v4 2/2] mm: Check kmem_create_cache flags are commons
Date: Mon,  7 Nov 2016 14:47:21 -0800
Message-Id: <1478558841-23005-2-git-send-email-thgarnie@google.com>
In-Reply-To: <1478558841-23005-1-git-send-email-thgarnie@google.com>
References: <1478558841-23005-1-git-send-email-thgarnie@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, gthelen@google.com, vdavydov.dev@gmail.com, mhocko@kernel.org, Thomas Garnier <thgarnie@google.com>

Verify that kmem_create_cache flags are not allocator specific. It is
done before removing flags that are not available with the current
configuration.

Signed-off-by: Thomas Garnier <thgarnie@google.com>
---
Based on next-20161027
---
 mm/slab.h        | 15 +++++++++++++++
 mm/slab_common.c |  6 ++++++
 2 files changed, 21 insertions(+)

diff --git a/mm/slab.h b/mm/slab.h
index 9653f2e..3b11896 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -142,8 +142,23 @@ static inline unsigned long kmem_cache_flags(unsigned long object_size,
 #define SLAB_CACHE_FLAGS (0)
 #endif
 
+/* Common flags available with current configuration */
 #define CACHE_CREATE_MASK (SLAB_CORE_FLAGS | SLAB_DEBUG_FLAGS | SLAB_CACHE_FLAGS)
 
+/* Common flags permitted for kmem_cache_create */
+#define SLAB_FLAGS_PERMITTED (SLAB_CORE_FLAGS | \
+			      SLAB_RED_ZONE | \
+			      SLAB_POISON | \
+			      SLAB_STORE_USER | \
+			      SLAB_TRACE | \
+			      SLAB_CONSISTENCY_CHECKS | \
+			      SLAB_MEM_SPREAD | \
+			      SLAB_NOLEAKTRACE | \
+			      SLAB_RECLAIM_ACCOUNT | \
+			      SLAB_TEMPORARY | \
+			      SLAB_NOTRACK | \
+			      SLAB_ACCOUNT)
+
 int __kmem_cache_shutdown(struct kmem_cache *);
 void __kmem_cache_release(struct kmem_cache *);
 int __kmem_cache_shrink(struct kmem_cache *, bool);
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 329b038..5e01994 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -404,6 +404,12 @@ kmem_cache_create(const char *name, size_t size, size_t align,
 		goto out_unlock;
 	}
 
+	/* Refuse requests with allocator specific flags */
+	if (flags & ~SLAB_FLAGS_PERMITTED) {
+		err = -EINVAL;
+		goto out_unlock;
+	}
+
 	/*
 	 * Some allocators will constraint the set of valid flags to a subset
 	 * of all flags. We expect them to define CACHE_CREATE_MASK in this
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
