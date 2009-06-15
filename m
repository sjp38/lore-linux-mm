From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 03/22] HWPOISON: Add support for poison swap entries v2
Date: Mon, 15 Jun 2009 10:45:23 +0800
Message-ID: <20090615031252.669979630@intel.com>
References: <20090615024520.786814520@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2032F6B004F
	for <linux-mm@kvack.org>; Sun, 14 Jun 2009 23:14:27 -0400 (EDT)
Content-Disposition: inline; filename=poison-swp-entry
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, "Wu, Fengguang" <fengguang.wu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

From: Andi Kleen <ak@linux.intel.com>

Memory migration uses special swap entry types to trigger special actions on 
page faults. Extend this mechanism to also support poisoned swap entries, to 
trigger poison handling on page faults. This allows follow-on patches to 
prevent processes from faulting in poisoned pages again.

v2: Fix overflow in MAX_SWAPFILES (Fengguang Wu)
v3: Better overflow fix (Hidehiro Kawai)

Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
Reviewed-by: Hidehiro Kawai <hidehiro.kawai.ez@hitachi.com>
Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 include/linux/swap.h    |   34 ++++++++++++++++++++++++++++------
 include/linux/swapops.h |   38 ++++++++++++++++++++++++++++++++++++++
 mm/swapfile.c           |    4 ++--
 3 files changed, 68 insertions(+), 8 deletions(-)

--- sound-2.6.orig/include/linux/swap.h
+++ sound-2.6/include/linux/swap.h
@@ -34,16 +34,38 @@ static inline int current_is_kswapd(void
  * the type/offset into the pte as 5/27 as well.
  */
 #define MAX_SWAPFILES_SHIFT	5
-#ifndef CONFIG_MIGRATION
-#define MAX_SWAPFILES		(1 << MAX_SWAPFILES_SHIFT)
+
+/*
+ * Use some of the swap files numbers for other purposes. This
+ * is a convenient way to hook into the VM to trigger special
+ * actions on faults.
+ */
+
+/*
+ * NUMA node memory migration support
+ */
+#ifdef CONFIG_MIGRATION
+#define SWP_MIGRATION_NUM 2
+#define SWP_MIGRATION_READ	(MAX_SWAPFILES + SWP_HWPOISON_NUM)
+#define SWP_MIGRATION_WRITE	(MAX_SWAPFILES + SWP_HWPOISON_NUM + 1)
 #else
-/* Use last two entries for page migration swap entries */
-#define MAX_SWAPFILES		((1 << MAX_SWAPFILES_SHIFT)-2)
-#define SWP_MIGRATION_READ	MAX_SWAPFILES
-#define SWP_MIGRATION_WRITE	(MAX_SWAPFILES + 1)
+#define SWP_MIGRATION_NUM 0
 #endif
 
 /*
+ * Handling of hardware poisoned pages with memory corruption.
+ */
+#ifdef CONFIG_MEMORY_FAILURE
+#define SWP_HWPOISON_NUM 1
+#define SWP_HWPOISON		MAX_SWAPFILES
+#else
+#define SWP_HWPOISON_NUM 0
+#endif
+
+#define MAX_SWAPFILES \
+	((1 << MAX_SWAPFILES_SHIFT) - SWP_MIGRATION_NUM - SWP_HWPOISON_NUM)
+
+/*
  * Magic header for a swap area. The first part of the union is
  * what the swap magic looks like for the old (limited to 128MB)
  * swap area format, the second part of the union adds - in the
--- sound-2.6.orig/include/linux/swapops.h
+++ sound-2.6/include/linux/swapops.h
@@ -131,3 +131,41 @@ static inline int is_write_migration_ent
 
 #endif
 
+#ifdef CONFIG_MEMORY_FAILURE
+/*
+ * Support for hardware poisoned pages
+ */
+static inline swp_entry_t make_hwpoison_entry(struct page *page)
+{
+	BUG_ON(!PageLocked(page));
+	return swp_entry(SWP_HWPOISON, page_to_pfn(page));
+}
+
+static inline int is_hwpoison_entry(swp_entry_t entry)
+{
+	return swp_type(entry) == SWP_HWPOISON;
+}
+#else
+
+static inline swp_entry_t make_hwpoison_entry(struct page *page)
+{
+	return swp_entry(0, 0);
+}
+
+static inline int is_hwpoison_entry(swp_entry_t swp)
+{
+	return 0;
+}
+#endif
+
+#if defined(CONFIG_MEMORY_FAILURE) || defined(CONFIG_MIGRATION)
+static inline int non_swap_entry(swp_entry_t entry)
+{
+	return swp_type(entry) >= MAX_SWAPFILES;
+}
+#else
+static inline int non_swap_entry(swp_entry_t entry)
+{
+	return 0;
+}
+#endif
--- sound-2.6.orig/mm/swapfile.c
+++ sound-2.6/mm/swapfile.c
@@ -697,7 +697,7 @@ int free_swap_and_cache(swp_entry_t entr
 	struct swap_info_struct *p;
 	struct page *page = NULL;
 
-	if (is_migration_entry(entry))
+	if (non_swap_entry(entry))
 		return 1;
 
 	p = swap_info_get(entry);
@@ -2083,7 +2083,7 @@ static int __swap_duplicate(swp_entry_t 
 	int count;
 	bool has_cache;
 
-	if (is_migration_entry(entry))
+	if (non_swap_entry(entry))
 		return -EINVAL;
 
 	type = swp_type(entry);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
