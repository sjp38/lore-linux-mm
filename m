Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id 5C2306B0069
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 09:49:55 -0400 (EDT)
Received: by mail-lb0-f172.google.com with SMTP id b6so2600511lbj.31
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 06:49:54 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id la5si7081716lac.99.2014.10.24.06.49.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Oct 2014 06:49:53 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 1/3] mm: memcontrol: remove bogus NULL check after mem_cgroup_from_task()
Date: Fri, 24 Oct 2014 09:49:47 -0400
Message-Id: <1414158589-26094-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

That function acts like a typecast - unless NULL is passed in, no NULL
can come out.  task_in_mem_cgroup() callers don't pass NULL tasks.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 23cf27cca370..bdf8520979cf 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1335,7 +1335,7 @@ static bool mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,
 bool task_in_mem_cgroup(struct task_struct *task,
 			const struct mem_cgroup *memcg)
 {
-	struct mem_cgroup *curr = NULL;
+	struct mem_cgroup *curr;
 	struct task_struct *p;
 	bool ret;
 
@@ -1351,8 +1351,7 @@ bool task_in_mem_cgroup(struct task_struct *task,
 		 */
 		rcu_read_lock();
 		curr = mem_cgroup_from_task(task);
-		if (curr)
-			css_get(&curr->css);
+		css_get(&curr->css);
 		rcu_read_unlock();
 	}
 	/*
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
