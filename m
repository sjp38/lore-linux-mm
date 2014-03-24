Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 3F98F6B00A6
	for <linux-mm@kvack.org>; Mon, 24 Mar 2014 07:36:49 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id up15so5338105pbc.20
        for <linux-mm@kvack.org>; Mon, 24 Mar 2014 04:36:48 -0700 (PDT)
Received: from mail-pb0-x232.google.com (mail-pb0-x232.google.com [2607:f8b0:400e:c01::232])
        by mx.google.com with ESMTPS id iw3si9141165pac.219.2014.03.24.04.36.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Mar 2014 04:36:46 -0700 (PDT)
Received: by mail-pb0-f50.google.com with SMTP id md12so5331951pbc.37
        for <linux-mm@kvack.org>; Mon, 24 Mar 2014 04:36:42 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 02/14] vrange: Add purged page detection on setting memory non-volatile
Date: Mon, 24 Mar 2014 20:35:03 +0900
Message-Id: <1395660915-17445-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1395660915-17445-1-git-send-email-minchan@kernel.org>
References: <1395660915-17445-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, John Stultz <john.stultz@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

From: John Stultz <john.stultz@linaro.org>

Users of volatile ranges will need to know if memory was discarded.
This patch adds the purged state tracking required to inform userland
when it marks memory as non-volatile that some memory in that range
was purged and needs to be regenerated.

This simplified implementation which uses some of the logic from
Minchan's earlier efforts, so credit to Minchan for his work.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Android Kernel Team <kernel-team@android.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Robert Love <rlove@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave@sr71.net>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dmitry Adamushko <dmitry.adamushko@gmail.com>
Cc: Neil Brown <neilb@suse.de>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mike Hommey <mh@glandium.org>
Cc: Taras Glek <tglek@mozilla.com>
Cc: Jan Kara <jack@suse.cz>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org <linux-mm@kvack.org>
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 include/linux/swap.h    | 15 ++++++++--
 include/linux/swapops.h | 10 +++++++
 include/linux/vrange.h  |  3 ++
 mm/vrange.c             | 75 +++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 101 insertions(+), 2 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 46ba0c6..18c12f9 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -70,8 +70,19 @@ static inline int current_is_kswapd(void)
 #define SWP_HWPOISON_NUM 0
 #endif
 
-#define MAX_SWAPFILES \
-	((1 << MAX_SWAPFILES_SHIFT) - SWP_MIGRATION_NUM - SWP_HWPOISON_NUM)
+
+/*
+ * Purged volatile range pages
+ */
+#define SWP_VRANGE_PURGED_NUM 1
+#define SWP_VRANGE_PURGED (MAX_SWAPFILES + SWP_HWPOISON_NUM + SWP_MIGRATION_NUM)
+
+
+#define MAX_SWAPFILES ((1 << MAX_SWAPFILES_SHIFT)	\
+				- SWP_MIGRATION_NUM	\
+				- SWP_HWPOISON_NUM	\
+				- SWP_VRANGE_PURGED_NUM	\
+			)
 
 /*
  * Magic header for a swap area. The first part of the union is
diff --git a/include/linux/swapops.h b/include/linux/swapops.h
index c0f7526..84f43d9 100644
--- a/include/linux/swapops.h
+++ b/include/linux/swapops.h
@@ -161,6 +161,16 @@ static inline int is_write_migration_entry(swp_entry_t entry)
 
 #endif
 
+static inline swp_entry_t make_vpurged_entry(void)
+{
+	return swp_entry(SWP_VRANGE_PURGED, 0);
+}
+
+static inline int is_vpurged_entry(swp_entry_t entry)
+{
+	return swp_type(entry) == SWP_VRANGE_PURGED;
+}
+
 #ifdef CONFIG_MEMORY_FAILURE
 /*
  * Support for hardware poisoned pages
diff --git a/include/linux/vrange.h b/include/linux/vrange.h
index 6e5331e..986fa85 100644
--- a/include/linux/vrange.h
+++ b/include/linux/vrange.h
@@ -1,6 +1,9 @@
 #ifndef _LINUX_VRANGE_H
 #define _LINUX_VRANGE_H
 
+#include <linux/swap.h>
+#include <linux/swapops.h>
+
 #define VRANGE_NONVOLATILE 0
 #define VRANGE_VOLATILE 1
 #define VRANGE_VALID_FLAGS (0) /* Don't yet support any flags */
diff --git a/mm/vrange.c b/mm/vrange.c
index 2f8e2ce..1ff3cbd 100644
--- a/mm/vrange.c
+++ b/mm/vrange.c
@@ -8,6 +8,76 @@
 #include <linux/mm_inline.h>
 #include "internal.h"
 
+struct vrange_walker {
+	struct vm_area_struct *vma;
+	int page_was_purged;
+};
+
+
+/**
+ * vrange_check_purged_pte - Checks ptes for purged pages
+ *
+ * Iterates over the ptes in the pmd checking if they have
+ * purged swap entries.
+ *
+ * Sets the vrange_walker.pages_purged to 1 if any were purged.
+ */
+static int vrange_check_purged_pte(pmd_t *pmd, unsigned long addr,
+					unsigned long end, struct mm_walk *walk)
+{
+	struct vrange_walker *vw = walk->private;
+	pte_t *pte;
+	spinlock_t *ptl;
+
+	if (pmd_trans_huge(*pmd))
+		return 0;
+	if (pmd_trans_unstable(pmd))
+		return 0;
+
+	pte = pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
+	for (; addr != end; pte++, addr += PAGE_SIZE) {
+		if (!pte_present(*pte)) {
+			swp_entry_t vrange_entry = pte_to_swp_entry(*pte);
+
+			if (unlikely(is_vpurged_entry(vrange_entry))) {
+				vw->page_was_purged = 1;
+				break;
+			}
+		}
+	}
+	pte_unmap_unlock(pte - 1, ptl);
+	cond_resched();
+
+	return 0;
+}
+
+
+/**
+ * vrange_check_purged - Sets up a mm_walk to check for purged pages
+ *
+ * Sets up and calls wa_page_range() to check for purge pages.
+ *
+ * Returns 1 if pages in the range were purged, 0 otherwise.
+ */
+static int vrange_check_purged(struct mm_struct *mm,
+					 struct vm_area_struct *vma,
+					 unsigned long start,
+					 unsigned long end)
+{
+	struct vrange_walker vw;
+	struct mm_walk vrange_walk = {
+		.pmd_entry = vrange_check_purged_pte,
+		.mm = vma->vm_mm,
+		.private = &vw,
+	};
+	vw.page_was_purged = 0;
+	vw.vma = vma;
+
+	walk_page_range(start, end, &vrange_walk);
+
+	return vw.page_was_purged;
+
+}
 
 /**
  * do_vrange - Marks or clears VMAs in the range (start-end) as VM_VOLATILE
@@ -106,6 +176,11 @@ success:
 		vma = prev->vm_next;
 	}
 out:
+	if (count && (mode == VRANGE_NONVOLATILE))
+		*purged = vrange_check_purged(mm, vma,
+						orig_start,
+						orig_start+count);
+
 	up_read(&mm->mmap_sem);
 
 	/* report bytes successfully marked, even if we're exiting on error */
-- 
1.8.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
