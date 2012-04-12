Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id A3D326B00FF
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 07:26:03 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 3F5BC3EE0C0
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 20:26:02 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 227F145DE51
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 20:26:02 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F209045DE4E
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 20:26:01 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E44831DB8041
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 20:26:01 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9173C1DB803E
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 20:26:01 +0900 (JST)
Message-ID: <4F86BB5E.6080509@jp.fujitsu.com>
Date: Thu, 12 Apr 2012 20:24:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 4/7] memcg: remove 'uncharge' argument from mem_cgroup_move_account()
References: <4F86B9BE.8000105@jp.fujitsu.com>
In-Reply-To: <4F86B9BE.8000105@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>

Only one call passes 'true'. remove it and handle it in caller.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   29 ++++++++++++-----------------
 1 files changed, 12 insertions(+), 17 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 8246418..9ac7984 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2576,23 +2576,19 @@ void mem_cgroup_split_huge_fixup(struct page *head)
  * @pc:	page_cgroup of the page.
  * @from: mem_cgroup which the page is moved from.
  * @to:	mem_cgroup which the page is moved to. @from != @to.
- * @uncharge: whether we should call uncharge and css_put against @from.
  *
  * The caller must confirm following.
  * - page is not on LRU (isolate_page() is useful.)
  * - compound_lock is held when nr_pages > 1
  *
- * This function doesn't do "charge" nor css_get to new cgroup. It should be
- * done by a caller(__mem_cgroup_try_charge would be useful). If @uncharge is
- * true, this function does "uncharge" from old cgroup, but it doesn't if
- * @uncharge is false, so a caller should do "uncharge".
+ * This function doesn't access res_counter at all. Caller should take
+ * care of it.
  */
 static int mem_cgroup_move_account(struct page *page,
 				   unsigned int nr_pages,
 				   struct page_cgroup *pc,
 				   struct mem_cgroup *from,
-				   struct mem_cgroup *to,
-				   bool uncharge)
+				   struct mem_cgroup *to)
 {
 	unsigned long flags;
 	int ret;
@@ -2626,9 +2622,6 @@ static int mem_cgroup_move_account(struct page *page,
 		preempt_enable();
 	}
 	mem_cgroup_charge_statistics(from, anon, -nr_pages);
-	if (uncharge)
-		/* This is not "cancel", but cancel_charge does all we need. */
-		__mem_cgroup_cancel_charge(from, nr_pages);
 
 	/* caller should have done css_get */
 	pc->mem_cgroup = to;
@@ -2688,10 +2681,13 @@ static int mem_cgroup_move_parent(struct page *page,
 	if (nr_pages > 1)
 		flags = compound_lock_irqsave(page);
 
-	ret = mem_cgroup_move_account(page, nr_pages, pc, child, parent,
-					need_cancel);
-	if (!need_cancel && !ret)
-		__mem_cgroup_move_charge_parent(child, nr_pages);
+	ret = mem_cgroup_move_account(page, nr_pages, pc, child, parent);
+	if (!ret) {
+		if (need_cancel)
+			__mem_cgroup_cancel_charge(child, nr_pages);
+		else
+			__mem_cgroup_move_charge_parent(child, nr_pages);
+	}
 
 	if (nr_pages > 1)
 		compound_unlock_irqrestore(page, flags);
@@ -5451,8 +5447,7 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
 			if (!isolate_lru_page(page)) {
 				pc = lookup_page_cgroup(page);
 				if (!mem_cgroup_move_account(page, HPAGE_PMD_NR,
-							     pc, mc.from, mc.to,
-							     false)) {
+							pc, mc.from, mc.to)) {
 					mc.precharge -= HPAGE_PMD_NR;
 					mc.moved_charge += HPAGE_PMD_NR;
 				}
@@ -5482,7 +5477,7 @@ retry:
 				goto put;
 			pc = lookup_page_cgroup(page);
 			if (!mem_cgroup_move_account(page, 1, pc,
-						     mc.from, mc.to, false)) {
+						     mc.from, mc.to)) {
 				mc.precharge--;
 				/* we uncharge from mc.from later. */
 				mc.moved_charge++;
-- 
1.7.4.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
