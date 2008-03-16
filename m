Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2GHUF5K014255
	for <linux-mm@kvack.org>; Sun, 16 Mar 2008 13:30:15 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2GHVLdl220486
	for <linux-mm@kvack.org>; Sun, 16 Mar 2008 11:31:21 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2GHVKXO008896
	for <linux-mm@kvack.org>; Sun, 16 Mar 2008 11:31:20 -0600
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Sun, 16 Mar 2008 22:59:53 +0530
Message-Id: <20080316172953.8812.50482.sendpatchset@localhost.localdomain>
In-Reply-To: <20080316172942.8812.56051.sendpatchset@localhost.localdomain>
References: <20080316172942.8812.56051.sendpatchset@localhost.localdomain>
Subject: [RFC][1/3] Add user interface for virtual address space control
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
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

 mm/memcontrol.c |   31 +++++++++++++++++++++++++++++++
 1 file changed, 31 insertions(+)

diff -puN mm/memcontrol.c~memory-controller-virtual-address-space-control-user-interface mm/memcontrol.c
--- linux-2.6.25-rc5/mm/memcontrol.c~memory-controller-virtual-address-space-control-user-interface	2008-03-16 22:57:38.000000000 +0530
+++ linux-2.6.25-rc5-balbir/mm/memcontrol.c	2008-03-16 22:57:38.000000000 +0530
@@ -128,6 +128,10 @@ struct mem_cgroup {
 	 */
 	struct res_counter res;
 	/*
+	 * Address space limits
+	 */
+	struct res_counter as_res;
+	/*
 	 * Per cgroup active and inactive list, similar to the
 	 * per zone LRU lists.
 	 */
@@ -870,6 +874,21 @@ static ssize_t mem_cgroup_write(struct c
 				mem_cgroup_write_strategy);
 }
 
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
+
 static ssize_t mem_force_empty_write(struct cgroup *cont,
 				struct cftype *cft, struct file *file,
 				const char __user *userbuf,
@@ -931,6 +950,17 @@ static struct cftype mem_cgroup_files[] 
 		.read_u64 = mem_cgroup_read,
 	},
 	{
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
+	{
 		.name = "failcnt",
 		.private = RES_FAILCNT,
 		.read_u64 = mem_cgroup_read,
@@ -999,6 +1029,7 @@ mem_cgroup_create(struct cgroup_subsys *
 		return ERR_PTR(-ENOMEM);
 
 	res_counter_init(&mem->res);
+	res_counter_init(&mem->as_res);
 
 	memset(&mem->info, 0, sizeof(mem->info));
 
diff -puN include/linux/memcontrol.h~memory-controller-virtual-address-space-control-user-interface include/linux/memcontrol.h
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
