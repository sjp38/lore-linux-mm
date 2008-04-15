Date: Tue, 15 Apr 2008 14:12:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] use vmalloc for mem_cgroup allocation. v3
Message-Id: <20080415141208.8be5af56.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080415105434.3044afb6.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080415105434.3044afb6.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, lizf@cn.fujitsu.com, menage@google.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Tested on ia64/NUMA and x86/smp.
==
On ia64, this kmalloc() requires order-4 pages. But this is not
necessary to be phisically contiguous. 
For big mem_cgroup, vmalloc is better. For small ones, kmalloc is used.


Changelog: v2->v3
 - fixed the place of memset.
 - added mem_cgroup_alloc()/free()
 - use kmalloc if mem_cgroup is enough small.
Changelog: v1->v2
 - added memset().

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: mm-2.6.25-rc8-mm2/mm/memcontrol.c
===================================================================
--- mm-2.6.25-rc8-mm2.orig/mm/memcontrol.c
+++ mm-2.6.25-rc8-mm2/mm/memcontrol.c
@@ -31,6 +31,7 @@
 #include <linux/spinlock.h>
 #include <linux/fs.h>
 #include <linux/seq_file.h>
+#include <linux/vmalloc.h>
 
 #include <asm/uaccess.h>
 
@@ -983,6 +984,31 @@ static void free_mem_cgroup_per_zone_inf
 	kfree(mem->info.nodeinfo[node]);
 }
 
+static struct mem_cgroup *mem_cgroup_alloc(void)
+{
+	struct mem_cgroup *mem;
+
+	if (sizeof(*mem) < PAGE_SIZE)
+		mem = kmalloc(sizeof(*mem), GFP_KERNEL);
+	else
+		mem = vmalloc(sizeof(*mem));
+
+	if (!mem)
+		return NULL;
+
+	memset(mem, 0, sizeof(*mem));
+	return mem;
+}
+
+static void mem_cgroup_free(struct mem_cgroup *mem)
+{
+	if (sizeof(*mem) < PAGE_SIZE)
+		kfree(mem);
+	else
+		vfree(mem);
+}
+
+
 static struct cgroup_subsys_state *
 mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 {
@@ -992,11 +1018,11 @@ mem_cgroup_create(struct cgroup_subsys *
 	if (unlikely((cont->parent) == NULL)) {
 		mem = &init_mem_cgroup;
 		page_cgroup_cache = KMEM_CACHE(page_cgroup, SLAB_PANIC);
-	} else
-		mem = kzalloc(sizeof(struct mem_cgroup), GFP_KERNEL);
-
-	if (mem == NULL)
-		return ERR_PTR(-ENOMEM);
+	} else {
+		mem = mem_cgroup_alloc();
+		if (!mem)
+			return ERR_PTR(-ENOMEM);
+	}
 
 	res_counter_init(&mem->res);
 
@@ -1011,7 +1037,7 @@ free_out:
 	for_each_node_state(node, N_POSSIBLE)
 		free_mem_cgroup_per_zone_info(mem, node);
 	if (cont->parent != NULL)
-		kfree(mem);
+		mem_cgroup_free(mem);
 	return ERR_PTR(-ENOMEM);
 }
 
@@ -1031,7 +1057,7 @@ static void mem_cgroup_destroy(struct cg
 	for_each_node_state(node, N_POSSIBLE)
 		free_mem_cgroup_per_zone_info(mem, node);
 
-	kfree(mem_cgroup_from_cont(cont));
+	mem_cgroup_free(mem_cgroup_from_cont(cont));
 }
 
 static int mem_cgroup_populate(struct cgroup_subsys *ss,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
