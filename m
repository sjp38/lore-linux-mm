Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 70AA16B0069
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 15:56:52 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id f5so9297364pgp.18
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 12:56:52 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k3sor798029pgf.39.2018.01.09.12.56.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Jan 2018 12:56:50 -0800 (PST)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 02/36] usercopy: Include offset in overflow report
Date: Tue,  9 Jan 2018 12:55:31 -0800
Message-Id: <1515531365-37423-3-git-send-email-keescook@chromium.org>
In-Reply-To: <1515531365-37423-1-git-send-email-keescook@chromium.org>
References: <1515531365-37423-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Windsor <dave@nullcore.net>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux.com>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-fsdevel@vger.kernel.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

This refactors the hardened usercopy reporting code so that the object
offset can be included in the report. Having the offset can be much more
helpful in understanding usercopy bugs.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 include/linux/slab.h        |  11 +++--
 include/linux/thread_info.h |   2 +
 mm/slab.c                   |   8 ++--
 mm/slub.c                   |  14 +++---
 mm/usercopy.c               | 101 +++++++++++++++++++++++---------------------
 5 files changed, 72 insertions(+), 64 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 50697a1d6621..ca11d5affacf 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -167,14 +167,13 @@ void kzfree(const void *);
 size_t ksize(const void *);
 
 #ifdef CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR
-const char *__check_heap_object(const void *ptr, unsigned long n,
-				struct page *page);
+int __check_heap_object(const void *ptr, unsigned long n, struct page *page,
+			bool to_user);
 #else
-static inline const char *__check_heap_object(const void *ptr,
-					      unsigned long n,
-					      struct page *page)
+static inline int __check_heap_object(const void *ptr, unsigned long n,
+				      struct page *page, bool to_user)
 {
-	return NULL;
+	return 0;
 }
 #endif
 
diff --git a/include/linux/thread_info.h b/include/linux/thread_info.h
index 34f053a150a9..2ae26d138ac9 100644
--- a/include/linux/thread_info.h
+++ b/include/linux/thread_info.h
@@ -111,6 +111,8 @@ static __always_inline void check_object_size(const void *ptr, unsigned long n,
 	if (!__builtin_constant_p(n))
 		__check_object_size(ptr, n, to_user);
 }
+int report_usercopy(const char *name, const char *detail, bool to_user,
+		    unsigned long offset, unsigned long len);
 #else
 static inline void check_object_size(const void *ptr, unsigned long n,
 				     bool to_user)
diff --git a/mm/slab.c b/mm/slab.c
index 183e996dde5f..1a33ba68df3d 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4397,8 +4397,8 @@ module_init(slab_proc_init);
  * Returns NULL if check passes, otherwise const char * to name of cache
  * to indicate an error.
  */
-const char *__check_heap_object(const void *ptr, unsigned long n,
-				struct page *page)
+int __check_heap_object(const void *ptr, unsigned long n, struct page *page,
+			bool to_user)
 {
 	struct kmem_cache *cachep;
 	unsigned int objnr;
@@ -4414,9 +4414,9 @@ const char *__check_heap_object(const void *ptr, unsigned long n,
 
 	/* Allow address range falling entirely within object size. */
 	if (offset <= cachep->object_size && n <= cachep->object_size - offset)
-		return NULL;
+		return 0;
 
-	return cachep->name;
+	return report_usercopy("SLAB object", cachep->name, to_user, offset, n);
 }
 #endif /* CONFIG_HARDENED_USERCOPY */
 
diff --git a/mm/slub.c b/mm/slub.c
index cfd56e5a35fb..8c82872cc8ef 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3818,8 +3818,8 @@ EXPORT_SYMBOL(__kmalloc_node);
  * Returns NULL if check passes, otherwise const char * to name of cache
  * to indicate an error.
  */
-const char *__check_heap_object(const void *ptr, unsigned long n,
-				struct page *page)
+int __check_heap_object(const void *ptr, unsigned long n, struct page *page,
+			bool to_user)
 {
 	struct kmem_cache *s;
 	unsigned long offset;
@@ -3831,7 +3831,8 @@ const char *__check_heap_object(const void *ptr, unsigned long n,
 
 	/* Reject impossible pointers. */
 	if (ptr < page_address(page))
-		return s->name;
+		return report_usercopy("SLUB object not in SLUB page?!", NULL,
+				       to_user, 0, n);
 
 	/* Find offset within object. */
 	offset = (ptr - page_address(page)) % s->size;
@@ -3839,15 +3840,16 @@ const char *__check_heap_object(const void *ptr, unsigned long n,
 	/* Adjust for redzone and reject if within the redzone. */
 	if (kmem_cache_debug(s) && s->flags & SLAB_RED_ZONE) {
 		if (offset < s->red_left_pad)
-			return s->name;
+			return report_usercopy("SLUB object in left red zone",
+					       s->name, to_user, offset, n);
 		offset -= s->red_left_pad;
 	}
 
 	/* Allow address range falling entirely within object size. */
 	if (offset <= object_size && n <= object_size - offset)
-		return NULL;
+		return 0;
 
-	return s->name;
+	return report_usercopy("SLUB object", s->name, to_user, offset, n);
 }
 #endif /* CONFIG_HARDENED_USERCOPY */
 
diff --git a/mm/usercopy.c b/mm/usercopy.c
index 5df1e68d4585..a8426a502136 100644
--- a/mm/usercopy.c
+++ b/mm/usercopy.c
@@ -58,24 +58,30 @@ static noinline int check_stack_object(const void *obj, unsigned long len)
 	return GOOD_STACK;
 }
 
-static void report_usercopy(unsigned long len, bool to_user, const char *type)
+int report_usercopy(const char *name, const char *detail, bool to_user,
+		    unsigned long offset, unsigned long len)
 {
-	pr_emerg("kernel memory %s attempt detected %s '%s' (%lu bytes)\n",
+	pr_emerg("kernel memory %s attempt detected %s %s%s%s%s (offset %lu, size %lu)\n",
 		to_user ? "exposure" : "overwrite",
-		to_user ? "from" : "to", type ? : "unknown", len);
+		to_user ? "from" : "to",
+		name ? : "unknown?!",
+		detail ? " '" : "", detail ? : "", detail ? "'" : "",
+		offset, len);
 	/*
 	 * For greater effect, it would be nice to do do_group_exit(),
 	 * but BUG() actually hooks all the lock-breaking and per-arch
 	 * Oops code, so that is used here instead.
 	 */
 	BUG();
+
+	return -1;
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
@@ -86,15 +92,16 @@ static bool overlaps(const void *ptr, unsigned long n, unsigned long low,
 }
 
 /* Is this address range in the kernel text area? */
-static inline const char *check_kernel_text_object(const void *ptr,
-						   unsigned long n)
+static inline int check_kernel_text_object(const unsigned long ptr,
+					   unsigned long n, bool to_user)
 {
 	unsigned long textlow = (unsigned long)_stext;
 	unsigned long texthigh = (unsigned long)_etext;
 	unsigned long textlow_linear, texthigh_linear;
 
 	if (overlaps(ptr, n, textlow, texthigh))
-		return "<kernel text>";
+		return report_usercopy("kernel text", NULL, to_user,
+				       ptr - textlow, n);
 
 	/*
 	 * Some architectures have virtual memory mappings with a secondary
@@ -107,32 +114,35 @@ static inline const char *check_kernel_text_object(const void *ptr,
 	textlow_linear = (unsigned long)lm_alias(textlow);
 	/* No different mapping: we're done. */
 	if (textlow_linear == textlow)
-		return NULL;
+		return 0;
 
 	/* Check the secondary mapping... */
 	texthigh_linear = (unsigned long)lm_alias(texthigh);
 	if (overlaps(ptr, n, textlow_linear, texthigh_linear))
-		return "<linear kernel text>";
+		return report_usercopy("linear kernel text", NULL, to_user,
+				       ptr - textlow_linear, n);
 
-	return NULL;
+	return 0;
 }
 
-static inline const char *check_bogus_address(const void *ptr, unsigned long n)
+static inline int check_bogus_address(const unsigned long ptr, unsigned long n,
+				      bool to_user)
 {
 	/* Reject if object wraps past end of memory. */
-	if ((unsigned long)ptr + n < (unsigned long)ptr)
-		return "<wrapped address>";
+	if (ptr + n < ptr)
+		return report_usercopy("wrapped address", NULL, to_user,
+				       0, ptr + n);
 
 	/* Reject if NULL or ZERO-allocation. */
 	if (ZERO_OR_NULL_PTR(ptr))
-		return "<null>";
+		return report_usercopy("null address", NULL, to_user, ptr, n);
 
-	return NULL;
+	return 0;
 }
 
 /* Checks for allocs that are marked in some way as spanning multiple pages. */
-static inline const char *check_page_span(const void *ptr, unsigned long n,
-					  struct page *page, bool to_user)
+static inline int check_page_span(const void *ptr, unsigned long n,
+				  struct page *page, bool to_user)
 {
 #ifdef CONFIG_HARDENED_USERCOPY_PAGESPAN
 	const void *end = ptr + n - 1;
@@ -149,28 +159,28 @@ static inline const char *check_page_span(const void *ptr, unsigned long n,
 	if (ptr >= (const void *)__start_rodata &&
 	    end <= (const void *)__end_rodata) {
 		if (!to_user)
-			return "<rodata>";
-		return NULL;
+			return report_usercopy("rodata", NULL, to_user, 0, n);
+		return 0;
 	}
 
 	/* Allow kernel data region (if not marked as Reserved). */
 	if (ptr >= (const void *)_sdata && end <= (const void *)_edata)
-		return NULL;
+		return 0;
 
 	/* Allow kernel bss region (if not marked as Reserved). */
 	if (ptr >= (const void *)__bss_start &&
 	    end <= (const void *)__bss_stop)
-		return NULL;
+		return 0;
 
 	/* Is the object wholly within one base page? */
 	if (likely(((unsigned long)ptr & (unsigned long)PAGE_MASK) ==
 		   ((unsigned long)end & (unsigned long)PAGE_MASK)))
-		return NULL;
+		return 0;
 
 	/* Allow if fully inside the same compound (__GFP_COMP) page. */
 	endpage = virt_to_head_page(end);
 	if (likely(endpage == page))
-		return NULL;
+		return 0;
 
 	/*
 	 * Reject if range is entirely either Reserved (i.e. special or
@@ -180,33 +190,36 @@ static inline const char *check_page_span(const void *ptr, unsigned long n,
 	is_reserved = PageReserved(page);
 	is_cma = is_migrate_cma_page(page);
 	if (!is_reserved && !is_cma)
-		return "<spans multiple pages>";
+		return report_usercopy("spans multiple pages", NULL, to_user,
+				       0, n);
 
 	for (ptr += PAGE_SIZE; ptr <= end; ptr += PAGE_SIZE) {
 		page = virt_to_head_page(ptr);
 		if (is_reserved && !PageReserved(page))
-			return "<spans Reserved and non-Reserved pages>";
+			return report_usercopy("spans Reserved and non-Reserved pages",
+					       NULL, to_user, 0, n);
 		if (is_cma && !is_migrate_cma_page(page))
-			return "<spans CMA and non-CMA pages>";
+			return report_usercopy("spans CMA and non-CMA pages",
+					       NULL, to_user, 0, n);
 	}
 #endif
 
-	return NULL;
+	return 0;
 }
 
-static inline const char *check_heap_object(const void *ptr, unsigned long n,
-					    bool to_user)
+static inline int check_heap_object(const void *ptr, unsigned long n,
+				    bool to_user)
 {
 	struct page *page;
 
 	if (!virt_addr_valid(ptr))
-		return NULL;
+		return 0;
 
 	page = virt_to_head_page(ptr);
 
 	/* Check slab allocator for flags and size. */
 	if (PageSlab(page))
-		return __check_heap_object(ptr, n, page);
+		return __check_heap_object(ptr, n, page, to_user);
 
 	/* Verify object does not incorrectly span multiple pages. */
 	return check_page_span(ptr, n, page, to_user);
@@ -220,21 +233,17 @@ static inline const char *check_heap_object(const void *ptr, unsigned long n,
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
+	if (check_bogus_address((const unsigned long)ptr, n, to_user))
+		return;
 
 	/* Check for bad heap object. */
-	err = check_heap_object(ptr, n, to_user);
-	if (err)
-		goto report;
+	if (check_heap_object(ptr, n, to_user))
+		return;
 
 	/* Check for bad stack object. */
 	switch (check_stack_object(ptr, n)) {
@@ -250,16 +259,12 @@ void __check_object_size(const void *ptr, unsigned long n, bool to_user)
 		 */
 		return;
 	default:
-		err = "<process stack>";
-		goto report;
+		report_usercopy("process stack", NULL, to_user, 0, n);
+		return;
 	}
 
 	/* Check for object in kernel to avoid text exposure. */
-	err = check_kernel_text_object(ptr, n);
-	if (!err)
+	if (check_kernel_text_object((const unsigned long)ptr, n, to_user))
 		return;
-
-report:
-	report_usercopy(n, to_user, err);
 }
 EXPORT_SYMBOL(__check_object_size);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
