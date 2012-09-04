Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 5D6F76B0069
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 10:21:52 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [RFC 1/5] cgroup: allow some comounts to be forced.
Date: Tue,  4 Sep 2012 18:18:16 +0400
Message-Id: <1346768300-10282-2-git-send-email-glommer@parallels.com>
In-Reply-To: <1346768300-10282-1-git-send-email-glommer@parallels.com>
References: <1346768300-10282-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, davej@redhat.com, ben@decadent.org.uk, a.p.zijlstra@chello.nl, pjt@google.com, lennart@poettering.net, kay.sievers@vrfy.org, tj@kernel.org, Glauber Costa <glommer@parallels.com>

One of the pain points we have today with cgroups, is the excessive
flexibility coming from the fact that controllers can be mounted at
will, without any relationship with each other.

Although this is nice in principle, this comes with a cost that is not
always welcome in practice. The very fact of this being possible is
already enough to trigger those costs. We cannot assume a common
hierarchy between controllers, and then hierarchy walks have to be done
more than once. This happens in hotpaths as well.

This patch introduces a Kconfig option, default n, that will force some
controllers to be comounted. After some time, we may be able to
deprecate this mode of operation.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Dave Jones <davej@redhat.com>
CC: Ben Hutchings <ben@decadent.org.uk>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Paul Turner <pjt@google.com>
CC: Lennart Poettering <lennart@poettering.net>
CC: Kay Sievers <kay.sievers@vrfy.org>
CC: Tejun Heo <tj@kernel.org>
---
 include/linux/cgroup.h |  6 ++++++
 init/Kconfig           |  4 ++++
 kernel/cgroup.c        | 29 ++++++++++++++++++++++++++++-
 3 files changed, 38 insertions(+), 1 deletion(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index d3f5fba..f986ad1 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -531,6 +531,12 @@ struct cgroup_subsys {
 
 	/* should be defined only by modular subsystems */
 	struct module *module;
+
+#ifdef CONFIG_CGROUP_FORCE_COMOUNT
+	/* List of groups that we must be comounted with */
+	int comounts;
+	int must_comount[3];
+#endif
 };
 
 #define SUBSYS(_x) extern struct cgroup_subsys _x ## _subsys;
diff --git a/init/Kconfig b/init/Kconfig
index f64f888..d7d693d 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -680,6 +680,10 @@ config CGROUP_CPUACCT
 	  Provides a simple Resource Controller for monitoring the
 	  total CPU consumed by the tasks in a cgroup.
 
+config CGROUP_FORCE_COMOUNT
+	bool
+	default n
+
 config RESOURCE_COUNTERS
 	bool "Resource counters"
 	help
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index b303dfc..137ac62 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1058,6 +1058,33 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 	if (root->number_of_cgroups > 1)
 		return -EBUSY;
 
+#ifdef CONFIG_CGROUP_FORCE_COMOUNT
+	/*
+	 * Some subsystems should not be allowed to be freely mounted in
+	 * separate hierarchies. They may not be present, but if they are, they
+	 * should be together. For compatibility with older kernels, we'll allow
+	 * this to live inside a separate Kconfig option. Each subsys will be
+	 * able to tell us which other subsys it expects to be mounted with.
+	 *
+	 * We do a separate path for this, to avoid unwinding our modifications
+	 * in case of an error.
+	 */
+	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
+		unsigned long bit = 1UL << i;
+		int j;
+
+		if (!(bit & added_bits))
+			continue;
+
+		for (j = 0; j < subsys[i]->comounts; j++) {
+			int comount_id = subsys[i]->must_comount[j];
+			struct cgroup_subsys *ss = subsys[comount_id];
+			if ((ss->root != &rootnode) && (ss->root != root))
+				return -EINVAL;
+		}
+	}
+#endif
+
 	/* Process each subsystem */
 	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
 		struct cgroup_subsys *ss = subsys[i];
@@ -1634,7 +1661,7 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 			goto unlock_drop;
 
 		ret = rebind_subsystems(root, root->subsys_bits);
-		if (ret == -EBUSY) {
+		if ((ret == -EBUSY) || (ret == -EINVAL)) {
 			free_cg_links(&tmp_cg_links);
 			goto unlock_drop;
 		}
-- 
1.7.11.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
