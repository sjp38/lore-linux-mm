Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1F4EC6B0242
	for <linux-mm@kvack.org>; Mon, 10 May 2010 18:26:01 -0400 (EDT)
Date: Mon, 10 May 2010 15:25:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 -mmotm 1/2] memcg: clean up move charge
Message-Id: <20100510152554.5f8a1be0.akpm@linux-foundation.org>
In-Reply-To: <20100408141020.47535e5e.nishimura@mxp.nes.nec.co.jp>
References: <20100408140922.422b21b0.nishimura@mxp.nes.nec.co.jp>
	<20100408141020.47535e5e.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 8 Apr 2010 14:10:20 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> This patch cleans up move charge code by:
> 
> - define functions to handle pte for each types, and make is_target_pte_for_mc()
>   cleaner.
> - instead of checking the MOVE_CHARGE_TYPE_ANON bit, define a function that
>   checks the bit.
>
> ...
>

> @@ -4241,13 +4263,15 @@ static int is_target_pte_for_mc(struct vm_area_struct *vma,
>  		if (!ret || !target)
>  			put_page(page);
>  	}
> -	/* throught */
> -	if (ent.val && do_swap_account && !ret &&
> -			css_id(&mc.from->css) == lookup_swap_cgroup(ent)) {
> -		ret = MC_TARGET_SWAP;
> -		if (target)
> -			target->ent = ent;
> +	/* Threre is a swap entry and a page doesn't exist or isn't charged */
> +	if (ent.val && !ret) {
> +		if (css_id(&mc.from->css) == lookup_swap_cgroup(ent)) {
> +			ret = MC_TARGET_SWAP;
> +			if (target)
> +				target->ent = ent;
> +		}
>  	}
> +
>  	return ret;
>  }

Are you sure that the test of do_swap_account should be removed here? 
it didn't seem to be covered in the changelog.

This patch got somewaht trashed by
memcg-fix-css_id-rcu-locking-for-real.patch, which is was sent under the
not-very-useful title "[BUGFIX][PATCH 2/2] cgroup/cssid/memcg rcu
fixes.  (Was Re: [PATCH tip/core/urgent 08/10] memcg: css_id() must be
called under rcu_read_lock()". (the same title as [patch 1/1]).

I reworked memcg-clean-up-move-charge.patch as below:



From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

This patch cleans up move charge code by:

- define functions to handle pte for each types, and make
  is_target_pte_for_mc() cleaner.

- instead of checking the MOVE_CHARGE_TYPE_ANON bit, define a function
  that checks the bit.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@in.ibm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/memcontrol.c |   96 ++++++++++++++++++++++++++++------------------
 1 file changed, 59 insertions(+), 37 deletions(-)

diff -puN mm/memcontrol.c~memcg-clean-up-move-charge mm/memcontrol.c
--- a/mm/memcontrol.c~memcg-clean-up-move-charge
+++ a/mm/memcontrol.c
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
@@ -4185,50 +4191,66 @@ enum mc_target_type {
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
@@ -4244,8 +4266,8 @@ static int is_target_pte_for_mc(struct v
 		if (!ret || !target)
 			put_page(page);
 	}
-	/* throught */
-	if (ent.val && do_swap_account && !ret &&
+	/* There is a swap entry and a page doesn't exist or isn't charged */
+	if (ent.val && !ret &&
 			css_id(&mc.from->css) == lookup_swap_cgroup(ent)) {
 		ret = MC_TARGET_SWAP;
 		if (target)
_



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
