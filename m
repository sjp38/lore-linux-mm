Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id BB28C6B0089
	for <linux-mm@kvack.org>; Fri, 13 Feb 2015 17:20:46 -0500 (EST)
Received: by mail-wi0-f174.google.com with SMTP id em10so15212443wid.1
        for <linux-mm@kvack.org>; Fri, 13 Feb 2015 14:20:46 -0800 (PST)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id lh1si6486415wjb.88.2015.02.13.14.20.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 13 Feb 2015 14:20:45 -0800 (PST)
From: Chris J Arges <chris.j.arges@canonical.com>
Subject: [PATCH 3/3] mm: slub: Add SLAB_DEBUG_CRASH option
Date: Fri, 13 Feb 2015 16:19:37 -0600
Message-Id: <1423865980-10417-3-git-send-email-chris.j.arges@canonical.com>
In-Reply-To: <1423865980-10417-1-git-send-email-chris.j.arges@canonical.com>
References: <1423865980-10417-1-git-send-email-chris.j.arges@canonical.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Chris J Arges <chris.j.arges@canonical.com>, Jonathan Corbet <corbet@lwn.net>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org

This option crashes the kernel whenever corruption is initially detected. This
is useful when trying to use crash dump analysis to determine where memory was
corrupted.

To enable this option use slub_debug=C.

Signed-off-by: Chris J Arges <chris.j.arges@canonical.com>
---
 Documentation/vm/slub.txt |  2 ++
 include/linux/slab.h      |  1 +
 mm/slub.c                 | 10 ++++++++++
 3 files changed, 13 insertions(+)

diff --git a/Documentation/vm/slub.txt b/Documentation/vm/slub.txt
index e159c04..78fbe44 100644
--- a/Documentation/vm/slub.txt
+++ b/Documentation/vm/slub.txt
@@ -44,6 +44,8 @@ Possible debug options are
 	A		Toggle failslab filter mark for the cache
 	O		Switch debugging off for caches that would have
 			caused higher minimum slab orders
+	C		Crash kernel on corruption detection. (Useful for
+			debugging with crash dumps)
 	-		Switch all debugging off (useful if the kernel is
 			configured with CONFIG_SLUB_DEBUG_ON)
 
diff --git a/include/linux/slab.h b/include/linux/slab.h
index ed2ffaa..6c8eda9 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -23,6 +23,7 @@
 #define SLAB_DEBUG_FREE		0x00000100UL	/* DEBUG: Perform (expensive) checks on free */
 #define SLAB_RED_ZONE		0x00000400UL	/* DEBUG: Red zone objs in a cache */
 #define SLAB_POISON		0x00000800UL	/* DEBUG: Poison objects */
+#define SLAB_DEBUG_CRASH	0x00001000UL	/* DEBUG: Crash on any errors detected */
 #define SLAB_HWCACHE_ALIGN	0x00002000UL	/* Align objs on cache lines */
 #define SLAB_CACHE_DMA		0x00004000UL	/* Use GFP_DMA memory */
 #define SLAB_STORE_USER		0x00010000UL	/* DEBUG: Store the last owner for bug hunting */
diff --git a/mm/slub.c b/mm/slub.c
index 88482f8..1eb0031 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1025,6 +1025,9 @@ static noinline int alloc_debug_processing(struct kmem_cache *s,
 	return 1;
 
 bad:
+	/* BUG_ON to trace initial corruption */
+	BUG_ON(s->flags & SLAB_DEBUG_CRASH);
+
 	if (PageSlab(page)) {
 		/*
 		 * If this is a slab page then lets do the best we can
@@ -1092,6 +1095,10 @@ out:
 fail:
 	slab_unlock(page);
 	spin_unlock_irqrestore(&n->list_lock, *flags);
+
+	/* BUG_ON to trace initial corruption */
+	BUG_ON(s->flags & SLAB_DEBUG_CRASH);
+
 	slab_fix(s, "Object at 0x%p not freed", object);
 	return NULL;
 }
@@ -1149,6 +1156,9 @@ static int __init setup_slub_debug(char *str)
 			 */
 			disable_higher_order_debug = 1;
 			break;
+		case 'c':
+			slub_debug |= SLAB_DEBUG_CRASH;
+			break;
 		default:
 			pr_err("slub_debug option '%c' unknown. skipped\n",
 			       *str);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
