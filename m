Date: Fri, 22 Aug 2008 20:30:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 1/14] memcg: unlimted root cgroup
Message-Id: <20080822203025.eb4b2ec3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Make root cgroup of memory resource controller to have no limit.

By this, users cannot set limit to root group. This is for making root cgroup
as a kind of trash-can.

For accounting pages which has no owner, which are created by force_empty,
we need some cgroup with no_limit. A patch for rewriting force_empty will
will follow this one.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 Documentation/controllers/memory.txt |    4 ++++
 mm/memcontrol.c                      |   12 ++++++++++++
 2 files changed, 16 insertions(+)

Index: mmtom-2.6.27-rc3+/mm/memcontrol.c
===================================================================
--- mmtom-2.6.27-rc3+.orig/mm/memcontrol.c
+++ mmtom-2.6.27-rc3+/mm/memcontrol.c
@@ -133,6 +133,10 @@ struct mem_cgroup {
 	 * statistics.
 	 */
 	struct mem_cgroup_stat stat;
+	/*
+	 * special flags.
+	 */
+	int	no_limit;
 };
 static struct mem_cgroup init_mem_cgroup;
 
@@ -920,6 +924,10 @@ static int mem_cgroup_write(struct cgrou
 
 	switch (cft->private) {
 	case RES_LIMIT:
+		if (memcg->no_limit == 1) {
+			ret = -EINVAL;
+			break;
+		}
 		/* This function does all necessary parse...reuse it */
 		ret = res_counter_memparse_write_strategy(buffer, &val);
 		if (!ret)
@@ -1119,6 +1127,10 @@ mem_cgroup_create(struct cgroup_subsys *
 		if (alloc_mem_cgroup_per_zone_info(mem, node))
 			goto free_out;
 
+	/* Default cgroup have no limit */
+	if (cont->parent == NULL)
+		mem->no_limit = 1;
+
 	return &mem->css;
 free_out:
 	for_each_node_state(node, N_POSSIBLE)
Index: mmtom-2.6.27-rc3+/Documentation/controllers/memory.txt
===================================================================
--- mmtom-2.6.27-rc3+.orig/Documentation/controllers/memory.txt
+++ mmtom-2.6.27-rc3+/Documentation/controllers/memory.txt
@@ -121,6 +121,9 @@ The corresponding routines that remove a
 a page from Page Cache is used to decrement the accounting counters of the
 cgroup.
 
+The root cgroup is not allowed to be set limit but usage is accounted.
+For controlling usage of memory, you need to create a cgroup.
+
 2.3 Shared Page Accounting
 
 Shared pages are accounted on the basis of the first touch approach. The
@@ -172,6 +175,7 @@ We can alter the memory limit:
 
 NOTE: We can use a suffix (k, K, m, M, g or G) to indicate values in kilo,
 mega or gigabytes.
+Note: root cgroup is not able to be set limit.
 
 # cat /cgroups/0/memory.limit_in_bytes
 4194304

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
