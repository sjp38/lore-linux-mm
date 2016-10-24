Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 49A406B0262
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:42:50 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id i85so114870910pfa.5
        for <linux-mm@kvack.org>; Sun, 23 Oct 2016 21:42:50 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id h187si13533952pgc.329.2016.10.23.21.42.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Oct 2016 21:42:49 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9O4cYXb111076
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:42:49 -0400
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com [202.81.31.140])
	by mx0a-001b2d01.pphosted.com with ESMTP id 268yyud9nc-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:42:48 -0400
Received: from localhost
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 24 Oct 2016 14:42:46 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 50AEF2BB0054
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 15:42:44 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9O4giQI16515316
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 15:42:44 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9O4ghhb030600
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 15:42:44 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [DEBUG 05/10] powerpc/mm: Identify isolation seeking coherent memory nodes during boot
Date: Mon, 24 Oct 2016 10:12:24 +0530
In-Reply-To: <1477284149-2976-1-git-send-email-khandual@linux.vnet.ibm.com>
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
 <1477284149-2976-1-git-send-email-khandual@linux.vnet.ibm.com>
Message-Id: <1477284149-2976-6-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com

Isolation seeking coherent memory nodes which wish to be MNODE_ISOLATION
in core VM will have "ibm,hotplug-aperture" as one of the compatible
properties in their respective device nodes in device tree. Detect them
during platform NUMA initialization and mark their respective coherent
mask in pglist_data structure as MNODE_ISOLATION.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 arch/powerpc/mm/numa.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
index 5010181..89ae64c 100644
--- a/arch/powerpc/mm/numa.c
+++ b/arch/powerpc/mm/numa.c
@@ -64,6 +64,7 @@ static int form1_affinity;
 static int distance_ref_points_depth;
 static const __be32 *distance_ref_points;
 static int distance_lookup_table[MAX_NUMNODES][MAX_DISTANCE_REF_POINTS];
+static int node_to_phys_device_map[MAX_NUMNODES];
 
 /*
  * Allocate node_to_cpumask_map based on number of available nodes
@@ -714,6 +715,17 @@ static const struct of_device_id memory_match[] = {
 	{ /* sentinel */ }
 };
 
+int arch_get_memory_phys_device(unsigned long start_pfn)
+{
+	return node_to_phys_device_map[pfn_to_nid(start_pfn)];
+}
+
+int special_mem_node(int nid)
+{
+	return node_to_phys_device_map[nid];
+}
+EXPORT_SYMBOL(special_mem_node);
+
 static int __init parse_numa_properties(void)
 {
 	struct device_node *memory;
@@ -789,6 +801,9 @@ static int __init parse_numa_properties(void)
 		if (nid < 0)
 			nid = default_nid;
 
+		if (of_device_is_compatible(memory, "ibm,hotplug-aperture"))
+			node_to_phys_device_map[nid] = 1;
+
 		fake_numa_create_new_node(((start + size) >> PAGE_SHIFT), &nid);
 		node_set_online(nid);
 
@@ -908,6 +923,11 @@ static void __init setup_node_data(int nid, u64 start_pfn, u64 end_pfn)
 	NODE_DATA(nid)->node_id = nid;
 	NODE_DATA(nid)->node_start_pfn = start_pfn;
 	NODE_DATA(nid)->node_spanned_pages = spanned_pages;
+
+#ifdef CONFIG_COHERENT_DEVICE
+	if (special_mem_node(nid))
+		set_cdm_isolation(nid);
+#endif
 }
 
 void __init initmem_init(void)
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
