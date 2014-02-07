Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f174.google.com (mail-ea0-f174.google.com [209.85.215.174])
	by kanga.kvack.org (Postfix) with ESMTP id 52FA46B0036
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 12:04:33 -0500 (EST)
Received: by mail-ea0-f174.google.com with SMTP id b10so1703785eae.33
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 09:04:32 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id j48si3944116eew.163.2014.02.07.09.04.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 09:04:32 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 1/8] mm: memcg: remove unnecessary preemption disabling
Date: Fri,  7 Feb 2014 12:04:18 -0500
Message-Id: <1391792665-21678-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1391792665-21678-1-git-send-email-hannes@cmpxchg.org>
References: <1391792665-21678-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

lock_page_cgroup() disables preemption, remove explicit preemption
disabling for code paths holding this lock.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 15 ++++-----------
 1 file changed, 4 insertions(+), 11 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 53385cd4e6f0..befb3dd9d46c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -921,8 +921,6 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
 					 struct page *page,
 					 bool anon, int nr_pages)
 {
-	preempt_disable();
-
 	/*
 	 * Here, RSS means 'mapped anon' and anon's SwapCache. Shmem/tmpfs is
 	 * counted as CACHE even if it's on ANON LRU.
@@ -947,8 +945,6 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
 	}
 
 	__this_cpu_add(memcg->stat->nr_page_events, nr_pages);
-
-	preempt_enable();
 }
 
 unsigned long
@@ -3780,17 +3776,14 @@ void mem_cgroup_split_huge_fixup(struct page *head)
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
-static inline
-void mem_cgroup_move_account_page_stat(struct mem_cgroup *from,
-					struct mem_cgroup *to,
-					unsigned int nr_pages,
-					enum mem_cgroup_stat_index idx)
+static void mem_cgroup_move_account_page_stat(struct mem_cgroup *from,
+					      struct mem_cgroup *to,
+					      unsigned int nr_pages,
+					      enum mem_cgroup_stat_index idx)
 {
 	/* Update stat data for mem_cgroup */
-	preempt_disable();
 	__this_cpu_sub(from->stat->count[idx], nr_pages);
 	__this_cpu_add(to->stat->count[idx], nr_pages);
-	preempt_enable();
 }
 
 /**
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
