Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7AECA6B0287
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 16:46:02 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id m30so7400373pgn.2
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 13:46:02 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x7sor1349100plw.8.2017.09.20.13.46.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Sep 2017 13:46:01 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v3 02/31] usercopy: Enforce slab cache usercopy region boundaries
Date: Wed, 20 Sep 2017 13:45:08 -0700
Message-Id: <1505940337-79069-3-git-send-email-keescook@chromium.org>
In-Reply-To: <1505940337-79069-1-git-send-email-keescook@chromium.org>
References: <1505940337-79069-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Laura Abbott <labbott@redhat.com>, Ingo Molnar <mingo@kernel.org>, Mark Rutland <mark.rutland@arm.com>, linux-mm@kvack.org, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org, kernel-hardening@lists.openwall.com

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
Cc: linux-xfs@vger.kernel.org
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
index fae637726c44..bbf73024be3a 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3833,7 +3833,9 @@ EXPORT_SYMBOL(__kmalloc_node);
 
 #ifdef CONFIG_HARDENED_USERCOPY
 /*
- * Rejects objects that are incorrectly sized.
+ * Rejects incorrectly sized objects and objects that are to be copied
+ * to/from userspace but do not fall entirely within the containing slab
+ * cache's usercopy region.
  *
  * Returns NULL if check passes, otherwise const char * to name of cache
  * to indicate an error.
@@ -3843,11 +3845,9 @@ const char *__check_heap_object(const void *ptr, unsigned long n,
 {
 	struct kmem_cache *s;
 	unsigned long offset;
-	size_t object_size;
 
 	/* Find object and usable object size. */
 	s = page->slab_cache;
-	object_size = slab_ksize(s);
 
 	/* Reject impossible pointers. */
 	if (ptr < page_address(page))
@@ -3863,11 +3863,15 @@ const char *__check_heap_object(const void *ptr, unsigned long n,
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
