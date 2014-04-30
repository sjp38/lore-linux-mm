Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f52.google.com (mail-ee0-f52.google.com [74.125.83.52])
	by kanga.kvack.org (Postfix) with ESMTP id 030186B0039
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 16:26:03 -0400 (EDT)
Received: by mail-ee0-f52.google.com with SMTP id e53so1735448eek.39
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 13:26:03 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id l41si32043728eef.8.2014.04.30.13.26.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 30 Apr 2014 13:26:02 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 6/9] mm: memcontrol: remove ordering between pc->mem_cgroup and PageCgroupUsed
Date: Wed, 30 Apr 2014 16:25:40 -0400
Message-Id: <1398889543-23671-7-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1398889543-23671-1-git-send-email-hannes@cmpxchg.org>
References: <1398889543-23671-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

There is a write barrier between setting pc->mem_cgroup and
PageCgroupUsed, which was added to allow LRU operations to lookup the
memcg LRU list of a page without acquiring the page_cgroup lock.  But
ever since 38c5d72f3ebe ("memcg: simplify LRU handling by new rule"),
pages are ensured to be off-LRU while charging, so nobody else is
changing LRU state while pc->mem_cgroup is being written.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 34407d99262a..c528ae9ac230 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2823,14 +2823,6 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
 	}
 
 	pc->mem_cgroup = memcg;
-	/*
-	 * We access a page_cgroup asynchronously without lock_page_cgroup().
-	 * Especially when a page_cgroup is taken from a page, pc->mem_cgroup
-	 * is accessed after testing USED bit. To make pc->mem_cgroup visible
-	 * before USED bit, we need memory barrier here.
-	 * See mem_cgroup_add_lru_list(), etc.
-	 */
-	smp_wmb();
 	SetPageCgroupUsed(pc);
 
 	if (lrucare) {
@@ -3609,7 +3601,6 @@ void mem_cgroup_split_huge_fixup(struct page *head)
 	for (i = 1; i < HPAGE_PMD_NR; i++) {
 		pc = head_pc + i;
 		pc->mem_cgroup = memcg;
-		smp_wmb();/* see __commit_charge() */
 		pc->flags = head_pc->flags & ~PCGF_NOCOPY_AT_SPLIT;
 	}
 	__this_cpu_sub(memcg->stat->count[MEM_CGROUP_STAT_RSS_HUGE],
-- 
1.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
