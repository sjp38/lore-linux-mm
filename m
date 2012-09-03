Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 06F126B0074
	for <linux-mm@kvack.org>; Mon,  3 Sep 2012 11:50:36 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v2] memcg: first step towards hierarchical controller
Date: Mon,  3 Sep 2012 19:46:51 +0400
Message-Id: <1346687211-31848-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Glauber Costa <glommer@parallels.com>, Dave Jones <davej@redhat.com>, Ben Hutchings <ben@decadent.org.uk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lennart Poettering <lennart@poettering.net>, Kay Sievers <kay.sievers@vrfy.org>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>

Here is a new attempt to lay down a path that will allow us to deprecate
the non-hierarchical mode of operation from memcg.  Unlike what I posted
before, I am making this behavior conditional on a Kconfig option.
Vanilla users will see no change in behavior unless they don't
explicitly set this option to on.

Distributions, however, are encouraged to set it.  In that case,
hierarchy will still be there. We'll just default to true in the root
cgroup, and print a warning once if you try to set it back to 0.

After a grace period, we should be able to gauge if anyone actually
relies on it and get rid of the hierarchy file, or at least of its
behavior.

[ v2: make it dependent on a Kconfig option ]

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Dave Jones <davej@redhat.com>
CC: Ben Hutchings <ben@decadent.org.uk>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Paul Turner <pjt@google.com>
CC: Lennart Poettering <lennart@poettering.net>
CC: Kay Sievers <kay.sievers@vrfy.org>
CC: Michal Hocko <mhocko@suse.cz>
CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: Tejun Heo <tj@kernel.org>
---
 init/Kconfig    | 18 ++++++++++++++++++
 mm/memcontrol.c |  9 +++++++++
 2 files changed, 27 insertions(+)

diff --git a/init/Kconfig b/init/Kconfig
index 707d015..f64f888 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -726,6 +726,24 @@ config MEMCG_SWAP
 	  if boot option "swapaccount=0" is set, swap will not be accounted.
 	  Now, memory usage of swap_cgroup is 2 bytes per entry. If swap page
 	  size is 4096bytes, 512k per 1Gbytes of swap.
+
+config MEMCG_HIERARCHY_DEFAULT
+	bool "Hierarchical memcg"
+	depends on MEMCG
+	default n
+	help
+	  The memory controller has two modes of accounting: hierarchical and
+	  flat. Hierarchical accounting will charge pages all the way towards a
+	  group's parent while flat hierarchy will threat all groups as children
+	  of the root memcg, regardless of their positioning in the tree.
+
+	  Use of flat hierarchies is highly discouraged, but has been the
+	  default for performance reasons for quite some time. Setting this flag
+	  to on will make hierarchical accounting the default. It is still
+	  possible to set it back to flat by writing 0 to the file
+	  memory.use_hierarchy, albeit discouraged. Distributors are encouraged
+	  to set this option.
+
 config MEMCG_SWAP_ENABLED
 	bool "Memory Resource Controller Swap Extension enabled by default"
 	depends on MEMCG_SWAP
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 61831c33..ab79746 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4073,6 +4073,12 @@ static int mem_cgroup_hierarchy_write(struct cgroup *cont, struct cftype *cft,
 	if (memcg->use_hierarchy == val)
 		goto out;
 
+#ifdef CONFIG_MEMCG_HIERARCHY_DEFAULT
+	WARN_ONCE((!parent_memcg && memcg->use_hierarchy && val == false),
+	"Setting this file to 0 (flat hierarchy) is considered deprecated.\n"
+	"If you believe you have a valid use case for that, we kindly ask you to contact linux-mm@kvack.org and let us know");
+#endif
+
 	/*
 	 * If parent's use_hierarchy is set, we can't make any modifications
 	 * in the child subtrees. If it is unset, then the change can
@@ -5325,6 +5331,9 @@ mem_cgroup_create(struct cgroup *cont)
 			INIT_WORK(&stock->work, drain_local_stock);
 		}
 		hotcpu_notifier(memcg_cpu_hotplug_callback, 0);
+#ifdef CONFIG_MEMCG_HIERARCHY_DEFAULT
+		memcg->use_hierarchy = true;
+#endif
 	} else {
 		parent = mem_cgroup_from_cont(cont->parent);
 		memcg->use_hierarchy = parent->use_hierarchy;
-- 
1.7.11.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
