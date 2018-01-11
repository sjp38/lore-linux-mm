Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3D13D6B025E
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 21:03:25 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id e26so1663659pgv.16
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 18:03:25 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n74sor4619662pfk.22.2018.01.10.18.03.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jan 2018 18:03:23 -0800 (PST)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 03/38] usercopy: Include offset in hardened usercopy report
Date: Wed, 10 Jan 2018 18:02:35 -0800
Message-Id: <1515636190-24061-4-git-send-email-keescook@chromium.org>
In-Reply-To: <1515636190-24061-1-git-send-email-keescook@chromium.org>
References: <1515636190-24061-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Windsor <dave@nullcore.net>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux.com>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-fsdevel@vger.kernel.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

This refactors the hardened usercopy code so that failure reporting can
happen within the checking functions instead of at the top level. This
simplifies the return value handling and allows more details and offsets
to be included in the report. Having the offset can be much more helpful
in understanding hardened usercopy bugs.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 include/linux/slab.h | 12 +++----
 mm/slab.c            |  8 ++---
 mm/slub.c            | 14 ++++----
 mm/usercopy.c        | 95 +++++++++++++++++++++++-----------------------------
 4 files changed, 57 insertions(+), 72 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 50697a1d6621..2dbeccdcb76b 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -167,15 +167,11 @@ void kzfree(const void *);
 size_t ksize(const void *);
 
 #ifdef CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR
-const char *__check_heap_object(const void *ptr, unsigned long n,
-				struct page *page);
+void __check_heap_object(const void *ptr, unsigned long n, struct page *page,
+			bool to_user);
 #else
-static inline const char *__check_heap_object(const void *ptr,
-					      unsigned long n,
-					      struct page *page)
-{
-	return NULL;
-}
+static inline void __check_heap_object(const void *ptr, unsigned long n,
+				       struct page *page, bool to_user) { }
 #endif
 
 /*
diff --git a/mm/slab.c b/mm/slab.c
index 183e996dde5f..b2beb2cc15e2 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4397,8 +4397,8 @@ module_init(slab_proc_init);
  * Returns NULL if check passes, otherwise const char * to name of cache
  * to indicate an error.
  */
-const char *__check_heap_object(const void *ptr, unsigned long n,
-				struct page *page)
+void __check_heap_object(const void *ptr, unsigned long n, struct page *page,
+			 bool to_user)
 {
 	struct kmem_cache *cachep;
 	unsigned int objnr;
@@ -4414,9 +4414,9 @@ const char *__check_heap_object(const void *ptr, unsigned long n,
 
 	/* Allow address range falling entirely within object size. */
 	if (offset <= cachep->object_size && n <= cachep->object_size - offset)
-		return NULL;
+		return;
 
-	return cachep->name;
+	usercopy_abort("SLAB object", cachep->name, to_user, offset, n);
 }
 #endif /* CONFIG_HARDENED_USERCOPY */
 
diff --git a/mm/slub.c b/mm/slub.c
index cfd56e5a35fb..bcd22332300a 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3818,8 +3818,8 @@ EXPORT_SYMBOL(__kmalloc_node);
  * Returns NULL if check passes, otherwise const char * to name of cache
  * to indicate an error.
  */
-const char *__check_heap_object(const void *ptr, unsigned long n,
-				struct page *page)
+void __check_heap_object(const void *ptr, unsigned long n, struct page *page,
+			 bool to_user)
 {
 	struct kmem_cache *s;
 	unsigned long offset;
@@ -3831,7 +3831,8 @@ const char *__check_heap_object(const void *ptr, unsigned long n,
 
 	/* Reject impossible pointers. */
 	if (ptr < page_address(page))
-		return s->name;
+		usercopy_abort("SLUB object not in SLUB page?!", NULL,
+			       to_user, 0, n);
 
 	/* Find offset within object. */
 	offset = (ptr - page_address(page)) % s->size;
@@ -3839,15 +3840,16 @@ const char *__check_heap_object(const void *ptr, unsigned long n,
 	/* Adjust for redzone and reject if within the redzone. */
 	if (kmem_cache_debug(s) && s->flags & SLAB_RED_ZONE) {
 		if (offset < s->red_left_pad)
-			return s->name;
+			usercopy_abort("SLUB object in left red zone",
+				       s->name, to_user, offset, n);
 		offset -= s->red_left_pad;
 	}
 
 	/* Allow address range falling entirely within object size. */
 	if (offset <= object_size && n <= object_size - offset)
-		return NULL;
+		return;
 
-	return s->name;
+	usercopy_abort("SLUB object", s->name, to_user, offset, n);
 }
 #endif /* CONFIG_HARDENED_USERCOPY */
 
diff --git a/mm/usercopy.c b/mm/usercopy.c
index 8006baa4caac..a562dd094ace 100644
--- a/mm/usercopy.c
+++ b/mm/usercopy.c
@@ -86,10 +86,10 @@ void __noreturn usercopy_abort(const char *name, const char *detail,
 }
 
 /* Returns true if any portion of [ptr,ptr+n) over laps with [low,high). */
-static bool overlaps(const void *ptr, unsigned long n, unsigned long low,
-		     unsigned long high)
+static bool overlaps(const unsigned long ptr, unsigned long n,
+		     unsigned long low, unsigned long high)
 {
-	unsigned long check_low = (uintptr_t)ptr;
+	const unsigned long check_low = ptr;
 	unsigned long check_high = check_low + n;
 
 	/* Does not overlap if entirely above or entirely below. */
@@ -100,15 +100,15 @@ static bool overlaps(const void *ptr, unsigned long n, unsigned long low,
 }
 
 /* Is this address range in the kernel text area? */
-static inline const char *check_kernel_text_object(const void *ptr,
-						   unsigned long n)
+static inline void check_kernel_text_object(const unsigned long ptr,
+					    unsigned long n, bool to_user)
 {
 	unsigned long textlow = (unsigned long)_stext;
 	unsigned long texthigh = (unsigned long)_etext;
 	unsigned long textlow_linear, texthigh_linear;
 
 	if (overlaps(ptr, n, textlow, texthigh))
-		return "<kernel text>";
+		usercopy_abort("kernel text", NULL, to_user, ptr - textlow, n);
 
 	/*
 	 * Some architectures have virtual memory mappings with a secondary
@@ -121,32 +121,30 @@ static inline const char *check_kernel_text_object(const void *ptr,
 	textlow_linear = (unsigned long)lm_alias(textlow);
 	/* No different mapping: we're done. */
 	if (textlow_linear == textlow)
-		return NULL;
+		return;
 
 	/* Check the secondary mapping... */
 	texthigh_linear = (unsigned long)lm_alias(texthigh);
 	if (overlaps(ptr, n, textlow_linear, texthigh_linear))
-		return "<linear kernel text>";
-
-	return NULL;
+		usercopy_abort("linear kernel text", NULL, to_user,
+			       ptr - textlow_linear, n);
 }
 
-static inline const char *check_bogus_address(const void *ptr, unsigned long n)
+static inline void check_bogus_address(const unsigned long ptr, unsigned long n,
+				       bool to_user)
 {
 	/* Reject if object wraps past end of memory. */
-	if ((unsigned long)ptr + n < (unsigned long)ptr)
-		return "<wrapped address>";
+	if (ptr + n < ptr)
+		usercopy_abort("wrapped address", NULL, to_user, 0, ptr + n);
 
 	/* Reject if NULL or ZERO-allocation. */
 	if (ZERO_OR_NULL_PTR(ptr))
-		return "<null>";
-
-	return NULL;
+		usercopy_abort("null address", NULL, to_user, ptr, n);
 }
 
 /* Checks for allocs that are marked in some way as spanning multiple pages. */
-static inline const char *check_page_span(const void *ptr, unsigned long n,
-					  struct page *page, bool to_user)
+static inline void check_page_span(const void *ptr, unsigned long n,
+				   struct page *page, bool to_user)
 {
 #ifdef CONFIG_HARDENED_USERCOPY_PAGESPAN
 	const void *end = ptr + n - 1;
@@ -163,28 +161,28 @@ static inline const char *check_page_span(const void *ptr, unsigned long n,
 	if (ptr >= (const void *)__start_rodata &&
 	    end <= (const void *)__end_rodata) {
 		if (!to_user)
-			return "<rodata>";
-		return NULL;
+			usercopy_abort("rodata", NULL, to_user, 0, n);
+		return;
 	}
 
 	/* Allow kernel data region (if not marked as Reserved). */
 	if (ptr >= (const void *)_sdata && end <= (const void *)_edata)
-		return NULL;
+		return;
 
 	/* Allow kernel bss region (if not marked as Reserved). */
 	if (ptr >= (const void *)__bss_start &&
 	    end <= (const void *)__bss_stop)
-		return NULL;
+		return;
 
 	/* Is the object wholly within one base page? */
 	if (likely(((unsigned long)ptr & (unsigned long)PAGE_MASK) ==
 		   ((unsigned long)end & (unsigned long)PAGE_MASK)))
-		return NULL;
+		return;
 
 	/* Allow if fully inside the same compound (__GFP_COMP) page. */
 	endpage = virt_to_head_page(end);
 	if (likely(endpage == page))
-		return NULL;
+		return;
 
 	/*
 	 * Reject if range is entirely either Reserved (i.e. special or
@@ -194,36 +192,37 @@ static inline const char *check_page_span(const void *ptr, unsigned long n,
 	is_reserved = PageReserved(page);
 	is_cma = is_migrate_cma_page(page);
 	if (!is_reserved && !is_cma)
-		return "<spans multiple pages>";
+		usercopy_abort("spans multiple pages", NULL, to_user, 0, n);
 
 	for (ptr += PAGE_SIZE; ptr <= end; ptr += PAGE_SIZE) {
 		page = virt_to_head_page(ptr);
 		if (is_reserved && !PageReserved(page))
-			return "<spans Reserved and non-Reserved pages>";
+			usercopy_abort("spans Reserved and non-Reserved pages",
+				       NULL, to_user, 0, n);
 		if (is_cma && !is_migrate_cma_page(page))
-			return "<spans CMA and non-CMA pages>";
+			usercopy_abort("spans CMA and non-CMA pages", NULL,
+				       to_user, 0, n);
 	}
 #endif
-
-	return NULL;
 }
 
-static inline const char *check_heap_object(const void *ptr, unsigned long n,
-					    bool to_user)
+static inline void check_heap_object(const void *ptr, unsigned long n,
+				     bool to_user)
 {
 	struct page *page;
 
 	if (!virt_addr_valid(ptr))
-		return NULL;
+		return;
 
 	page = virt_to_head_page(ptr);
 
-	/* Check slab allocator for flags and size. */
-	if (PageSlab(page))
-		return __check_heap_object(ptr, n, page);
-
-	/* Verify object does not incorrectly span multiple pages. */
-	return check_page_span(ptr, n, page, to_user);
+	if (PageSlab(page)) {
+		/* Check slab allocator for flags and size. */
+		__check_heap_object(ptr, n, page, to_user);
+	} else {
+		/* Verify object does not incorrectly span multiple pages. */
+		check_page_span(ptr, n, page, to_user);
+	}
 }
 
 /*
@@ -234,21 +233,15 @@ static inline const char *check_heap_object(const void *ptr, unsigned long n,
  */
 void __check_object_size(const void *ptr, unsigned long n, bool to_user)
 {
-	const char *err;
-
 	/* Skip all tests if size is zero. */
 	if (!n)
 		return;
 
 	/* Check for invalid addresses. */
-	err = check_bogus_address(ptr, n);
-	if (err)
-		goto report;
+	check_bogus_address((const unsigned long)ptr, n, to_user);
 
 	/* Check for bad heap object. */
-	err = check_heap_object(ptr, n, to_user);
-	if (err)
-		goto report;
+	check_heap_object(ptr, n, to_user);
 
 	/* Check for bad stack object. */
 	switch (check_stack_object(ptr, n)) {
@@ -264,16 +257,10 @@ void __check_object_size(const void *ptr, unsigned long n, bool to_user)
 		 */
 		return;
 	default:
-		err = "<process stack>";
-		goto report;
+		usercopy_abort("process stack", NULL, to_user, 0, n);
 	}
 
 	/* Check for object in kernel to avoid text exposure. */
-	err = check_kernel_text_object(ptr, n);
-	if (!err)
-		return;
-
-report:
-	usercopy_abort(err, NULL, to_user, 0, n);
+	check_kernel_text_object((const unsigned long)ptr, n, to_user);
 }
 EXPORT_SYMBOL(__check_object_size);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
