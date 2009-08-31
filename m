From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [RFC][PATCH 1/4] memcg: show memory.id in cgroupfs
Date: Mon, 31 Aug 2009 18:26:41 +0800
Message-ID: <20090831104216.648065078@intel.com>
References: <20090831102640.092092954@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B3E256B006A
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 06:43:32 -0400 (EDT)
Content-Disposition: inline; filename=memcg-show-id.patch
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, lizf@cn.fujitsu.com, nishimura@mxp.nes.nec.co.jp, menage@google.com, linux-mm <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

The hwpoison test suite need to selectively inject hwpoison to some
targeted task pages, and must not kill important system processes
such as init.

The memory cgroup serves this purpose well. We can put the target
processes under the control of a memory cgroup, tell the hwpoison
injection code the id of that memory cgroup so that it will only
poison pages associated with it.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/memcontrol.c |    9 +++++++++
 1 file changed, 9 insertions(+)

--- linux-mm.orig/mm/memcontrol.c	2009-08-31 15:27:34.000000000 +0800
+++ linux-mm/mm/memcontrol.c	2009-08-31 15:41:50.000000000 +0800
@@ -2510,6 +2510,11 @@ mem_cgroup_get_recursive_idx_stat(struct
 	*val = d.val;
 }
 
+static u64 mem_cgroup_id_read(struct cgroup *cont, struct cftype *cft)
+{
+	return css_id(cgroup_subsys_state(cont, mem_cgroup_subsys_id));
+}
+
 static u64 mem_cgroup_read(struct cgroup *cont, struct cftype *cft)
 {
 	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
@@ -2842,6 +2847,10 @@ static int mem_cgroup_swappiness_write(s
 
 static struct cftype mem_cgroup_files[] = {
 	{
+		.name = "id",
+		.read_u64 = mem_cgroup_id_read,
+	},
+	{
 		.name = "usage_in_bytes",
 		.private = MEMFILE_PRIVATE(_MEM, RES_USAGE),
 		.read_u64 = mem_cgroup_read,

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
