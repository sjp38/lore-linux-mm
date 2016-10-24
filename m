Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 248F06B025E
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:42:42 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e6so114139051pfk.2
        for <linux-mm@kvack.org>; Sun, 23 Oct 2016 21:42:42 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 3si13534544pfu.111.2016.10.23.21.42.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Oct 2016 21:42:41 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9O4cd7j041212
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:42:41 -0400
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2695ejayn1-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:42:40 -0400
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 24 Oct 2016 14:42:38 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 2CD7C2BB0054
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 15:42:37 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9O4gb2D6423028
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 15:42:37 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9O4gabP030368
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 15:42:36 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [DEBUG 02/10] powerpc/mm: Create numa nodes for hotplug memory
Date: Mon, 24 Oct 2016 10:12:21 +0530
In-Reply-To: <1477284149-2976-1-git-send-email-khandual@linux.vnet.ibm.com>
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
 <1477284149-2976-1-git-send-email-khandual@linux.vnet.ibm.com>
Message-Id: <1477284149-2976-3-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com

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
index a51c188..42fcc8e 100644
--- a/arch/powerpc/mm/numa.c
+++ b/arch/powerpc/mm/numa.c
@@ -708,6 +708,12 @@ static void __init parse_drconf_memory(struct device_node *memory)
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
@@ -752,7 +758,7 @@ static int __init parse_numa_properties(void)
 
 	get_n_mem_cells(&n_mem_addr_cells, &n_mem_size_cells);
 
-	for_each_node_by_type(memory, "memory") {
+	for_each_matching_node(memory, memory_match) {
 		unsigned long start;
 		unsigned long size;
 		int nid;
@@ -1044,7 +1050,7 @@ static int hot_add_node_scn_to_nid(unsigned long scn_addr)
 	struct device_node *memory;
 	int nid = -1;
 
-	for_each_node_by_type(memory, "memory") {
+	for_each_matching_node(memory, memory_match) {
 		unsigned long start, size;
 		int ranges;
 		const __be32 *memcell_buf;
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
