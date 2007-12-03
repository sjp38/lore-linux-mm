Date: Mon, 3 Dec 2007 18:37:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][for -mm] memory controller enhancements for reclaiming take2
 [3/8] define free_mem_cgroup_per_zone_info
Message-Id: <20071203183719.b929cb92.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071203183355.0061ddeb.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071203183355.0061ddeb.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "riel@redhat.com" <riel@redhat.com>, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

Now allocation of per_zone of mem_controller is done by
alloc_mem_cgroup_per_zone_info(). Then it will be good to use
free_mem_cgroup_per_zone_info() for maintainance.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


 mm/memcontrol.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

Index: linux-2.6.24-rc3-mm2/mm/memcontrol.c
===================================================================
--- linux-2.6.24-rc3-mm2.orig/mm/memcontrol.c
+++ linux-2.6.24-rc3-mm2/mm/memcontrol.c
@@ -1141,6 +1141,11 @@ static int alloc_mem_cgroup_per_zone_inf
 	return 0;
 }
 
+static void free_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
+{
+	kfree(mem->info.nodeinfo[node]);
+}
+
 
 static struct mem_cgroup init_mem_cgroup;
 
@@ -1171,7 +1176,7 @@ mem_cgroup_create(struct cgroup_subsys *
 	return &mem->css;
 free_out:
 	for_each_node_state(node, N_POSSIBLE)
-		kfree(mem->info.nodeinfo[node]);
+		free_mem_cgroup_per_zone_info(mem, node);
 	if (cont->parent != NULL)
 		kfree(mem);
 	return NULL;
@@ -1191,7 +1196,7 @@ static void mem_cgroup_destroy(struct cg
 	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
 
 	for_each_node_state(node, N_POSSIBLE)
-		kfree(mem->info.nodeinfo[node]);
+		free_mem_cgroup_per_zone_info(mem, node);
 
 	kfree(mem_cgroup_from_cont(cont));
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
