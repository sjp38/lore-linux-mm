Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4D52C6B0269
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:42:54 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e6so114141603pfk.2
        for <linux-mm@kvack.org>; Sun, 23 Oct 2016 21:42:54 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id h70si13482887pfc.168.2016.10.23.21.42.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Oct 2016 21:42:53 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9O4cYxL130777
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:42:53 -0400
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com [202.81.31.140])
	by mx0a-001b2d01.pphosted.com with ESMTP id 268yyuneed-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:42:53 -0400
Received: from localhost
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 24 Oct 2016 14:42:50 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 1C0012CE8056
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 15:42:49 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9O4gnpY19398856
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 15:42:49 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9O4gmUq030688
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 15:42:48 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [DEBUG 07/10] mm: Add debugfs interface to dump each node's zonelist information
Date: Mon, 24 Oct 2016 10:12:26 +0530
In-Reply-To: <1477284149-2976-1-git-send-email-khandual@linux.vnet.ibm.com>
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
 <1477284149-2976-1-git-send-email-khandual@linux.vnet.ibm.com>
Message-Id: <1477284149-2976-8-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com

Each individual node in the system has a ZONELIST_FALLBACK zonelist
and a ZONELIST_NOFALLBACK zonelist. These zonelists decide fallback
order of zones during memory allocations. Sometimes it helps to dump
these zonelists to see the priority order of various zones in them.

Particularly platforms which support memory hotplug into previously
non existing zones (at boot), this interface helps in visualizing
which all zonelists of the system at what priority level, the new
hot added memory ends up in. POWER is such a platform where all the
memory detected during boot time remains with ZONE_DMA for good but
then hot plug process can actually get new memory into ZONE_MOVABLE.
So having a way to get the snapshot of the zonelists on the system
after memory or node hot[un]plug is desirable. This change adds one
new debugfs interface (/sys/kernel/debug/zonelists) which will fetch
and dump this information.

Example zonelist information from a KVM guest with four NUMA nodes
on a POWER8 platform.

[NODE (0)]
	ZONELIST_FALLBACK
		(0) (Node 0) (DMA)
		(1) (Node 1) (DMA)
		(2) (Node 2) (DMA)
		(3) (Node 3) (DMA)
	ZONELIST_NOFALLBACK
		(0) (Node 0) (DMA)
[NODE (1)]
	ZONELIST_FALLBACK
		(0) (Node 1) (DMA)
		(1) (Node 2) (DMA)
		(2) (Node 3) (DMA)
		(3) (Node 0) (DMA)
	ZONELIST_NOFALLBACK
		(0) (Node 1) (DMA)
[NODE (2)]
	ZONELIST_FALLBACK
		(0) (Node 2) (DMA)
		(1) (Node 3) (DMA)
		(2) (Node 0) (DMA)
		(3) (Node 1) (DMA)
	ZONELIST_NOFALLBACK
		(0) (Node 2) (DMA)
[NODE (3)]
	ZONELIST_FALLBACK
		(0) (Node 3) (DMA)
		(1) (Node 0) (DMA)
		(2) (Node 1) (DMA)
		(3) (Node 2) (DMA)
	ZONELIST_NOFALLBACK
		(0) (Node 3) (DMA)

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 mm/memory.c | 63 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 63 insertions(+)

diff --git a/mm/memory.c b/mm/memory.c
index e18c57b..3be1753 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -64,6 +64,7 @@
 #include <linux/debugfs.h>
 #include <linux/userfaultfd_k.h>
 #include <linux/dax.h>
+#include <linux/mmzone.h>
 
 #include <asm/io.h>
 #include <asm/mmu_context.h>
@@ -3087,6 +3088,68 @@ static int __init fault_around_debugfs(void)
 		pr_warn("Failed to create fault_around_bytes in debugfs");
 	return 0;
 }
+
+#ifdef CONFIG_NUMA
+static void show_zonelist(struct seq_file *m, struct zonelist *zonelist)
+{
+	unsigned int i;
+
+	for (i = 0; zonelist->_zonerefs[i].zone; i++) {
+		seq_printf(m, "\t\t(%d) (Node %d) (%-7s 0x%pK)\n", i,
+			zonelist->_zonerefs[i].zone->zone_pgdat->node_id,
+			zone_names[zonelist->_zonerefs[i].zone_idx],
+			(void *) zonelist->_zonerefs[i].zone);
+	}
+}
+
+static int zonelists_show(struct seq_file *m, void *v)
+{
+	struct zonelist *zonelist;
+	unsigned int node;
+
+	for_each_online_node(node) {
+		zonelist = &(NODE_DATA(node)->
+				node_zonelists[ZONELIST_FALLBACK]);
+		seq_printf(m, "[NODE (%d)]\n", node);
+		seq_puts(m, "\tZONELIST_FALLBACK ");
+		seq_printf(m, "(0x%pK)\n", zonelist);
+		show_zonelist(m, zonelist);
+
+		zonelist = &(NODE_DATA(node)->
+				node_zonelists[ZONELIST_NOFALLBACK]);
+		seq_puts(m, "\tZONELIST_NOFALLBACK ");
+		seq_printf(m, "(0x%pK)\n", zonelist);
+		show_zonelist(m, zonelist);
+	}
+	return 0;
+}
+
+static int zonelists_open(struct inode *inode, struct file *filp)
+{
+	return single_open(filp, zonelists_show, NULL);
+}
+
+static const struct file_operations zonelists_fops = {
+	.open		= zonelists_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
+static int __init zonelists_debugfs(void)
+{
+	void *ret;
+
+	ret = debugfs_create_file("zonelists", 0444, NULL, NULL,
+			&zonelists_fops);
+	if (!ret)
+		pr_warn("Failed to create zonelists in debugfs");
+	return 0;
+}
+
+late_initcall(zonelists_debugfs);
+#endif /* CONFIG_NUMA */
+
 late_initcall(fault_around_debugfs);
 #endif
 
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
