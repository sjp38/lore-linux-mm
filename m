Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id BFA5B6B0033
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 10:49:24 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id kq3so693884wjc.1
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 07:49:24 -0800 (PST)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id x10si11642260wrc.249.2017.01.13.07.49.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jan 2017 07:49:23 -0800 (PST)
Received: by mail-wm0-x230.google.com with SMTP id r144so76567796wme.1
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 07:49:23 -0800 (PST)
From: Daniel Thompson <daniel.thompson@linaro.org>
Subject: [PATCH] slub: Trace free objects at KERN_INFO
Date: Fri, 13 Jan 2017 15:48:50 +0000
Message-Id: <20170113154850.518-1-daniel.thompson@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Daniel Thompson <daniel.thompson@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, patches@linaro.org

Currently when trace is enabled (e.g. slub_debug=T,kmalloc-128 ) the
trace messages are mostly output at KERN_INFO. However the trace code
also calls print_section() to hexdump the head of a free object. This
is hard coded to use KERN_ERR, meaning the console is deluged with
trace messages even if we've asked for quiet.

Fix this the obvious way but adding a level parameter to
print_section(), allowing calls from the trace code to use the same
trace level as other trace messages.

Signed-off-by: Daniel Thompson <daniel.thompson@linaro.org>
---
 mm/slub.c | 23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 067598a00849..7aa6f433f4de 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -496,10 +496,11 @@ static inline int check_valid_pointer(struct kmem_cache *s,
 	return 1;
 }

-static void print_section(char *text, u8 *addr, unsigned int length)
+static void print_section(char *level, char *text, u8 *addr,
+			  unsigned int length)
 {
 	metadata_access_enable();
-	print_hex_dump(KERN_ERR, text, DUMP_PREFIX_ADDRESS, 16, 1, addr,
+	print_hex_dump(level, text, DUMP_PREFIX_ADDRESS, 16, 1, addr,
 			length, 1);
 	metadata_access_disable();
 }
@@ -636,14 +637,15 @@ static void print_trailer(struct kmem_cache *s, struct page *page, u8 *p)
 	       p, p - addr, get_freepointer(s, p));

 	if (s->flags & SLAB_RED_ZONE)
-		print_section("Redzone ", p - s->red_left_pad, s->red_left_pad);
+		print_section(KERN_ERR, "Redzone ", p - s->red_left_pad,
+			      s->red_left_pad);
 	else if (p > addr + 16)
-		print_section("Bytes b4 ", p - 16, 16);
+		print_section(KERN_ERR, "Bytes b4 ", p - 16, 16);

-	print_section("Object ", p, min_t(unsigned long, s->object_size,
-				PAGE_SIZE));
+	print_section(KERN_ERR, "Object ", p,
+		      min_t(unsigned long, s->object_size, PAGE_SIZE));
 	if (s->flags & SLAB_RED_ZONE)
-		print_section("Redzone ", p + s->object_size,
+		print_section(KERN_ERR, "Redzone ", p + s->object_size,
 			s->inuse - s->object_size);

 	if (s->offset)
@@ -658,7 +660,8 @@ static void print_trailer(struct kmem_cache *s, struct page *page, u8 *p)

 	if (off != size_from_object(s))
 		/* Beginning of the filler is the free pointer */
-		print_section("Padding ", p + off, size_from_object(s) - off);
+		print_section(KERN_ERR, "Padding ", p + off,
+			      size_from_object(s) - off);

 	dump_stack();
 }
@@ -820,7 +823,7 @@ static int slab_pad_check(struct kmem_cache *s, struct page *page)
 		end--;

 	slab_err(s, page, "Padding overwritten. 0x%p-0x%p", fault, end - 1);
-	print_section("Padding ", end - remainder, remainder);
+	print_section(KERN_ERR, "Padding ", end - remainder, remainder);

 	restore_bytes(s, "slab padding", POISON_INUSE, end - remainder, end);
 	return 0;
@@ -973,7 +976,7 @@ static void trace(struct kmem_cache *s, struct page *page, void *object,
 			page->freelist);

 		if (!alloc)
-			print_section("Object ", (void *)object,
+			print_section(KERN_INFO, "Object ", (void *)object,
 					s->object_size);

 		dump_stack();
--
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
