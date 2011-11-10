Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D6FB46B006C
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 09:04:37 -0500 (EST)
Received: from d06nrmr1307.portsmouth.uk.ibm.com (d06nrmr1307.portsmouth.uk.ibm.com [9.149.38.129])
	by mtagate7.uk.ibm.com (8.13.1/8.13.1) with ESMTP id pAAE4UQj029452
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 14:04:30 GMT
Received: from d06av08.portsmouth.uk.ibm.com (d06av08.portsmouth.uk.ibm.com [9.149.37.249])
	by d06nrmr1307.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAAE4UY91855514
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 14:04:30 GMT
Received: from d06av08.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av08.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAAE4R8b019345
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 14:04:28 GMT
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [PATCH 3/3] mm,x86,um: move CMPXCHG_DOUBLE config option
Date: Thu, 10 Nov 2011 15:04:20 +0100
Message-Id: <1320933860-15588-4-git-send-email-heiko.carstens@de.ibm.com>
In-Reply-To: <1320933860-15588-1-git-send-email-heiko.carstens@de.ibm.com>
References: <1320933860-15588-1-git-send-email-heiko.carstens@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jeff Dike <jdike@addtoit.com>, Ingo Molnar <mingo@elte.hu>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Heiko Carstens <heiko.carstens@de.ibm.com>

Move CMPXCHG_DOUBLE and rename it to HAVE_CMPXCHG_DOUBLE so architectures can
simply select the option if it is supported.

Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
---
 arch/Kconfig         |    3 +++
 arch/x86/Kconfig     |    1 +
 arch/x86/Kconfig.cpu |    3 ---
 arch/x86/um/Kconfig  |    4 ----
 mm/slub.c            |    9 ++++++---
 5 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index f5e749b..a5d7e7a 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -192,4 +192,7 @@ config HAVE_ALIGNED_STRUCT_PAGE
 config HAVE_CMPXCHG_LOCAL
 	bool
 
+config HAVE_CMPXCHG_DOUBLE
+	bool
+
 source "kernel/gcov/Kconfig"
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 71aebf5..6f38b61 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -77,6 +77,7 @@ config X86
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
 	select HAVE_ALIGNED_STRUCT_PAGE if SLUB && !M386
 	select HAVE_CMPXCHG_LOCAL if !M386
+	select HAVE_CMPXCHG_DOUBLE
 
 config INSTRUCTION_DECODER
 	def_bool (KPROBES || PERF_EVENTS)
diff --git a/arch/x86/Kconfig.cpu b/arch/x86/Kconfig.cpu
index 99d2ab8..3c57033 100644
--- a/arch/x86/Kconfig.cpu
+++ b/arch/x86/Kconfig.cpu
@@ -309,9 +309,6 @@ config X86_INTERNODE_CACHE_SHIFT
 config X86_CMPXCHG
 	def_bool X86_64 || (X86_32 && !M386)
 
-config CMPXCHG_DOUBLE
-	def_bool y
-
 config X86_L1_CACHE_SHIFT
 	int
 	default "7" if MPENTIUM4 || MPSC
diff --git a/arch/x86/um/Kconfig b/arch/x86/um/Kconfig
index a62bfc6..b2b54d2 100644
--- a/arch/x86/um/Kconfig
+++ b/arch/x86/um/Kconfig
@@ -6,10 +6,6 @@ menu "UML-specific options"
 
 menu "Host processor type and features"
 
-config CMPXCHG_DOUBLE
-	bool
-	default n
-
 source "arch/x86/Kconfig.cpu"
 
 endmenu
diff --git a/mm/slub.c b/mm/slub.c
index 7669b4c..7fd4e00 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -366,7 +366,8 @@ static inline bool __cmpxchg_double_slab(struct kmem_cache *s, struct page *page
 		const char *n)
 {
 	VM_BUG_ON(!irqs_disabled());
-#if defined(CONFIG_CMPXCHG_DOUBLE) && defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
+#if defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
+    defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
 	if (s->flags & __CMPXCHG_DOUBLE) {
 		if (cmpxchg_double(&page->freelist,
 			freelist_old, counters_old,
@@ -400,7 +401,8 @@ static inline bool cmpxchg_double_slab(struct kmem_cache *s, struct page *page,
 		void *freelist_new, unsigned long counters_new,
 		const char *n)
 {
-#if defined(CONFIG_CMPXCHG_DOUBLE) && defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
+#if defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
+    defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
 	if (s->flags & __CMPXCHG_DOUBLE) {
 		if (cmpxchg_double(&page->freelist,
 			freelist_old, counters_old,
@@ -2990,7 +2992,8 @@ static int kmem_cache_open(struct kmem_cache *s,
 		}
 	}
 
-#if defined(CONFIG_CMPXCHG_DOUBLE) && defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
+#if defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
+    defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
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
