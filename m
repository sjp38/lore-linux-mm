Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id DBD756B02F4
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 19:36:47 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 132so49528393pgb.6
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 16:36:47 -0700 (PDT)
Received: from mail-pf0-x235.google.com (mail-pf0-x235.google.com. [2607:f8b0:400e:c00::235])
        by mx.google.com with ESMTPS id c14si9512583pgt.177.2017.06.19.16.36.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 16:36:47 -0700 (PDT)
Received: by mail-pf0-x235.google.com with SMTP id s66so60754705pfs.1
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 16:36:47 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 02/23] usercopy: Enforce slab cache usercopy region boundaries
Date: Mon, 19 Jun 2017 16:36:16 -0700
Message-Id: <1497915397-93805-3-git-send-email-keescook@chromium.org>
In-Reply-To: <1497915397-93805-1-git-send-email-keescook@chromium.org>
References: <1497915397-93805-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: David Windsor <dave@nullcore.net>

This patch adds the enforcement component of usercopy cache whitelisting,
and is modified from Brad Spengler/PaX Team's PAX_USERCOPY whitelisting
code in the last public patch of grsecurity/PaX based on my understanding
of the code. Changes or omissions from the original code are mine and
don't reflect the original grsecurity/PaX code.

The SLAB and SLUB allocators are modified to deny all copy operations
in which the kernel heap memory being modified falls outside of the cache's
defined usercopy region.

Signed-off-by: David Windsor <dave@nullcore.net>
[kees: adjust commit log and comments]
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 mm/slab.c | 16 +++++++++++-----
 mm/slub.c | 18 +++++++++++-------
 2 files changed, 22 insertions(+), 12 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index cf77f1691588..5c78830aeea0 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4416,7 +4416,9 @@ module_init(slab_proc_init);
 
 #ifdef CONFIG_HARDENED_USERCOPY
 /*
- * Rejects objects that are incorrectly sized.
+ * Rejects incorrectly sized objects and objects that are to be copied
+ * to/from userspace but do not fall entirely within the containing slab
+ * cache's usercopy region.
  *
  * Returns NULL if check passes, otherwise const char * to name of cache
  * to indicate an error.
@@ -4436,11 +4438,15 @@ const char *__check_heap_object(const void *ptr, unsigned long n,
 	/* Find offset within object. */
 	offset = ptr - index_to_obj(cachep, page, objnr) - obj_offset(cachep);
 
-	/* Allow address range falling entirely within object size. */
-	if (offset <= cachep->object_size && n <= cachep->object_size - offset)
-		return NULL;
+	/* Make sure object falls entirely within cache's usercopy region. */
+	if (offset < cachep->useroffset)
+		return cachep->name;
+	if (offset - cachep->useroffset > cachep->usersize)
+		return cachep->name;
+	if (n > cachep->useroffset - offset + cachep->usersize)
+		return cachep->name;
 
-	return cachep->name;
+	return NULL;
 }
 #endif /* CONFIG_HARDENED_USERCOPY */
 
diff --git a/mm/slub.c b/mm/slub.c
index b8cbbc31b005..e12a2bfbca1e 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3796,7 +3796,9 @@ EXPORT_SYMBOL(__kmalloc_node);
 
 #ifdef CONFIG_HARDENED_USERCOPY
 /*
- * Rejects objects that are incorrectly sized.
+ * Rejects incorrectly sized objects and objects that are to be copied
+ * to/from userspace but do not fall entirely within the containing slab
+ * cache's usercopy region.
  *
  * Returns NULL if check passes, otherwise const char * to name of cache
  * to indicate an error.
@@ -3806,11 +3808,9 @@ const char *__check_heap_object(const void *ptr, unsigned long n,
 {
 	struct kmem_cache *s;
 	unsigned long offset;
-	size_t object_size;
 
 	/* Find object and usable object size. */
 	s = page->slab_cache;
-	object_size = slab_ksize(s);
 
 	/* Reject impossible pointers. */
 	if (ptr < page_address(page))
@@ -3826,11 +3826,15 @@ const char *__check_heap_object(const void *ptr, unsigned long n,
 		offset -= s->red_left_pad;
 	}
 
-	/* Allow address range falling entirely within object size. */
-	if (offset <= object_size && n <= object_size - offset)
-		return NULL;
+	/* Make sure object falls entirely within cache's usercopy region. */
+	if (offset < s->useroffset)
+		return s->name;
+	if (offset - s->useroffset > s->usersize)
+		return s->name;
+	if (n > s->useroffset - offset + s->usersize)
+		return s->name;
 
-	return s->name;
+	return NULL;
 }
 #endif /* CONFIG_HARDENED_USERCOPY */
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
