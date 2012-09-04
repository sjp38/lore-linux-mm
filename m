Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id EA6EB6B0070
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 10:21:53 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [RFC 5/5] sched: add cpusets to comounts list
Date: Tue,  4 Sep 2012 18:18:20 +0400
Message-Id: <1346768300-10282-6-git-send-email-glommer@parallels.com>
In-Reply-To: <1346768300-10282-1-git-send-email-glommer@parallels.com>
References: <1346768300-10282-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, davej@redhat.com, ben@decadent.org.uk, a.p.zijlstra@chello.nl, pjt@google.com, lennart@poettering.net, kay.sievers@vrfy.org, tj@kernel.org, Glauber Costa <glommer@parallels.com>

Although we have not yet identified any place where cpusets could be
improved performance-wise by guaranteeing comounts with the other two
cpu cgroups, it is a sane choice to mount them together.

We can preemptively benefit from it and avoid a growing mess, by
guaranteeing that subsystems that mostly contraint the same kind of
resource will live together. With cgroups is never that simple, and
things crosses boundaries quite often. But I hope this can be seen as a
potential improvement.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Dave Jones <davej@redhat.com>
CC: Ben Hutchings <ben@decadent.org.uk>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Paul Turner <pjt@google.com>
CC: Lennart Poettering <lennart@poettering.net>
CC: Kay Sievers <kay.sievers@vrfy.org>
CC: Tejun Heo <tj@kernel.org>
---
 kernel/cpuset.c     | 4 ++++
 kernel/sched/core.c | 8 ++++----
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 8c8bd65..f8e1c49 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1879,6 +1879,10 @@ struct cgroup_subsys cpuset_subsys = {
 	.post_clone = cpuset_post_clone,
 	.subsys_id = cpuset_subsys_id,
 	.base_cftypes = files,
+#ifdef CONFIG_CGROUP_FORCE_COMOUNT_CPU
+	.comounts = 2,
+	.must_comount = { cpu_cgroup_subsys_id, cpuacct_subsys_id, },
+#endif
 	.early_init = 1,
 };
 
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index d654bd1..aeff02c 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -8301,8 +8301,8 @@ struct cgroup_subsys cpu_cgroup_subsys = {
 	.subsys_id	= cpu_cgroup_subsys_id,
 	.base_cftypes	= cpu_files,
 #ifdef CONFIG_CGROUP_FORCE_COMOUNT_CPU
-	.comounts	= 1,
-	.must_comount	= { cpuacct_subsys_id, },
+	.comounts	= 2,
+	.must_comount	= { cpuacct_subsys_id, cpuset_subsys_id, },
 	.bind		= cpu_cgroup_bind,
 #endif
 	.early_init	= 1,
@@ -8637,8 +8637,8 @@ struct cgroup_subsys cpuacct_subsys = {
 	.base_cftypes = files,
 	.bind = cpuacct_bind,
 #ifdef CONFIG_CGROUP_FORCE_COMOUNT_CPU
-	.comounts = 1,
-	.must_comount = { cpu_cgroup_subsys_id, },
+	.comounts = 2,
+	.must_comount = { cpu_cgroup_subsys_id, cpuset_subsys_id, },
 #endif
 };
 #endif	/* CONFIG_CGROUP_CPUACCT */
-- 
1.7.11.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
