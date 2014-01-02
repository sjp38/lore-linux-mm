Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6E1E56B004D
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 02:13:19 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id lf10so14235747pab.14
        for <linux-mm@kvack.org>; Wed, 01 Jan 2014 23:13:19 -0800 (PST)
Received: from LGEMRELSE7Q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id gm1si15344151pac.100.2014.01.01.23.13.16
        for <linux-mm@kvack.org>;
        Wed, 01 Jan 2014 23:13:18 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v10 10/16] vrange: Purging vrange-anon pages from shrinker
Date: Thu,  2 Jan 2014 16:12:18 +0900
Message-Id: <1388646744-15608-11-git-send-email-minchan@kernel.org>
In-Reply-To: <1388646744-15608-1-git-send-email-minchan@kernel.org>
References: <1388646744-15608-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, John Stultz <john.stultz@linaro.org>, Dhaval Giani <dhaval.giani@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Rob Clark <robdclark@gmail.com>, Jason Evans <je@fb.com>, Minchan Kim <minchan@kernel.org>

This patch provides the logic to discard anonymous vranges by
generating the page list for the volatile ranges setting the ptes
volatile, and discarding the pages.

Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: John Stultz <john.stultz@linaro.org>
[jstultz: Code tweaks and commit log rewording]
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/vrange.c |  184 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 183 insertions(+), 1 deletion(-)

diff --git a/mm/vrange.c b/mm/vrange.c
index 4a52b7a05f9a..0fa669c56ab8 100644
--- a/mm/vrange.c
+++ b/mm/vrange.c
@@ -11,6 +11,8 @@
 #include <linux/hugetlb.h>
 #include "internal.h"
 #include <linux/mmu_notifier.h>
+#include <linux/mm_inline.h>
+#include <linux/migrate.h>
 
 static struct kmem_cache *vrange_cachep;
 
@@ -19,6 +21,11 @@ static struct vrange_list {
 	spinlock_t lock;
 } vrange_list;
 
+struct vrange_walker {
+	struct vm_area_struct *vma;
+	struct list_head *pagelist;
+};
+
 static inline unsigned long vrange_size(struct vrange *range)
 {
 	return range->node.last + 1 - range->node.start;
@@ -682,11 +689,186 @@ static struct vrange *vrange_isolate(void)
 	return vrange;
 }
 
-static int discard_vrange(struct vrange *vrange, unsigned long *nr_discard)
+static unsigned long discard_vrange_pagelist(struct list_head *page_list)
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
 {
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
+	BUG_ON(PageCompound(page));
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
+{
+	struct vrange_walker *vw = walk->private;
+	struct vm_area_struct *uninitialized_var(vma);
+	pte_t *pte;
+	spinlock_t *ptl;
+
+	vma = vw->vma;
+	split_huge_page_pmd(vma, addr, pmd);
+	if (pmd_trans_unstable(pmd))
+		return 0;
+
+	pte = pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
+	for (; addr != end; pte++, addr += PAGE_SIZE)
+		vrange_pte_entry(*pte, addr, PAGE_SIZE, walk);
+	pte_unmap_unlock(pte - 1, ptl);
+	cond_resched();
+
 	return 0;
 }
 
+static unsigned long discard_vma_pages(struct mm_struct *mm,
+		struct vm_area_struct *vma, unsigned long start,
+		unsigned long end)
+{
+	unsigned long ret = 0;
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
+		unsigned long *ret_discard)
+{
+	struct vm_area_struct *vma;
+	unsigned long nr_discard = 0;
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
+		ret = -EAGAIN;
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
+static int discard_vrange(struct vrange *vrange, unsigned long *nr_discard)
+{
+	int ret = 0;
+	struct mm_struct *mm;
+	struct vrange_root *vroot;
+	vroot = vrange->owner;
+
+	/* TODO : handle VRANGE_FILE */
+	if (vroot->type != VRANGE_MM)
+		goto out;
+
+	mm = vroot->object;
+	ret = __discard_vrange_anon(mm, vrange, nr_discard);
+out:
+	return ret;
+}
+
+
 #define VRANGE_SCAN_THRESHOLD	(4 << 20)
 
 unsigned long shrink_vrange(enum lru_list lru, struct lruvec *lruvec,
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
