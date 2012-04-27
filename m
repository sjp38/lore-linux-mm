Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id E69E06B007E
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 02:02:22 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 7DEFF3EE0BB
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 15:02:21 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6425D45DE58
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 15:02:21 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 417FB45DE55
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 15:02:21 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 301F41DB803C
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 15:02:21 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CFD5F1DB802C
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 15:02:20 +0900 (JST)
Message-ID: <4F9A35FB.7090401@jp.fujitsu.com>
Date: Fri, 27 Apr 2012 15:00:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC][PATCH 6/9 v2] memcg: don't uncharge in mem_cgroup_move_account
References: <4F9A327A.6050409@jp.fujitsu.com>
In-Reply-To: <4F9A327A.6050409@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>, Han Ying <yinghan@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyuki@gmail.com


Now, all caller passes 'false' for 'bool uncharge', remove the argument.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   20 ++++++--------------
 1 files changed, 6 insertions(+), 14 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 62200f1..2715223 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2589,23 +2589,19 @@ void mem_cgroup_split_huge_fixup(struct page *head)
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
+ * This function doesn't do "charge" to new cgroup and doesn't do "uncharge"
+ * from old cgroup.
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
@@ -2639,9 +2635,6 @@ static int mem_cgroup_move_account(struct page *page,
 		preempt_enable();
 	}
 	mem_cgroup_charge_statistics(from, anon, -nr_pages);
-	if (uncharge)
-		/* This is not "cancel", but cancel_charge does all we need. */
-		__mem_cgroup_cancel_charge(from, nr_pages);
 
 	/* caller should have done css_get */
 	pc->mem_cgroup = to;
@@ -2706,7 +2699,7 @@ static int mem_cgroup_move_parent(struct page *page,
 		flags = compound_lock_irqsave(page);
 
 	ret = mem_cgroup_move_account(page, nr_pages,
-				pc, child, parent, false);
+				pc, child, parent);
 	if (!ret)
 		__mem_cgroup_cancel_local_charge(child, nr_pages);
 
@@ -5724,8 +5717,7 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
 			if (!isolate_lru_page(page)) {
 				pc = lookup_page_cgroup(page);
 				if (!mem_cgroup_move_account(page, HPAGE_PMD_NR,
-							     pc, mc.from, mc.to,
-							     false)) {
+							pc, mc.from, mc.to)) {
 					mc.precharge -= HPAGE_PMD_NR;
 					mc.moved_charge += HPAGE_PMD_NR;
 				}
@@ -5755,7 +5747,7 @@ retry:
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
