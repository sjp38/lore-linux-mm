Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id C17FD8E0073
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 02:00:43 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id p3so3293887plk.9
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 23:00:43 -0800 (PST)
Received: from mailgw02.mediatek.com ([210.61.82.184])
        by mx.google.com with ESMTPS id 102si11499284plc.277.2019.01.23.23.00.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 23:00:42 -0800 (PST)
From: <miles.chen@mediatek.com>
Subject: [PATCH v2] mm/slub: introduce SLAB_WARN_ON_ERROR
Date: Thu, 24 Jan 2019 15:00:23 +0800
Message-ID: <1548313223-17114-1-git-send-email-miles.chen@mediatek.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org, Miles Chen <miles.chen@mediatek.com>

From: Miles Chen <miles.chen@mediatek.com>

When debugging slab errors in slub.c, sometimes we have to trigger
a panic in order to get the coredump file. Add a debug option
SLAB_WARN_ON_ERROR to toggle WARN_ON() when the option is set.

Change since v1:
1. Add a special debug option SLAB_WARN_ON_ERROR and toggle WARN_ON()
if it is set.
2. SLAB_WARN_ON_ERROR can be set by kernel parameter slub_debug.

Cc: Christopher Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>,
Cc: David Rientjes <rientjes@google.com>,
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>,
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Jonathan Corbet <corbet@lwn.net>
Signed-off-by: Miles Chen <miles.chen@mediatek.com>
---
 Documentation/vm/slub.rst |  1 +
 include/linux/slab.h      |  3 +++
 mm/slub.c                 | 34 ++++++++++++++++++++++++++++++++--
 3 files changed, 36 insertions(+), 2 deletions(-)

diff --git a/Documentation/vm/slub.rst b/Documentation/vm/slub.rst
index 195928808bac..236c00b2d17b 100644
--- a/Documentation/vm/slub.rst
+++ b/Documentation/vm/slub.rst
@@ -52,6 +52,7 @@ Possible debug options are::
 	A		Toggle failslab filter mark for the cache
 	O		Switch debugging off for caches that would have
 			caused higher minimum slab orders
+	W		Toggle WARN_ON() on slab errors
 	-		Switch all debugging off (useful if the kernel is
 			configured with CONFIG_SLUB_DEBUG_ON)
 
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 11b45f7ae405..1fd9911890c6 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -109,6 +109,9 @@
 #define SLAB_KASAN		0
 #endif
 
+/* WARN_ON slab error */
+#define SLAB_WARN_ON_ERROR	((slab_flags_t __force)0x10000000U)
+
 /* The following flags affect the page allocator grouping pages by mobility */
 /* Objects are reclaimable */
 #define SLAB_RECLAIM_ACCOUNT	((slab_flags_t __force)0x00020000U)
diff --git a/mm/slub.c b/mm/slub.c
index 1e3d0ec4e200..60f93e0657fb 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -684,7 +684,10 @@ static void print_trailer(struct kmem_cache *s, struct page *page, u8 *p)
 		print_section(KERN_ERR, "Padding ", p + off,
 			      size_from_object(s) - off);
 
-	dump_stack();
+	if (unlikely(s->flags & SLAB_WARN_ON_ERROR))
+		WARN_ON(1);
+	else
+		dump_stack();
 }
 
 void object_err(struct kmem_cache *s, struct page *page,
@@ -705,7 +708,11 @@ static __printf(3, 4) void slab_err(struct kmem_cache *s, struct page *page,
 	va_end(args);
 	slab_bug(s, "%s", buf);
 	print_page_info(page);
-	dump_stack();
+
+	if (unlikely(s->flags & SLAB_WARN_ON_ERROR))
+		WARN_ON(1);
+	else
+		dump_stack();
 }
 
 static void init_object(struct kmem_cache *s, void *object, u8 val)
@@ -1254,6 +1261,9 @@ static int __init setup_slub_debug(char *str)
 		case 'a':
 			slub_debug |= SLAB_FAILSLAB;
 			break;
+		case 'w':
+			slub_debug |= SLAB_WARN_ON_ERROR;
+			break;
 		case 'o':
 			/*
 			 * Avoid enabling debugging on caches if its minimum
@@ -5220,6 +5230,25 @@ static ssize_t store_user_store(struct kmem_cache *s,
 }
 SLAB_ATTR(store_user);
 
+static ssize_t warn_on_error_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%d\n", !!(s->flags & SLAB_WARN_ON_ERROR));
+}
+
+static ssize_t warn_on_error_store(struct kmem_cache *s,
+				const char *buf, size_t length)
+{
+	if (any_slab_objects(s))
+		return -EBUSY;
+
+	s->flags &= ~SLAB_WARN_ON_ERROR;
+	if (buf[0] == '1')
+		s->flags |= SLAB_WARN_ON_ERROR;
+
+	return length;
+}
+SLAB_ATTR(warn_on_error);
+
 static ssize_t validate_show(struct kmem_cache *s, char *buf)
 {
 	return 0;
@@ -5428,6 +5457,7 @@ static struct attribute *slab_attrs[] = {
 	&validate_attr.attr,
 	&alloc_calls_attr.attr,
 	&free_calls_attr.attr,
+	&warn_on_error_attr.attr,
 #endif
 #ifdef CONFIG_ZONE_DMA
 	&cache_dma_attr.attr,
-- 
2.18.0
