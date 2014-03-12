Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f53.google.com (mail-bk0-f53.google.com [209.85.214.53])
	by kanga.kvack.org (Postfix) with ESMTP id AC1DA6B003A
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 21:28:51 -0400 (EDT)
Received: by mail-bk0-f53.google.com with SMTP id r7so1347326bkg.40
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 18:28:51 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id lp6si9813970bkb.267.2014.03.11.18.28.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Mar 2014 18:28:50 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/8] mm: memcg: remove mem_cgroup_move_account_page_stat()
Date: Tue, 11 Mar 2014 21:28:28 -0400
Message-Id: <1394587714-6966-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1394587714-6966-1-git-send-email-hannes@cmpxchg.org>
References: <1394587714-6966-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

It used to disable preemption and run sanity checks but now it's only
taking a number out of one percpu counter and putting it into another.
Do this directly in the callsite and save the indirection.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c | 28 ++++++++++++----------------
 1 file changed, 12 insertions(+), 16 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 393864c162ac..5abdfab957ad 100644
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
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
