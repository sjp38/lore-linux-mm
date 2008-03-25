Message-Id: <20080325023122.427054000@polaris-admin.engr.sgi.com>
References: <20080325023120.859257000@polaris-admin.engr.sgi.com>
Date: Mon, 24 Mar 2008 19:31:29 -0700
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 09/12] sched: fix memory leak in build_sched_domains
Content-Disposition: inline; filename=build_sched_domain_leak_fix
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

I'm not 100% sure if this is needed but I can't find where memory
allocated for sched_group_nodes is released if the kmalloc for
alloc_rootdomain fails.  Also, sched_group_nodes_bycpu[] is set,
but never completely filled in for the kmalloc failure case.

Based on linux-2.6.25-rc5-mm1

Cc: Ingo Molnar <mingo@elte.hu>

Signed-off-by: Mike Travis <travis@sgi.com>
---
 kernel/sched.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

--- linux-2.6.25-rc5.orig/kernel/sched.c
+++ linux-2.6.25-rc5/kernel/sched.c
@@ -6646,15 +6646,21 @@ static int build_sched_domains(const cpu
 		printk(KERN_WARNING "Can not alloc sched group node list\n");
 		return -ENOMEM;
 	}
-	sched_group_nodes_bycpu[first_cpu(*cpu_map)] = sched_group_nodes;
 #endif
 
 	rd = alloc_rootdomain();
 	if (!rd) {
 		printk(KERN_WARNING "Cannot alloc root domain\n");
+#ifdef CONFIG_NUMA
+		kfree(sched_group_nodes);
+#endif
 		return -ENOMEM;
 	}
 
+#ifdef CONFIG_NUMA
+	sched_group_nodes_bycpu[first_cpu(*cpu_map)] = sched_group_nodes;
+#endif
+
 	/*
 	 * Set up domains for cpus specified by the cpu_map.
 	 */

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
