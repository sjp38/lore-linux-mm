Date: Sat, 16 Sep 2006 11:18:27 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: [PATCH] scheduler: NUMA aware placement of sched_group_allnodes
Message-ID: <Pine.LNX.4.64.0609161117550.12595@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: npiggin@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

When the per cpu sched domains are build then they also need to be placed
on the node where the cpu resides otherwise we will have frequent off
node accesses which will slow down the system.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc6-mm2/kernel/sched.c
===================================================================
--- linux-2.6.18-rc6-mm2.orig/kernel/sched.c	2006-09-13 20:00:48.000000000 -0500
+++ linux-2.6.18-rc6-mm2/kernel/sched.c	2006-09-15 13:05:32.269416181 -0500
@@ -6449,9 +6449,10 @@ static int build_sched_domains(const cpu
 				> SD_NODES_PER_DOMAIN*cpus_weight(nodemask)) {
 			if (!sched_group_allnodes) {
 				sched_group_allnodes
-					= kmalloc(sizeof(struct sched_group)
-							* MAX_NUMNODES,
-						  GFP_KERNEL);
+					= kmalloc_node(sizeof(struct sched_group)
+						  	* MAX_NUMNODES,
+						  GFP_KERNEL,
+						  cpu_to_node(i));
 				if (!sched_group_allnodes) {
 					printk(KERN_WARNING
 					"Can not alloc allnodes sched group\n");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
