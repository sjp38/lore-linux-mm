Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 831A76B0261
	for <linux-mm@kvack.org>; Mon,  8 Aug 2016 14:27:40 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 1so77753859wmz.2
        for <linux-mm@kvack.org>; Mon, 08 Aug 2016 11:27:40 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id rb4si31242110wjb.208.2016.08.08.11.27.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Aug 2016 11:27:34 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u78H5aum015703
	for <linux-mm@kvack.org>; Mon, 8 Aug 2016 14:27:32 -0400
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com [32.97.110.154])
	by mx0b-001b2d01.pphosted.com with ESMTP id 24nc30ax1x-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 08 Aug 2016 14:27:32 -0400
Received: from localhost
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Mon, 8 Aug 2016 12:27:31 -0600
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: [PATCH 2/4] powerpc/mm: create numa nodes for hotplug memory
Date: Mon,  8 Aug 2016 13:27:21 -0500
In-Reply-To: <1470680843-28702-1-git-send-email-arbab@linux.vnet.ibm.com>
References: <1470680843-28702-1-git-send-email-arbab@linux.vnet.ibm.com>
Message-Id: <1470680843-28702-3-git-send-email-arbab@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Herring <robh+dt@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Jonathan Corbet <corbet@lwn.net>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, devicetree@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

When scanning the device tree to initialize the system NUMA topology,
process dt elements with compatible id "ibm,hotplug-aperture" to create
memoryless numa nodes.

These nodes will be filled when hotplug occurs within the associated
address range.

Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
---
 arch/powerpc/mm/numa.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
index 75b9cd6..80d067d 100644
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
@@ -1080,7 +1086,7 @@ static int hot_add_node_scn_to_nid(unsigned long scn_addr)
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
