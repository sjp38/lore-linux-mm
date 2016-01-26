From: Borislav Petkov <bp@alien8.de>
Subject: [PATCH 14/17] x86, kexec, nvdimm: Use walk_iomem_res_desc() for iomem search
Date: Tue, 26 Jan 2016 21:57:30 +0100
Message-ID: <1453841853-11383-15-git-send-email-bp@alien8.de>
References: <1453841853-11383-1-git-send-email-bp@alien8.de>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1453841853-11383-1-git-send-email-bp@alien8.de>
Sender: linux-arch-owner@vger.kernel.org
To: Ingo Molnar <mingo@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Don Zickus <dzickus@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, kexec@lists.infradead.org, "Lee, Chun-Yi" <joeyli.kernel@gmail.com>, linux-arch@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-nvdimm@lists.01.org, Minfei Huang <mnfhuang@gmail.com>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Takao Indoh <indou.takao@jp.fujitsu.com>, Thomas Gleixner <tglx@linutronix.de>, x86-ml <x86@kernel.org>
List-Id: linux-mm.kvack.org

From: Toshi Kani <toshi.kani@hpe.com>

Change the callers of walk_iomem_res() scanning for the following
resources by name to use walk_iomem_res_desc() instead.

 "ACPI Tables"
 "ACPI Non-volatile Storage"
 "Persistent Memory (legacy)"
 "Crash kernel"

Note, the caller of walk_iomem_res() with "GART" will be removed in a
later patch.

Reviewed-by: Dave Young <dyoung@redhat.com>
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Don Zickus <dzickus@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: kexec@lists.infradead.org
Cc: "Lee, Chun-Yi" <joeyli.kernel@gmail.com>
Cc: linux-arch@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>
Cc: linux-nvdimm@lists.01.org
Cc: Minfei Huang <mnfhuang@gmail.com>
Cc: "Peter Zijlstra (Intel)" <peterz@infradead.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Takao Indoh <indou.takao@jp.fujitsu.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: x86-ml <x86@kernel.org>
Link: http://lkml.kernel.org/r/1452020081-26534-14-git-send-email-toshi.kani@hpe.com
Signed-off-by: Borislav Petkov <bp@suse.de>
---
 arch/x86/kernel/crash.c | 4 ++--
 arch/x86/kernel/pmem.c  | 4 ++--
 drivers/nvdimm/e820.c   | 2 +-
 kernel/kexec_file.c     | 8 ++++----
 4 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/arch/x86/kernel/crash.c b/arch/x86/kernel/crash.c
index 58f34319b29a..35e152eeb6e0 100644
--- a/arch/x86/kernel/crash.c
+++ b/arch/x86/kernel/crash.c
@@ -599,12 +599,12 @@ int crash_setup_memmap_entries(struct kimage *image, struct boot_params *params)
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
index 14415aff1813..92f70147a9a6 100644
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
index b0045a505dc8..95825b38559a 100644
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
index 2bfcdc064116..56b18eb1f001 100644
--- a/kernel/kexec_file.c
+++ b/kernel/kexec_file.c
@@ -524,10 +524,10 @@ int kexec_add_buffer(struct kimage *image, char *buffer, unsigned long bufsz,
 
 	/* Walk the RAM ranges and allocate a suitable range for the buffer */
 	if (image->type == KEXEC_TYPE_CRASH)
-		ret = walk_iomem_res("Crash kernel",
-				     IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY,
-				     crashk_res.start, crashk_res.end, kbuf,
-				     locate_mem_hole_callback);
+		ret = walk_iomem_res_desc(crashk_res.desc,
+				IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY,
+				crashk_res.start, crashk_res.end, kbuf,
+				locate_mem_hole_callback);
 	else
 		ret = walk_system_ram_res(0, -1, kbuf,
 					  locate_mem_hole_callback);
-- 
2.3.5
