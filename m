Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 3C5836B008A
	for <linux-mm@kvack.org>; Fri, 29 May 2015 07:57:54 -0400 (EDT)
Received: by wgv5 with SMTP id 5so60616621wgv.1
        for <linux-mm@kvack.org>; Fri, 29 May 2015 04:57:53 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id he9si9173528wjc.173.2015.05.29.04.57.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 29 May 2015 04:57:38 -0700 (PDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC -v2 7/7] memcg: get rid of mem_cgroup_from_task
Date: Fri, 29 May 2015 13:57:25 +0200
Message-Id: <1432900645-8856-8-git-send-email-mhocko@suse.cz>
In-Reply-To: <1432900645-8856-1-git-send-email-mhocko@suse.cz>
References: <1432900645-8856-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

mem_cgroup_from_task has always been a tricky API. It was added
by 78fb74669e80 ("Memory controller: accounting setup") for
mm_struct::mem_cgroup initialization. Later on it gained new callers
mostly due to mm_struct::mem_cgroup -> mem_cgroup::owner transition and
most users had to do mem_cgroup_from_task(mm->owner) to get the
resulting memcg. Now that mm_struct::owner is gone this is not
necessary, yet the API is still confusing.

One tricky part has always been that the API sounds generic but it is
not really. mem_cgroup_from_task(current) doesn't necessarily mean the
same thing as current->mm->memcg (resp.
mem_cgroup_from_task(current->mm->owner) previously) because mm might be
associated with a different cgroup than the process.

Another tricky part is that p->mm->memcg is unsafe if p!=current
as pointed by Oleg because nobody is holding a reference on that
mm. This is not a problem right now because we have only 2 callers in
the tree. sock_update_memcg operates on current and task_in_mem_cgroup
is providing non-NULL task so it is always using task_css.

Let's ditch this function and use current->mm->memcg for
sock_update_memcg and use task_css for task_in_mem_cgroup. This doesn't
have any functional effect.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c | 24 +++++++-----------------
 1 file changed, 7 insertions(+), 17 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 33d2ed086673..7461a00cb3ee 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -292,18 +292,6 @@ static inline struct mem_cgroup *mem_cgroup_from_id(unsigned short id)
 	return mem_cgroup_from_css(css);
 }
 
-static struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
-{
-	if (p->mm)
-		return rcu_dereference(p->mm->memcg);
-
-	/*
-	 * If the process doesn't have mm struct anymore we have to fallback
-	 * to the task_css.
-	 */
-	return mem_cgroup_from_css(task_css(p, memory_cgrp_id));
-}
-
 /* Writing them here to avoid exposing memcg's inner layout */
 #if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
 
@@ -330,7 +318,7 @@ void sock_update_memcg(struct sock *sk)
 		}
 
 		rcu_read_lock();
-		memcg = mem_cgroup_from_task(current);
+		memcg = rcu_dereference(current->mm->memcg);
 		cg_proto = sk->sk_prot->proto_cgroup(memcg);
 		if (cg_proto && memcg_proto_active(cg_proto) &&
 		    css_tryget_online(&memcg->css)) {
@@ -1070,12 +1058,14 @@ bool task_in_mem_cgroup(struct task_struct *task, struct mem_cgroup *memcg)
 		task_unlock(p);
 	} else {
 		/*
-		 * All threads may have already detached their mm's, but the oom
-		 * killer still needs to detect if they have already been oom
-		 * killed to prevent needlessly killing additional tasks.
+		 * All threads have already detached their mm's but we should
+		 * still be able to at least guess the original memcg from the
+		 * task_css. These two will match most of the time but there are
+		 * corner cases where task->mm and task_css refer to a different
+		 * cgroups.
 		 */
 		rcu_read_lock();
-		task_memcg = mem_cgroup_from_task(task);
+		task_memcg = mem_cgroup_from_css(task_css(task, memory_cgrp_id));
 		css_get(&task_memcg->css);
 		rcu_read_unlock();
 	}
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
