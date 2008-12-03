Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB359IwT023361
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 3 Dec 2008 14:09:18 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 75C4045DD7E
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 14:09:18 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 49A7C45DD76
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 14:09:18 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 21EF51DB8040
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 14:09:18 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C38CB1DB8042
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 14:09:17 +0900 (JST)
Date: Wed, 3 Dec 2008 14:08:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH  17/21] memcg_prev_priority_protect.patch
Message-Id: <20081203140828.c02bf20f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081203134718.6b60986f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081203134718.6b60986f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

From:	KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Currently, mem_cgroup doesn't have own lock and almost its member doesn't need.
 (e.g. mem_cgroup->info is protected by zone lock, mem_cgroup->stat is
  per cpu variable)

However, there is one explict exception. mem_cgroup->prev_priorit need lock,
but doesn't protect.
Luckly, this is NOT bug because prev_priority isn't used for current reclaim code.

However, we plan to use prev_priority future again.
Therefore, fixing is better.


In addision, we plan to reuse this lock for another member.
Then "reclaim_param_lock" name is better than "prev_priority_lock".


Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
 mm/memcontrol.c |   18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

Index: mmotm-2.6.28-Dec02/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-Dec02.orig/mm/memcontrol.c
+++ mmotm-2.6.28-Dec02/mm/memcontrol.c
@@ -144,6 +144,11 @@ struct mem_cgroup {
 	 */
 	struct mem_cgroup_lru_info info;
 
+	/*
+	  protect against reclaim related member.
+	*/
+	spinlock_t reclaim_param_lock;
+
 	int	prev_priority;	/* for recording reclaim priority */
 
 	/*
@@ -400,18 +405,28 @@ int mem_cgroup_calc_mapped_ratio(struct 
  */
 int mem_cgroup_get_reclaim_priority(struct mem_cgroup *mem)
 {
-	return mem->prev_priority;
+	int prev_priority;
+
+	spin_lock(&mem->reclaim_param_lock);
+	prev_priority = mem->prev_priority;
+	spin_unlock(&mem->reclaim_param_lock);
+
+	return prev_priority;
 }
 
 void mem_cgroup_note_reclaim_priority(struct mem_cgroup *mem, int priority)
 {
+	spin_lock(&mem->reclaim_param_lock);
 	if (priority < mem->prev_priority)
 		mem->prev_priority = priority;
+	spin_unlock(&mem->reclaim_param_lock);
 }
 
 void mem_cgroup_record_reclaim_priority(struct mem_cgroup *mem, int priority)
 {
+	spin_lock(&mem->reclaim_param_lock);
 	mem->prev_priority = priority;
+	spin_unlock(&mem->reclaim_param_lock);
 }
 
 int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg, struct zone *zone)
@@ -2070,6 +2085,7 @@ mem_cgroup_create(struct cgroup_subsys *
 	}
 	mem_cgroup_set_inactive_ratio(mem);
 	mem->last_scanned_child = NULL;
+	spin_lock_init(&mem->reclaim_param_lock);
 
 	return &mem->css;
 free_out:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
