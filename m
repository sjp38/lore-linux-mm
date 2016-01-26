Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 539786B0254
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 20:15:26 -0500 (EST)
Received: by mail-qg0-f54.google.com with SMTP id o11so123455835qge.2
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 17:15:26 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z107si27635026qge.1.2016.01.25.17.15.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 17:15:25 -0800 (PST)
From: Laura Abbott <labbott@fedoraproject.org>
Subject: [PATCH 3/3] slub: Add option to skip consistency checks
Date: Mon, 25 Jan 2016 17:15:13 -0800
Message-Id: <1453770913-32287-4-git-send-email-labbott@fedoraproject.org>
In-Reply-To: <1453770913-32287-1-git-send-email-labbott@fedoraproject.org>
References: <1453770913-32287-1-git-send-email-labbott@fedoraproject.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Laura Abbott <labbott@fedoraproject.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Kees Cook <keescook@chromium.org>


SLUB debugging by default does checks to ensure consistency.
These checks, while useful, are expensive for allocation speed.
Features such as poisoning and tracing can stand alone without
any checks. Add a slab flag to skip these checks.

Signed-off-by: Laura Abbott <labbott@fedoraproject.org>
---
 include/linux/slab.h |  1 +
 mm/slub.c            | 29 +++++++++++++++++++++++++++++
 2 files changed, 30 insertions(+)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 3627d5c..789f6a3 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -23,6 +23,7 @@
 #define SLAB_DEBUG_FREE		0x00000100UL	/* DEBUG: Perform (expensive) checks on free */
 #define SLAB_RED_ZONE		0x00000400UL	/* DEBUG: Red zone objs in a cache */
 #define SLAB_POISON		0x00000800UL	/* DEBUG: Poison objects */
+#define SLAB_NO_CHECKS		0x00001000UL	/* DEBUG: Skip all consistency checks*/
 #define SLAB_HWCACHE_ALIGN	0x00002000UL	/* Align objs on cache lines */
 #define SLAB_CACHE_DMA		0x00004000UL	/* Use GFP_DMA memory */
 #define SLAB_STORE_USER		0x00010000UL	/* DEBUG: Store the last owner for bug hunting */
diff --git a/mm/slub.c b/mm/slub.c
index a47e615..078f088 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -230,6 +230,9 @@ static inline int check_valid_pointer(struct kmem_cache *s,
 {
 	void *base;
 
+	if (s->flags & SLAB_NO_CHECKS)
+		return 1;
+
 	if (!object)
 		return 1;
 
@@ -818,6 +821,9 @@ static int check_object(struct kmem_cache *s, struct page *page,
 	u8 *p = object;
 	u8 *endobject = object + s->object_size;
 
+	if (s->flags & SLAB_NO_CHECKS)
+		return 1;
+
 	if (s->flags & SLAB_RED_ZONE) {
 		if (!check_bytes_and_report(s, page, object, "Redzone",
 			endobject, val, s->inuse - s->object_size))
@@ -873,6 +879,9 @@ static int check_slab(struct kmem_cache *s, struct page *page)
 
 	VM_BUG_ON(!irqs_disabled());
 
+	if (s->flags & SLAB_NO_CHECKS)
+		return 1;
+
 	if (!PageSlab(page)) {
 		slab_err(s, page, "Not a valid slab page");
 		return 0;
@@ -906,6 +915,9 @@ static int on_freelist(struct kmem_cache *s, struct page *page, void *search,
 	void *object = NULL;
 	int max_objects;
 
+	if (s->flags & SLAB_NO_CHECKS)
+		return 0;
+
 	fp = page->freelist;
 	while (fp && nr <= page->objects) {
 		if (fp == search)
@@ -1303,6 +1315,8 @@ static int __init setup_slub_debug(char *str)
 		case 'a':
 			slub_debug |= SLAB_FAILSLAB;
 			break;
+		case 'q':
+			slub_debug |= SLAB_NO_CHECKS;
 		case 'o':
 			/*
 			 * Avoid enabling debugging on caches if its minimum
@@ -5032,6 +5046,20 @@ static ssize_t poison_store(struct kmem_cache *s,
 }
 SLAB_ATTR(poison);
 
+static ssize_t no_checks_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%d\n", !!(s->flags & SLAB_NO_CHECKS));
+}
+
+static ssize_t no_checks_store(struct kmem_cache *s,
+				const char *buf, size_t length)
+{
+	return -EINVAL;
+}
+SLAB_ATTR(no_checks);
+
+
+
 static ssize_t store_user_show(struct kmem_cache *s, char *buf)
 {
 	return sprintf(buf, "%d\n", !!(s->flags & SLAB_STORE_USER));
@@ -5257,6 +5285,7 @@ static struct attribute *slab_attrs[] = {
 	&trace_attr.attr,
 	&red_zone_attr.attr,
 	&poison_attr.attr,
+	&no_checks_attr.attr,
 	&store_user_attr.attr,
 	&validate_attr.attr,
 	&alloc_calls_attr.attr,
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
