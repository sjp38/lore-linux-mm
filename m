Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f46.google.com (mail-qe0-f46.google.com [209.85.128.46])
	by kanga.kvack.org (Postfix) with ESMTP id B26F66B0035
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 15:07:52 -0500 (EST)
Received: by mail-qe0-f46.google.com with SMTP id 8so126268qea.5
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 12:07:52 -0800 (PST)
Received: from qmta01.emeryville.ca.mail.comcast.net (qmta01.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:16])
        by mx.google.com with ESMTP id o8si1974370qey.43.2014.01.14.12.07.50
        for <linux-mm@kvack.org>;
        Tue, 14 Jan 2014 12:07:51 -0800 (PST)
Date: Tue, 14 Jan 2014 14:07:47 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/9] re-shrink 'struct page' when SLUB is on.
In-Reply-To: <52D41F52.5020805@sr71.net>
Message-ID: <alpine.DEB.2.10.1401141404190.19618@nuc>
References: <20140103180147.6566F7C1@viggo.jf.intel.com> <20140103141816.20ef2a24c8adffae040e53dc@linux-foundation.org> <20140106043237.GE696@lge.com> <52D05D90.3060809@sr71.net> <20140110153913.844e84755256afd271371493@linux-foundation.org> <52D0854F.5060102@sr71.net>
 <CAOJsxLE-oMpV2G-gxrhyv0Au1tPd87Ow57VD5CWFo41wF8F4Yw@mail.gmail.com> <alpine.DEB.2.10.1401111854580.6036@nuc> <20140113014408.GA25900@lge.com> <52D41F52.5020805@sr71.net>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

One easy way to shrink struct page is to simply remove the feature. The
patchset looked a bit complicated and does many other things.


Subject: slub: Remove struct page alignment restriction by dropping cmpxchg_double on struct page fields

Remove the logic that will do cmpxchg_doubles on struct page fields with
the requirement of double word alignment. This allows struct page
to shrink by 8 bytes.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/include/linux/mm_types.h
===================================================================
--- linux.orig/include/linux/mm_types.h	2014-01-14 13:55:00.611838185 -0600
+++ linux/include/linux/mm_types.h	2014-01-14 13:55:00.601838496 -0600
@@ -73,18 +73,12 @@ struct page {
 		};

 		union {
-#if defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
-	defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
-			/* Used for cmpxchg_double in slub */
-			unsigned long counters;
-#else
 			/*
 			 * Keep _count separate from slub cmpxchg_double data.
 			 * As the rest of the double word is protected by
 			 * slab_lock but _count is not.
 			 */
 			unsigned counters;
-#endif

 			struct {

@@ -195,15 +189,7 @@ struct page {
 #ifdef LAST_CPUPID_NOT_IN_PAGE_FLAGS
 	int _last_cpupid;
 #endif
-}
-/*
- * The struct page can be forced to be double word aligned so that atomic ops
- * on double words work. The SLUB allocator can make use of such a feature.
- */
-#ifdef CONFIG_HAVE_ALIGNED_STRUCT_PAGE
-	__aligned(2 * sizeof(unsigned long))
-#endif
-;
+};

 struct page_frag {
 	struct page *page;
Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2014-01-14 13:55:00.611838185 -0600
+++ linux/mm/slub.c	2014-01-14 14:03:31.025903976 -0600
@@ -185,7 +185,6 @@ static inline bool kmem_cache_has_cpu_pa

 /* Internal SLUB flags */
 #define __OBJECT_POISON		0x80000000UL /* Poison object */
-#define __CMPXCHG_DOUBLE	0x40000000UL /* Use cmpxchg_double */

 #ifdef CONFIG_SMP
 static struct notifier_block slab_notifier;
@@ -362,34 +361,19 @@ static inline bool __cmpxchg_double_slab
 		const char *n)
 {
 	VM_BUG_ON(!irqs_disabled());
-#if defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
-    defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
-	if (s->flags & __CMPXCHG_DOUBLE) {
-		if (cmpxchg_double(&page->freelist, &page->counters,
-			freelist_old, counters_old,
-			freelist_new, counters_new))
-		return 1;
-	} else
-#endif
-	{
-		slab_lock(page);
-		if (page->freelist == freelist_old &&
-					page->counters == counters_old) {
-			page->freelist = freelist_new;
-			page->counters = counters_new;
-			slab_unlock(page);
-			return 1;
-		}
+
+	slab_lock(page);
+	if (page->freelist == freelist_old &&
+				page->counters == counters_old) {
+		page->freelist = freelist_new;
+		page->counters = counters_new;
 		slab_unlock(page);
+		return 1;
 	}
-
-	cpu_relax();
 	stat(s, CMPXCHG_DOUBLE_FAIL);
-
 #ifdef SLUB_DEBUG_CMPXCHG
 	printk(KERN_INFO "%s %s: cmpxchg double redo ", n, s->name);
 #endif
-
 	return 0;
 }

@@ -398,40 +382,14 @@ static inline bool cmpxchg_double_slab(s
 		void *freelist_new, unsigned long counters_new,
 		const char *n)
 {
-#if defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
-    defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
-	if (s->flags & __CMPXCHG_DOUBLE) {
-		if (cmpxchg_double(&page->freelist, &page->counters,
-			freelist_old, counters_old,
-			freelist_new, counters_new))
-		return 1;
-	} else
-#endif
-	{
-		unsigned long flags;
-
-		local_irq_save(flags);
-		slab_lock(page);
-		if (page->freelist == freelist_old &&
-					page->counters == counters_old) {
-			page->freelist = freelist_new;
-			page->counters = counters_new;
-			slab_unlock(page);
-			local_irq_restore(flags);
-			return 1;
-		}
-		slab_unlock(page);
-		local_irq_restore(flags);
-	}
-
-	cpu_relax();
-	stat(s, CMPXCHG_DOUBLE_FAIL);
-
-#ifdef SLUB_DEBUG_CMPXCHG
-	printk(KERN_INFO "%s %s: cmpxchg double redo ", n, s->name);
-#endif
+	unsigned long flags;
+	int r;

-	return 0;
+	local_irq_save(flags);
+	r = __cmpxchg_double_slab(s, page, freelist_old, counters_old,
+			freelist_new, counters_new, n);
+	local_irq_restore(flags);
+	return r;
 }

 #ifdef CONFIG_SLUB_DEBUG
@@ -3078,13 +3036,6 @@ static int kmem_cache_open(struct kmem_c
 		}
 	}

-#if defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
-    defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
-	if (system_has_cmpxchg_double() && (s->flags & SLAB_DEBUG_FLAGS) == 0)
-		/* Enable fast mode */
-		s->flags |= __CMPXCHG_DOUBLE;
-#endif
-
 	/*
 	 * The larger the object size is, the more pages we want on the partial
 	 * list to avoid pounding the page allocator excessively.
@@ -4608,10 +4559,8 @@ static ssize_t sanity_checks_store(struc
 				const char *buf, size_t length)
 {
 	s->flags &= ~SLAB_DEBUG_FREE;
-	if (buf[0] == '1') {
-		s->flags &= ~__CMPXCHG_DOUBLE;
+	if (buf[0] == '1')
 		s->flags |= SLAB_DEBUG_FREE;
-	}
 	return length;
 }
 SLAB_ATTR(sanity_checks);
@@ -4625,10 +4574,8 @@ static ssize_t trace_store(struct kmem_c
 							size_t length)
 {
 	s->flags &= ~SLAB_TRACE;
-	if (buf[0] == '1') {
-		s->flags &= ~__CMPXCHG_DOUBLE;
+	if (buf[0] == '1')
 		s->flags |= SLAB_TRACE;
-	}
 	return length;
 }
 SLAB_ATTR(trace);
@@ -4645,10 +4592,8 @@ static ssize_t red_zone_store(struct kme
 		return -EBUSY;

 	s->flags &= ~SLAB_RED_ZONE;
-	if (buf[0] == '1') {
-		s->flags &= ~__CMPXCHG_DOUBLE;
+	if (buf[0] == '1')
 		s->flags |= SLAB_RED_ZONE;
-	}
 	calculate_sizes(s, -1);
 	return length;
 }
@@ -4666,10 +4611,8 @@ static ssize_t poison_store(struct kmem_
 		return -EBUSY;

 	s->flags &= ~SLAB_POISON;
-	if (buf[0] == '1') {
-		s->flags &= ~__CMPXCHG_DOUBLE;
+	if (buf[0] == '1')
 		s->flags |= SLAB_POISON;
-	}
 	calculate_sizes(s, -1);
 	return length;
 }
@@ -4687,10 +4630,9 @@ static ssize_t store_user_store(struct k
 		return -EBUSY;

 	s->flags &= ~SLAB_STORE_USER;
-	if (buf[0] == '1') {
-		s->flags &= ~__CMPXCHG_DOUBLE;
+	if (buf[0] == '1')
 		s->flags |= SLAB_STORE_USER;
-	}
+
 	calculate_sizes(s, -1);
 	return length;
 }
Index: linux/arch/Kconfig
===================================================================
--- linux.orig/arch/Kconfig	2014-01-14 13:55:00.611838185 -0600
+++ linux/arch/Kconfig	2014-01-14 13:55:00.601838496 -0600
@@ -289,14 +289,6 @@ config HAVE_RCU_TABLE_FREE
 config ARCH_HAVE_NMI_SAFE_CMPXCHG
 	bool

-config HAVE_ALIGNED_STRUCT_PAGE
-	bool
-	help
-	  This makes sure that struct pages are double word aligned and that
-	  e.g. the SLUB allocator can perform double word atomic operations
-	  on a struct page for better performance. However selecting this
-	  might increase the size of a struct page by a word.
-
 config HAVE_CMPXCHG_LOCAL
 	bool

Index: linux/arch/s390/Kconfig
===================================================================
--- linux.orig/arch/s390/Kconfig	2014-01-14 13:55:00.611838185 -0600
+++ linux/arch/s390/Kconfig	2014-01-14 13:55:00.601838496 -0600
@@ -102,7 +102,6 @@ config S390
 	select GENERIC_FIND_FIRST_BIT
 	select GENERIC_SMP_IDLE_THREAD
 	select GENERIC_TIME_VSYSCALL
-	select HAVE_ALIGNED_STRUCT_PAGE if SLUB
 	select HAVE_ARCH_JUMP_LABEL if !MARCH_G5
 	select HAVE_ARCH_SECCOMP_FILTER
 	select HAVE_ARCH_TRACEHOOK
Index: linux/arch/x86/Kconfig
===================================================================
--- linux.orig/arch/x86/Kconfig	2014-01-14 13:55:00.611838185 -0600
+++ linux/arch/x86/Kconfig	2014-01-14 13:55:00.601838496 -0600
@@ -77,7 +77,6 @@ config X86
 	select HAVE_PERF_USER_STACK_DUMP
 	select HAVE_DEBUG_KMEMLEAK
 	select ANON_INODES
-	select HAVE_ALIGNED_STRUCT_PAGE if SLUB
 	select HAVE_CMPXCHG_LOCAL
 	select HAVE_CMPXCHG_DOUBLE
 	select HAVE_ARCH_KMEMCHECK

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
