Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2070D6B02F3
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 17:35:21 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id r62so2457483pfj.5
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:35:21 -0700 (PDT)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id o14si1037260pli.466.2017.08.28.14.35.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Aug 2017 14:35:20 -0700 (PDT)
Received: by mail-pf0-x22d.google.com with SMTP id r62so4720698pfj.0
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:35:19 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v2 02/30] usercopy: Enforce slab cache usercopy region boundaries
Date: Mon, 28 Aug 2017 14:34:43 -0700
Message-Id: <1503956111-36652-3-git-send-email-keescook@chromium.org>
In-Reply-To: <1503956111-36652-1-git-send-email-keescook@chromium.org>
References: <1503956111-36652-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Laura Abbott <labbott@redhat.com>, Ingo Molnar <mingo@kernel.org>, Mark Rutland <mark.rutland@arm.com>, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

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
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Laura Abbott <labbott@redhat.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: linux-mm@kvack.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 mm/slab.c     | 16 +++++++++++-----
 mm/slub.c     | 18 +++++++++++-------
 mm/usercopy.c | 12 ++++++++++++
 3 files changed, 34 insertions(+), 12 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 87b6e5e0cdaf..df268999cf02 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4408,7 +4408,9 @@ module_init(slab_proc_init);
 
 #ifdef CONFIG_HARDENED_USERCOPY
 /*
- * Rejects objects that are incorrectly sized.
+ * Rejects incorrectly sized objects and objects that are to be copied
+ * to/from userspace but do not fall entirely within the containing slab
+ * cache's usercopy region.
  *
  * Returns NULL if check passes, otherwise const char * to name of cache
  * to indicate an error.
@@ -4428,11 +4430,15 @@ const char *__check_heap_object(const void *ptr, unsigned long n,
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
index dfed8ef99b68..bd4e2b9d4524 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3797,7 +3797,9 @@ EXPORT_SYMBOL(__kmalloc_node);
 
 #ifdef CONFIG_HARDENED_USERCOPY
 /*
- * Rejects objects that are incorrectly sized.
+ * Rejects incorrectly sized objects and objects that are to be copied
+ * to/from userspace but do not fall entirely within the containing slab
+ * cache's usercopy region.
  *
  * Returns NULL if check passes, otherwise const char * to name of cache
  * to indicate an error.
@@ -3807,11 +3809,9 @@ const char *__check_heap_object(const void *ptr, unsigned long n,
 {
 	struct kmem_cache *s;
 	unsigned long offset;
-	size_t object_size;
 
 	/* Find object and usable object size. */
 	s = page->slab_cache;
-	object_size = slab_ksize(s);
 
 	/* Reject impossible pointers. */
 	if (ptr < page_address(page))
@@ -3827,11 +3827,15 @@ const char *__check_heap_object(const void *ptr, unsigned long n,
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
 
diff --git a/mm/usercopy.c b/mm/usercopy.c
index a9852b24715d..cbffde670c49 100644
--- a/mm/usercopy.c
+++ b/mm/usercopy.c
@@ -58,6 +58,18 @@ static noinline int check_stack_object(const void *obj, unsigned long len)
 	return GOOD_STACK;
 }
 
+/*
+ * If this function is reached, then CONFIG_HARDENED_USERCOPY has found an
+ * unexpected state during a copy_from_user() or copy_to_user() call.
+ * There are several checks being performed on the buffer by the
+ * __check_object_size() function. Normal stack buffer usage should never
+ * trip the checks, and kernel text addressing will always trip the check.
+ * For cache objects, it is checking that only the whitelisted range of
+ * bytes for a given cache is being accessed (via the cache's usersize and
+ * useroffset fields). To adjust a cache whitelist, use the usercopy-aware
+ * kmem_cache_create_usercopy() function to create the cache (and
+ * carefully audit the whitelist range).
+ */
 static void report_usercopy(const void *ptr, unsigned long len,
 			    bool to_user, const char *type)
 {
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
