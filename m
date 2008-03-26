Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2QIrRhp029516
	for <linux-mm@kvack.org>; Wed, 26 Mar 2008 14:53:27 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2QIrQN1192492
	for <linux-mm@kvack.org>; Wed, 26 Mar 2008 12:53:26 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2QIrQoU002482
	for <linux-mm@kvack.org>; Wed, 26 Mar 2008 12:53:26 -0600
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Thu, 27 Mar 2008 00:20:06 +0530
Message-Id: <20080326185006.9465.4720.sendpatchset@localhost.localdomain>
In-Reply-To: <20080326184954.9465.19379.sendpatchset@localhost.localdomain>
References: <20080326184954.9465.19379.sendpatchset@localhost.localdomain>
Subject: [RFC][1/3] Add user interface for virtual address space control (v2)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>
Cc: Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


Add as_usage_in_bytes and as_limit_in_bytes interfaces. These provide
control over the total address space that the processes combined together
in the cgroup can grow upto. This functionality is analogous to
the RLIMIT_AS function of the getrlimit(2) and setrlimit(2) calls.
A as_res resource counter is added to the mem_cgroup structure. The
as_res counter handles all the accounting associated with the virtual
address space accounting and control of cgroups.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 init/Kconfig    |   10 ++++++++++
 mm/memcontrol.c |   39 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 49 insertions(+)

diff -puN mm/memcontrol.c~memory-controller-virtual-address-space-control-user-interface mm/memcontrol.c
--- linux-2.6.25-rc5/mm/memcontrol.c~memory-controller-virtual-address-space-control-user-interface	2008-03-26 16:00:42.000000000 +0530
+++ linux-2.6.25-rc5-balbir/mm/memcontrol.c	2008-03-26 16:07:56.000000000 +0530
@@ -127,6 +127,12 @@ struct mem_cgroup {
 	 * the counter to account for memory usage
 	 */
 	struct res_counter res;
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_AS
+	/*
+	 * Address space limits
+	 */
+	struct res_counter as_res;
+#endif
 	/*
 	 * Per cgroup active and inactive list, similar to the
 	 * per zone LRU lists.
@@ -870,6 +876,23 @@ static ssize_t mem_cgroup_write(struct c
 				mem_cgroup_write_strategy);
 }
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_AS
+static u64 mem_cgroup_as_read(struct cgroup *cont, struct cftype *cft)
+{
+	return res_counter_read_u64(&mem_cgroup_from_cont(cont)->as_res,
+				    cft->private);
+}
+
+static ssize_t mem_cgroup_as_write(struct cgroup *cont, struct cftype *cft,
+				struct file *file, const char __user *userbuf,
+				size_t nbytes, loff_t *ppos)
+{
+	return res_counter_write(&mem_cgroup_from_cont(cont)->as_res,
+				cft->private, userbuf, nbytes, ppos,
+				mem_cgroup_write_strategy);
+}
+#endif
+
 static ssize_t mem_force_empty_write(struct cgroup *cont,
 				struct cftype *cft, struct file *file,
 				const char __user *userbuf,
@@ -943,6 +966,19 @@ static struct cftype mem_cgroup_files[] 
 		.name = "stat",
 		.read_map = mem_control_stat_show,
 	},
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_AS
+	{
+		.name = "as_usage_in_bytes",
+		.private = RES_USAGE,
+		.read_u64 = mem_cgroup_as_read,
+	},
+	{
+		.name = "as_limit_in_bytes",
+		.private = RES_LIMIT,
+		.write = mem_cgroup_as_write,
+		.read_u64 = mem_cgroup_as_read,
+	},
+#endif
 };
 
 static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
@@ -999,6 +1035,9 @@ mem_cgroup_create(struct cgroup_subsys *
 		return ERR_PTR(-ENOMEM);
 
 	res_counter_init(&mem->res);
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_AS
+	res_counter_init(&mem->as_res);
+#endif
 
 	memset(&mem->info, 0, sizeof(mem->info));
 
diff -puN include/linux/memcontrol.h~memory-controller-virtual-address-space-control-user-interface include/linux/memcontrol.h
diff -puN init/Kconfig~memory-controller-virtual-address-space-control-user-interface init/Kconfig
--- linux-2.6.25-rc5/init/Kconfig~memory-controller-virtual-address-space-control-user-interface	2008-03-26 16:06:34.000000000 +0530
+++ linux-2.6.25-rc5-balbir/init/Kconfig	2008-03-26 16:13:06.000000000 +0530
@@ -379,6 +379,16 @@ config CGROUP_MEM_RES_CTLR
 	  Only enable when you're ok with these trade offs and really
 	  sure you need the memory resource controller.
 
+confg CGROUP_MEM_RES_CTLR_AS
+	bool "Virtual Address Space Controller for Control Groups"
+	depends on CGROUP_MEM_RES_CTLR
+	help
+	  Provides control over the maximum amount of virtual address space
+	  that can be consumed by the tasks in the cgroup. Setting a reasonable
+	  address limit will allow applications to fail more gracefully and
+	  avoid forceful reclaim or OOM when a cgroup exceeds it's memory
+	  limit.
+
 config SYSFS_DEPRECATED
 	bool
 
_

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
