Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 8B6A96B004D
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 11:03:55 -0500 (EST)
From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH repost] mm,x86: remove debug_pagealloc_enabled
Date: Tue, 29 Nov 2011 17:05:11 +0100
Message-Id: <1322582711-14571-1-git-send-email-sgruszka@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, x86@kernel.org
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Stanislaw Gruszka <sgruszka@redhat.com>

When (no)bootmem finish operation, it pass pages to buddy allocator.
Since debug_pagealloc_enabled is not set, we will do not protect pages,
what is not what we want with CONFIG_DEBUG_PAGEALLOC=y.

To fix remove debug_pagealloc_enabled. That variable was introduced by
commit 12d6f21e "x86: do not PSE on CONFIG_DEBUG_PAGEALLOC=y" to get
more CPA (change page attribude) code testing. But currently we have
CONFIG_CPA_DEBUG, which test CPA.

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
Acked-by: Mel Gorman <mgorman@suse.de>
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
