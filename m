Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3020F620084
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 01:22:23 -0400 (EDT)
Date: Thu, 8 Apr 2010 14:10:20 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH v3 -mmotm 1/2] memcg: clean up move charge
Message-Id: <20100408141020.47535e5e.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100408140922.422b21b0.nishimura@mxp.nes.nec.co.jp>
References: <20100408140922.422b21b0.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

This patch cleans up move charge code by:

- define functions to handle pte for each types, and make is_target_pte_for_mc()
  cleaner.
- instead of checking the MOVE_CHARGE_TYPE_ANON bit, define a function that
  checks the bit.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/memcontrol.c |  106 +++++++++++++++++++++++++++++++++---------------------
 1 files changed, 65 insertions(+), 41 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f6c9d42..95a1706 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -266,6 +266,12 @@ static struct move_charge_struct {
 	.waitq = __WAIT_QUEUE_HEAD_INITIALIZER(mc.waitq),
 };
 
+static bool move_anon(void)
+{
+	return test_bit(MOVE_CHARGE_TYPE_ANON,
+					&mc.to->move_charge_at_immigrate);
+}
+
 /*
  * Maximum loops in mem_cgroup_hierarchical_reclaim(), used for soft
  * limit reclaim to prevent infinite loops, if they ever occur.
@@ -4182,50 +4188,66 @@ enum mc_target_type {
 	MC_TARGET_SWAP,
 };
 
-static int is_target_pte_for_mc(struct vm_area_struct *vma,
-		unsigned long addr, pte_t ptent, union mc_target *target)
+static struct page *mc_handle_present_pte(struct vm_area_struct *vma,
+						unsigned long addr, pte_t ptent)
 {
-	struct page *page = NULL;
-	struct page_cgroup *pc;
-	int ret = 0;
-	swp_entry_t ent = { .val = 0 };
-	int usage_count = 0;
-	bool move_anon = test_bit(MOVE_CHARGE_TYPE_ANON,
-					&mc.to->move_charge_at_immigrate);
+	struct page *page = vm_normal_page(vma, addr, ptent);
 
-	if (!pte_present(ptent)) {
-		/* TODO: handle swap of shmes/tmpfs */
-		if (pte_none(ptent) || pte_file(ptent))
-			return 0;
-		else if (is_swap_pte(ptent)) {
-			ent = pte_to_swp_entry(ptent);
-			if (!move_anon || non_swap_entry(ent))
-				return 0;
-			usage_count = mem_cgroup_count_swap_user(ent, &page);
-		}
-	} else {
-		page = vm_normal_page(vma, addr, ptent);
-		if (!page || !page_mapped(page))
-			return 0;
+	if (!page || !page_mapped(page))
+		return NULL;
+	if (PageAnon(page)) {
+		/* we don't move shared anon */
+		if (!move_anon() || page_mapcount(page) > 2)
+			return NULL;
+	} else
 		/*
 		 * TODO: We don't move charges of file(including shmem/tmpfs)
 		 * pages for now.
 		 */
-		if (!move_anon || !PageAnon(page))
-			return 0;
-		if (!get_page_unless_zero(page))
-			return 0;
-		usage_count = page_mapcount(page);
-	}
-	if (usage_count > 1) {
-		/*
-		 * TODO: We don't move charges of shared(used by multiple
-		 * processes) pages for now.
-		 */
+		return NULL;
+	if (!get_page_unless_zero(page))
+		return NULL;
+
+	return page;
+}
+
+static struct page *mc_handle_swap_pte(struct vm_area_struct *vma,
+			unsigned long addr, pte_t ptent, swp_entry_t *entry)
+{
+	int usage_count;
+	struct page *page = NULL;
+	swp_entry_t ent = pte_to_swp_entry(ptent);
+
+	if (!move_anon() || non_swap_entry(ent))
+		return NULL;
+	usage_count = mem_cgroup_count_swap_user(ent, &page);
+	if (usage_count > 1) { /* we don't move shared anon */
 		if (page)
 			put_page(page);
-		return 0;
+		return NULL;
 	}
+	if (do_swap_account)
+		entry->val = ent.val;
+
+	return page;
+}
+
+static int is_target_pte_for_mc(struct vm_area_struct *vma,
+		unsigned long addr, pte_t ptent, union mc_target *target)
+{
+	struct page *page = NULL;
+	struct page_cgroup *pc;
+	int ret = 0;
+	swp_entry_t ent = { .val = 0 };
+
+	if (pte_present(ptent))
+		page = mc_handle_present_pte(vma, addr, ptent);
+	else if (is_swap_pte(ptent))
+		page = mc_handle_swap_pte(vma, addr, ptent, &ent);
+	/* TODO: handle swap of shmes/tmpfs */
+
+	if (!page && !ent.val)
+		return 0;
 	if (page) {
 		pc = lookup_page_cgroup(page);
 		/*
@@ -4241,13 +4263,15 @@ static int is_target_pte_for_mc(struct vm_area_struct *vma,
 		if (!ret || !target)
 			put_page(page);
 	}
-	/* throught */
-	if (ent.val && do_swap_account && !ret &&
-			css_id(&mc.from->css) == lookup_swap_cgroup(ent)) {
-		ret = MC_TARGET_SWAP;
-		if (target)
-			target->ent = ent;
+	/* Threre is a swap entry and a page doesn't exist or isn't charged */
+	if (ent.val && !ret) {
+		if (css_id(&mc.from->css) == lookup_swap_cgroup(ent)) {
+			ret = MC_TARGET_SWAP;
+			if (target)
+				target->ent = ent;
+		}
 	}
+
 	return ret;
 }
 
-- 
1.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
