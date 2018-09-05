Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id E9B3A6B7414
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 12:00:46 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id j17-v6so8988958oii.8
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 09:00:46 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j12-v6si1484466oib.280.2018.09.05.09.00.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 09:00:45 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w85Fvvqp104025
	for <linux-mm@kvack.org>; Wed, 5 Sep 2018 12:00:45 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2maj3wrjx1-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 05 Sep 2018 12:00:39 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 5 Sep 2018 17:00:37 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [RFC PATCH 16/29] memblock: replace __alloc_bootmem_node with appropriate memblock_ API
Date: Wed,  5 Sep 2018 18:59:31 +0300
In-Reply-To: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1536163184-26356-17-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Paul Burton <paul.burton@mips.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Use memblock_alloc_try_nid whenever goal (i.e. mininal address is
specified) and memblock_alloc_node otherwise.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 arch/ia64/mm/discontig.c       |  6 ++++--
 arch/ia64/mm/init.c            |  2 +-
 arch/powerpc/kernel/setup_64.c |  6 ++++--
 arch/sparc/kernel/setup_64.c   | 10 ++++------
 arch/sparc/kernel/smp_64.c     |  4 ++--
 5 files changed, 15 insertions(+), 13 deletions(-)

diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index 1928d57..918dda9 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -451,8 +451,10 @@ static void __init *memory_less_node_alloc(int nid, unsigned long pernodesize)
 	if (bestnode == -1)
 		bestnode = anynode;
 
-	ptr = __alloc_bootmem_node(pgdat_list[bestnode], pernodesize,
-		PERCPU_PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
+	ptr = memblock_alloc_try_nid(pernodesize, PERCPU_PAGE_SIZE,
+				     __pa(MAX_DMA_ADDRESS),
+				     BOOTMEM_ALLOC_ACCESSIBLE,
+				     bestnode);
 
 	return ptr;
 }
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index ffcc358..2169ca5 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -459,7 +459,7 @@ int __init create_mem_map_page_table(u64 start, u64 end, void *arg)
 		pte = pte_offset_kernel(pmd, address);
 
 		if (pte_none(*pte))
-			set_pte(pte, pfn_pte(__pa(memblock_alloc_node(PAGE_SIZE, PAGE_SIZE, node))) >> PAGE_SHIFT,
+			set_pte(pte, pfn_pte(__pa(memblock_alloc_node(PAGE_SIZE, PAGE_SIZE, node)) >> PAGE_SHIFT,
 					     PAGE_KERNEL));
 	}
 	return 0;
diff --git a/arch/powerpc/kernel/setup_64.c b/arch/powerpc/kernel/setup_64.c
index 6a501b2..6add560 100644
--- a/arch/powerpc/kernel/setup_64.c
+++ b/arch/powerpc/kernel/setup_64.c
@@ -757,8 +757,10 @@ void __init emergency_stack_init(void)
 
 static void * __init pcpu_fc_alloc(unsigned int cpu, size_t size, size_t align)
 {
-	return __alloc_bootmem_node(NODE_DATA(early_cpu_to_node(cpu)), size, align,
-				    __pa(MAX_DMA_ADDRESS));
+	return memblock_alloc_try_nid(size, align, __pa(MAX_DMA_ADDRESS),
+				      BOOTMEM_ALLOC_ACCESSIBLE,
+				      early_cpu_to_node(cpu));
+
 }
 
 static void __init pcpu_fc_free(void *ptr, size_t size)
diff --git a/arch/sparc/kernel/setup_64.c b/arch/sparc/kernel/setup_64.c
index 206bf81..5fb11ea 100644
--- a/arch/sparc/kernel/setup_64.c
+++ b/arch/sparc/kernel/setup_64.c
@@ -622,12 +622,10 @@ void __init alloc_irqstack_bootmem(void)
 	for_each_possible_cpu(i) {
 		node = cpu_to_node(i);
 
-		softirq_stack[i] = __alloc_bootmem_node(NODE_DATA(node),
-							THREAD_SIZE,
-							THREAD_SIZE, 0);
-		hardirq_stack[i] = __alloc_bootmem_node(NODE_DATA(node),
-							THREAD_SIZE,
-							THREAD_SIZE, 0);
+		softirq_stack[i] = memblock_alloc_node(THREAD_SIZE,
+						       THREAD_SIZE, node);
+		hardirq_stack[i] = memblock_alloc_node(THREAD_SIZE,
+						       THREAD_SIZE, node);
 	}
 }
 
diff --git a/arch/sparc/kernel/smp_64.c b/arch/sparc/kernel/smp_64.c
index d3ea1f3..83ff88d 100644
--- a/arch/sparc/kernel/smp_64.c
+++ b/arch/sparc/kernel/smp_64.c
@@ -1594,8 +1594,8 @@ static void * __init pcpu_alloc_bootmem(unsigned int cpu, size_t size,
 		pr_debug("per cpu data for cpu%d %lu bytes at %016lx\n",
 			 cpu, size, __pa(ptr));
 	} else {
-		ptr = __alloc_bootmem_node(NODE_DATA(node),
-					   size, align, goal);
+		ptr = memblock_alloc_try_nid(size, align, goal,
+					     BOOTMEM_ALLOC_ACCESSIBLE, node);
 		pr_debug("per cpu data for cpu%d %lu bytes on node%d at "
 			 "%016lx\n", cpu, size, node, __pa(ptr));
 	}
-- 
2.7.4
