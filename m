Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id CF9876B0039
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:09:37 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fb1so977949pad.9
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 01:09:37 -0700 (PDT)
From: Ming Liu <ming.liu@windriver.com>
Subject: [PATCH V1] oom: avoid selecting threads sharing mm with init
Date: Thu, 26 Sep 2013 16:09:17 +0800
Message-ID: <1380182957-3231-1-git-send-email-ming.liu@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rientjes@google.com, mhocko@suse.cz, rusty@rustcorp.com.au, hannes@cmpxchg.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

It won't help free memory for killing tasks sharing mm with init, we should
skip them in oom_unkillable_task(), or we may risk init process getting
killed because after selecting a task to kill, the oom killer iterates all
processes and kills all other user threads that share the same mm_struct
in different thread groups.

In some extreme cases, the selected task happens to be a vfork child of
init process sharing the same mm_struct with it, which causes kernel
panic on init getting killed. This panic is observed in a busybox shell that
busybox itself is init, with a kthread keeps consuming memories.

Signed-off-by: Ming Liu <ming.liu@windriver.com>
---
 mm/oom_kill.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 314e9d2..7e50a95 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -113,11 +113,22 @@ struct task_struct *find_lock_task_mm(struct task_struct *p)
 static bool oom_unkillable_task(struct task_struct *p,
 		const struct mem_cgroup *memcg, const nodemask_t *nodemask)
 {
+	struct task_struct *init_tsk;
+
 	if (is_global_init(p))
 		return true;
 	if (p->flags & PF_KTHREAD)
 		return true;
 
+	/* It won't help free memory if p is sharing mm with init */
+	rcu_read_lock();
+	init_tsk = find_task_by_pid_ns(1, &init_pid_ns);
+	if(p->mm == init_tsk->mm) {
+		rcu_read_unlock();
+		return true;
+	}
+	rcu_read_unlock();
+
 	/* When mem_cgroup_out_of_memory() and p is not member of the group */
 	if (memcg && !task_in_mem_cgroup(p, memcg))
 		return true;
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
