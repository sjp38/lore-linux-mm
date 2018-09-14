Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5236F8E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 08:12:54 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id w185-v6so9286681oig.19
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 05:12:54 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 88-v6si1421296otw.234.2018.09.14.05.12.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 05:12:53 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8EC5Fmb093368
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 08:12:52 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mg9yyetuj-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 08:12:51 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 14 Sep 2018 13:12:48 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 17/30] memblock: replace alloc_bootmem_node with memblock_alloc_node
Date: Fri, 14 Sep 2018 15:10:32 +0300
In-Reply-To: <1536927045-23536-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1536927045-23536-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1536927045-23536-18-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Chris Zankel <chris@zankel.net>, "David S. Miller" <davem@davemloft.net>, Geert Uytterhoeven <geert@linux-m68k.org>, Greentime Hu <green.hu@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guan Xuetao <gxt@pku.edu.cn>, Ingo Molnar <mingo@redhat.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Jonas Bonn <jonas@southpole.se>, Jonathan Corbet <corbet@lwn.net>, Ley Foon Tan <lftan@altera.com>, Mark Salter <msalter@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Matt Turner <mattst88@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Michal Simek <monstr@monstr.eu>, Palmer Dabbelt <palmer@sifive.com>, Paul Burton <paul.burton@mips.com>, Richard Kuo <rkuo@codeaurora.org>, Richard Weinberger <richard@nod.at>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Serge Semin <fancer.lancer@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp, Mike Rapoport <rppt@linux.vnet.ibm.com>

Both functions attempt to allocate memory with specified alignment from a
particular node. If the allocation from that node fails, they both fall
back to allocating from any node in the system.

Usage of native memblock API eliminates the nobootmem translation layer.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Acked-by: Michal Hocko <mhocko@suse.com>
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
