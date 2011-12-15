Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id C4BE76B00CB
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 21:39:43 -0500 (EST)
Received: by yhgm50 with SMTP id m50so154031yhg.14
        for <linux-mm@kvack.org>; Wed, 14 Dec 2011 18:39:42 -0800 (PST)
Date: Wed, 14 Dec 2011 18:39:40 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch v2] oom, memcg: fix exclusion of memcg threads after they
 have detached their mm
In-Reply-To: <20111214102942.GA11786@tiehlicka.suse.cz>
Message-ID: <alpine.DEB.2.00.1112141838470.27595@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1112131659100.32369@chino.kir.corp.google.com> <20111214102942.GA11786@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org

oom, memcg: fix exclusion of memcg threads after they have detached their mm

The oom killer relies on logic that identifies threads that have already
been oom killed when scanning the tasklist and, if found, deferring until
such threads have exited.  This is done by checking for any candidate
threads that have the TIF_MEMDIE bit set.

For memcg ooms, candidate threads are first found by calling
task_in_mem_cgroup() since the oom killer should not defer if there's an
oom killed thread in another memcg.

Unfortunately, task_in_mem_cgroup() excludes threads if they have
detached their mm in the process of exiting so TIF_MEMDIE is never
detected for such conditions.  This is different for global, mempolicy,
and cpuset oom conditions where a detached mm is only excluded after
checking for TIF_MEMDIE and deferring, if necessary, in
select_bad_process().

The fix is to return true if a task has a detached mm but is still in the
memcg or its hierarchy that is currently oom.  This will allow the oom
killer to appropriately defer rather than kill unnecessarily or, in the
worst case, panic the machine if nothing else is available to kill.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/memcontrol.c |   17 +++++++++++++----
 1 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1109,10 +1109,19 @@ int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *memcg)
 	struct task_struct *p;
 
 	p = find_lock_task_mm(task);
-	if (!p)
-		return 0;
-	curr = try_get_mem_cgroup_from_mm(p->mm);
-	task_unlock(p);
+	if (p) {
+		curr = try_get_mem_cgroup_from_mm(p->mm);
+		task_unlock(p);
+	} else {
+		/*
+		 * All threads may have already detached their mm's, but the oom
+		 * killer still needs to detect if they have already been oom
+		 * killed to prevent needlessly killing additional tasks.
+		 */
+		curr = mem_cgroup_from_task(task);
+		if (curr)
+			css_get(&curr->css);
+	}
 	if (!curr)
 		return 0;
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
