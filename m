Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id A0BF26B03B9
	for <linux-mm@kvack.org>; Fri,  7 Jul 2017 09:43:19 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id b130so2470982oii.9
        for <linux-mm@kvack.org>; Fri, 07 Jul 2017 06:43:19 -0700 (PDT)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0072.outbound.protection.outlook.com. [104.47.37.72])
        by mx.google.com with ESMTPS id f143si2388155oig.338.2017.07.07.06.43.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 07 Jul 2017 06:43:18 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v9 27/38] iommu/amd: Allow the AMD IOMMU to work with memory
 encryption
Date: Fri, 07 Jul 2017 08:43:08 -0500
Message-ID: <20170707134308.29711.87493.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170707133804.29711.1616.stgit@tlendack-t1.amdoffice.net>
References: <20170707133804.29711.1616.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

The IOMMU is programmed with physical addresses for the various tables
and buffers that are used to communicate between the device and the
driver. When the driver allocates this memory it is encrypted. In order
for the IOMMU to access the memory as encrypted the encryption mask needs
to be included in these physical addresses during configuration.

The PTE entries created by the IOMMU should also include the encryption
mask so that when the device behind the IOMMU performs a DMA, the DMA
will be performed to encrypted memory.

Acked-by: Joerg Roedel <jroedel@suse.de>
Reviewed-by: Borislav Petkov <bp@suse.de>
Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/iommu/amd_iommu.c       |   30 ++++++++++++++++--------------
 drivers/iommu/amd_iommu_init.c  |   34 ++++++++++++++++++++++++++++------
 drivers/iommu/amd_iommu_proto.h |   10 ++++++++++
 drivers/iommu/amd_iommu_types.h |    2 +-
 4 files changed, 55 insertions(+), 21 deletions(-)

diff --git a/drivers/iommu/amd_iommu.c b/drivers/iommu/amd_iommu.c
index 5c9759e..a0a39f6 100644
--- a/drivers/iommu/amd_iommu.c
+++ b/drivers/iommu/amd_iommu.c
@@ -544,7 +544,7 @@ static void dump_dte_entry(u16 devid)
 
 static void dump_command(unsigned long phys_addr)
 {
-	struct iommu_cmd *cmd = phys_to_virt(phys_addr);
+	struct iommu_cmd *cmd = iommu_phys_to_virt(phys_addr);
 	int i;
 
 	for (i = 0; i < 4; ++i)
@@ -865,11 +865,13 @@ static void copy_cmd_to_buffer(struct amd_iommu *iommu,
 
 static void build_completion_wait(struct iommu_cmd *cmd, u64 address)
 {
+	u64 paddr = iommu_virt_to_phys((void *)address);
+
 	WARN_ON(address & 0x7ULL);
 
 	memset(cmd, 0, sizeof(*cmd));
-	cmd->data[0] = lower_32_bits(__pa(address)) | CMD_COMPL_WAIT_STORE_MASK;
-	cmd->data[1] = upper_32_bits(__pa(address));
+	cmd->data[0] = lower_32_bits(paddr) | CMD_COMPL_WAIT_STORE_MASK;
+	cmd->data[1] = upper_32_bits(paddr);
 	cmd->data[2] = 1;
 	CMD_SET_TYPE(cmd, CMD_COMPL_WAIT);
 }
@@ -1328,7 +1330,7 @@ static bool increase_address_space(struct protection_domain *domain,
 		return false;
 
 	*pte             = PM_LEVEL_PDE(domain->mode,
-					virt_to_phys(domain->pt_root));
+					iommu_virt_to_phys(domain->pt_root));
 	domain->pt_root  = pte;
 	domain->mode    += 1;
 	domain->updated  = true;
@@ -1365,7 +1367,7 @@ static u64 *alloc_pte(struct protection_domain *domain,
 			if (!page)
 				return NULL;
 
-			__npte = PM_LEVEL_PDE(level, virt_to_phys(page));
+			__npte = PM_LEVEL_PDE(level, iommu_virt_to_phys(page));
 
 			/* pte could have been changed somewhere. */
 			if (cmpxchg64(pte, __pte, __npte) != __pte) {
@@ -1481,10 +1483,10 @@ static int iommu_map_page(struct protection_domain *dom,
 			return -EBUSY;
 
 	if (count > 1) {
-		__pte = PAGE_SIZE_PTE(phys_addr, page_size);
+		__pte = PAGE_SIZE_PTE(__sme_set(phys_addr), page_size);
 		__pte |= PM_LEVEL_ENC(7) | IOMMU_PTE_P | IOMMU_PTE_FC;
 	} else
-		__pte = phys_addr | IOMMU_PTE_P | IOMMU_PTE_FC;
+		__pte = __sme_set(phys_addr) | IOMMU_PTE_P | IOMMU_PTE_FC;
 
 	if (prot & IOMMU_PROT_IR)
 		__pte |= IOMMU_PTE_IR;
@@ -1700,7 +1702,7 @@ static void free_gcr3_tbl_level1(u64 *tbl)
 		if (!(tbl[i] & GCR3_VALID))
 			continue;
 
-		ptr = __va(tbl[i] & PAGE_MASK);
+		ptr = iommu_phys_to_virt(tbl[i] & PAGE_MASK);
 
 		free_page((unsigned long)ptr);
 	}
@@ -1715,7 +1717,7 @@ static void free_gcr3_tbl_level2(u64 *tbl)
 		if (!(tbl[i] & GCR3_VALID))
 			continue;
 
-		ptr = __va(tbl[i] & PAGE_MASK);
+		ptr = iommu_phys_to_virt(tbl[i] & PAGE_MASK);
 
 		free_gcr3_tbl_level1(ptr);
 	}
@@ -1807,7 +1809,7 @@ static void set_dte_entry(u16 devid, struct protection_domain *domain, bool ats)
 	u64 flags = 0;
 
 	if (domain->mode != PAGE_MODE_NONE)
-		pte_root = virt_to_phys(domain->pt_root);
+		pte_root = iommu_virt_to_phys(domain->pt_root);
 
 	pte_root |= (domain->mode & DEV_ENTRY_MODE_MASK)
 		    << DEV_ENTRY_MODE_SHIFT;
@@ -1819,7 +1821,7 @@ static void set_dte_entry(u16 devid, struct protection_domain *domain, bool ats)
 		flags |= DTE_FLAG_IOTLB;
 
 	if (domain->flags & PD_IOMMUV2_MASK) {
-		u64 gcr3 = __pa(domain->gcr3_tbl);
+		u64 gcr3 = iommu_virt_to_phys(domain->gcr3_tbl);
 		u64 glx  = domain->glx;
 		u64 tmp;
 
@@ -3470,10 +3472,10 @@ static u64 *__get_gcr3_pte(u64 *root, int level, int pasid, bool alloc)
 			if (root == NULL)
 				return NULL;
 
-			*pte = __pa(root) | GCR3_VALID;
+			*pte = iommu_virt_to_phys(root) | GCR3_VALID;
 		}
 
-		root = __va(*pte & PAGE_MASK);
+		root = iommu_phys_to_virt(*pte & PAGE_MASK);
 
 		level -= 1;
 	}
@@ -3652,7 +3654,7 @@ static void set_dte_irq_entry(u16 devid, struct irq_remap_table *table)
 
 	dte	= amd_iommu_dev_table[devid].data[2];
 	dte	&= ~DTE_IRQ_PHYS_ADDR_MASK;
-	dte	|= virt_to_phys(table->table);
+	dte	|= iommu_virt_to_phys(table->table);
 	dte	|= DTE_IRQ_REMAP_INTCTL;
 	dte	|= DTE_IRQ_TABLE_LEN;
 	dte	|= DTE_IRQ_REMAP_ENABLE;
diff --git a/drivers/iommu/amd_iommu_init.c b/drivers/iommu/amd_iommu_init.c
index 5a11328..096538c 100644
--- a/drivers/iommu/amd_iommu_init.c
+++ b/drivers/iommu/amd_iommu_init.c
@@ -29,6 +29,7 @@
 #include <linux/export.h>
 #include <linux/iommu.h>
 #include <linux/kmemleak.h>
+#include <linux/mem_encrypt.h>
 #include <asm/pci-direct.h>
 #include <asm/iommu.h>
 #include <asm/gart.h>
@@ -346,7 +347,7 @@ static void iommu_set_device_table(struct amd_iommu *iommu)
 
 	BUG_ON(iommu->mmio_base == NULL);
 
-	entry = virt_to_phys(amd_iommu_dev_table);
+	entry = iommu_virt_to_phys(amd_iommu_dev_table);
 	entry |= (dev_table_size >> 12) - 1;
 	memcpy_toio(iommu->mmio_base + MMIO_DEV_TABLE_OFFSET,
 			&entry, sizeof(entry));
@@ -602,7 +603,7 @@ static void iommu_enable_command_buffer(struct amd_iommu *iommu)
 
 	BUG_ON(iommu->cmd_buf == NULL);
 
-	entry = (u64)virt_to_phys(iommu->cmd_buf);
+	entry = iommu_virt_to_phys(iommu->cmd_buf);
 	entry |= MMIO_CMD_SIZE_512;
 
 	memcpy_toio(iommu->mmio_base + MMIO_CMD_BUF_OFFSET,
@@ -631,7 +632,7 @@ static void iommu_enable_event_buffer(struct amd_iommu *iommu)
 
 	BUG_ON(iommu->evt_buf == NULL);
 
-	entry = (u64)virt_to_phys(iommu->evt_buf) | EVT_LEN_MASK;
+	entry = iommu_virt_to_phys(iommu->evt_buf) | EVT_LEN_MASK;
 
 	memcpy_toio(iommu->mmio_base + MMIO_EVT_BUF_OFFSET,
 		    &entry, sizeof(entry));
@@ -664,7 +665,7 @@ static void iommu_enable_ppr_log(struct amd_iommu *iommu)
 	if (iommu->ppr_log == NULL)
 		return;
 
-	entry = (u64)virt_to_phys(iommu->ppr_log) | PPR_LOG_SIZE_512;
+	entry = iommu_virt_to_phys(iommu->ppr_log) | PPR_LOG_SIZE_512;
 
 	memcpy_toio(iommu->mmio_base + MMIO_PPR_LOG_OFFSET,
 		    &entry, sizeof(entry));
@@ -744,10 +745,10 @@ static int iommu_init_ga_log(struct amd_iommu *iommu)
 	if (!iommu->ga_log_tail)
 		goto err_out;
 
-	entry = (u64)virt_to_phys(iommu->ga_log) | GA_LOG_SIZE_512;
+	entry = iommu_virt_to_phys(iommu->ga_log) | GA_LOG_SIZE_512;
 	memcpy_toio(iommu->mmio_base + MMIO_GA_LOG_BASE_OFFSET,
 		    &entry, sizeof(entry));
-	entry = ((u64)virt_to_phys(iommu->ga_log) & 0xFFFFFFFFFFFFFULL) & ~7ULL;
+	entry = (iommu_virt_to_phys(iommu->ga_log) & 0xFFFFFFFFFFFFFULL) & ~7ULL;
 	memcpy_toio(iommu->mmio_base + MMIO_GA_LOG_TAIL_OFFSET,
 		    &entry, sizeof(entry));
 	writel(0x00, iommu->mmio_base + MMIO_GA_HEAD_OFFSET);
@@ -2535,6 +2536,24 @@ static int __init amd_iommu_init(void)
 	return ret;
 }
 
+static bool amd_iommu_sme_check(void)
+{
+	if (!sme_active() || (boot_cpu_data.x86 != 0x17))
+		return true;
+
+	/* For Fam17h, a specific level of support is required */
+	if (boot_cpu_data.microcode >= 0x08001205)
+		return true;
+
+	if ((boot_cpu_data.microcode >= 0x08001126) &&
+	    (boot_cpu_data.microcode <= 0x080011ff))
+		return true;
+
+	pr_notice("AMD-Vi: IOMMU not currently supported when SME is active\n");
+
+	return false;
+}
+
 /****************************************************************************
  *
  * Early detect code. This code runs at IOMMU detection time in the DMA
@@ -2552,6 +2571,9 @@ int __init amd_iommu_detect(void)
 	if (amd_iommu_disabled)
 		return -ENODEV;
 
+	if (!amd_iommu_sme_check())
+		return -ENODEV;
+
 	ret = iommu_go_to_state(IOMMU_IVRS_DETECTED);
 	if (ret)
 		return ret;
diff --git a/drivers/iommu/amd_iommu_proto.h b/drivers/iommu/amd_iommu_proto.h
index 466260f..3f12fb2 100644
--- a/drivers/iommu/amd_iommu_proto.h
+++ b/drivers/iommu/amd_iommu_proto.h
@@ -87,4 +87,14 @@ static inline bool iommu_feature(struct amd_iommu *iommu, u64 f)
 	return !!(iommu->features & f);
 }
 
+static inline u64 iommu_virt_to_phys(void *vaddr)
+{
+	return (u64)__sme_set(virt_to_phys(vaddr));
+}
+
+static inline void *iommu_phys_to_virt(unsigned long paddr)
+{
+	return phys_to_virt(__sme_clr(paddr));
+}
+
 #endif /* _ASM_X86_AMD_IOMMU_PROTO_H  */
diff --git a/drivers/iommu/amd_iommu_types.h b/drivers/iommu/amd_iommu_types.h
index 4de8f41..3ce587d 100644
--- a/drivers/iommu/amd_iommu_types.h
+++ b/drivers/iommu/amd_iommu_types.h
@@ -343,7 +343,7 @@
 
 #define IOMMU_PAGE_MASK (((1ULL << 52) - 1) & ~0xfffULL)
 #define IOMMU_PTE_PRESENT(pte) ((pte) & IOMMU_PTE_P)
-#define IOMMU_PTE_PAGE(pte) (phys_to_virt((pte) & IOMMU_PAGE_MASK))
+#define IOMMU_PTE_PAGE(pte) (iommu_phys_to_virt((pte) & IOMMU_PAGE_MASK))
 #define IOMMU_PTE_MODE(pte) (((pte) >> 9) & 0x07)
 
 #define IOMMU_PROT_MASK 0x03

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
