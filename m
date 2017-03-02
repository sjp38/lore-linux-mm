Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1E4176B0397
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 10:13:50 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id f103so67577655ioi.5
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 07:13:50 -0800 (PST)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0076.outbound.protection.outlook.com. [104.47.32.76])
        by mx.google.com with ESMTPS id 143si9227925ioe.128.2017.03.02.07.13.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 02 Mar 2017 07:13:49 -0800 (PST)
Subject: [RFC PATCH v2 08/32] x86: Use PAGE_KERNEL protection for ioremap of
 memory page
From: Brijesh Singh <brijesh.singh@amd.com>
Date: Thu, 2 Mar 2017 10:13:32 -0500
Message-ID: <148846761276.2349.4899767672892365544.stgit@brijesh-build-machine>
In-Reply-To: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, brijesh.singh@amd.com, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

From: Tom Lendacky <thomas.lendacky@amd.com>

In order for memory pages to be properly mapped when SEV is active, we
need to use the PAGE_KERNEL protection attribute as the base protection.
This will insure that memory mapping of, e.g. ACPI tables, receives the
proper mapping attributes.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/mm/ioremap.c |    8 ++++++++
 include/linux/mm.h    |    1 +
 kernel/resource.c     |   40 ++++++++++++++++++++++++++++++++++++++++
 3 files changed, 49 insertions(+)

diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
index c400ab5..481c999 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -151,7 +151,15 @@ static void __iomem *__ioremap_caller(resource_size_t phys_addr,
 		pcm = new_pcm;
 	}
 
+	/*
+	 * If the page being mapped is in memory and SEV is active then
+	 * make sure the memory encryption attribute is enabled in the
+	 * resulting mapping.
+	 */
 	prot = PAGE_KERNEL_IO;
+	if (sev_active() && page_is_mem(pfn))
+		prot = __pgprot(pgprot_val(prot) | _PAGE_ENC);
+
 	switch (pcm) {
 	case _PAGE_CACHE_MODE_UC:
 	default:
diff --git a/include/linux/mm.h b/include/linux/mm.h
index b84615b..825df27 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -445,6 +445,7 @@ static inline int get_page_unless_zero(struct page *page)
 }
 
 extern int page_is_ram(unsigned long pfn);
+extern int page_is_mem(unsigned long pfn);
 
 enum {
 	REGION_INTERSECTS,
diff --git a/kernel/resource.c b/kernel/resource.c
index 9b5f044..db56ba3 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
@@ -518,6 +518,46 @@ int __weak page_is_ram(unsigned long pfn)
 }
 EXPORT_SYMBOL_GPL(page_is_ram);
 
+/*
+ * This function returns true if the target memory is marked as
+ * IORESOURCE_MEM and IORESOUCE_BUSY and described as other than
+ * IORES_DESC_NONE (e.g. IORES_DESC_ACPI_TABLES).
+ */
+static int walk_mem_range(unsigned long start_pfn, unsigned long nr_pages)
+{
+	struct resource res;
+	unsigned long pfn, end_pfn;
+	u64 orig_end;
+	int ret = -1;
+
+	res.start = (u64) start_pfn << PAGE_SHIFT;
+	res.end = ((u64)(start_pfn + nr_pages) << PAGE_SHIFT) - 1;
+	res.flags = IORESOURCE_MEM | IORESOURCE_BUSY;
+	orig_end = res.end;
+	while ((res.start < res.end) &&
+		(find_next_iomem_res(&res, IORES_DESC_NONE, true) >= 0)) {
+		pfn = (res.start + PAGE_SIZE - 1) >> PAGE_SHIFT;
+		end_pfn = (res.end + 1) >> PAGE_SHIFT;
+		if (end_pfn > pfn)
+			ret = (res.desc != IORES_DESC_NONE) ? 1 : 0;
+		if (ret)
+			break;
+		res.start = res.end + 1;
+		res.end = orig_end;
+	}
+	return ret;
+}
+
+/*
+ * This generic page_is_mem() returns true if specified address is
+ * registered as memory in iomem_resource list.
+ */
+int __weak page_is_mem(unsigned long pfn)
+{
+	return walk_mem_range(pfn, 1) == 1;
+}
+EXPORT_SYMBOL_GPL(page_is_mem);
+
 /**
  * region_intersects() - determine intersection of region with known resources
  * @start: region start address

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
