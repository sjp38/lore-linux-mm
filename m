Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 63B616B016C
	for <linux-mm@kvack.org>; Wed,  7 Sep 2011 00:24:58 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v2 2/9] Kernel Memory cgroup
Date: Wed,  7 Sep 2011 01:23:12 -0300
Message-Id: <1315369399-3073-3-git-send-email-glommer@parallels.com>
In-Reply-To: <1315369399-3073-1-git-send-email-glommer@parallels.com>
References: <1315369399-3073-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, containers@lists.osdl.org, netdev@vger.kernel.org, xemul@parallels.com, Glauber Costa <glommer@parallels.com>, "David S. Miller" <davem@davemloft.net>, Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>, "Eric W. Biederman" <ebiederm@xmission.com>

This patch introduces the kernel memory cgroup. Its purpose
is to track and control/limit allocation of kernel objects.
Kernel objects are very different in nature than user memory,
because they can't be swapped out, so can't be overcommited.

The first incarnation is very simple. The current patch doesn't
add any objects to be tracked, but rather, just the cgroup
structure.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: David S. Miller <davem@davemloft.net>
CC: Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>
CC: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/cgroup_subsys.h |    4 +++
 include/linux/kmem_cgroup.h   |   53 +++++++++++++++++++++++++++++++++++++++++
 init/Kconfig                  |   11 ++++++++
 mm/Makefile                   |    1 +
 mm/kmem_cgroup.c              |   53 +++++++++++++++++++++++++++++++++++++++++
 5 files changed, 122 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/kmem_cgroup.h
 create mode 100644 mm/kmem_cgroup.c

diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
index ac663c1..363b8e8 100644
--- a/include/linux/cgroup_subsys.h
+++ b/include/linux/cgroup_subsys.h
@@ -35,6 +35,10 @@ SUBSYS(cpuacct)
 SUBSYS(mem_cgroup)
 #endif
 
+#ifdef CONFIG_CGROUP_KMEM
+SUBSYS(kmem)
+#endif
+
 /* */
 
 #ifdef CONFIG_CGROUP_DEVICE
diff --git a/include/linux/kmem_cgroup.h b/include/linux/kmem_cgroup.h
new file mode 100644
index 0000000..0e4a74b
--- /dev/null
+++ b/include/linux/kmem_cgroup.h
@@ -0,0 +1,53 @@
+/* kmem_cgroup.h - Kernel Memory Controller
+ *
+ * Copyright Parallels Inc., 2011
+ * Author: Glauber Costa <glommer@parallels.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#ifndef _LINUX_KMEM_CGROUP_H
+#define _LINUX_KMEM_CGROUP_H
+#include <linux/cgroup.h>
+#include <linux/atomic.h>
+#include <linux/percpu_counter.h>
+
+struct kmem_cgroup {
+	struct cgroup_subsys_state css;
+	struct kmem_cgroup *parent;
+};
+
+
+#ifdef CONFIG_CGROUP_KMEM
+static inline struct kmem_cgroup *kcg_from_cgroup(struct cgroup *cgrp)
+{
+	return container_of(cgroup_subsys_state(cgrp, kmem_subsys_id),
+		struct kmem_cgroup, css);
+}
+
+static inline struct kmem_cgroup *kcg_from_task(struct task_struct *tsk)
+{
+	return container_of(task_subsys_state(tsk, kmem_subsys_id),
+		struct kmem_cgroup, css);
+}
+#else
+static inline struct kmem_cgroup *kcg_from_cgroup(struct cgroup *cgrp)
+{
+	return NULL;
+}
+
+static inline struct kmem_cgroup *kcg_from_task(struct task_struct *tsk)
+{
+	return NULL;
+}
+#endif /* CONFIG_CGROUP_KMEM */
+#endif /* _LINUX_KMEM_CGROUP_H */
+
diff --git a/init/Kconfig b/init/Kconfig
index d627783..5955ac2 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -690,6 +690,17 @@ config CGROUP_MEM_RES_CTLR_SWAP_ENABLED
 	  select this option (if, for some reason, they need to disable it
 	  then swapaccount=0 does the trick).
 
+config CGROUP_KMEM
+	bool "Kernel Memory Resource Controller for Control Groups"
+	depends on CGROUPS
+	help
+	  The Kernel Memory cgroup can limit the amount of memory used by
+	  certain kernel objects in the system. Those are fundamentally
+	  different from the entities handled by the Memory Controller,
+	  which are page-based, and can be swapped. Users of the kmem
+	  cgroup can use it to guarantee that no group of processes will
+	  ever exhaust kernel resources alone.
+
 config CGROUP_PERF
 	bool "Enable perf_event per-cpu per-container group (cgroup) monitoring"
 	depends on PERF_EVENTS && CGROUPS
diff --git a/mm/Makefile b/mm/Makefile
index 836e416..1b1aa24 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -45,6 +45,7 @@ obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
 obj-$(CONFIG_TRANSPARENT_HUGEPAGE) += huge_memory.o
 obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o page_cgroup.o
+obj-$(CONFIG_CGROUP_KMEM) += kmem_cgroup.o
 obj-$(CONFIG_MEMORY_FAILURE) += memory-failure.o
 obj-$(CONFIG_HWPOISON_INJECT) += hwpoison-inject.o
 obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
diff --git a/mm/kmem_cgroup.c b/mm/kmem_cgroup.c
new file mode 100644
index 0000000..7950e69
--- /dev/null
+++ b/mm/kmem_cgroup.c
@@ -0,0 +1,53 @@
+/* kmem_cgroup.c - Kernel Memory Controller
+ *
+ * Copyright Parallels Inc, 2011
+ * Author: Glauber Costa <glommer@parallels.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#include <linux/cgroup.h>
+#include <linux/slab.h>
+#include <linux/kmem_cgroup.h>
+
+static int kmem_populate(struct cgroup_subsys *ss, struct cgroup *cgrp)
+{
+	return 0;
+}
+
+static void
+kmem_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp)
+{
+	struct kmem_cgroup *cg = kcg_from_cgroup(cgrp);
+	kfree(cg);
+}
+
+static struct cgroup_subsys_state *kmem_create(
+	struct cgroup_subsys *ss, struct cgroup *cgrp)
+{
+	struct kmem_cgroup *sk = kzalloc(sizeof(*sk), GFP_KERNEL);
+
+	if (!sk)
+		return ERR_PTR(-ENOMEM);
+
+	if (cgrp->parent)
+		sk->parent = kcg_from_cgroup(cgrp->parent);
+
+	return &sk->css;
+}
+
+struct cgroup_subsys kmem_subsys = {
+	.name = "kmem",
+	.create = kmem_create,
+	.destroy = kmem_destroy,
+	.populate = kmem_populate,
+	.subsys_id = kmem_subsys_id,
+};
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
