Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id CDE054402ED
	for <linux-mm@kvack.org>; Thu, 17 Dec 2015 13:16:13 -0500 (EST)
Received: by mail-pf0-f179.google.com with SMTP id o64so34737536pfb.3
        for <linux-mm@kvack.org>; Thu, 17 Dec 2015 10:16:13 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id z12si17834228pas.77.2015.12.17.10.16.12
        for <linux-mm@kvack.org>;
        Thu, 17 Dec 2015 10:16:12 -0800 (PST)
From: Dave Gordon <david.s.gordon@intel.com>
Subject: [PATCH v3] mm: Export {__}get_nr_swap_pages()
Date: Thu, 17 Dec 2015 18:15:44 +0000
Message-Id: <1450376144-32792-1-git-send-email-david.s.gordon@intel.com>
References: <1449244734-25733-1-git-send-email-chris@chris-wilson.co.uk>
References: <20151208112225.GB25800@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: intel-gfx@lists.freedesktop.org
Cc: Dave Gordon <david.s.gordon@intel.com>, Chris Wilson <chris@chris-wilson.co.uk>, "Goel, Akash" <akash.goel@intel.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

Some modules, like i915.ko, use swappable objects and may try to swap
them out under memory pressure (via the shrinker). Before doing so,
they want to check using get_nr_swap_pages() to see if any swap space
is available as otherwise they will waste time purging the object from
the device without recovering any memory for the system. This requires
the kernel function get_nr_swap_pages() to be exported to the modules.

The current implementation of this function is as a static inline
inside the header file swap.h>; this doesn't work when compiled in
a module, as the necessary global data is not visible. The original
proposed solution was to export the kernel global variable to modules,
but this was considered poor practice as it exposed more than necessary,
and in an uncontrolled fashion. Another idea was to turn it into a real
(non-inline) function; however this was considered to unnecessarily add
overhead for users within the base kernel.

Therefore, to avoid both objections, this patch leaves the base kernel
implementation unchanged, but adds a separate (read-only) functional
interface for callers in loadable kernel modules (LKMs). Which definition
is visible to code depends on the compile-time symbol MODULE, defined
by the Kbuild system when building an LKM.

Signed-off-by: Dave Gordon <david.s.gordon@intel.com>
Cc: Chris Wilson <chris@chris-wilson.co.uk>
Cc: "Goel, Akash" <akash.goel@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org
Cc: intel-gfx@lists.freedesktop.org
---
 include/linux/swap.h | 12 ++++++++++++
 mm/swapfile.c        |  7 +++++++
 2 files changed, 19 insertions(+)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 7ba7dcc..7dac1fe 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -413,6 +413,10 @@ extern struct page *swapin_readahead(swp_entry_t, gfp_t,
 			struct vm_area_struct *vma, unsigned long addr);
 
 /* linux/mm/swapfile.c */
+
+#ifndef	MODULE
+
+/* Inside the base kernel, code can see these variables */
 extern atomic_long_t nr_swap_pages;
 extern long total_swap_pages;
 
@@ -427,6 +431,14 @@ static inline long get_nr_swap_pages(void)
 	return atomic_long_read(&nr_swap_pages);
 }
 
+#else	/* MODULE */
+
+/* Only this read-only interface is available to modules */
+extern long __get_nr_swap_pages(void);
+#define	get_nr_swap_pages	__get_nr_swap_pages
+
+#endif	/* MODULE */
+
 extern void si_swapinfo(struct sysinfo *);
 extern swp_entry_t get_swap_page(void);
 extern swp_entry_t get_swap_page_of_type(int);
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 5887731..9309d6e 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2754,6 +2754,13 @@ pgoff_t __page_file_index(struct page *page)
 }
 EXPORT_SYMBOL_GPL(__page_file_index);
 
+/* Trivial accessor exported to kernel modules */
+long __get_nr_swap_pages(void)
+{
+	return get_nr_swap_pages();
+}
+EXPORT_SYMBOL_GPL(__get_nr_swap_pages);
+
 /*
  * add_swap_count_continuation - called when a swap count is duplicated
  * beyond SWAP_MAP_MAX, it allocates a new page and links that to the entry's
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
