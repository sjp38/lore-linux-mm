Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id 912746B0031
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 10:42:33 -0500 (EST)
Received: by mail-ee0-f45.google.com with SMTP id d49so2996813eek.4
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 07:42:33 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id h45si19632101eeo.67.2013.12.11.07.42.32
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 07:42:32 -0800 (PST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] memcg, oom: lock mem_cgroup_print_oom_info
Date: Wed, 11 Dec 2013 16:42:25 +0100
Message-Id: <1386776545-24916-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, David Rientjes <rientjes@google.com>

mem_cgroup_print_oom_info uses a static buffer (memcg_name) to store the
name of the cgroup. This is not safe as pointed out by David Rientjes
because memcg oom is locked only for its hierarchy and nothing prevents
another parallel hierarchy to trigger oom as well and overwrite the
already in-use buffer.

This patch introduces oom_info_lock hidden inside mem_cgroup_print_oom_info
which is held throughout the function. It make access to memcg_name safe
and as a bonus it also prevents parallel memcg ooms to interleave their
statistics which would make the printed data hard to analyze otherwise.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 28c9221b74ea..c72b03bf9679 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1647,13 +1647,13 @@ static void move_unlock_mem_cgroup(struct mem_cgroup *memcg,
  */
 void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 {
-	struct cgroup *task_cgrp;
-	struct cgroup *mem_cgrp;
 	/*
-	 * Need a buffer in BSS, can't rely on allocations. The code relies
-	 * on the assumption that OOM is serialized for memory controller.
-	 * If this assumption is broken, revisit this code.
+	 * protects memcg_name and makes sure that parallel ooms do not
+	 * interleave
 	 */
+	static DEFINE_SPINLOCK(oom_info_lock);
+	struct cgroup *task_cgrp;
+	struct cgroup *mem_cgrp;
 	static char memcg_name[PATH_MAX];
 	int ret;
 	struct mem_cgroup *iter;
@@ -1662,6 +1662,7 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 	if (!p)
 		return;
 
+	spin_lock(&oom_info_lock);
 	rcu_read_lock();
 
 	mem_cgrp = memcg->css.cgroup;
@@ -1730,6 +1731,7 @@ done:
 
 		pr_cont("\n");
 	}
+	spin_unlock(&oom_info_lock);
 }
 
 /*
-- 
1.8.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
