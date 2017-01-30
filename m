Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 706E86B027E
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:39:06 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id r18so5943947wmd.1
        for <linux-mm@kvack.org>; Sun, 29 Jan 2017 19:39:06 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id k69si11710872wmh.64.2017.01.29.19.39.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Jan 2017 19:39:05 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0U3YPEA082493
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:39:04 -0500
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com [202.81.31.142])
	by mx0a-001b2d01.pphosted.com with ESMTP id 289he1j4bc-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:39:03 -0500
Received: from localhost
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 30 Jan 2017 13:39:01 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id D860E2BB0057
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:38:57 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0U3cna717956944
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:38:57 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0U3cP5g021734
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:38:25 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [DEBUG 14/21] powerpc/mm: Create numa nodes for hotplug memory
Date: Mon, 30 Jan 2017 09:05:55 +0530
In-Reply-To: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
Message-Id: <20170130033602.12275-15-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

From: Reza Arbab <arbab@linux.vnet.ibm.com>

When scanning the device tree to initialize the system NUMA topology,
process dt elements with compatible id "ibm,hotplug-aperture" to create
memoryless numa nodes.

These nodes will be filled when hotplug occurs within the associated
address range.

Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 .../bindings/powerpc/opal/hotplug-aperture.txt     | 26 ++++++++++++++++++++++
 arch/powerpc/mm/numa.c                             | 10 +++++++--
 2 files changed, 34 insertions(+), 2 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/powerpc/opal/hotplug-aperture.txt

diff --git a/Documentation/devicetree/bindings/powerpc/opal/hotplug-aperture.txt b/Documentation/devicetree/bindings/powerpc/opal/hotplug-aperture.txt
new file mode 100644
index 0000000..b8dffaa
--- /dev/null
+++ b/Documentation/devicetree/bindings/powerpc/opal/hotplug-aperture.txt
@@ -0,0 +1,26 @@
+Designated hotplug memory
+-------------------------
+
+This binding describes a region of hotplug memory which is not present at boot,
+allowing its eventual NUMA associativity to be prespecified.
+
+Required properties:
+
+- compatible
+	"ibm,hotplug-aperture"
+
+- reg
+	base address and size of the region (standard definition)
+
+- ibm,associativity
+	NUMA associativity (standard definition)
+
+Example:
+
+A 2 GiB aperture at 0x100000000, to be part of nid 3 when hotplugged:
+
+	hotplug-memory@100000000 {
+		compatible = "ibm,hotplug-aperture";
+		reg = <0x0 0x100000000 0x0 0x80000000>;
+		ibm,associativity = <0x4 0x0 0x0 0x0 0x3>;
+	};
diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
index 6def078..5370833 100644
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
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
