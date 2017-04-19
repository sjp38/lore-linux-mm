Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id CAA8F2806DB
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 03:53:13 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id j16so8582668pfk.4
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 00:53:13 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id q126si1623145pfb.236.2017.04.19.00.53.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Apr 2017 00:53:13 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id a188so2579854pfa.2
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 00:53:13 -0700 (PDT)
From: Balbir Singh <bsingharora@gmail.com>
Subject: [RFC 2/4] arch/powerpc/mm: add support for coherent memory
Date: Wed, 19 Apr 2017 17:52:40 +1000
Message-Id: <20170419075242.29929-3-bsingharora@gmail.com>
In-Reply-To: <20170419075242.29929-1-bsingharora@gmail.com>
References: <20170419075242.29929-1-bsingharora@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: khandual@linux.vnet.ibm.com, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, mgorman@techsingularity.net, mhocko@kernel.org, arbab@linux.vnet.ibm.com, vbabka@suse.cz, cl@linux.com, Balbir Singh <bsingharora@gmail.com>

Add support for N_COHERENT_MEMORY by marking nodes compatible
with ibm,coherent-device-memory as coherent nodes. The code
sets N_COHERENT_MEMORY before the system has had a chance to
set N_MEMORY.

Signed-off-by: Balbir Singh <bsingharora@gmail.com>
---
 arch/powerpc/mm/numa.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
index 371792e..c977de8 100644
--- a/arch/powerpc/mm/numa.c
+++ b/arch/powerpc/mm/numa.c
@@ -652,6 +652,7 @@ static void __init parse_drconf_memory(struct device_node *memory)
 	unsigned long lmb_size, base, size, sz;
 	int nid;
 	struct assoc_arrays aa = { .arrays = NULL };
+	int coherent = 0;
 
 	n = of_get_drconf_memory(memory, &dm);
 	if (!n)
@@ -696,6 +697,10 @@ static void __init parse_drconf_memory(struct device_node *memory)
 				size = read_n_cells(n_mem_size_cells, &usm);
 			}
 			nid = of_drconf_to_nid_single(&drmem, &aa);
+			coherent = of_device_is_compatible(memory,
+					"ibm,coherent-device-memory");
+			if (coherent)
+				node_set_state(nid, N_COHERENT_MEMORY);
 			fake_numa_create_new_node(
 				((base + size) >> PAGE_SHIFT),
 					   &nid);
@@ -713,6 +718,7 @@ static int __init parse_numa_properties(void)
 	struct device_node *memory;
 	int default_nid = 0;
 	unsigned long i;
+	int coherent = 0;
 
 	if (numa_enabled == 0) {
 		printk(KERN_WARNING "NUMA disabled by user\n");
@@ -785,6 +791,10 @@ static int __init parse_numa_properties(void)
 
 		fake_numa_create_new_node(((start + size) >> PAGE_SHIFT), &nid);
 		node_set_online(nid);
+		coherent = of_device_is_compatible(memory,
+				"ibm,coherent-device-memory");
+		if (coherent)
+			node_set_state(nid, N_COHERENT_MEMORY);
 
 		size = numa_enforce_memory_limit(start, size);
 		if (size)
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
