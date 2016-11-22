Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 236146B026D
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 09:20:17 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id j10so9324565wjb.3
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 06:20:17 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id gs7si25844964wjc.209.2016.11.22.06.20.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Nov 2016 06:20:16 -0800 (PST)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAMEItQi066431
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 09:20:14 -0500
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com [202.81.31.147])
	by mx0b-001b2d01.pphosted.com with ESMTP id 26vm47a8y5-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 09:20:13 -0500
Received: from localhost
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 23 Nov 2016 00:20:11 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 1D8B33578056
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 01:20:09 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAMEK8Qo34209982
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 01:20:08 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAMEK839016164
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 01:20:08 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [DEBUG 06/12] powerpc/mm: Create numa nodes for hotplug memory
Date: Tue, 22 Nov 2016 19:49:42 +0530
In-Reply-To: <1479824388-30446-1-git-send-email-khandual@linux.vnet.ibm.com>
References: <1479824388-30446-1-git-send-email-khandual@linux.vnet.ibm.com>
Message-Id: <1479824388-30446-7-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com

From: Reza Arbab <arbab@linux.vnet.ibm.com>

When scanning the device tree to initialize the system NUMA topology,
process dt elements with compatible id "ibm,hotplug-aperture" to create
memoryless numa nodes.

These nodes will be filled when hotplug occurs within the associated
address range.

Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 arch/powerpc/mm/numa.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
index b625e0e..e4cb4e62 100644
--- a/arch/powerpc/mm/numa.c
+++ b/arch/powerpc/mm/numa.c
@@ -717,6 +717,12 @@ static void __init parse_drconf_memory(struct device_node *memory)
 	}
 }
 
+static const struct of_device_id memory_match[] = {
+	{ .type = "memory" },
+	{ .compatible = "ibm,hotplug-aperture" },
+	{ /* sentinel */ }
+};
+
 static int __init parse_numa_properties(void)
 {
 	struct device_node *memory;
@@ -761,7 +767,7 @@ static int __init parse_numa_properties(void)
 
 	get_n_mem_cells(&n_mem_addr_cells, &n_mem_size_cells);
 
-	for_each_node_by_type(memory, "memory") {
+	for_each_matching_node(memory, memory_match) {
 		unsigned long start;
 		unsigned long size;
 		int nid;
@@ -1056,7 +1062,7 @@ static int hot_add_node_scn_to_nid(unsigned long scn_addr)
 	struct device_node *memory;
 	int nid = -1;
 
-	for_each_node_by_type(memory, "memory") {
+	for_each_matching_node(memory, memory_match) {
 		unsigned long start, size;
 		int ranges;
 		const __be32 *memcell_buf;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
