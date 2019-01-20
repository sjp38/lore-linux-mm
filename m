Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 576348E0002
	for <linux-mm@kvack.org>; Sat, 19 Jan 2019 22:30:56 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id g12so10597718pll.22
        for <linux-mm@kvack.org>; Sat, 19 Jan 2019 19:30:56 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e39sor12518160plb.21.2019.01.19.19.30.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 19 Jan 2019 19:30:54 -0800 (PST)
From: Xiongchun Duan <duanxiongchun@bytedance.com>
Subject: [PATCH 1/5] Memcgroup: force empty after memcgroup offline
Date: Sat, 19 Jan 2019 22:30:17 -0500
Message-Id: <1547955021-11520-2-git-send-email-duanxiongchun@bytedance.com>
In-Reply-To: <1547955021-11520-1-git-send-email-duanxiongchun@bytedance.com>
References: <1547955021-11520-1-git-send-email-duanxiongchun@bytedance.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org, linux-mm@kvack.org
Cc: shy828301@gmail.com, mhocko@kernel.org, tj@kernel.org, hannes@cmpxchg.org, zhangyongsu@bytedance.com, liuxiaozhou@bytedance.com, zhengfeiran@bytedance.com, wangdongdong.6@bytedance.com, Xiongchun Duan <duanxiongchun@bytedance.com>

After memcgroup offline,if page still charge in memcgroup, this memcgroup will hold
in memory.in some system which has many memory(such 256G) will hold more than
100000 offline memcgroup. this memory can't be free as soon as possible.
Using workqueue and timer to repeatedly trigger offline memcgroup force empty
memory will solve this problem. the reason why need repeatedly trigger is
that force_empty fail to reclaim page when this page is locked.

Signed-off-by: Xiongchun Duan <duanxiongchun@bytedance.com>
---
 Documentation/cgroup-v1/memory.txt |  7 +++++--
 Documentation/sysctl/kernel.txt    | 10 ++++++++++
 include/linux/memcontrol.h         |  6 ++++++
 kernel/sysctl.c                    |  9 +++++++++
 mm/memcontrol.c                    | 17 +++++++++++++++++
 5 files changed, 47 insertions(+), 2 deletions(-)

diff --git a/Documentation/cgroup-v1/memory.txt b/Documentation/cgroup-v1/memory.txt
index 3682e99..bdba86f 100644
--- a/Documentation/cgroup-v1/memory.txt
+++ b/Documentation/cgroup-v1/memory.txt
@@ -452,11 +452,14 @@ About use_hierarchy, see Section 6.
 
 5.1 force_empty
   memory.force_empty interface is provided to make cgroup's memory usage empty.
-  When writing anything to this
+  When writing o or 1 or >18 to this
 
   # echo 0 > memory.force_empty
 
-  the cgroup will be reclaimed and as many pages reclaimed as possible.
+  the cgroup will be reclaimed and as many pages reclaimed as possible
+  synchronously.
+  writing 2 to 18 to this, the cgroup will delay the memory reclaim to css offline.
+  if memory reclaim fail one call, will delay to workqueue to recalaim as many as value.
 
   The typical use case for this interface is before calling rmdir().
   Because rmdir() moves all pages to parent, some out-of-use page caches can be
diff --git a/Documentation/sysctl/kernel.txt b/Documentation/sysctl/kernel.txt
index c0527d8..fc0b9b1 100644
--- a/Documentation/sysctl/kernel.txt
+++ b/Documentation/sysctl/kernel.txt
@@ -99,6 +99,7 @@ show up in /proc/sys/kernel:
 - unknown_nmi_panic
 - watchdog
 - watchdog_thresh
+- cgroup_default_retry
 - version
 
 ==============================================================
@@ -1137,3 +1138,12 @@ The softlockup threshold is (2 * watchdog_thresh). Setting this
 tunable to zero will disable lockup detection altogether.
 
 ==============================================================
+
+cgroup_default_retry:
+
+This value can be used to control the default of memory cgroup reclaim
+times . The default value is 0 .
+
+the max value is 16 the min value is 0.
+
+==============================================================
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 83ae11c..d6fbb77 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -311,9 +311,15 @@ struct mem_cgroup {
 	struct list_head event_list;
 	spinlock_t event_list_lock;
 
+	int max_retry;
+	int current_retry;
+
 	struct mem_cgroup_per_node *nodeinfo[0];
 	/* WARNING: nodeinfo must be the last member here */
 };
+extern int sysctl_cgroup_default_retry;
+extern int sysctl_cgroup_default_retry_min;
+extern int sysctl_cgroup_default_retry_max;
 
 /*
  * size of first charge trial. "32" comes from vmscan.c's magic value.
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index ba4d9e8..b6dbb10 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1252,6 +1252,15 @@ static int sysrq_sysctl_handler(struct ctl_table *table, int write,
 		.extra2		= &one,
 	},
 #endif
+	{
+		.procname       = "cgroup_default_retry",
+		.data           = &sysctl_cgroup_default_retry,
+		.maxlen         = sizeof(unsigned int),
+		.mode           = 0644,
+		.proc_handler   = proc_dointvec_minmax,
+		.extra1         = &sysctl_cgroup_default_retry_min,
+		.extra2         = &sysctl_cgroup_default_retry_max,
+	},
 	{ }
 };
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index af7f18b..2b13c2b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -77,6 +77,10 @@
 struct cgroup_subsys memory_cgrp_subsys __read_mostly;
 EXPORT_SYMBOL(memory_cgrp_subsys);
 
+int sysctl_cgroup_default_retry __read_mostly;
+int sysctl_cgroup_default_retry_min;
+int sysctl_cgroup_default_retry_max = 16;
+
 struct mem_cgroup *root_mem_cgroup __read_mostly;
 
 #define MEM_CGROUP_RECLAIM_RETRIES	5
@@ -2911,10 +2915,21 @@ static ssize_t mem_cgroup_force_empty_write(struct kernfs_open_file *of,
 					    char *buf, size_t nbytes,
 					    loff_t off)
 {
+	unsigned long val;
+	ssize_t ret;
 	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
 
 	if (mem_cgroup_is_root(memcg))
 		return -EINVAL;
+
+	buf = strstrip(buf);
+	ret = kstrtoul(buf, 10, &val);
+	if (ret < 0)
+		return ret;
+	if (val > 1 && val < 18) {
+		memcg->max_retry = val - 1;
+		return nbytes;
+	}
 	return mem_cgroup_force_empty(memcg) ?: nbytes;
 }
 
@@ -4521,6 +4536,8 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 
 	if (cgroup_subsys_on_dfl(memory_cgrp_subsys) && !cgroup_memory_nosocket)
 		static_branch_inc(&memcg_sockets_enabled_key);
+	memcg->max_retry = sysctl_cgroup_default_retry;
+	memcg->current_retry  = 0;
 
 	return &memcg->css;
 fail:
-- 
1.8.3.1
