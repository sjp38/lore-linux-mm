Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id DC6316B0069
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 16:21:47 -0400 (EDT)
Received: by mail-la0-f47.google.com with SMTP id pv20so1751387lab.6
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 13:21:47 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id tb1si13746891lbb.130.2014.10.21.13.21.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Oct 2014 13:21:46 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 1/4] mm: memcontrol: inline memcg->move_lock locking
Date: Tue, 21 Oct 2014 16:21:33 -0400
Message-Id: <1413922896-29042-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

The wrappers around taking and dropping the memcg->move_lock spinlock
add nothing of value.  Inline the spinlock calls into the callsites.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 34 +++++++++-------------------------
 1 file changed, 9 insertions(+), 25 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 293db8234179..1ff125d2a427 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1507,23 +1507,6 @@ static bool mem_cgroup_wait_acct_move(struct mem_cgroup *memcg)
 	return false;
 }
 
-/*
- * Take this lock when
- * - a code tries to modify page's memcg while it's USED.
- * - a code tries to modify page state accounting in a memcg.
- */
-static void move_lock_mem_cgroup(struct mem_cgroup *memcg,
-				  unsigned long *flags)
-{
-	spin_lock_irqsave(&memcg->move_lock, *flags);
-}
-
-static void move_unlock_mem_cgroup(struct mem_cgroup *memcg,
-				unsigned long *flags)
-{
-	spin_unlock_irqrestore(&memcg->move_lock, *flags);
-}
-
 #define K(x) ((x) << (PAGE_SHIFT-10))
 /**
  * mem_cgroup_print_oom_info: Print OOM information relevant to memory controller.
@@ -2013,7 +1996,7 @@ again:
 		return;
 	/*
 	 * If this memory cgroup is not under account moving, we don't
-	 * need to take move_lock_mem_cgroup(). Because we already hold
+	 * need to take &memcg->move_lock. Because we already hold
 	 * rcu_read_lock(), any calls to move_account will be delayed until
 	 * rcu_read_unlock().
 	 */
@@ -2021,9 +2004,9 @@ again:
 	if (atomic_read(&memcg->moving_account) <= 0)
 		return;
 
-	move_lock_mem_cgroup(memcg, flags);
+	spin_lock_irqsave(&memcg->move_lock, *flags);
 	if (memcg != pc->mem_cgroup) {
-		move_unlock_mem_cgroup(memcg, flags);
+		spin_unlock_irqrestore(&memcg->move_lock, *flags);
 		goto again;
 	}
 	*locked = true;
@@ -2038,7 +2021,7 @@ void __mem_cgroup_end_update_page_stat(struct page *page, unsigned long *flags)
 	 * lock is held because a routine modifies pc->mem_cgroup
 	 * should take move_lock_mem_cgroup().
 	 */
-	move_unlock_mem_cgroup(pc->mem_cgroup, flags);
+	spin_unlock_irqrestore(&pc->mem_cgroup->move_lock, *flags);
 }
 
 void mem_cgroup_update_page_stat(struct page *page,
@@ -3083,7 +3066,7 @@ static int mem_cgroup_move_account(struct page *page,
 	if (pc->mem_cgroup != from)
 		goto out_unlock;
 
-	move_lock_mem_cgroup(from, &flags);
+	spin_lock_irqsave(&from->move_lock, flags);
 
 	if (!PageAnon(page) && page_mapped(page)) {
 		__this_cpu_sub(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED],
@@ -3107,7 +3090,8 @@ static int mem_cgroup_move_account(struct page *page,
 
 	/* caller should have done css_get */
 	pc->mem_cgroup = to;
-	move_unlock_mem_cgroup(from, &flags);
+	spin_unlock_irqrestore(&from->move_lock, flags);
+
 	ret = 0;
 
 	local_irq_disable();
@@ -6033,9 +6017,9 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
 	 * but there might still be references, e.g. from finishing
 	 * writeback.  Follow the charge moving protocol here.
 	 */
-	move_lock_mem_cgroup(memcg, &flags);
+	spin_lock_irqsave(&memcg->move_lock, flags);
 	pc->mem_cgroup = NULL;
-	move_unlock_mem_cgroup(memcg, &flags);
+	spin_unlock_irqrestore(&memcg->move_lock, flags);
 
 	if (lrucare)
 		unlock_page_lru(oldpage, isolated);
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
