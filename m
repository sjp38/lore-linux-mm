Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 9C1646B003D
	for <linux-mm@kvack.org>; Fri,  3 Jan 2014 13:02:14 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id v10so15536058pde.41
        for <linux-mm@kvack.org>; Fri, 03 Jan 2014 10:02:14 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id eb3si46443688pbc.116.2014.01.03.10.02.12
        for <linux-mm@kvack.org>;
        Fri, 03 Jan 2014 10:02:13 -0800 (PST)
Subject: [PATCH 8/9] mm: slub: remove 'struct page' alignment restrictions
From: Dave Hansen <dave@sr71.net>
Date: Fri, 03 Jan 2014 10:02:02 -0800
References: <20140103180147.6566F7C1@viggo.jf.intel.com>
In-Reply-To: <20140103180147.6566F7C1@viggo.jf.intel.com>
Message-Id: <20140103180202.DE1B5842@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, penberg@kernel.org, cl@linux-foundation.org, Dave Hansen <dave@sr71.net>


From: Dave Hansen <dave.hansen@linux.intel.com>

SLUB depends on a 16-byte cmpxchg for an optimization.  In order
to get guaranteed 16-byte alignment (required by the hardware on
x86), 'struct page' is padded out from 56 to 64 bytes.

Those 8-bytes matter.  We've gone to great lengths to keep
'struct page' small in the past.  It's a shame that we bloat it
now just for alignment reasons when we have *extra* space.  Also,
increasing the size of 'struct page' by 14% makes it 14% more
likely that we will miss a cacheline when fetching it.

This patch takes an unused 8-byte area of slub's 'struct page'
and reuses it to internally align to the 16-bytes that we need.

Note that this also gets rid of the ugly slub #ifdef that we use
to segregate ->counters and ->_count for cases where we need to
manipulate ->counters without the benefit of a hardware cmpxchg.

This patch takes me from 16909584K of reserved memory at boot
down to 14814472K, so almost *exactly* 2GB of savings!  It also
helps performance, presumably because of that 14% fewer
cacheline effect.  A 30GB dd to a ramfs file:

	dd if=/dev/zero of=bigfile bs=$((1<<30)) count=30

is sped up by about 4.4% in my testing.

The value of maintaining the cmpxchg16 operation can be
demonstrated in some tiny little microbenchmarks, so it is
probably something we should keep around instead of just using
the spinlock for everything:

	http://lkml.kernel.org/r/52B345A3.6090700@sr71.net

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 linux.git-davehans/arch/Kconfig             |    8 ----
 linux.git-davehans/arch/s390/Kconfig        |    1 
 linux.git-davehans/arch/x86/Kconfig         |    1 
 linux.git-davehans/include/linux/mm_types.h |   55 +++++++---------------------
 linux.git-davehans/init/Kconfig             |    2 -
 linux.git-davehans/mm/slab_common.c         |   10 +++--
 linux.git-davehans/mm/slub.c                |    4 ++
 7 files changed, 26 insertions(+), 55 deletions(-)

diff -puN arch/Kconfig~remove-struct-page-alignment-restrictions arch/Kconfig
--- linux.git/arch/Kconfig~remove-struct-page-alignment-restrictions	2014-01-02 14:56:39.071044198 -0800
+++ linux.git-davehans/arch/Kconfig	2014-01-02 14:56:39.086044872 -0800
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
 
diff -puN arch/s390/Kconfig~remove-struct-page-alignment-restrictions arch/s390/Kconfig
--- linux.git/arch/s390/Kconfig~remove-struct-page-alignment-restrictions	2014-01-02 14:56:39.073044287 -0800
+++ linux.git-davehans/arch/s390/Kconfig	2014-01-02 14:56:39.087044917 -0800
@@ -102,7 +102,6 @@ config S390
 	select GENERIC_FIND_FIRST_BIT
 	select GENERIC_SMP_IDLE_THREAD
 	select GENERIC_TIME_VSYSCALL
-	select HAVE_ALIGNED_STRUCT_PAGE if SLUB
 	select HAVE_ARCH_JUMP_LABEL if !MARCH_G5
 	select HAVE_ARCH_SECCOMP_FILTER
 	select HAVE_ARCH_SECCOMP
diff -puN arch/x86/Kconfig~remove-struct-page-alignment-restrictions arch/x86/Kconfig
--- linux.git/arch/x86/Kconfig~remove-struct-page-alignment-restrictions	2014-01-02 14:56:39.075044377 -0800
+++ linux.git-davehans/arch/x86/Kconfig	2014-01-02 14:56:39.088044962 -0800
@@ -77,7 +77,6 @@ config X86
 	select HAVE_PERF_USER_STACK_DUMP
 	select HAVE_DEBUG_KMEMLEAK
 	select ANON_INODES
-	select HAVE_ALIGNED_STRUCT_PAGE if SLUB
 	select HAVE_CMPXCHG_LOCAL
 	select HAVE_ARCH_KMEMCHECK
 	select HAVE_USER_RETURN_NOTIFIER
diff -puN include/linux/mm_types.h~remove-struct-page-alignment-restrictions include/linux/mm_types.h
--- linux.git/include/linux/mm_types.h~remove-struct-page-alignment-restrictions	2014-01-02 14:56:39.076044423 -0800
+++ linux.git-davehans/include/linux/mm_types.h	2014-01-02 14:56:39.089045007 -0800
@@ -24,38 +24,30 @@
 struct address_space;
 
 struct slub_data {
-	void *unused;
 	void *freelist;
 	union {
 		struct {
 			unsigned inuse:16;
 			unsigned objects:15;
 			unsigned frozen:1;
-			atomic_t dontuse_slub_count;
 		};
-		/*
-		 * ->counters is used to make it easier to copy
-		 * all of the above counters in one chunk.
-		 * The actual counts are never accessed via this.
-		 */
-#if defined(CONFIG_SLUB_ATTEMPT_CMPXCHG_DOUBLE)
-		unsigned long counters;
-#else
-		/*
-		 * Keep _count separate from slub cmpxchg_double data.
-		 * As the rest of the double word is protected by
-		 * slab_lock but _count is not.
-		 */
 		struct {
-			unsigned counters;
-			/*
-			 * This isn't used directly, but declare it here
-			 * for clarity since it must line up with _count
-			 * from 'struct page'
-			 */
+			/* counters is just a helperfor the above bitfield */
+			unsigned long counters;
+			atomic_t padding;
 			atomic_t separate_count;
 		};
-#endif
+		/*
+		 * the double-cmpxchg case:
+		 * counters and _count overlap:
+		 */
+		union {
+			unsigned long counters2;
+			struct {
+				atomic_t padding2;
+				atomic_t _count;
+			};
+		};
 	};
 };
 
@@ -70,15 +62,8 @@ struct slub_data {
  * moment. Note that we have no way to track which tasks are using
  * a page, though if it is a pagecache page, rmap structures can tell us
  * who is mapping it.
- *
- * The objects in struct page are organized in double word blocks in
- * order to allows us to use atomic double word operations on portions
- * of struct page. That is currently only used by slub but the arrangement
- * allows the use of atomic double word operations on the flags/mapping
- * and lru list pointers also.
  */
 struct page {
-	/* First double word block */
 	unsigned long flags;		/* Atomic flags, some possibly
 					 * updated asynchronously */
 	union {
@@ -121,7 +106,6 @@ struct page {
 		};
 	};
 
-	/* Third double word block */
 	union {
 		struct list_head lru;	/* Pageout list, eg. active_list
 					 * protected by zone->lru_lock !
@@ -150,7 +134,6 @@ struct page {
 #endif
 	};
 
-	/* Remainder is not double word aligned */
 	union {
 		unsigned long private;		/* Mapping-private opaque data:
 					 	 * usually used for buffer_heads
@@ -199,15 +182,7 @@ struct page {
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
diff -puN init/Kconfig~remove-struct-page-alignment-restrictions init/Kconfig
--- linux.git/init/Kconfig~remove-struct-page-alignment-restrictions	2014-01-02 14:56:39.078044513 -0800
+++ linux.git-davehans/init/Kconfig	2014-01-02 14:56:39.090045052 -0800
@@ -841,7 +841,7 @@ config SLUB_CPU_PARTIAL
 
 config SLUB_ATTEMPT_CMPXCHG_DOUBLE
 	default y
-	depends on SLUB && HAVE_CMPXCHG_DOUBLE && HAVE_ALIGNED_STRUCT_PAGE
+	depends on SLUB && HAVE_CMPXCHG_DOUBLE
 	bool "SLUB: attempt to use double-cmpxchg operations"
 	help
 	  Some CPUs support instructions that let you do a large double-word
diff -puN mm/slab_common.c~remove-struct-page-alignment-restrictions mm/slab_common.c
--- linux.git/mm/slab_common.c~remove-struct-page-alignment-restrictions	2014-01-02 14:56:39.080044602 -0800
+++ linux.git-davehans/mm/slab_common.c	2014-01-02 14:56:39.090045052 -0800
@@ -674,7 +674,6 @@ module_init(slab_proc_init);
 void slab_build_checks(void)
 {
 	SLAB_PAGE_CHECK(_count, dontuse_slab_count);
-	SLAB_PAGE_CHECK(_count, slub_data.dontuse_slub_count);
 	SLAB_PAGE_CHECK(_count, dontuse_slob_count);
 
 	/*
@@ -688,9 +687,12 @@ void slab_build_checks(void)
 	 * carve out for _count in that case actually lines up
 	 * with the real _count.
 	 */
-#if !(defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
-	    defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE))
 	SLAB_PAGE_CHECK(_count, slub_data.separate_count);
-#endif
+
+	/*
+	 * We need at least three double-words worth of space to
+	 * ensure that we can align to a double-wordk internally.
+	 */
+	BUILD_BUG_ON(sizeof(struct slub_data) != sizeof(unsigned long) * 3);
 }
 
diff -puN mm/slub.c~remove-struct-page-alignment-restrictions mm/slub.c
--- linux.git/mm/slub.c~remove-struct-page-alignment-restrictions	2014-01-02 14:56:39.082044693 -0800
+++ linux.git-davehans/mm/slub.c	2014-01-02 14:56:39.092045142 -0800
@@ -239,7 +239,11 @@ static inline struct kmem_cache_node *ge
 
 static inline struct slub_data *slub_data(struct page *page)
 {
+	int doubleword_bytes = BITS_PER_LONG * 2 / 8;
 	void *ptr = &page->slub_data;
+#if defined(CONFIG_SLUB_ATTEMPT_CMPXCHG_DOUBLE)
+	ptr = PTR_ALIGN(ptr, doubleword_bytes);
+#endif
 	return ptr;
 }
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
