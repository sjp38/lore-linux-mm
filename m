Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010asp105.postini.com [74.125.245.225])
	by kanga.kvack.org (Postfix) with SMTP id 4DC196B004D
	for <linux-mm@kvack.org>; Mon, 12 Mar 2012 19:10:28 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v4 1/3] memcg: clean up existing move charge code
Date: Mon, 12 Mar 2012 18:30:54 -0400
Message-Id: <1331591456-20769-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

We'll introduce the thp variant of move charge code in later patches,
but before doing that let's start with refactoring existing code.
Here we replace lengthy function name is_target_pte_for_mc() with
shorter one in order to avoid ugly line breaks.
And for better readability, we explicitly use MC_TARGET_* instead of
simply using integers.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memcontrol.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git linux-next-20120307.orig/mm/memcontrol.c linux-next-20120307/mm/memcontrol.c
index a288855..3d16618 100644
--- linux-next-20120307.orig/mm/memcontrol.c
+++ linux-next-20120307/mm/memcontrol.c
@@ -5069,7 +5069,7 @@ one_by_one:
 }
 
 /**
- * is_target_pte_for_mc - check a pte whether it is valid for move charge
+ * get_mctgt_type - get target type of moving charge
  * @vma: the vma the pte to be checked belongs
  * @addr: the address corresponding to the pte to be checked
  * @ptent: the pte to be checked
@@ -5092,7 +5092,7 @@ union mc_target {
 };
 
 enum mc_target_type {
-	MC_TARGET_NONE,	/* not used */
+	MC_TARGET_NONE,
 	MC_TARGET_PAGE,
 	MC_TARGET_SWAP,
 };
@@ -5173,12 +5173,12 @@ static struct page *mc_handle_file_pte(struct vm_area_struct *vma,
 	return page;
 }
 
-static int is_target_pte_for_mc(struct vm_area_struct *vma,
+static enum mc_target_type get_mctgt_type(struct vm_area_struct *vma,
 		unsigned long addr, pte_t ptent, union mc_target *target)
 {
 	struct page *page = NULL;
 	struct page_cgroup *pc;
-	int ret = 0;
+	enum mc_target_type ret = MC_TARGET_NONE;
 	swp_entry_t ent = { .val = 0 };
 
 	if (pte_present(ptent))
@@ -5189,7 +5189,7 @@ static int is_target_pte_for_mc(struct vm_area_struct *vma,
 		page = mc_handle_file_pte(vma, addr, ptent, &ent);
 
 	if (!page && !ent.val)
-		return 0;
+		return ret;
 	if (page) {
 		pc = lookup_page_cgroup(page);
 		/*
@@ -5206,7 +5206,7 @@ static int is_target_pte_for_mc(struct vm_area_struct *vma,
 			put_page(page);
 	}
 	/* There is a swap entry and a page doesn't exist or isn't charged */
-	if (ent.val && !ret &&
+	if (ent.val && ret != MC_TARGET_NONE &&
 			css_id(&mc.from->css) == lookup_swap_cgroup_id(ent)) {
 		ret = MC_TARGET_SWAP;
 		if (target)
@@ -5227,7 +5227,7 @@ static int mem_cgroup_count_precharge_pte_range(pmd_t *pmd,
 
 	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
 	for (; addr != end; pte++, addr += PAGE_SIZE)
-		if (is_target_pte_for_mc(vma, addr, *pte, NULL))
+		if (get_mctgt_type(vma, addr, *pte, NULL))
 			mc.precharge++;	/* increment precharge temporarily */
 	pte_unmap_unlock(pte - 1, ptl);
 	cond_resched();
@@ -5397,8 +5397,8 @@ retry:
 		if (!mc.precharge)
 			break;
 
-		type = is_target_pte_for_mc(vma, addr, ptent, &target);
-		switch (type) {
+		target_type = get_mctgt_type(vma, addr, ptent, &target);
+		switch (target_type) {
 		case MC_TARGET_PAGE:
 			page = target.page;
 			if (isolate_lru_page(page))
@@ -5411,7 +5411,7 @@ retry:
 				mc.moved_charge++;
 			}
 			putback_lru_page(page);
-put:			/* is_target_pte_for_mc() gets the page */
+put:			/* get_mctgt_type() gets the page */
 			put_page(page);
 			break;
 		case MC_TARGET_SWAP:
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
