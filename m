Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1308D8E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 08:12:49 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id x145-v6so9302307oia.10
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 05:12:49 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id q32-v6si1388045ote.235.2018.09.14.05.12.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 05:12:47 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8EC4ZxT125132
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 08:12:47 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mgc6csray-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 08:12:46 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 14 Sep 2018 13:12:42 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 16/30] memblock: replace __alloc_bootmem_node with appropriate memblock_ API
Date: Fri, 14 Sep 2018 15:10:31 +0300
In-Reply-To: <1536927045-23536-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1536927045-23536-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1536927045-23536-17-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Chris Zankel <chris@zankel.net>, "David S. Miller" <davem@davemloft.net>, Geert Uytterhoeven <geert@linux-m68k.org>, Greentime Hu <green.hu@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guan Xuetao <gxt@pku.edu.cn>, Ingo Molnar <mingo@redhat.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Jonas Bonn <jonas@southpole.se>, Jonathan Corbet <corbet@lwn.net>, Ley Foon Tan <lftan@altera.com>, Mark Salter <msalter@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Matt Turner <mattst88@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Michal Simek <monstr@monstr.eu>, Palmer Dabbelt <palmer@sifive.com>, Paul Burton <paul.burton@mips.com>, Richard Kuo <rkuo@codeaurora.org>, Richard Weinberger <richard@nod.at>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Serge Semin <fancer.lancer@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp, Mike Rapoport <rppt@linux.vnet.ibm.com>

Use memblock_alloc_try_nid whenever goal (i.e. minimal address is
specified) and memblock_alloc_node otherwise.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 arch/ia64/mm/discontig.c       |  6 ++++--
 arch/powerpc/kernel/setup_64.c |  6 ++++--
 arch/sparc/kernel/setup_64.c   | 10 ++++------
 arch/sparc/kernel/smp_64.c     |  4 ++--
 4 files changed, 14 insertions(+), 12 deletions(-)

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
