Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 43B406B0070
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 09:05:19 -0500 (EST)
Received: from d06nrmr1707.portsmouth.uk.ibm.com (d06nrmr1707.portsmouth.uk.ibm.com [9.149.39.225])
	by mtagate1.uk.ibm.com (8.13.1/8.13.1) with ESMTP id pAAE5Efo000727
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 14:05:14 GMT
Received: from d06av10.portsmouth.uk.ibm.com (d06av10.portsmouth.uk.ibm.com [9.149.37.251])
	by d06nrmr1707.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAAE5Ee82482304
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 14:05:14 GMT
Received: from d06av10.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av10.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAAE4R6M015550
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 07:04:28 -0700
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [PATCH 1/3] mm,slub,x86: decouple size of struct page from CONFIG_CMPXCHG_LOCAL
Date: Thu, 10 Nov 2011 15:04:18 +0100
Message-Id: <1320933860-15588-2-git-send-email-heiko.carstens@de.ibm.com>
In-Reply-To: <1320933860-15588-1-git-send-email-heiko.carstens@de.ibm.com>
References: <1320933860-15588-1-git-send-email-heiko.carstens@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jeff Dike <jdike@addtoit.com>, Ingo Molnar <mingo@elte.hu>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Heiko Carstens <heiko.carstens@de.ibm.com>

If an architecture supports CMPXCHG_LOCAL this shouldn't result automatically
in larger struct pages if the SLUB allocator is used. Instead introduce a new
config option "HAVE_ALIGNED_STRUCT_PAGE" which can be selected if a double
word aligned struct page is required.
Also update x86 Kconfig so that it should work as before.

Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
---
 arch/Kconfig             |    8 ++++++++
 arch/x86/Kconfig         |    1 +
 include/linux/mm_types.h |    9 ++++-----
 mm/slub.c                |    6 +++---
 4 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index 4b0669c..4b4a140 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -181,4 +181,12 @@ config HAVE_RCU_TABLE_FREE
 config ARCH_HAVE_NMI_SAFE_CMPXCHG
 	bool
 
+config HAVE_ALIGNED_STRUCT_PAGE
+	bool
+	help
+	  This makes sure that struct pages are double word aligned and that
+	  e.g. the SLUB allocator can perform double word atomic operations
+	  on a struct page for better performance. However selecting this
+	  might increase the size of a struct page by a word.
+
 source "kernel/gcov/Kconfig"
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index cb9a104..5115ce4 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -75,6 +75,7 @@ config X86
 	select HAVE_BPF_JIT if (X86_64 && NET)
 	select CLKEVT_I8253
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
+	select HAVE_ALIGNED_STRUCT_PAGE if SLUB && !M386
 
 config INSTRUCTION_DECODER
 	def_bool (KPROBES || PERF_EVENTS)
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 5b42f1b..3cc3062 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -151,12 +151,11 @@ struct page {
 #endif
 }
 /*
- * If another subsystem starts using the double word pairing for atomic
- * operations on struct page then it must change the #if to ensure
- * proper alignment of the page struct.
+ * The struct page can be forced to be double word aligned so that atomic ops
+ * on double words work. The SLUB allocator can make use of such a feature.
  */
-#if defined(CONFIG_SLUB) && defined(CONFIG_CMPXCHG_LOCAL)
-	__attribute__((__aligned__(2*sizeof(unsigned long))))
+#ifdef CONFIG_HAVE_ALIGNED_STRUCT_PAGE
+	__aligned(2 * sizeof(unsigned long))
 #endif
 ;
 
diff --git a/mm/slub.c b/mm/slub.c
index 7d2a996..7669b4c 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -366,7 +366,7 @@ static inline bool __cmpxchg_double_slab(struct kmem_cache *s, struct page *page
 		const char *n)
 {
 	VM_BUG_ON(!irqs_disabled());
-#ifdef CONFIG_CMPXCHG_DOUBLE
+#if defined(CONFIG_CMPXCHG_DOUBLE) && defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
 	if (s->flags & __CMPXCHG_DOUBLE) {
 		if (cmpxchg_double(&page->freelist,
 			freelist_old, counters_old,
@@ -400,7 +400,7 @@ static inline bool cmpxchg_double_slab(struct kmem_cache *s, struct page *page,
 		void *freelist_new, unsigned long counters_new,
 		const char *n)
 {
-#ifdef CONFIG_CMPXCHG_DOUBLE
+#if defined(CONFIG_CMPXCHG_DOUBLE) && defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
 	if (s->flags & __CMPXCHG_DOUBLE) {
 		if (cmpxchg_double(&page->freelist,
 			freelist_old, counters_old,
@@ -2990,7 +2990,7 @@ static int kmem_cache_open(struct kmem_cache *s,
 		}
 	}
 
-#ifdef CONFIG_CMPXCHG_DOUBLE
+#if defined(CONFIG_CMPXCHG_DOUBLE) && defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
 	if (system_has_cmpxchg_double() && (s->flags & SLAB_DEBUG_FLAGS) == 0)
 		/* Enable fast mode */
 		s->flags |= __CMPXCHG_DOUBLE;
-- 
1.7.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
