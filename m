Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A72D76B027D
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 15:57:16 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id v25so11132787pfg.14
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 12:57:16 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p8sor3473674pgc.40.2018.01.09.12.57.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Jan 2018 12:57:15 -0800 (PST)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 05/36] usercopy: WARN() on slab cache usercopy region violations
Date: Tue,  9 Jan 2018 12:55:34 -0800
Message-Id: <1515531365-37423-6-git-send-email-keescook@chromium.org>
In-Reply-To: <1515531365-37423-1-git-send-email-keescook@chromium.org>
References: <1515531365-37423-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Laura Abbott <labbott@redhat.com>, Ingo Molnar <mingo@kernel.org>, Mark Rutland <mark.rutland@arm.com>, linux-mm@kvack.org, linux-xfs@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, "David S. Miller" <davem@davemloft.net>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-fsdevel@vger.kernel.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, kernel-hardening@lists.openwall.com

From: David Windsor <dave@nullcore.net>

This patch adds checking of usercopy cache whitelisting, and is modified
from Brad Spengler/PaX Team's PAX_USERCOPY whitelisting code in the
last public patch of grsecurity/PaX based on my understanding of the
code. Changes or omissions from the original code are mine and don't
reflect the original grsecurity/PaX code.

The SLAB and SLUB allocators are modified to WARN() on all copy operations
in which the kernel heap memory being modified falls outside of the cache's
defined usercopy region.

Signed-off-by: David Windsor <dave@nullcore.net>
[kees: adjust commit log and comments, switch to WARN-by-default]
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
 mm/slab.c     | 30 +++++++++++++++++++++++++-----
 mm/slub.c     | 34 +++++++++++++++++++++++++++-------
 mm/usercopy.c | 12 ++++++++++++
 3 files changed, 64 insertions(+), 12 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index f1ead7b7909d..d9939828f8e4 100644
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
@@ -4412,11 +4414,29 @@ int __check_heap_object(const void *ptr, unsigned long n, struct page *page,
 	/* Find offset within object. */
 	offset = ptr - index_to_obj(cachep, page, objnr) - obj_offset(cachep);
 
-	/* Allow address range falling entirely within object size. */
-	if (offset <= cachep->object_size && n <= cachep->object_size - offset)
-		return 0;
+	/* Make sure object falls entirely within cache's usercopy region. */
+	if (offset < cachep->useroffset ||
+	    offset - cachep->useroffset > cachep->usersize ||
+	    n > cachep->useroffset - offset + cachep->usersize) {
+		/*
+		 * If the copy is still within the allocated object, produce
+		 * a warning instead of rejecting the copy. This is intended
+		 * to be a temporary method to find any missing usercopy
+		 * whitelists.
+		 */
+		if (offset <= cachep->object_size &&
+		    n <= cachep->object_size - offset) {
+			WARN_ONCE(1, "unexpected usercopy %s with bad or missing whitelist with SLAB object '%s' (offset %lu, size %lu)",
+				  to_user ? "exposure" : "overwrite",
+				  cachep->name, offset, n);
+			return 0;
+		}
 
-	return report_usercopy("SLAB object", cachep->name, to_user, offset, n);
+		return report_usercopy("SLAB object", cachep->name, to_user,
+				       offset, n);
+	}
+
+	return 0;
 }
 #endif /* CONFIG_HARDENED_USERCOPY */
 
diff --git a/mm/slub.c b/mm/slub.c
index 8738a8d8bf8e..2aa4972a2058 100644
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
@@ -3823,11 +3825,9 @@ int __check_heap_object(const void *ptr, unsigned long n, struct page *page,
 {
 	struct kmem_cache *s;
 	unsigned long offset;
-	size_t object_size;
 
 	/* Find object and usable object size. */
 	s = page->slab_cache;
-	object_size = slab_ksize(s);
 
 	/* Reject impossible pointers. */
 	if (ptr < page_address(page))
@@ -3845,11 +3845,31 @@ int __check_heap_object(const void *ptr, unsigned long n, struct page *page,
 		offset -= s->red_left_pad;
 	}
 
-	/* Allow address range falling entirely within object size. */
-	if (offset <= object_size && n <= object_size - offset)
-		return 0;
+	/* Make sure object falls entirely within cache's usercopy region. */
+	if (offset < s->useroffset ||
+	    offset - s->useroffset > s->usersize ||
+	    n > s->useroffset - offset + s->usersize) {
+		size_t object_size;
 
-	return report_usercopy("SLUB object", s->name, to_user, offset, n);
+		/*
+		 * If the copy is still within the allocated object, produce
+		 * a warning instead of rejecting the copy. This is intended
+		 * to be a temporary method to find any missing usercopy
+		 * whitelists.
+		 */
+		object_size = slab_ksize(s);
+		if ((offset <= object_size && n <= object_size - offset)) {
+			WARN_ONCE(1, "unexpected usercopy %s with bad or missing whitelist with SLUB object '%s' (offset %lu size %lu)",
+				  to_user ? "exposure" : "overwrite",
+				  s->name, offset, n);
+			return 0;
+		}
+
+		return report_usercopy("SLUB object", s->name, to_user,
+				       offset, n);
+	}
+
+	return 0;
 }
 #endif /* CONFIG_HARDENED_USERCOPY */
 
diff --git a/mm/usercopy.c b/mm/usercopy.c
index a8426a502136..4ed615d4efc8 100644
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
 int report_usercopy(const char *name, const char *detail, bool to_user,
 		    unsigned long offset, unsigned long len)
 {
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
