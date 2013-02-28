Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 7F71F6B0024
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 16:57:56 -0500 (EST)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 28 Feb 2013 14:57:55 -0700
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 42ABD19D8046
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 14:57:50 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1SLvb7V108044
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 14:57:41 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1SLvYVI017214
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 14:57:34 -0700
Received: from kernel.stglabs.ibm.com (kernel.stglabs.ibm.com [9.114.214.19])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id r1SLvXXa017121
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 14:57:33 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 24/24] XXX: x86/mm/numa: Avoid spamming warnings due to lack of cpu reconfig
Date: Thu, 28 Feb 2013 13:57:27 -0800
Message-Id: <1362088647-19726-4-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1362088647-19726-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1362088647-19726-1-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1362084272-11282-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1362084272-11282-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: Cody P Schafer <cody@linux.vnet.ibm.com>, David Hansen <dave@linux.vnet.ibm.com>

the code wants to map a node id to a cpu mask, but we don't update the
arch specific cpu masks when onlining a new node. For now, avoid this
warning (as it is expected) when DYNAMIC_NUMA is enabled.

Modifying __mem_online_node() to fix this up would be ideal.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 arch/x86/mm/numa.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index 1ed76d5..e9a50df 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -813,10 +813,14 @@ void __cpuinit numa_remove_cpu(int cpu)
 const struct cpumask *cpumask_of_node(int node)
 {
 	if (node >= nr_node_ids) {
+		/* XXX: this ifdef should be removed when proper cpu to node
+		 * mapping updates are added */
+#ifndef CONFIG_DYNAMIC_NUMA
 		printk(KERN_WARNING
 			"cpumask_of_node(%d): node > nr_node_ids(%d)\n",
 			node, nr_node_ids);
 		dump_stack();
+#endif
 		return cpu_none_mask;
 	}
 	if (node_to_cpumask_map[node] == NULL) {
-- 
1.8.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
