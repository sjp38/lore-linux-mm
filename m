Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id AD1FC6B0261
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 21:03:27 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id z24so1656162pgu.20
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 18:03:27 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l8sor4013183pgs.283.2018.01.10.18.03.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jan 2018 18:03:26 -0800 (PST)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 07/38] usercopy: WARN() on slab cache usercopy region violations
Date: Wed, 10 Jan 2018 18:02:39 -0800
Message-Id: <1515636190-24061-8-git-send-email-keescook@chromium.org>
In-Reply-To: <1515636190-24061-1-git-send-email-keescook@chromium.org>
References: <1515636190-24061-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Laura Abbott <labbott@redhat.com>, Ingo Molnar <mingo@kernel.org>, Mark Rutland <mark.rutland@arm.com>, linux-mm@kvack.org, linux-xfs@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, David Windsor <dave@nullcore.net>, Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, "David S. Miller" <davem@davemloft.net>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-fsdevel@vger.kernel.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, kernel-hardening@lists.openwall.com

This patch adds checking of usercopy cache whitelisting, and is modified
from Brad Spengler/PaX Team's PAX_USERCOPY whitelisting code in the
last public patch of grsecurity/PaX based on my understanding of the
code. Changes or omissions from the original code are mine and don't
reflect the original grsecurity/PaX code.

The SLAB and SLUB allocators are modified to WARN() on all copy operations
in which the kernel heap memory being modified falls outside of the cache's
defined usercopy region.

Based on an earlier patch from David Windsor.

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
 mm/slab.c     | 22 +++++++++++++++++++---
 mm/slab.h     |  2 ++
 mm/slub.c     | 23 +++++++++++++++++++----
 mm/usercopy.c | 21 ++++++++++++++++++---
 4 files changed, 58 insertions(+), 10 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 47acfe54e1ae..1c02f6e94235 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4392,7 +4392,9 @@ module_init(slab_proc_init);
 
 #ifdef CONFIG_HARDENED_USERCOPY
 /*
- * Rejects objects that are incorrectly sized.
+ * Rejects incorrectly sized objects and objects that are to be copied
+ * to/from userspace but do not fall entirely within the containing slab
+ * cache's usercopy region.
  *
  * Returns NULL if check passes, otherwise const char * to name of cache
  * to indicate an error.
@@ -4412,10 +4414,24 @@ void __check_heap_object(const void *ptr, unsigned long n, struct page *page,
 	/* Find offset within object. */
 	offset = ptr - index_to_obj(cachep, page, objnr) - obj_offset(cachep);
 
-	/* Allow address range falling entirely within object size. */
-	if (offset <= cachep->object_size && n <= cachep->object_size - offset)
+	/* Allow address range falling entirely within usercopy region. */
+	if (offset >= cachep->useroffset &&
+	    offset - cachep->useroffset <= cachep->usersize &&
+	    n <= cachep->useroffset - offset + cachep->usersize)
 		return;
 
+	/*
+	 * If the copy is still within the allocated object, produce
+	 * a warning instead of rejecting the copy. This is intended
+	 * to be a temporary method to find any missing usercopy
+	 * whitelists.
+	 */
+	if (offset <= cachep->object_size &&
+	    n <= cachep->object_size - offset) {
+		usercopy_warn("SLAB object", cachep->name, to_user, offset, n);
+		return;
+	}
+
 	usercopy_abort("SLAB object", cachep->name, to_user, offset, n);
 }
 #endif /* CONFIG_HARDENED_USERCOPY */
diff --git a/mm/slab.h b/mm/slab.h
index 1897991df3fa..b476c435680f 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -530,6 +530,8 @@ static inline void cache_random_seq_destroy(struct kmem_cache *cachep) { }
 #endif /* CONFIG_SLAB_FREELIST_RANDOM */
 
 #ifdef CONFIG_HARDENED_USERCOPY
+void usercopy_warn(const char *name, const char *detail, bool to_user,
+		   unsigned long offset, unsigned long len);
 void __noreturn usercopy_abort(const char *name, const char *detail,
 			       bool to_user, unsigned long offset,
 			       unsigned long len);
diff --git a/mm/slub.c b/mm/slub.c
index f40a57164dd6..6d9b1e7d3226 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3813,7 +3813,9 @@ EXPORT_SYMBOL(__kmalloc_node);
 
 #ifdef CONFIG_HARDENED_USERCOPY
 /*
- * Rejects objects that are incorrectly sized.
+ * Rejects incorrectly sized objects and objects that are to be copied
+ * to/from userspace but do not fall entirely within the containing slab
+ * cache's usercopy region.
  *
  * Returns NULL if check passes, otherwise const char * to name of cache
  * to indicate an error.
@@ -3827,7 +3829,6 @@ void __check_heap_object(const void *ptr, unsigned long n, struct page *page,
 
 	/* Find object and usable object size. */
 	s = page->slab_cache;
-	object_size = slab_ksize(s);
 
 	/* Reject impossible pointers. */
 	if (ptr < page_address(page))
@@ -3845,10 +3846,24 @@ void __check_heap_object(const void *ptr, unsigned long n, struct page *page,
 		offset -= s->red_left_pad;
 	}
 
-	/* Allow address range falling entirely within object size. */
-	if (offset <= object_size && n <= object_size - offset)
+	/* Allow address range falling entirely within usercopy region. */
+	if (offset >= s->useroffset &&
+	    offset - s->useroffset <= s->usersize &&
+	    n <= s->useroffset - offset + s->usersize)
 		return;
 
+	/*
+	 * If the copy is still within the allocated object, produce
+	 * a warning instead of rejecting the copy. This is intended
+	 * to be a temporary method to find any missing usercopy
+	 * whitelists.
+	 */
+	object_size = slab_ksize(s);
+	if (offset <= object_size && n <= object_size - offset) {
+		usercopy_warn("SLUB object", s->name, to_user, offset, n);
+		return;
+	}
+
 	usercopy_abort("SLUB object", s->name, to_user, offset, n);
 }
 #endif /* CONFIG_HARDENED_USERCOPY */
diff --git a/mm/usercopy.c b/mm/usercopy.c
index a562dd094ace..e9e9325f7638 100644
--- a/mm/usercopy.c
+++ b/mm/usercopy.c
@@ -59,13 +59,28 @@ static noinline int check_stack_object(const void *obj, unsigned long len)
 }
 
 /*
- * If this function is reached, then CONFIG_HARDENED_USERCOPY has found an
- * unexpected state during a copy_from_user() or copy_to_user() call.
+ * If these functions are reached, then CONFIG_HARDENED_USERCOPY has found
+ * an unexpected state during a copy_from_user() or copy_to_user() call.
  * There are several checks being performed on the buffer by the
  * __check_object_size() function. Normal stack buffer usage should never
  * trip the checks, and kernel text addressing will always trip the check.
- * For cache objects, copies must be within the object size.
+ * For cache objects, it is checking that only the whitelisted range of
+ * bytes for a given cache is being accessed (via the cache's usersize and
+ * useroffset fields). To adjust a cache whitelist, use the usercopy-aware
+ * kmem_cache_create_usercopy() function to create the cache (and
+ * carefully audit the whitelist range).
  */
+void usercopy_warn(const char *name, const char *detail, bool to_user,
+		   unsigned long offset, unsigned long len)
+{
+	WARN_ONCE(1, "Bad or missing usercopy whitelist? Kernel memory %s attempt detected %s %s%s%s%s (offset %lu, size %lu)!\n",
+		 to_user ? "exposure" : "overwrite",
+		 to_user ? "from" : "to",
+		 name ? : "unknown?!",
+		 detail ? " '" : "", detail ? : "", detail ? "'" : "",
+		 offset, len);
+}
+
 void __noreturn usercopy_abort(const char *name, const char *detail,
 			       bool to_user, unsigned long offset,
 			       unsigned long len)
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
