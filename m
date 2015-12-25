Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id 18E57680DC6
	for <linux-mm@kvack.org>; Fri, 25 Dec 2015 17:10:33 -0500 (EST)
Received: by mail-oi0-f41.google.com with SMTP id o62so146469538oif.3
        for <linux-mm@kvack.org>; Fri, 25 Dec 2015 14:10:33 -0800 (PST)
Received: from g4t3428.houston.hp.com (g4t3428.houston.hp.com. [15.201.208.56])
        by mx.google.com with ESMTPS id b10si19101083oif.76.2015.12.25.14.10.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Dec 2015 14:10:32 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v2 14/16] x86,nvdimm,kexec: Use walk_iomem_res_desc() for iomem search
Date: Fri, 25 Dec 2015 15:09:23 -0700
Message-Id: <1451081365-15190-14-git-send-email-toshi.kani@hpe.com>
In-Reply-To: <1451081365-15190-1-git-send-email-toshi.kani@hpe.com>
References: <1451081365-15190-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, bp@alien8.de
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>, Dave Young <dyoung@redhat.com>, x86@kernel.org, linux-nvdimm@lists.01.org, Toshi Kani <toshi.kani@hpe.com>

Change to call walk_iomem_res_desc() for searching resource entries
with the following names:
 "ACPI Tables"
 "ACPI Non-volatile Storage"
 "Persistent Memory (legacy)"
 "Crash kernel"

Note, the caller of walk_iomem_res() with "GART" is left unchanged
because this entry may be initialized by out-of-tree drivers, which
do not have 'desc' set to IORES_DESC_GART.

Cc: Borislav Petkov <bp@alien8.de>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Young <dyoung@redhat.com>
Cc: x86@kernel.org
Cc: linux-nvdimm@lists.01.org
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
---
 arch/x86/kernel/crash.c |    4 ++--
 arch/x86/kernel/pmem.c  |    4 ++--
 drivers/nvdimm/e820.c   |    2 +-
 kernel/kexec_file.c     |    8 ++++----
 4 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/arch/x86/kernel/crash.c b/arch/x86/kernel/crash.c
index 2c1910f..082373b 100644
--- a/arch/x86/kernel/crash.c
+++ b/arch/x86/kernel/crash.c
@@ -588,12 +588,12 @@ int crash_setup_memmap_entries(struct kimage *image, struct boot_params *params)
 	/* Add ACPI tables */
 	cmd.type = E820_ACPI;
 	flags = IORESOURCE_MEM | IORESOURCE_BUSY;
-	walk_iomem_res("ACPI Tables", flags, 0, -1, &cmd,
+	walk_iomem_res_desc(IORES_DESC_ACPI_TABLES, flags, 0, -1, &cmd,
 		       memmap_entry_callback);
 
 	/* Add ACPI Non-volatile Storage */
 	cmd.type = E820_NVS;
-	walk_iomem_res("ACPI Non-volatile Storage", flags, 0, -1, &cmd,
+	walk_iomem_res_desc(IORES_DESC_ACPI_NV_STORAGE, flags, 0, -1, &cmd,
 			memmap_entry_callback);
 
 	/* Add crashk_low_res region */
diff --git a/arch/x86/kernel/pmem.c b/arch/x86/kernel/pmem.c
index 14415af..92f7014 100644
--- a/arch/x86/kernel/pmem.c
+++ b/arch/x86/kernel/pmem.c
@@ -13,11 +13,11 @@ static int found(u64 start, u64 end, void *data)
 
 static __init int register_e820_pmem(void)
 {
-	char *pmem = "Persistent Memory (legacy)";
 	struct platform_device *pdev;
 	int rc;
 
-	rc = walk_iomem_res(pmem, IORESOURCE_MEM, 0, -1, NULL, found);
+	rc = walk_iomem_res_desc(IORES_DESC_PERSISTENT_MEMORY_LEGACY,
+				 IORESOURCE_MEM, 0, -1, NULL, found);
 	if (rc <= 0)
 		return 0;
 
diff --git a/drivers/nvdimm/e820.c b/drivers/nvdimm/e820.c
index b0045a5..95825b3 100644
--- a/drivers/nvdimm/e820.c
+++ b/drivers/nvdimm/e820.c
@@ -55,7 +55,7 @@ static int e820_pmem_probe(struct platform_device *pdev)
 	for (p = iomem_resource.child; p ; p = p->sibling) {
 		struct nd_region_desc ndr_desc;
 
-		if (strncmp(p->name, "Persistent Memory (legacy)", 26) != 0)
+		if (p->desc != IORES_DESC_PERSISTENT_MEMORY_LEGACY)
 			continue;
 
 		memset(&ndr_desc, 0, sizeof(ndr_desc));
diff --git a/kernel/kexec_file.c b/kernel/kexec_file.c
index c245085..e2bd737 100644
--- a/kernel/kexec_file.c
+++ b/kernel/kexec_file.c
@@ -522,10 +522,10 @@ int kexec_add_buffer(struct kimage *image, char *buffer, unsigned long bufsz,
 
 	/* Walk the RAM ranges and allocate a suitable range for the buffer */
 	if (image->type == KEXEC_TYPE_CRASH)
-		ret = walk_iomem_res("Crash kernel",
-				     IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY,
-				     crashk_res.start, crashk_res.end, kbuf,
-				     locate_mem_hole_callback);
+		ret = walk_iomem_res_desc(IORES_DESC_CRASH_KERNEL,
+				IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY,
+				crashk_res.start, crashk_res.end, kbuf,
+				locate_mem_hole_callback);
 	else
 		ret = walk_system_ram_res(0, -1, kbuf,
 					  locate_mem_hole_callback);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
