Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id 8487D6B0088
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 10:33:08 -0400 (EDT)
Received: by mail-lb0-f181.google.com with SMTP id l4so956627lbv.12
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 07:33:07 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id i3si2890220lae.59.2014.10.23.07.33.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Oct 2014 07:33:06 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: memcontrol: inline memcg->move_lock locking
Date: Thu, 23 Oct 2014 10:33:02 -0400
Message-Id: <1414074782-14340-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

The wrappers around taking and dropping the memcg->move_lock spinlock
add nothing of value.  Inline the spinlock calls into the callsites.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/memcontrol.c | 28 ++++++----------------------
 1 file changed, 6 insertions(+), 22 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 09fece0eb9f1..a5c9aa4688e8 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1522,23 +1522,6 @@ static bool mem_cgroup_wait_acct_move(struct mem_cgroup *memcg)
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
@@ -2156,9 +2139,9 @@ again:
 	if (atomic_read(&memcg->moving_account) <= 0)
 		return memcg;
 
-	move_lock_mem_cgroup(memcg, flags);
+	spin_lock_irqsave(&memcg->move_lock, *flags);
 	if (memcg != pc->mem_cgroup) {
-		move_unlock_mem_cgroup(memcg, flags);
+		spin_unlock_irqrestore(&memcg->move_lock, *flags);
 		goto again;
 	}
 	*locked = true;
@@ -2176,7 +2159,7 @@ void mem_cgroup_end_page_stat(struct mem_cgroup *memcg, bool locked,
 			      unsigned long flags)
 {
 	if (memcg && locked)
-		move_unlock_mem_cgroup(memcg, &flags);
+		spin_unlock_irqrestore(&memcg->move_lock, flags);
 
 	rcu_read_unlock();
 }
@@ -3219,7 +3202,7 @@ static int mem_cgroup_move_account(struct page *page,
 	if (pc->mem_cgroup != from)
 		goto out_unlock;
 
-	move_lock_mem_cgroup(from, &flags);
+	spin_lock_irqsave(&from->move_lock, flags);
 
 	if (!PageAnon(page) && page_mapped(page)) {
 		__this_cpu_sub(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED],
@@ -3243,7 +3226,8 @@ static int mem_cgroup_move_account(struct page *page,
 
 	/* caller should have done css_get */
 	pc->mem_cgroup = to;
-	move_unlock_mem_cgroup(from, &flags);
+	spin_unlock_irqrestore(&from->move_lock, flags);
+
 	ret = 0;
 
 	local_irq_disable();
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
