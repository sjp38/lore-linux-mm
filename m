Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0B3026B7421
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 12:01:00 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id x4-v6so5416326ywd.13
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 09:01:00 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 199-v6si1554924oic.364.2018.09.05.09.00.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 09:00:58 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w85FuDSQ046964
	for <linux-mm@kvack.org>; Wed, 5 Sep 2018 12:00:57 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mag027jkw-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 05 Sep 2018 12:00:53 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 5 Sep 2018 17:00:41 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [RFC PATCH 17/29] memblock: replace alloc_bootmem_node with memblock_alloc_node
Date: Wed,  5 Sep 2018 18:59:32 +0300
In-Reply-To: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1536163184-26356-18-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Paul Burton <paul.burton@mips.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 arch/alpha/kernel/pci_iommu.c   | 4 ++--
 arch/ia64/sn/kernel/io_common.c | 7 ++-----
 arch/ia64/sn/kernel/setup.c     | 4 ++--
 3 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/arch/alpha/kernel/pci_iommu.c b/arch/alpha/kernel/pci_iommu.c
index 6923b0d..b52d76f 100644
--- a/arch/alpha/kernel/pci_iommu.c
+++ b/arch/alpha/kernel/pci_iommu.c
@@ -74,7 +74,7 @@ iommu_arena_new_node(int nid, struct pci_controller *hose, dma_addr_t base,
 
 #ifdef CONFIG_DISCONTIGMEM
 
-	arena = alloc_bootmem_node(NODE_DATA(nid), sizeof(*arena));
+	arena = memblock_alloc_node(sizeof(*arena), align, nid);
 	if (!NODE_DATA(nid) || !arena) {
 		printk("%s: couldn't allocate arena from node %d\n"
 		       "    falling back to system-wide allocation\n",
@@ -82,7 +82,7 @@ iommu_arena_new_node(int nid, struct pci_controller *hose, dma_addr_t base,
 		arena = alloc_bootmem(sizeof(*arena));
 	}
 
-	arena->ptes = __alloc_bootmem_node(NODE_DATA(nid), mem_size, align, 0);
+	arena->ptes = memblock_alloc_node(sizeof(*arena), align, nid);
 	if (!NODE_DATA(nid) || !arena->ptes) {
 		printk("%s: couldn't allocate arena ptes from node %d\n"
 		       "    falling back to system-wide allocation\n",
diff --git a/arch/ia64/sn/kernel/io_common.c b/arch/ia64/sn/kernel/io_common.c
index 102aaba..8b05d55 100644
--- a/arch/ia64/sn/kernel/io_common.c
+++ b/arch/ia64/sn/kernel/io_common.c
@@ -385,16 +385,13 @@ void __init hubdev_init_node(nodepda_t * npda, cnodeid_t node)
 {
 	struct hubdev_info *hubdev_info;
 	int size;
-	pg_data_t *pg;
 
 	size = sizeof(struct hubdev_info);
 
 	if (node >= num_online_nodes())	/* Headless/memless IO nodes */
-		pg = NODE_DATA(0);
-	else
-		pg = NODE_DATA(node);
+		node = 0;
 
-	hubdev_info = (struct hubdev_info *)alloc_bootmem_node(pg, size);
+	hubdev_info = (struct hubdev_info *)memblock_alloc_node(size, 0, node);
 
 	npda->pdinfo = (void *)hubdev_info;
 }
diff --git a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
index 5f6b6b4..ab2564f 100644
--- a/arch/ia64/sn/kernel/setup.c
+++ b/arch/ia64/sn/kernel/setup.c
@@ -511,7 +511,7 @@ static void __init sn_init_pdas(char **cmdline_p)
 	 */
 	for_each_online_node(cnode) {
 		nodepdaindr[cnode] =
-		    alloc_bootmem_node(NODE_DATA(cnode), sizeof(nodepda_t));
+		    memblock_alloc_node(sizeof(nodepda_t), 0, cnode);
 		memset(nodepdaindr[cnode]->phys_cpuid, -1,
 		    sizeof(nodepdaindr[cnode]->phys_cpuid));
 		spin_lock_init(&nodepdaindr[cnode]->ptc_lock);
@@ -522,7 +522,7 @@ static void __init sn_init_pdas(char **cmdline_p)
 	 */
 	for (cnode = num_online_nodes(); cnode < num_cnodes; cnode++)
 		nodepdaindr[cnode] =
-		    alloc_bootmem_node(NODE_DATA(0), sizeof(nodepda_t));
+		    memblock_alloc_node(sizeof(nodepda_t), 0, 0);
 
 	/*
 	 * Now copy the array of nodepda pointers to each nodepda.
-- 
2.7.4
