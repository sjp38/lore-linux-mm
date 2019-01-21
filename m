Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH v2 14/21] ia64: add checks for the return value of memblock_alloc*()
Date: Mon, 21 Jan 2019 10:04:01 +0200
In-Reply-To: <1548057848-15136-1-git-send-email-rppt@linux.ibm.com>
References: <1548057848-15136-1-git-send-email-rppt@linux.ibm.com>
Message-Id: <1548057848-15136-15-git-send-email-rppt@linux.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Christoph Hellwig <hch@lst.de>, "David S. Miller" <davem@davemloft.net>, Dennis Zhou <dennis@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greentime Hu <green.hu@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guan Xuetao <gxt@pku.edu.cn>, Guo Ren <guoren@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Mark Salter <msalter@redhat.com>, Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Simek <monstr@monstr.eu>, Paul Burton <paul.burton@mips.com>, Petr Mladek <pmladek@suse.com>, Rich Felker <dalias@libc.org>, Richard Weinberger <richard@nod.at>, Rob Herring <robh+dt@kernel.org>, Russell King <linux@armlinux.org.uk>, Stafford Horne <shorne@gmail.com>, Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, devicetree@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, linux-usb@vger.kernel.org, linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp, x86@kernel.org, xen-devel@lists.xenproject.org, Mike Rapoport <rppt@linux.ibm.com>
List-ID: <linux-mm.kvack.org>

Add panic() calls if memblock_alloc*() returns NULL.

Most of the changes are simply addition of

	if(!ptr)
		panic();

statements after the calls to memblock_alloc*() variants.

Exceptions are create_mem_map_page_table() and ia64_log_init() that were
slightly refactored to accommodate the change.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/ia64/kernel/mca.c          | 20 ++++++++++++++------
 arch/ia64/mm/contig.c           |  8 ++++++--
 arch/ia64/mm/discontig.c        |  4 ++++
 arch/ia64/mm/init.c             | 38 ++++++++++++++++++++++++++++++--------
 arch/ia64/mm/tlb.c              |  6 ++++++
 arch/ia64/sn/kernel/io_common.c |  3 +++
 arch/ia64/sn/kernel/setup.c     | 12 +++++++++++-
 7 files changed, 74 insertions(+), 17 deletions(-)

diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index 370bc34..5cabb3f 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -359,11 +359,6 @@ typedef struct ia64_state_log_s
 
 static ia64_state_log_t ia64_state_log[IA64_MAX_LOG_TYPES];
 
-#define IA64_LOG_ALLOCATE(it, size) \
-	{ia64_state_log[it].isl_log[IA64_LOG_CURR_INDEX(it)] = \
-		(ia64_err_rec_t *)memblock_alloc(size, SMP_CACHE_BYTES); \
-	ia64_state_log[it].isl_log[IA64_LOG_NEXT_INDEX(it)] = \
-		(ia64_err_rec_t *)memblock_alloc(size, SMP_CACHE_BYTES);}
 #define IA64_LOG_LOCK_INIT(it) spin_lock_init(&ia64_state_log[it].isl_lock)
 #define IA64_LOG_LOCK(it)      spin_lock_irqsave(&ia64_state_log[it].isl_lock, s)
 #define IA64_LOG_UNLOCK(it)    spin_unlock_irqrestore(&ia64_state_log[it].isl_lock,s)
@@ -378,6 +373,19 @@ static ia64_state_log_t ia64_state_log[IA64_MAX_LOG_TYPES];
 #define IA64_LOG_CURR_BUFFER(it)   (void *)((ia64_state_log[it].isl_log[IA64_LOG_CURR_INDEX(it)]))
 #define IA64_LOG_COUNT(it)         ia64_state_log[it].isl_count
 
+static inline void ia64_log_allocate(int it, u64 size)
+{
+	ia64_state_log[it].isl_log[IA64_LOG_CURR_INDEX(it)] =
+		(ia64_err_rec_t *)memblock_alloc(size, SMP_CACHE_BYTES);
+	if (!ia64_state_log[it].isl_log[IA64_LOG_CURR_INDEX(it)])
+		panic("%s: Failed to allocate %llu bytes\n", __func__, size);
+
+	ia64_state_log[it].isl_log[IA64_LOG_NEXT_INDEX(it)] =
+		(ia64_err_rec_t *)memblock_alloc(size, SMP_CACHE_BYTES);
+	if (!ia64_state_log[it].isl_log[IA64_LOG_NEXT_INDEX(it)])
+		panic("%s: Failed to allocate %llu bytes\n", __func__, size);
+}
+
 /*
  * ia64_log_init
  *	Reset the OS ia64 log buffer
@@ -399,7 +407,7 @@ ia64_log_init(int sal_info_type)
 		return;
 
 	// set up OS data structures to hold error info
-	IA64_LOG_ALLOCATE(sal_info_type, max_size);
+	ia64_log_allocate(sal_info_type, max_size);
 }
 
 /*
diff --git a/arch/ia64/mm/contig.c b/arch/ia64/mm/contig.c
index 6e44723..d29fb6b 100644
--- a/arch/ia64/mm/contig.c
+++ b/arch/ia64/mm/contig.c
@@ -84,9 +84,13 @@ void *per_cpu_init(void)
 static inline void
 alloc_per_cpu_data(void)
 {
-	cpu_data = memblock_alloc_from(PERCPU_PAGE_SIZE * num_possible_cpus(),
-				       PERCPU_PAGE_SIZE,
+	size_t size = PERCPU_PAGE_SIZE * num_possible_cpus();
+
+	cpu_data = memblock_alloc_from(size, PERCPU_PAGE_SIZE,
 				       __pa(MAX_DMA_ADDRESS));
+	if (!cpu_data)
+		panic("%s: Failed to allocate %lu bytes align=%lx from=%lx\n",
+		      __func__, size, PERCPU_PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
 }
 
 /**
diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index f9c3675..05490dd 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -454,6 +454,10 @@ static void __init *memory_less_node_alloc(int nid, unsigned long pernodesize)
 				     __pa(MAX_DMA_ADDRESS),
 				     MEMBLOCK_ALLOC_ACCESSIBLE,
 				     bestnode);
+	if (!ptr)
+		panic("%s: Failed to allocate %lu bytes align=0x%lx nid=%d from=%lx\n",
+		      __func__, pernodesize, PERCPU_PAGE_SIZE, bestnode,
+		      __pa(MAX_DMA_ADDRESS));
 
 	return ptr;
 }
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 29d8415..e49200e 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -444,23 +444,45 @@ int __init create_mem_map_page_table(u64 start, u64 end, void *arg)
 
 	for (address = start_page; address < end_page; address += PAGE_SIZE) {
 		pgd = pgd_offset_k(address);
-		if (pgd_none(*pgd))
-			pgd_populate(&init_mm, pgd, memblock_alloc_node(PAGE_SIZE, PAGE_SIZE, node));
+		if (pgd_none(*pgd)) {
+			pud = memblock_alloc_node(PAGE_SIZE, PAGE_SIZE, node);
+			if (!pud)
+				goto err_alloc;
+			pgd_populate(&init_mm, pgd, pud);
+		}
 		pud = pud_offset(pgd, address);
 
-		if (pud_none(*pud))
-			pud_populate(&init_mm, pud, memblock_alloc_node(PAGE_SIZE, PAGE_SIZE, node));
+		if (pud_none(*pud)) {
+			pmd = memblock_alloc_node(PAGE_SIZE, PAGE_SIZE, node);
+			if (!pmd)
+				goto err_alloc;
+			pud_populate(&init_mm, pud, pmd);
+		}
 		pmd = pmd_offset(pud, address);
 
-		if (pmd_none(*pmd))
-			pmd_populate_kernel(&init_mm, pmd, memblock_alloc_node(PAGE_SIZE, PAGE_SIZE, node));
+		if (pmd_none(*pmd)) {
+			pte = memblock_alloc_node(PAGE_SIZE, PAGE_SIZE, node);
+			if (!pte)
+				goto err_alloc;
+			pmd_populate_kernel(&init_mm, pmd, pte);
+		}
 		pte = pte_offset_kernel(pmd, address);
 
-		if (pte_none(*pte))
-			set_pte(pte, pfn_pte(__pa(memblock_alloc_node(PAGE_SIZE, PAGE_SIZE, node)) >> PAGE_SHIFT,
+		if (pte_none(*pte)) {
+			void *page = memblock_alloc_node(PAGE_SIZE, PAGE_SIZE,
+							 node);
+			if (!page)
+				goto err_alloc;
+			set_pte(pte, pfn_pte(__pa(page) >> PAGE_SHIFT,
 					     PAGE_KERNEL));
+		}
 	}
 	return 0;
+
+err_alloc:
+	panic("%s: Failed to allocate %lu bytes align=0x%lx nid=%d\n",
+	      __func__, PAGE_SIZE, PAGE_SIZE, node);
+	return -ENOMEM;
 }
 
 struct memmap_init_callback_data {
diff --git a/arch/ia64/mm/tlb.c b/arch/ia64/mm/tlb.c
index 9340bcb..5fc89aa 100644
--- a/arch/ia64/mm/tlb.c
+++ b/arch/ia64/mm/tlb.c
@@ -61,8 +61,14 @@ mmu_context_init (void)
 {
 	ia64_ctx.bitmap = memblock_alloc((ia64_ctx.max_ctx + 1) >> 3,
 					 SMP_CACHE_BYTES);
+	if (!ia64_ctx.bitmap)
+		panic("%s: Failed to allocate %u bytes\n", __func__,
+		      (ia64_ctx.max_ctx + 1) >> 3);
 	ia64_ctx.flushmap = memblock_alloc((ia64_ctx.max_ctx + 1) >> 3,
 					   SMP_CACHE_BYTES);
+	if (!ia64_ctx.flushmap)
+		panic("%s: Failed to allocate %u bytes\n", __func__,
+		      (ia64_ctx.max_ctx + 1) >> 3);
 }
 
 /*
diff --git a/arch/ia64/sn/kernel/io_common.c b/arch/ia64/sn/kernel/io_common.c
index 8df13d0..d468473 100644
--- a/arch/ia64/sn/kernel/io_common.c
+++ b/arch/ia64/sn/kernel/io_common.c
@@ -394,6 +394,9 @@ void __init hubdev_init_node(nodepda_t * npda, cnodeid_t node)
 	hubdev_info = (struct hubdev_info *)memblock_alloc_node(size,
 								SMP_CACHE_BYTES,
 								node);
+	if (!hubdev_info)
+		panic("%s: Failed to allocate %d bytes align=0x%x nid=%d\n",
+		      __func__, size, SMP_CACHE_BYTES, node);
 
 	npda->pdinfo = (void *)hubdev_info;
 }
diff --git a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
index a6d40a2..e6a5049 100644
--- a/arch/ia64/sn/kernel/setup.c
+++ b/arch/ia64/sn/kernel/setup.c
@@ -513,6 +513,10 @@ static void __init sn_init_pdas(char **cmdline_p)
 		nodepdaindr[cnode] =
 		    memblock_alloc_node(sizeof(nodepda_t), SMP_CACHE_BYTES,
 					cnode);
+		if (!nodepdaindr[cnode])
+			panic("%s: Failed to allocate %lu bytes align=0x%x nid=%d\n",
+			      __func__, sizeof(nodepda_t), SMP_CACHE_BYTES,
+			      cnode);
 		memset(nodepdaindr[cnode]->phys_cpuid, -1,
 		    sizeof(nodepdaindr[cnode]->phys_cpuid));
 		spin_lock_init(&nodepdaindr[cnode]->ptc_lock);
@@ -521,9 +525,15 @@ static void __init sn_init_pdas(char **cmdline_p)
 	/*
 	 * Allocate & initialize nodepda for TIOs.  For now, put them on node 0.
 	 */
-	for (cnode = num_online_nodes(); cnode < num_cnodes; cnode++)
+	for (cnode = num_online_nodes(); cnode < num_cnodes; cnode++) {
 		nodepdaindr[cnode] =
 		    memblock_alloc_node(sizeof(nodepda_t), SMP_CACHE_BYTES, 0);
+		if (!nodepdaindr[cnode])
+			panic("%s: Failed to allocate %lu bytes align=0x%x nid=%d\n",
+			      __func__, sizeof(nodepda_t), SMP_CACHE_BYTES,
+			      cnode);
+	}
+
 
 	/*
 	 * Now copy the array of nodepda pointers to each nodepda.
-- 
2.7.4
