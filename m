Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 462216B007B
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:14:53 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 11 Apr 2013 19:14:52 -0600
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 378A438C801C
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:14:49 -0400 (EDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3C1EmkD310230
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:14:49 -0400
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3C1EmUO019573
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 19:14:48 -0600
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [RFC PATCH v2 25/25] mm: add a early_param "extra_nr_node_ids" to increase nr_node_ids above the minimum by a percentage.
Date: Thu, 11 Apr 2013 18:13:57 -0700
Message-Id: <1365729237-29711-26-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1365729237-29711-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1365729237-29711-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>, Simon Jeons <simon.jeons@gmail.com>

For dynamic numa, sometimes the hypervisor we're running under will want
to split a single NUMA node into multiple NUMA nodes. If the number of
numa nodes is limited to the number avaliable when the system booted (as
it is on x86), we may not be able to fully adopt the new memory layout
provided by the hypervisor.

This option allows reserving some extra node ids as a percentage of the
boot time node ids. While not perfect (idealy nr_node_ids would be fully
dynamic), this allows decent functionality without invasive changes to
the SL{U,A}B allocators.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 Documentation/kernel-parameters.txt |  6 ++++++
 mm/page_alloc.c                     | 24 ++++++++++++++++++++++++
 2 files changed, 30 insertions(+)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 4609e81..b0523d8 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -2033,6 +2033,12 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			use hotplug cpu feature to put more cpu back to online.
 			just like you compile the kernel NR_CPUS=n
 
+	extra_nr_node_ids= [NUMA] Increase the maximum number of NUMA nodes
+			above the number detected at boot by the specified
+			percentage (rounded up). For example:
+			extra_nr_node_ids=100 would double the number of
+			node_ids avaliable (up to a max of MAX_NUMNODES).
+
 	nr_uarts=	[SERIAL] maximum number of UARTs to be registered.
 
 	numa_balancing=	[KNL,X86] Enable or disable automatic NUMA balancing.
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 686d8f8..d333d91 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4798,6 +4798,17 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 
 #if MAX_NUMNODES > 1
+
+static unsigned nr_node_ids_mod_percent;
+static int __init setup_extra_nr_node_ids(char *arg)
+{
+	int r = kstrtouint(arg, 10, &nr_node_ids_mod_percent);
+	if (r)
+		pr_err("invalid param value extra_nr_node_ids=\"%s\"\n", arg);
+	return 0;
+}
+early_param("extra_nr_node_ids", setup_extra_nr_node_ids);
+
 /*
  * Figure out the number of possible node ids.
  */
@@ -4809,6 +4820,19 @@ void __init setup_nr_node_ids(void)
 	for_each_node_mask(node, node_possible_map)
 		highest = node;
 	nr_node_ids = highest + 1;
+
+	/*
+	 * expand nr_node_ids and node_possible_map so more can be onlined
+	 * later
+	 */
+	nr_node_ids +=
+		DIV_ROUND_UP(nr_node_ids * nr_node_ids_mod_percent, 100);
+
+	if (nr_node_ids > MAX_NUMNODES)
+		nr_node_ids = MAX_NUMNODES;
+
+	for (node = highest + 1; node < nr_node_ids; node++)
+		node_set(node, node_possible_map);
 }
 #endif
 
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
