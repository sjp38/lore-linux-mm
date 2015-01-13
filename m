Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id BBECD6B0032
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 01:46:03 -0500 (EST)
Received: by mail-ig0-f179.google.com with SMTP id l13so1718601iga.0
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 22:46:03 -0800 (PST)
Received: from mail-ie0-x22e.google.com (mail-ie0-x22e.google.com. [2607:f8b0:4001:c03::22e])
        by mx.google.com with ESMTPS id eh8si6032002igb.48.2015.01.12.22.46.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 Jan 2015 22:46:02 -0800 (PST)
Received: by mail-ie0-f174.google.com with SMTP id at20so1216403iec.5
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 22:46:01 -0800 (PST)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH] memcg: remove extra newlines from memcg oom kill log
Date: Mon, 12 Jan 2015 22:45:39 -0800
Message-Id: <1421131539-3211-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Thelen <gthelen@google.com>

Commit e61734c55c24 ("cgroup: remove cgroup->name") added two extra
newlines to memcg oom kill log messages.  This makes dmesg hard to read
and parse.  The issue affects 3.15+.
Example:
  Task in /t                          <<< extra #1
   killed as a result of limit of /t
                                      <<< extra #2
  memory: usage 102400kB, limit 102400kB, failcnt 274712

Remove the extra newlines from memcg oom kill messages, so the messages
look like:
  Task in /t killed as a result of limit of /t
  memory: usage 102400kB, limit 102400kB, failcnt 240649

Fixes: e61734c55c24 ("cgroup: remove cgroup->name")
Signed-off-by: Greg Thelen <gthelen@google.com>
---
 mm/memcontrol.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 851924fa5170..683b4782019b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1477,9 +1477,9 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 
 	pr_info("Task in ");
 	pr_cont_cgroup_path(task_cgroup(p, memory_cgrp_id));
-	pr_info(" killed as a result of limit of ");
+	pr_cont(" killed as a result of limit of ");
 	pr_cont_cgroup_path(memcg->css.cgroup);
-	pr_info("\n");
+	pr_cont("\n");
 
 	rcu_read_unlock();
 
-- 
2.2.0.rc0.207.ga3a616c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
