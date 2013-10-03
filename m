Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 85F316B0062
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 20:52:27 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id wz12so1652333pbc.25
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 17:52:27 -0700 (PDT)
Received: by mail-pb0-f51.google.com with SMTP id jt11so1663603pbb.24
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 17:52:24 -0700 (PDT)
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 11/14] vrange: Purging vrange-anon pages from shrinker
Date: Wed,  2 Oct 2013 17:51:40 -0700
Message-Id: <1380761503-14509-12-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1380761503-14509-1-git-send-email-john.stultz@linaro.org>
References: <1380761503-14509-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dhaval.giani@gmail.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Rob Clark <robdclark@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, John Stultz <john.stultz@linaro.org>

From: Minchan Kim <minchan@kernel.org>

This patch provides the logic to discard anonymous
vranges from the shrinker, by generating the page list
for the volatile ranges setting the ptes volatile, and
discarding the pages.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Android Kernel Team <kernel-team@android.com>
Cc: Robert Love <rlove@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dmitry Adamushko <dmitry.adamushko@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Neil Brown <neilb@suse.de>
Cc: Andrea Righi <andrea@betterlinux.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Cc: Mike Hommey <mh@glandium.org>
Cc: Taras Glek <tglek@mozilla.com>
Cc: Dhaval Giani <dhaval.giani@gmail.com>
Cc: Jan Kara <jack@suse.cz>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Rob Clark <robdclark@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org <linux-mm@kvack.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
[jstultz: Code tweaks and commit log rewording]
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 mm/vrange.c | 179 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 178 insertions(+), 1 deletion(-)

diff --git a/mm/vrange.c b/mm/vrange.c
index e7c5a25..c6bc32f 100644
--- a/mm/vrange.c
+++ b/mm/vrange.c
@@ -11,6 +11,8 @@
 #include <linux/hugetlb.h>
 #include "internal.h"
 #include <linux/mmu_notifier.h>
+#include <linux/mm_inline.h>
+#include <linux/migrate.h>
 
 static struct kmem_cache *vrange_cachep;
 
@@ -20,6 +22,11 @@ static struct vrange_list {
 	struct mutex lock;
 } vrange_list;
 
+struct vrange_walker {
+	struct vm_area_struct *vma;
+	struct list_head *pagelist;
+};
+
 static inline unsigned int vrange_size(struct vrange *range)
 {
 	return range->node.last + 1 - range->node.start;
@@ -690,11 +697,181 @@ static struct vrange *vrange_isolate(void)
 	return vrange;
 }
 
-static unsigned int discard_vrange(struct vrange *vrange)
+static unsigned int discard_vrange_pagelist(struct list_head *page_list)
+{
+	struct page *page;
+	unsigned int nr_discard = 0;
+	LIST_HEAD(ret_pages);
+	LIST_HEAD(free_pages);
+
+	while (!list_empty(page_list)) {
+		int err;
+		page = list_entry(page_list->prev, struct page, lru);
+		list_del(&page->lru);
+		if (!trylock_page(page)) {
+			list_add(&page->lru, &ret_pages);
+			continue;
+		}
+
+		/*
+		 * discard_vpage returns unlocked page if it
+		 * is successful
+		 */
+		err = discard_vpage(page);
+		if (err) {
+			unlock_page(page);
+			list_add(&page->lru, &ret_pages);
+			continue;
+		}
+
+		ClearPageActive(page);
+		list_add(&page->lru, &free_pages);
+		dec_zone_page_state(page, NR_ISOLATED_ANON);
+		nr_discard++;
+	}
+
+	free_hot_cold_page_list(&free_pages, 1);
+	list_splice(&ret_pages, page_list);
+	return nr_discard;
+}
+
+static void vrange_pte_entry(pte_t pteval, unsigned long address,
+		unsigned ptent_size, struct mm_walk *walk)
+{
+	struct page *page;
+	struct vrange_walker *vw = walk->private;
+	struct vm_area_struct *vma = vw->vma;
+	struct list_head *pagelist = vw->pagelist;
+
+	if (pte_none(pteval))
+		return;
+
+	if (!pte_present(pteval))
+		return;
+
+	page = vm_normal_page(vma, address, pteval);
+	if (unlikely(!page))
+		return;
+
+	if (!PageLRU(page) || PageLocked(page))
+		return;
+
+	/* TODO : Support THP */
+	if (unlikely(PageCompound(page)))
+		return;
+
+	if (isolate_lru_page(page))
+		return;
+
+	list_add(&page->lru, pagelist);
+
+	VM_BUG_ON(page_is_file_cache(page));
+	inc_zone_page_state(page, NR_ISOLATED_ANON);
+}
+
+static int vrange_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
+		struct mm_walk *walk)
 {
+	pte_t *pte;
+	spinlock_t *ptl;
+
+	pte = pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
+	for (; addr != end; pte++, addr += PAGE_SIZE)
+		vrange_pte_entry(*pte, addr, PAGE_SIZE, walk);
+	pte_unmap_unlock(pte - 1, ptl);
+	cond_resched();
+
 	return 0;
 }
 
+static unsigned int discard_vma_pages(struct mm_struct *mm,
+		struct vm_area_struct *vma, unsigned long start,
+		unsigned long end)
+{
+	unsigned int ret = 0;
+	LIST_HEAD(pagelist);
+	struct vrange_walker vw;
+	struct mm_walk vrange_walk = {
+		.pmd_entry = vrange_pte_range,
+		.mm = vma->vm_mm,
+		.private = &vw,
+	};
+
+	vw.pagelist = &pagelist;
+	vw.vma = vma;
+
+	walk_page_range(start, end, &vrange_walk);
+
+	if (!list_empty(&pagelist))
+		ret = discard_vrange_pagelist(&pagelist);
+
+	putback_lru_pages(&pagelist);
+	return ret;
+}
+
+/*
+ * vrange->owner isn't stable because caller doesn't hold vrange_lock
+ * so avoid touching vrange->owner.
+ */
+static int __discard_vrange_anon(struct mm_struct *mm, struct vrange *vrange,
+					unsigned int *ret_discard)
+{
+	struct vm_area_struct *vma;
+	unsigned int nr_discard = 0;
+	unsigned long start = vrange->node.start;
+	unsigned long end = vrange->node.last + 1;
+	int ret = 0;
+
+	/* It prevent to destroy vma when the process exist */
+	if (!atomic_inc_not_zero(&mm->mm_users))
+		return ret;
+
+	if (!down_read_trylock(&mm->mmap_sem)) {
+		mmput(mm);
+		ret = -EBUSY;
+		goto out; /* this vrange could be retried */
+	}
+
+	vma = find_vma(mm, start);
+	if (!vma || (vma->vm_start >= end))
+		goto out_unlock;
+
+	for (; vma; vma = vma->vm_next) {
+		if (vma->vm_start >= end)
+			break;
+		BUG_ON(vma->vm_flags & (VM_SPECIAL|VM_LOCKED|VM_MIXEDMAP|
+					VM_HUGETLB));
+		cond_resched();
+		nr_discard += discard_vma_pages(mm, vma,
+				max_t(unsigned long, start, vma->vm_start),
+				min_t(unsigned long, end, vma->vm_end));
+	}
+out_unlock:
+	up_read(&mm->mmap_sem);
+	mmput(mm);
+	*ret_discard = nr_discard;
+out:
+	return ret;
+}
+
+static int discard_vrange(struct vrange *vrange)
+{
+	int ret = 0;
+	struct mm_struct *mm;
+	struct vrange_root *vroot;
+	unsigned int nr_discard = 0;
+	vroot = vrange->owner;
+
+	/* TODO : handle VRANGE_FILE */
+	if (vroot->type != VRANGE_MM)
+		goto out;
+
+	mm = vroot->object;
+	ret = __discard_vrange_anon(mm, vrange, &nr_discard);
+out:
+	return nr_discard;
+}
+
 static int shrink_vrange(struct shrinker *s, struct shrink_control *sc)
 {
 	struct vrange *range = NULL;
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
