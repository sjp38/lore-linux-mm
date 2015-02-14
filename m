Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 14A0D900015
	for <linux-mm@kvack.org>; Sat, 14 Feb 2015 17:33:57 -0500 (EST)
Received: by mail-wg0-f51.google.com with SMTP id y19so22952979wgg.10
        for <linux-mm@kvack.org>; Sat, 14 Feb 2015 14:33:56 -0800 (PST)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id k3si12296525wjf.70.2015.02.14.14.33.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 14 Feb 2015 14:33:55 -0800 (PST)
From: Chris J Arges <chris.j.arges@canonical.com>
Subject: [PATCH v2] mm: slub: Add SLAB_DEBUG_CRASH option
Date: Sat, 14 Feb 2015 16:32:51 -0600
Message-Id: <1423953187-8293-1-git-send-email-chris.j.arges@canonical.com>
In-Reply-To: <alpine.DEB.2.11.1502131810520.14741@gentwo.org>
References: <alpine.DEB.2.11.1502131810520.14741@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com
Cc: Chris J Arges <chris.j.arges@canonical.com>, Jonathan Corbet <corbet@lwn.net>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This option crashes the kernel whenever corruption is initially detected. This
is useful when trying to use crash dump analysis to determine where memory was
initially corrupted.

To enable this option use slub_debug=C.

[v2]
Panic in slab_err and object_err instead of BUG_ON.

Signed-off-by: Chris J Arges <chris.j.arges@canonical.com>
---
 Documentation/vm/slub.txt | 2 ++
 include/linux/slab.h      | 1 +
 mm/slub.c                 | 9 +++++++++
 3 files changed, 12 insertions(+)

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
index 88482f8..89a8631 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -634,6 +634,9 @@ static void object_err(struct kmem_cache *s, struct page *page,
 {
 	slab_bug(s, "%s", reason);
 	print_trailer(s, page, object);
+
+	if (unlikely(s->flags & SLAB_DEBUG_CRASH))
+		panic("Panic on object error\n");
 }
 
 static void slab_err(struct kmem_cache *s, struct page *page,
@@ -648,6 +651,9 @@ static void slab_err(struct kmem_cache *s, struct page *page,
 	slab_bug(s, "%s", buf);
 	print_page_info(page);
 	dump_stack();
+
+	if (unlikely(s->flags & SLAB_DEBUG_CRASH))
+		panic("Panic on slab error\n");
 }
 
 static void init_object(struct kmem_cache *s, void *object, u8 val)
@@ -1149,6 +1155,9 @@ static int __init setup_slub_debug(char *str)
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
