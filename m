Date: Tue, 15 Apr 2008 10:54:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] use vmalloc for mem_cgroup allocation.
Message-Id: <20080415105434.3044afb6.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, lizf@cn.fujitsu.com, menage@google.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On ia64, kmalloc() in mem_cgroup_create requires order-4 pages. But this is not
necessary to be phisically contiguous. And we'll see page allocation failure.
(Note: x86-32, which has small vmalloc area, has small mem_cgroup struct.)
For here, vmalloc is better.


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
 
@@ -993,7 +994,7 @@ mem_cgroup_create(struct cgroup_subsys *
 		mem = &init_mem_cgroup;
 		page_cgroup_cache = KMEM_CACHE(page_cgroup, SLAB_PANIC);
 	} else
-		mem = kzalloc(sizeof(struct mem_cgroup), GFP_KERNEL);
+		mem = vmalloc(sizeof(struct mem_cgroup));
 
 	if (mem == NULL)
 		return ERR_PTR(-ENOMEM);
@@ -1011,7 +1012,7 @@ free_out:
 	for_each_node_state(node, N_POSSIBLE)
 		free_mem_cgroup_per_zone_info(mem, node);
 	if (cont->parent != NULL)
-		kfree(mem);
+		vfree(mem);
 	return ERR_PTR(-ENOMEM);
 }
 
@@ -1031,7 +1032,7 @@ static void mem_cgroup_destroy(struct cg
 	for_each_node_state(node, N_POSSIBLE)
 		free_mem_cgroup_per_zone_info(mem, node);
 
-	kfree(mem_cgroup_from_cont(cont));
+	vfree(mem_cgroup_from_cont(cont));
 }
 
 static int mem_cgroup_populate(struct cgroup_subsys *ss,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
