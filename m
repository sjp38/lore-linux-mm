Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8E8C98D0039
	for <linux-mm@kvack.org>; Wed, 16 Feb 2011 20:48:35 -0500 (EST)
Message-ID: <4D5C7EBF.2070603@cn.fujitsu.com>
Date: Thu, 17 Feb 2011 09:49:51 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 2/4] cpuset: Remove unneeded NODEMASK_ALLOC() in cpuset_attch()
References: <4D5C7EA7.1030409@cn.fujitsu.com>
In-Reply-To: <4D5C7EA7.1030409@cn.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, David Rientjes <rientjes@google.com>, =?UTF-8?B?57yqIOWLsA==?= <miaox@cn.fujitsu.com>, linux-mm@kvack.org

oldcs->mems_allowed is not modified during cpuset_attch(), so
we don't have to copy it to a buffer allocated by NODEMASK_ALLOC().
Just pass it to cpuset_migrate_mm().

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 kernel/cpuset.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index f13ff2e..70c9ca2 100644
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
