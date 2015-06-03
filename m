Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 3E35A900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 11:20:01 -0400 (EDT)
Received: by padj3 with SMTP id j3so9348203pad.0
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 08:20:01 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id rc3si1419115pbc.149.2015.06.03.08.20.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jun 2015 08:20:00 -0700 (PDT)
Received: by pabqy3 with SMTP id qy3so9273096pab.3
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 08:20:00 -0700 (PDT)
Date: Thu, 4 Jun 2015 00:19:53 +0900
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH v2 -mm 1/2] memcg: remove unused mem_cgroup->oom_wakeups
Message-ID: <20150603151953.GF20091@mtj.duckdns.org>
References: <20150603023824.GA7579@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150603023824.GA7579@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

Since 4942642080ea ("mm: memcg: handle non-error OOM situations more
gracefully"), nobody uses mem_cgroup->oom_wakeups.  Remove it.

While at it, also fold memcg_wakeup_oom() into memcg_oom_recover()
which is its only user.  This cleanup was suggested by Michal.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>
---
Patch updated.  I dropped the comment as it's kinda obvious from the
context and the use of __wake_up().

Thanks.

 mm/memcontrol.c |   10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -287,7 +287,6 @@ struct mem_cgroup {
 
 	bool		oom_lock;
 	atomic_t	under_oom;
-	atomic_t	oom_wakeups;
 
 	int	swappiness;
 	/* OOM-Killer disable */
@@ -1850,17 +1849,10 @@ static int memcg_oom_wake_function(wait_
 	return autoremove_wake_function(wait, mode, sync, arg);
 }
 
-static void memcg_wakeup_oom(struct mem_cgroup *memcg)
-{
-	atomic_inc(&memcg->oom_wakeups);
-	/* for filtering, pass "memcg" as argument. */
-	__wake_up(&memcg_oom_waitq, TASK_NORMAL, 0, memcg);
-}
-
 static void memcg_oom_recover(struct mem_cgroup *memcg)
 {
 	if (memcg && atomic_read(&memcg->under_oom))
-		memcg_wakeup_oom(memcg);
+		__wake_up(&memcg_oom_waitq, TASK_NORMAL, 0, memcg);
 }
 
 static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
