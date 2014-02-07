Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id D1DAE6B0037
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 12:04:34 -0500 (EST)
Received: by mail-ee0-f45.google.com with SMTP id b15so1668332eek.4
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 09:04:34 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id f45si9341326eep.194.2014.02.07.09.04.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 09:04:33 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/8] mm: memcg: remove mem_cgroup_move_account_page_stat()
Date: Fri,  7 Feb 2014 12:04:19 -0500
Message-Id: <1391792665-21678-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1391792665-21678-1-git-send-email-hannes@cmpxchg.org>
References: <1391792665-21678-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

It used to disable preemption and run sanity checks but now it's only
taking a number out of one percpu counter and putting it into another.
Do this directly in the callsite and save the indirection.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 28 ++++++++++++----------------
 1 file changed, 12 insertions(+), 16 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index befb3dd9d46c..639cf58b2643 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3776,16 +3776,6 @@ void mem_cgroup_split_huge_fixup(struct page *head)
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
-static void mem_cgroup_move_account_page_stat(struct mem_cgroup *from,
-					      struct mem_cgroup *to,
-					      unsigned int nr_pages,
-					      enum mem_cgroup_stat_index idx)
-{
-	/* Update stat data for mem_cgroup */
-	__this_cpu_sub(from->stat->count[idx], nr_pages);
-	__this_cpu_add(to->stat->count[idx], nr_pages);
-}
-
 /**
  * mem_cgroup_move_account - move account of the page
  * @page: the page
@@ -3831,13 +3821,19 @@ static int mem_cgroup_move_account(struct page *page,
 
 	move_lock_mem_cgroup(from, &flags);
 
-	if (!anon && page_mapped(page))
-		mem_cgroup_move_account_page_stat(from, to, nr_pages,
-			MEM_CGROUP_STAT_FILE_MAPPED);
+	if (!anon && page_mapped(page)) {
+		__this_cpu_sub(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED],
+			       nr_pages);
+		__this_cpu_add(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED],
+			       nr_pages);
+	}
 
-	if (PageWriteback(page))
-		mem_cgroup_move_account_page_stat(from, to, nr_pages,
-			MEM_CGROUP_STAT_WRITEBACK);
+	if (PageWriteback(page)) {
+		__this_cpu_sub(from->stat->count[MEM_CGROUP_STAT_WRITEBACK],
+			       nr_pages);
+		__this_cpu_add(to->stat->count[MEM_CGROUP_STAT_WRITEBACK],
+			       nr_pages);
+	}
 
 	mem_cgroup_charge_statistics(from, page, anon, -nr_pages);
 
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
