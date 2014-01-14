Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 9799C6B0037
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 13:01:30 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id y13so718459pdi.9
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 10:01:30 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id tb5si1159748pac.307.2014.01.14.10.01.28
        for <linux-mm@kvack.org>;
        Tue, 14 Jan 2014 10:01:29 -0800 (PST)
Subject: [RFC][PATCH 2/9] mm: slub: abstract out double cmpxchg option
From: Dave Hansen <dave@sr71.net>
Date: Tue, 14 Jan 2014 10:00:46 -0800
References: <20140114180042.C1C33F78@viggo.jf.intel.com>
In-Reply-To: <20140114180042.C1C33F78@viggo.jf.intel.com>
Message-Id: <20140114180046.C897727E@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, penberg@kernel.org, cl@linux-foundation.org, Dave Hansen <dave@sr71.net>


From: Dave Hansen <dave.hansen@linux.intel.com>

I found this useful to have in my testing.  I would like to have
it available for a bit, at least until other folks have had a
chance to do some testing with it.

We should probably just pull the help text and the description
out of this so that folks are not prompted for it instead of
ripping it out entirely.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/include/linux/mm_types.h |    3 +--
 b/init/Kconfig             |   11 +++++++++++
 b/mm/slub.c                |    9 +++------
 3 files changed, 15 insertions(+), 8 deletions(-)

diff -puN include/linux/mm_types.h~abstract-out-slub-double-cmpxchg-operation include/linux/mm_types.h
--- a/include/linux/mm_types.h~abstract-out-slub-double-cmpxchg-operation	2014-01-14 09:57:56.410635912 -0800
+++ b/include/linux/mm_types.h	2014-01-14 09:57:56.417636226 -0800
@@ -73,8 +73,7 @@ struct page {
 		};
 
 		union {
-#if defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
-	defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
+#if defined(CONFIG_SLUB_ATTEMPT_CMPXCHG_DOUBLE)
 			/* Used for cmpxchg_double in slub */
 			unsigned long counters;
 #else
diff -puN init/Kconfig~abstract-out-slub-double-cmpxchg-operation init/Kconfig
--- a/init/Kconfig~abstract-out-slub-double-cmpxchg-operation	2014-01-14 09:57:56.412636002 -0800
+++ b/init/Kconfig	2014-01-14 09:57:56.418636271 -0800
@@ -1603,6 +1603,17 @@ config SLUB_CPU_PARTIAL
 	  which requires the taking of locks that may cause latency spikes.
 	  Typically one would choose no for a realtime system.
 
+config SLUB_ATTEMPT_CMPXCHG_DOUBLE
+	default y
+	depends on SLUB && HAVE_CMPXCHG_DOUBLE && HAVE_ALIGNED_STRUCT_PAGE
+	bool "SLUB: attempt to use double-cmpxchg operations"
+	help
+	  Some CPUs support instructions that let you do a large double-word
+	  atomic cmpxchg operation.  This keeps the SLUB fastpath from
+	  needing to disable interrupts.
+
+	  If you are unsure, say y.
+
 config MMAP_ALLOW_UNINITIALIZED
 	bool "Allow mmapped anonymous memory to be uninitialized"
 	depends on EXPERT && !MMU
diff -puN mm/slub.c~abstract-out-slub-double-cmpxchg-operation mm/slub.c
--- a/mm/slub.c~abstract-out-slub-double-cmpxchg-operation	2014-01-14 09:57:56.414636092 -0800
+++ b/mm/slub.c	2014-01-14 09:57:56.420636361 -0800
@@ -362,8 +362,7 @@ static inline bool __cmpxchg_double_slab
 		const char *n)
 {
 	VM_BUG_ON(!irqs_disabled());
-#if defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
-    defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
+#if defined(CONFIG_SLUB_ATTEMPT_CMPXCHG_DOUBLE)
 	if (s->flags & __CMPXCHG_DOUBLE) {
 		if (cmpxchg_double(&page->freelist, &page->counters,
 			freelist_old, counters_old,
@@ -398,8 +397,7 @@ static inline bool cmpxchg_double_slab(s
 		void *freelist_new, unsigned long counters_new,
 		const char *n)
 {
-#if defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
-    defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
+#if defined(CONFIG_SLUB_ATTEMPT_CMPXCHG_DOUBLE)
 	if (s->flags & __CMPXCHG_DOUBLE) {
 		if (cmpxchg_double(&page->freelist, &page->counters,
 			freelist_old, counters_old,
@@ -3078,8 +3076,7 @@ static int kmem_cache_open(struct kmem_c
 		}
 	}
 
-#if defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
-    defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
+#if defined(CONFIG_SLUB_ATTEMPT_CMPXCHG_DOUBLE)
 	if (system_has_cmpxchg_double() && (s->flags & SLAB_DEBUG_FLAGS) == 0)
 		/* Enable fast mode */
 		s->flags |= __CMPXCHG_DOUBLE;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
