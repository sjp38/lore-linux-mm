Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 829A48D0039
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 01:55:45 -0500 (EST)
Message-ID: <4D660141.7020201@cn.fujitsu.com>
Date: Thu, 24 Feb 2011 14:57:05 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH v2 2/4] cpuset: Remove unneeded NODEMASK_ALLOC() in cpuset_attch()
References: <4D660130.8020009@cn.fujitsu.com>
In-Reply-To: <4D660130.8020009@cn.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Menage <menage@google.com>, David Rientjes <rientjes@google.com>, =?UTF-8?B?57yqIOWLsA==?= <miaox@cn.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

The variable 'from' is not modified after it's copied from
oldcs->mems_allowed, so we can just pass oldcs->mems_allowed
to cpuset_migrate_mm().

Acked-by: David Rientjes <rientjes@google.com>
Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 kernel/cpuset.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index e79650b..8fef8c6 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1438,10 +1438,9 @@ static void cpuset_attach(struct cgroup_subsys *ss, struct cgroup *cont,
 	struct mm_struct *mm;
 	struct cpuset *cs = cgroup_cs(cont);
 	struct cpuset *oldcs = cgroup_cs(oldcont);
-	NODEMASK_ALLOC(nodemask_t, from, GFP_KERNEL);
 	NODEMASK_ALLOC(nodemask_t, to, GFP_KERNEL);
 
-	if (from == NULL || to == NULL)
+	if (to == NULL)
 		goto alloc_fail;
 
 	if (cs == &top_cpuset) {
@@ -1463,18 +1462,16 @@ static void cpuset_attach(struct cgroup_subsys *ss, struct cgroup *cont,
 	}
 
 	/* change mm; only needs to be done once even if threadgroup */
-	*from = oldcs->mems_allowed;
 	*to = cs->mems_allowed;
 	mm = get_task_mm(tsk);
 	if (mm) {
 		mpol_rebind_mm(mm, to);
 		if (is_memory_migrate(cs))
-			cpuset_migrate_mm(mm, from, to);
+			cpuset_migrate_mm(mm, &oldcs->mems_allowed, to);
 		mmput(mm);
 	}
 
 alloc_fail:
-	NODEMASK_FREE(from);
 	NODEMASK_FREE(to);
 }
 
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
