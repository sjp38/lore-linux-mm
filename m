Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id E98446B002D
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 07:35:37 -0500 (EST)
From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH 1/4] mm: remove debug_pagealloc_enabled
Date: Fri, 11 Nov 2011 13:36:31 +0100
Message-Id: <1321014994-2426-1-git-send-email-sgruszka@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Christoph Lameter <cl@linux-foundation.org>, Stanislaw Gruszka <sgruszka@redhat.com>

After we finish (no)bootmem, pages are passed to buddy allocator. Since
debug_pagealloc_enabled is not set, we do not protect pages, what is
not what we want with CONFIG_DEBUG_PAGEALLOC=y. That could be fixed by
calling enable_debug_pagealloc() before free_all_bootmem(), but actually
I do not see any reason why we need that global variable. Hence patch
remove it.

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 arch/x86/mm/pageattr.c |    6 ------
 include/linux/mm.h     |   10 ----------
 init/main.c            |    5 -----
 mm/debug-pagealloc.c   |    3 ---
 4 files changed, 0 insertions(+), 24 deletions(-)

diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index f9e5267..5031eef 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -1334,12 +1334,6 @@ void kernel_map_pages(struct page *page, int numpages, int enable)
 	}
 
 	/*
-	 * If page allocator is not up yet then do not call c_p_a():
-	 */
-	if (!debug_pagealloc_enabled)
-		return;
-
-	/*
 	 * The return value is ignored as the calls cannot fail.
 	 * Large pages for identity mappings are not used at boot time
 	 * and hence no memory allocations during large page split.
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 3dc3a8c..0a22db1 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1537,23 +1537,13 @@ static inline void vm_stat_account(struct mm_struct *mm,
 #endif /* CONFIG_PROC_FS */
 
 #ifdef CONFIG_DEBUG_PAGEALLOC
-extern int debug_pagealloc_enabled;
-
 extern void kernel_map_pages(struct page *page, int numpages, int enable);
-
-static inline void enable_debug_pagealloc(void)
-{
-	debug_pagealloc_enabled = 1;
-}
 #ifdef CONFIG_HIBERNATION
 extern bool kernel_page_present(struct page *page);
 #endif /* CONFIG_HIBERNATION */
 #else
 static inline void
 kernel_map_pages(struct page *page, int numpages, int enable) {}
-static inline void enable_debug_pagealloc(void)
-{
-}
 #ifdef CONFIG_HIBERNATION
 static inline bool kernel_page_present(struct page *page) { return true; }
 #endif /* CONFIG_HIBERNATION */
diff --git a/init/main.c b/init/main.c
index 217ed23..99c4ba3 100644
--- a/init/main.c
+++ b/init/main.c
@@ -282,10 +282,6 @@ static int __init unknown_bootoption(char *param, char *val)
 	return 0;
 }
 
-#ifdef CONFIG_DEBUG_PAGEALLOC
-int __read_mostly debug_pagealloc_enabled = 0;
-#endif
-
 static int __init init_setup(char *str)
 {
 	unsigned int i;
@@ -597,7 +593,6 @@ asmlinkage void __init start_kernel(void)
 	}
 #endif
 	page_cgroup_init();
-	enable_debug_pagealloc();
 	debug_objects_mem_init();
 	kmemleak_init();
 	setup_per_cpu_pageset();
diff --git a/mm/debug-pagealloc.c b/mm/debug-pagealloc.c
index 7cea557..789ff70 100644
--- a/mm/debug-pagealloc.c
+++ b/mm/debug-pagealloc.c
@@ -95,9 +95,6 @@ static void unpoison_pages(struct page *page, int n)
 
 void kernel_map_pages(struct page *page, int numpages, int enable)
 {
-	if (!debug_pagealloc_enabled)
-		return;
-
 	if (enable)
 		unpoison_pages(page, numpages);
 	else
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
