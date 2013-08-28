Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 6DED76B003B
	for <linux-mm@kvack.org>; Wed, 28 Aug 2013 04:38:33 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id r10so6027443pdi.14
        for <linux-mm@kvack.org>; Wed, 28 Aug 2013 01:38:32 -0700 (PDT)
From: Alexey Kardashevskiy <aik@ozlabs.ru>
Subject: [PATCH v9 06/13] powerpc: add real mode support for dma operations on powernv
Date: Wed, 28 Aug 2013 18:37:43 +1000
Message-Id: <1377679070-3515-7-git-send-email-aik@ozlabs.ru>
In-Reply-To: <1377679070-3515-1-git-send-email-aik@ozlabs.ru>
References: <1377679070-3515-1-git-send-email-aik@ozlabs.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org
Cc: Alexey Kardashevskiy <aik@ozlabs.ru>, David Gibson <david@gibson.dropbear.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Gleb Natapov <gleb@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Graf <agraf@suse.de>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org

The existing TCE machine calls (tce_build and tce_free) only support
virtual mode as they call __raw_writeq for TCE invalidation what
fails in real mode.

This introduces tce_build_rm and tce_free_rm real mode versions
which do mostly the same but use "Store Doubleword Caching Inhibited
Indexed" instruction for TCE invalidation.

This new feature is going to be utilized by real mode support of VFIO.

Signed-off-by: Alexey Kardashevskiy <aik@ozlabs.ru>
---
Changes:
v8:
* fixed check_patch.pl warnings

2013/11/07:
* added comment why stdcix cannot be used in virtual mode

2013/08/07:
* tested on p7ioc and fixed a bug with realmode addresses
---
 arch/powerpc/include/asm/machdep.h        | 12 ++++++++
 arch/powerpc/platforms/powernv/pci-ioda.c | 49 +++++++++++++++++++++++--------
 arch/powerpc/platforms/powernv/pci.c      | 42 ++++++++++++++++++++++----
 arch/powerpc/platforms/powernv/pci.h      |  3 +-
 4 files changed, 87 insertions(+), 19 deletions(-)

diff --git a/arch/powerpc/include/asm/machdep.h b/arch/powerpc/include/asm/machdep.h
index 8b48090..07dd3b1 100644
--- a/arch/powerpc/include/asm/machdep.h
+++ b/arch/powerpc/include/asm/machdep.h
@@ -78,6 +78,18 @@ struct machdep_calls {
 				    long index);
 	void		(*tce_flush)(struct iommu_table *tbl);
 
+	/* _rm versions are for real mode use only */
+	int		(*tce_build_rm)(struct iommu_table *tbl,
+				     long index,
+				     long npages,
+				     unsigned long uaddr,
+				     enum dma_data_direction direction,
+				     struct dma_attrs *attrs);
+	void		(*tce_free_rm)(struct iommu_table *tbl,
+				    long index,
+				    long npages);
+	void		(*tce_flush_rm)(struct iommu_table *tbl);
+
 	void __iomem *	(*ioremap)(phys_addr_t addr, unsigned long size,
 				   unsigned long flags, void *caller);
 	void		(*iounmap)(volatile void __iomem *token);
diff --git a/arch/powerpc/platforms/powernv/pci-ioda.c b/arch/powerpc/platforms/powernv/pci-ioda.c
index 756bb58..8cba234 100644
--- a/arch/powerpc/platforms/powernv/pci-ioda.c
+++ b/arch/powerpc/platforms/powernv/pci-ioda.c
@@ -70,6 +70,16 @@ define_pe_printk_level(pe_err, KERN_ERR);
 define_pe_printk_level(pe_warn, KERN_WARNING);
 define_pe_printk_level(pe_info, KERN_INFO);
 
+/*
+ * stdcix is only supposed to be used in hypervisor real mode as per
+ * the architecture spec
+ */
+static inline void __raw_rm_writeq(u64 val, volatile void __iomem *paddr)
+{
+	__asm__ __volatile__("stdcix %0,0,%1"
+		: : "r" (val), "r" (paddr) : "memory");
+}
+
 static int pnv_ioda_alloc_pe(struct pnv_phb *phb)
 {
 	unsigned long pe;
@@ -454,10 +464,13 @@ static void pnv_ioda_setup_bus_dma(struct pnv_ioda_pe *pe, struct pci_bus *bus)
 	}
 }
 
-static void pnv_pci_ioda1_tce_invalidate(struct iommu_table *tbl,
-					 u64 *startp, u64 *endp)
+static void pnv_pci_ioda1_tce_invalidate(struct pnv_ioda_pe *pe,
+					 struct iommu_table *tbl,
+					 u64 *startp, u64 *endp, bool rm)
 {
-	u64 __iomem *invalidate = (u64 __iomem *)tbl->it_index;
+	u64 __iomem *invalidate = rm ?
+		(u64 __iomem *)pe->tce_inval_reg_phys :
+		(u64 __iomem *)tbl->it_index;
 	unsigned long start, end, inc;
 
 	start = __pa(startp);
@@ -484,7 +497,10 @@ static void pnv_pci_ioda1_tce_invalidate(struct iommu_table *tbl,
 
         mb(); /* Ensure above stores are visible */
         while (start <= end) {
-                __raw_writeq(start, invalidate);
+		if (rm)
+			__raw_rm_writeq(start, invalidate);
+		else
+			__raw_writeq(start, invalidate);
                 start += inc;
         }
 
@@ -496,10 +512,12 @@ static void pnv_pci_ioda1_tce_invalidate(struct iommu_table *tbl,
 
 static void pnv_pci_ioda2_tce_invalidate(struct pnv_ioda_pe *pe,
 					 struct iommu_table *tbl,
-					 u64 *startp, u64 *endp)
+					 u64 *startp, u64 *endp, bool rm)
 {
 	unsigned long start, end, inc;
-	u64 __iomem *invalidate = (u64 __iomem *)tbl->it_index;
+	u64 __iomem *invalidate = rm ?
+		(u64 __iomem *)pe->tce_inval_reg_phys :
+		(u64 __iomem *)tbl->it_index;
 
 	/* We'll invalidate DMA address in PE scope */
 	start = 0x2ul << 60;
@@ -515,22 +533,25 @@ static void pnv_pci_ioda2_tce_invalidate(struct pnv_ioda_pe *pe,
 	mb();
 
 	while (start <= end) {
-		__raw_writeq(start, invalidate);
+		if (rm)
+			__raw_rm_writeq(start, invalidate);
+		else
+			__raw_writeq(start, invalidate);
 		start += inc;
 	}
 }
 
 void pnv_pci_ioda_tce_invalidate(struct iommu_table *tbl,
-				 u64 *startp, u64 *endp)
+				 u64 *startp, u64 *endp, bool rm)
 {
 	struct pnv_ioda_pe *pe = container_of(tbl, struct pnv_ioda_pe,
 					      tce32_table);
 	struct pnv_phb *phb = pe->phb;
 
 	if (phb->type == PNV_PHB_IODA1)
-		pnv_pci_ioda1_tce_invalidate(tbl, startp, endp);
+		pnv_pci_ioda1_tce_invalidate(pe, tbl, startp, endp, rm);
 	else
-		pnv_pci_ioda2_tce_invalidate(pe, tbl, startp, endp);
+		pnv_pci_ioda2_tce_invalidate(pe, tbl, startp, endp, rm);
 }
 
 static void pnv_pci_ioda_setup_dma_pe(struct pnv_phb *phb,
@@ -603,7 +624,9 @@ static void pnv_pci_ioda_setup_dma_pe(struct pnv_phb *phb,
 		 * bus number, print that out instead.
 		 */
 		tbl->it_busno = 0;
-		tbl->it_index = (unsigned long)ioremap(be64_to_cpup(swinvp), 8);
+		pe->tce_inval_reg_phys = be64_to_cpup(swinvp);
+		tbl->it_index = (unsigned long)ioremap(pe->tce_inval_reg_phys,
+				8);
 		tbl->it_type = TCE_PCI_SWINV_CREATE | TCE_PCI_SWINV_FREE |
 			       TCE_PCI_SWINV_PAIR;
 	}
@@ -681,7 +704,9 @@ static void pnv_pci_ioda2_setup_dma_pe(struct pnv_phb *phb,
 		 * bus number, print that out instead.
 		 */
 		tbl->it_busno = 0;
-		tbl->it_index = (unsigned long)ioremap(be64_to_cpup(swinvp), 8);
+		pe->tce_inval_reg_phys = be64_to_cpup(swinvp);
+		tbl->it_index = (unsigned long)ioremap(pe->tce_inval_reg_phys,
+				8);
 		tbl->it_type = TCE_PCI_SWINV_CREATE | TCE_PCI_SWINV_FREE;
 	}
 	iommu_init_table(tbl, phb->hose->node);
diff --git a/arch/powerpc/platforms/powernv/pci.c b/arch/powerpc/platforms/powernv/pci.c
index c005011..8623529 100644
--- a/arch/powerpc/platforms/powernv/pci.c
+++ b/arch/powerpc/platforms/powernv/pci.c
@@ -401,7 +401,7 @@ struct pci_ops pnv_pci_ops = {
 
 static int pnv_tce_build(struct iommu_table *tbl, long index, long npages,
 			 unsigned long uaddr, enum dma_data_direction direction,
-			 struct dma_attrs *attrs)
+			 struct dma_attrs *attrs, bool rm)
 {
 	u64 proto_tce;
 	u64 *tcep, *tces;
@@ -423,12 +423,22 @@ static int pnv_tce_build(struct iommu_table *tbl, long index, long npages,
 	 * of flags if that becomes the case
 	 */
 	if (tbl->it_type & TCE_PCI_SWINV_CREATE)
-		pnv_pci_ioda_tce_invalidate(tbl, tces, tcep - 1);
+		pnv_pci_ioda_tce_invalidate(tbl, tces, tcep - 1, rm);
 
 	return 0;
 }
 
-static void pnv_tce_free(struct iommu_table *tbl, long index, long npages)
+static int pnv_tce_build_vm(struct iommu_table *tbl, long index, long npages,
+			    unsigned long uaddr,
+			    enum dma_data_direction direction,
+			    struct dma_attrs *attrs)
+{
+	return pnv_tce_build(tbl, index, npages, uaddr, direction, attrs,
+			false);
+}
+
+static void pnv_tce_free(struct iommu_table *tbl, long index, long npages,
+		bool rm)
 {
 	u64 *tcep, *tces;
 
@@ -438,7 +448,12 @@ static void pnv_tce_free(struct iommu_table *tbl, long index, long npages)
 		*(tcep++) = 0;
 
 	if (tbl->it_type & TCE_PCI_SWINV_FREE)
-		pnv_pci_ioda_tce_invalidate(tbl, tces, tcep - 1);
+		pnv_pci_ioda_tce_invalidate(tbl, tces, tcep - 1, rm);
+}
+
+static void pnv_tce_free_vm(struct iommu_table *tbl, long index, long npages)
+{
+	pnv_tce_free(tbl, index, npages, false);
 }
 
 static unsigned long pnv_tce_get(struct iommu_table *tbl, long index)
@@ -446,6 +461,19 @@ static unsigned long pnv_tce_get(struct iommu_table *tbl, long index)
 	return ((u64 *)tbl->it_base)[index - tbl->it_offset];
 }
 
+static int pnv_tce_build_rm(struct iommu_table *tbl, long index, long npages,
+			    unsigned long uaddr,
+			    enum dma_data_direction direction,
+			    struct dma_attrs *attrs)
+{
+	return pnv_tce_build(tbl, index, npages, uaddr, direction, attrs, true);
+}
+
+static void pnv_tce_free_rm(struct iommu_table *tbl, long index, long npages)
+{
+	pnv_tce_free(tbl, index, npages, true);
+}
+
 void pnv_pci_setup_iommu_table(struct iommu_table *tbl,
 			       void *tce_mem, u64 tce_size,
 			       u64 dma_offset)
@@ -610,8 +638,10 @@ void __init pnv_pci_init(void)
 
 	/* Configure IOMMU DMA hooks */
 	ppc_md.pci_dma_dev_setup = pnv_pci_dma_dev_setup;
-	ppc_md.tce_build = pnv_tce_build;
-	ppc_md.tce_free = pnv_tce_free;
+	ppc_md.tce_build = pnv_tce_build_vm;
+	ppc_md.tce_free = pnv_tce_free_vm;
+	ppc_md.tce_build_rm = pnv_tce_build_rm;
+	ppc_md.tce_free_rm = pnv_tce_free_rm;
 	ppc_md.tce_get = pnv_tce_get;
 	ppc_md.pci_probe_mode = pnv_pci_probe_mode;
 	set_pci_dma_ops(&dma_iommu_ops);
diff --git a/arch/powerpc/platforms/powernv/pci.h b/arch/powerpc/platforms/powernv/pci.h
index d633c64..170dd98 100644
--- a/arch/powerpc/platforms/powernv/pci.h
+++ b/arch/powerpc/platforms/powernv/pci.h
@@ -52,6 +52,7 @@ struct pnv_ioda_pe {
 	int			tce32_seg;
 	int			tce32_segcount;
 	struct iommu_table	tce32_table;
+	phys_addr_t		tce_inval_reg_phys;
 
 	/* XXX TODO: Add support for additional 64-bit iommus */
 
@@ -193,6 +194,6 @@ extern void pnv_pci_init_p5ioc2_hub(struct device_node *np);
 extern void pnv_pci_init_ioda_hub(struct device_node *np);
 extern void pnv_pci_init_ioda2_phb(struct device_node *np);
 extern void pnv_pci_ioda_tce_invalidate(struct iommu_table *tbl,
-					u64 *startp, u64 *endp);
+					u64 *startp, u64 *endp, bool rm);
 
 #endif /* __POWERNV_PCI_H */
-- 
1.8.4.rc4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
