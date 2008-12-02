Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB27iK2a028364
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 2 Dec 2008 16:44:20 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 37CCB45DE52
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 16:44:20 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F70945DE50
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 16:44:20 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EA9161DB8041
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 16:44:19 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A4CFB1DB8037
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 16:44:19 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 1/2] memcg: mem_cgroup->prev_priority protected by lock. take2
Message-Id: <20081202164334.1D0C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  2 Dec 2008 16:44:18 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>


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



Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/memcontrol.c |   18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

Index: b/mm/memcontrol.c
===================================================================
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -142,6 +142,11 @@ struct mem_cgroup {
 	 */
 	struct mem_cgroup_lru_info info;
 
+	/*
+	  protect against reclaim related member.
+	*/
+	spinlock_t reclaim_param_lock;
+
 	int	prev_priority;	/* for recording reclaim priority */
 
 	/*
@@ -393,18 +398,28 @@ int mem_cgroup_calc_mapped_ratio(struct 
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
 
 /*
@@ -1967,6 +1982,7 @@ mem_cgroup_create(struct cgroup_subsys *
 	}
 
 	mem->last_scanned_child = NULL;
+	spin_lock_init(&mem->reclaim_param_lock);
 
 	return &mem->css;
 free_out:


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
