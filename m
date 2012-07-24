Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 2E3186B005A
	for <linux-mm@kvack.org>; Tue, 24 Jul 2012 12:12:25 -0400 (EDT)
Received: by yenr5 with SMTP id r5so8330540yen.14
        for <linux-mm@kvack.org>; Tue, 24 Jul 2012 09:12:24 -0700 (PDT)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH 2/2] memcg, oom: Clarify some oom dump messages
Date: Wed, 25 Jul 2012 00:12:14 +0800
Message-Id: <1343146334-15161-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1343146160-15012-1-git-send-email-handai.szj@taobao.com>
References: <1343146160-15012-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org
Cc: Sha Zhengju <handai.szj@taobao.com>, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, mhocko@suse.cz, gthelen@google.com, hannes@cmpxchg.org, rientjes@google.com

From: Sha Zhengju <handai.szj@taobao.com>

Revise some oom dump messages to avoid misleading admin.

Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
Cc: kamezawa.hiroyu@jp.fujitsu.com
Cc: akpm@linux-foundation.org
Cc: mhocko@suse.cz
Cc: gthelen@google.com
Cc: hannes@cmpxchg.org
Cc: rientjes@google.com
---
 mm/memcontrol.c |    2 +-
 mm/oom_kill.c   |    5 +++--
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a3037af..7ce605c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1472,7 +1472,7 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 	}
 	rcu_read_unlock();
 
-	printk(KERN_INFO "Task in %s killed", memcg_name);
+	printk(KERN_INFO "Task in %s will be killed", memcg_name);
 
 	rcu_read_lock();
 	ret = cgroup_path(mem_cgrp, memcg_name, PATH_MAX);
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index b47ed97..3fc9f99 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -471,7 +471,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 		dump_header(p, gfp_mask, order, memcg, nodemask);
 
 	task_lock(p);
-	pr_err("%s: Kill process %d (%s) score %d or sacrifice child\n",
+	pr_err("%s: Will kill process %d (%s) score %d or sacrifice child\n",
 		message, task_pid_nr(p), p->comm, points);
 	task_unlock(p);
 
@@ -508,6 +508,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	if (!p) {
 		rcu_read_unlock();
 		put_task_struct(victim);
+		pr_err("No process has been killed!\n");
 		return;
 	} else if (victim != p) {
 		get_task_struct(p);
@@ -539,7 +540,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 				continue;
 
 			task_lock(p);	/* Protect ->comm from prctl() */
-			pr_err("Kill process %d (%s) sharing same memory\n",
+			pr_err("Killed process %d (%s) sharing same memory\n",
 				task_pid_nr(p), p->comm);
 			task_unlock(p);
 			do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
