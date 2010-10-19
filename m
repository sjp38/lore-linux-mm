Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2F8DF6B00B4
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 00:49:16 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9J4nCYL016544
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 19 Oct 2010 13:49:12 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 81C7E45DE52
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 13:49:12 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id E6A4745DE55
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 13:49:11 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F3F3E08002
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 13:49:11 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B47DE38005
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 13:49:08 +0900 (JST)
Date: Tue, 19 Oct 2010 13:43:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 1/2] memcg: move_account optimization  by reduct
 put,get page (Re: [PATCH v3 04/11] memcg: add lock to synchronize page
 accounting and migration
Message-Id: <20101019134308.3fe81638.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101019094512.11eabc62.kamezawa.hiroyu@jp.fujitsu.com>
References: <1287448784-25684-1-git-send-email-gthelen@google.com>
	<1287448784-25684-5-git-send-email-gthelen@google.com>
	<20101019094512.11eabc62.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Tue, 19 Oct 2010 09:45:12 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Mon, 18 Oct 2010 17:39:37 -0700
> Greg Thelen <gthelen@google.com> wrote:
> 
> > Performance Impact: moving a 8G anon process.
> > 
> > Before:
> > 	real    0m0.792s
> > 	user    0m0.000s
> > 	sys     0m0.780s
> > 
> > After:
> > 	real    0m0.854s
> > 	user    0m0.000s
> > 	sys     0m0.842s
> > 
> > This score is bad but planned patches for optimization can reduce
> > this impact.
> > 
> 
> I'll post optimization patches after this set goes to -mm.
> RFC version will be posted soon.
> 

This is a RFC and based on dirty-limit v3 patch.
Then, I'll post again this when dirty-limit patches are queued.
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

At moving account, a major source of cost is put/get_page().
This patch reduces cost of put/get page by the fact all operations are done
under pte_lock().
Because move_account() is done under pte_lock, pages present on page table are
never be freed. Then, we don't need to do get/put_page at isolating pages from
LRU.

Cost of moving 8G anon process.

[mmotm]
	real    0m0.792s
	user    0m0.000s
	sys     0m0.780s
	
[dirty]
        real    0m0.854s
        user    0m0.000s
        sys     0m0.842s
[get/put]
	real    0m0.757s
	user    0m0.000s
	sys     0m0.746s

seems nice.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   59 +++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 35 insertions(+), 24 deletions(-)

Index: dirty_limit_new/mm/memcontrol.c
===================================================================
--- dirty_limit_new.orig/mm/memcontrol.c
+++ dirty_limit_new/mm/memcontrol.c
@@ -4844,9 +4844,13 @@ one_by_one:
  * Returns
  *   0(MC_TARGET_NONE): if the pte is not a target for move charge.
  *   1(MC_TARGET_PAGE): if the page corresponding to this pte is a target for
- *     move charge. if @target is not NULL, the page is stored in target->page
- *     with extra refcnt got(Callers should handle it).
- *   2(MC_TARGET_SWAP): if the swap entry corresponding to this pte is a
+ *     move charge and it's mapped. If @target is not NULL, the page is stored,
+ *     in target->ent. We expect pte_lock is held throughout the operation and
+ *     no extra page_get() is done.
+ *   2.(MC_TARGET_UNMAPPED_PAGE): if the page corresponding to this pte is a
+ *     target for move charge and it's not mapped. If @target is not NULL, the
+ *     page is stored in target->ent with extra refcnt got.
+ *   3(MC_TARGET_SWAP): if the swap entry corresponding to this pte is a
  *     target for charge migration. if @target is not NULL, the entry is stored
  *     in target->ent.
  *
@@ -4859,7 +4863,8 @@ union mc_target {
 
 enum mc_target_type {
 	MC_TARGET_NONE,	/* not used */
-	MC_TARGET_PAGE,
+	MC_TARGET_PAGE, /* page mapped */
+	MC_TARGET_UNMAPPED_PAGE, /* page not mapped*/
 	MC_TARGET_SWAP,
 };
 
@@ -4877,8 +4882,6 @@ static struct page *mc_handle_present_pt
 	} else if (!move_file())
 		/* we ignore mapcount for file pages */
 		return NULL;
-	if (!get_page_unless_zero(page))
-		return NULL;
 
 	return page;
 }
@@ -4944,13 +4947,17 @@ static int is_target_pte_for_mc(struct v
 	struct page_cgroup *pc;
 	int ret = 0;
 	swp_entry_t ent = { .val = 0 };
+	bool mapped = true;
 
-	if (pte_present(ptent))
+	if (pte_present(ptent)) {
 		page = mc_handle_present_pte(vma, addr, ptent);
-	else if (is_swap_pte(ptent))
-		page = mc_handle_swap_pte(vma, addr, ptent, &ent);
-	else if (pte_none(ptent) || pte_file(ptent))
-		page = mc_handle_file_pte(vma, addr, ptent, &ent);
+	} else {
+		mapped = false;
+		if (is_swap_pte(ptent))
+			page = mc_handle_swap_pte(vma, addr, ptent, &ent);
+		else if (pte_none(ptent) || pte_file(ptent))
+			page = mc_handle_file_pte(vma, addr, ptent, &ent);
+	}
 
 	if (!page && !ent.val)
 		return 0;
@@ -4962,11 +4969,14 @@ static int is_target_pte_for_mc(struct v
 		 * the lock.
 		 */
 		if (PageCgroupUsed(pc) && pc->mem_cgroup == mc.from) {
-			ret = MC_TARGET_PAGE;
+			if (mapped)
+				ret = MC_TARGET_PAGE;
+			else
+				ret = MC_TARGET_UNMAPPED_PAGE;
 			if (target)
 				target->page = page;
 		}
-		if (!ret || !target)
+		if (!mapped && (!ret || !target))
 			put_page(page);
 	}
 	/* There is a swap entry and a page doesn't exist or isn't charged */
@@ -5153,19 +5163,20 @@ retry:
 		type = is_target_pte_for_mc(vma, addr, ptent, &target);
 		switch (type) {
 		case MC_TARGET_PAGE:
+		case MC_TARGET_UNMAPPED_PAGE:
 			page = target.page;
-			if (isolate_lru_page(page))
-				goto put;
-			pc = lookup_page_cgroup(page);
-			if (!mem_cgroup_move_account(pc,
-						mc.from, mc.to, false)) {
-				mc.precharge--;
-				/* we uncharge from mc.from later. */
-				mc.moved_charge++;
+			if (!isolate_lru_page(page)) {
+				pc = lookup_page_cgroup(page);
+				if (!mem_cgroup_move_account(pc, mc.from,
+						mc.to, false)) {
+					mc.precharge--;
+					/* we uncharge from mc.from later. */
+					mc.moved_charge++;
+				}
+				putback_lru_page(page);
 			}
-			putback_lru_page(page);
-put:			/* is_target_pte_for_mc() gets the page */
-			put_page(page);
+			if (type == MC_TARGET_UNMAPPED_PAGE)
+				put_page(page);
 			break;
 		case MC_TARGET_SWAP:
 			ent = target.ent;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
