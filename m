Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 6E9C26B0008
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 22:41:03 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id o64so98881309pfb.3
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 19:41:03 -0800 (PST)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id ra6si8157027pab.90.2015.12.21.19.41.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Dec 2015 19:41:00 -0800 (PST)
Received: by mail-pa0-x230.google.com with SMTP id jx14so81881530pad.2
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 19:41:00 -0800 (PST)
From: Laura Abbott <laura@labbott.name>
Subject: [RFC][PATCH 3/7] slab: Add support for sanitization
Date: Mon, 21 Dec 2015 19:40:37 -0800
Message-Id: <1450755641-7856-4-git-send-email-laura@labbott.name>
In-Reply-To: <1450755641-7856-1-git-send-email-laura@labbott.name>
References: <1450755641-7856-1-git-send-email-laura@labbott.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Laura Abbott <laura@labbott.name>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>, kernel-hardening@lists.openwall.com


Clearing of objects on free only happens on debug paths. This is a
security risk since sensative data may exist long past it's life
span. Add unconditional clearing of objects on free.

All credit for the original work should be given to Brad Spengler and
the PaX Team.

Signed-off-by: Laura Abbott <laura@labbott.name>
---
 mm/slab.c | 35 +++++++++++++++++++++++++++++++++++
 1 file changed, 35 insertions(+)

diff --git a/mm/slab.c b/mm/slab.c
index 4765c97..0ca92d8 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -319,6 +319,8 @@ static void kmem_cache_node_init(struct kmem_cache_node *parent)
 #define STATS_INC_ALLOCMISS(x)	atomic_inc(&(x)->allocmiss)
 #define STATS_INC_FREEHIT(x)	atomic_inc(&(x)->freehit)
 #define STATS_INC_FREEMISS(x)	atomic_inc(&(x)->freemiss)
+#define STATS_INC_SANITIZED(x)	atomic_inc(&(x)->sanitized)
+#define STATS_INC_NOT_SANITIZED(x) atomic_inc(&(x)->not_sanitized)
 #else
 #define	STATS_INC_ACTIVE(x)	do { } while (0)
 #define	STATS_DEC_ACTIVE(x)	do { } while (0)
@@ -335,6 +337,8 @@ static void kmem_cache_node_init(struct kmem_cache_node *parent)
 #define STATS_INC_ALLOCMISS(x)	do { } while (0)
 #define STATS_INC_FREEHIT(x)	do { } while (0)
 #define STATS_INC_FREEMISS(x)	do { } while (0)
+#define STATS_INC_SANITIZED(x)  do { } while (0)
+#define STATS_INC_NOT_SANITIZED(x) do { } while (0)
 #endif
 
 #if DEBUG
@@ -3359,6 +3363,27 @@ free_done:
 	memmove(ac->entry, &(ac->entry[batchcount]), sizeof(void *)*ac->avail);
 }
 
+#ifdef CONFIG_SLAB_MEMORY_SANITIZE
+static void slab_sanitize(struct kmem_cache *cachep, void *objp)
+{
+	if (cachep->flags & (SLAB_POISON | SLAB_NO_SANITIZE)) {
+		STATS_INC_NOT_SANITIZED(cachep);
+	} else {
+		memset(objp, SLAB_MEMORY_SANITIZE_VALUE, cachep->object_size);
+
+		if (cachep->ctor)
+			cachep->ctor(objp);
+
+		STATS_INC_SANITIZED(cachep);
+	}
+}
+#else
+static void slab_sanitize(struct kmem_cache *cachep, void *objp)
+{
+	return;
+}
+#endif
+
 /*
  * Release an obj back to its cache. If the obj has a constructed state, it must
  * be in this state _before_ it is released.  Called with disabled ints.
@@ -3369,6 +3394,8 @@ static inline void __cache_free(struct kmem_cache *cachep, void *objp,
 	struct array_cache *ac = cpu_cache_get(cachep);
 
 	check_irq_off();
+
+	slab_sanitize(cachep, objp);
 	kmemleak_free_recursive(objp, cachep->flags);
 	objp = cache_free_debugcheck(cachep, objp, caller);
 
@@ -4014,6 +4041,14 @@ void slabinfo_show_stats(struct seq_file *m, struct kmem_cache *cachep)
 		seq_printf(m, " : cpustat %6lu %6lu %6lu %6lu",
 			   allochit, allocmiss, freehit, freemiss);
 	}
+#ifdef CONFIG_SLAB_MEMORY_SANITIZE
+	{
+		unsigned long sanitized = atomic_read(&cachep->sanitized);
+		unsigned long not_sanitized = atomic_read(&cachep->not_sanitized);
+
+		seq_printf(m, " : sanitized %6lu %6lu", sanitized, not_sanitized);
+	}
+#endif
 #endif
 }
 
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
