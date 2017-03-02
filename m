Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id B326B6B0399
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 10:14:22 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f21so94565210pgi.4
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 07:14:22 -0800 (PST)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0087.outbound.protection.outlook.com. [104.47.41.87])
        by mx.google.com with ESMTPS id a62si7651216pgc.371.2017.03.02.07.14.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 02 Mar 2017 07:14:21 -0800 (PST)
Subject: [RFC PATCH v2 09/32] x86: Change early_ioremap to early_memremap
 for BOOT data
From: Brijesh Singh <brijesh.singh@amd.com>
Date: Thu, 2 Mar 2017 10:13:53 -0500
Message-ID: <148846763334.2349.9327692408737971533.stgit@brijesh-build-machine>
In-Reply-To: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, brijesh.singh@amd.com, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

From: Tom Lendacky <thomas.lendacky@amd.com>

In order to map BOOT data with the proper encryption bit, the
early_ioremap() function calls are changed to early_memremap() calls.
This allows the proper access for both SME and SEV.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/kernel/acpi/boot.c |    4 ++--
 arch/x86/kernel/mpparse.c   |   10 +++++-----
 drivers/sfi/sfi_core.c      |    6 +++---
 3 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/arch/x86/kernel/acpi/boot.c b/arch/x86/kernel/acpi/boot.c
index 35174c6..468c25a 100644
--- a/arch/x86/kernel/acpi/boot.c
+++ b/arch/x86/kernel/acpi/boot.c
@@ -124,7 +124,7 @@ char *__init __acpi_map_table(unsigned long phys, unsigned long size)
 	if (!phys || !size)
 		return NULL;
 
-	return early_ioremap(phys, size);
+	return early_memremap(phys, size);
 }
 
 void __init __acpi_unmap_table(char *map, unsigned long size)
@@ -132,7 +132,7 @@ void __init __acpi_unmap_table(char *map, unsigned long size)
 	if (!map || !size)
 		return;
 
-	early_iounmap(map, size);
+	early_memunmap(map, size);
 }
 
 #ifdef CONFIG_X86_LOCAL_APIC
diff --git a/arch/x86/kernel/mpparse.c b/arch/x86/kernel/mpparse.c
index 0d904d7..fd37f39 100644
--- a/arch/x86/kernel/mpparse.c
+++ b/arch/x86/kernel/mpparse.c
@@ -436,9 +436,9 @@ static unsigned long __init get_mpc_size(unsigned long physptr)
 	struct mpc_table *mpc;
 	unsigned long size;
 
-	mpc = early_ioremap(physptr, PAGE_SIZE);
+	mpc = early_memremap(physptr, PAGE_SIZE);
 	size = mpc->length;
-	early_iounmap(mpc, PAGE_SIZE);
+	early_memunmap(mpc, PAGE_SIZE);
 	apic_printk(APIC_VERBOSE, "  mpc: %lx-%lx\n", physptr, physptr + size);
 
 	return size;
@@ -450,7 +450,7 @@ static int __init check_physptr(struct mpf_intel *mpf, unsigned int early)
 	unsigned long size;
 
 	size = get_mpc_size(mpf->physptr);
-	mpc = early_ioremap(mpf->physptr, size);
+	mpc = early_memremap(mpf->physptr, size);
 	/*
 	 * Read the physical hardware table.  Anything here will
 	 * override the defaults.
@@ -461,10 +461,10 @@ static int __init check_physptr(struct mpf_intel *mpf, unsigned int early)
 #endif
 		pr_err("BIOS bug, MP table errors detected!...\n");
 		pr_cont("... disabling SMP support. (tell your hw vendor)\n");
-		early_iounmap(mpc, size);
+		early_memunmap(mpc, size);
 		return -1;
 	}
-	early_iounmap(mpc, size);
+	early_memunmap(mpc, size);
 
 	if (early)
 		return -1;
diff --git a/drivers/sfi/sfi_core.c b/drivers/sfi/sfi_core.c
index 296db7a..d00ae3f 100644
--- a/drivers/sfi/sfi_core.c
+++ b/drivers/sfi/sfi_core.c
@@ -92,7 +92,7 @@ static struct sfi_table_simple *syst_va __read_mostly;
 static u32 sfi_use_ioremap __read_mostly;
 
 /*
- * sfi_un/map_memory calls early_ioremap/iounmap which is a __init function
+ * sfi_un/map_memory calls early_memremap/memunmap which is a __init function
  * and introduces section mismatch. So use __ref to make it calm.
  */
 static void __iomem * __ref sfi_map_memory(u64 phys, u32 size)
@@ -103,7 +103,7 @@ static void __iomem * __ref sfi_map_memory(u64 phys, u32 size)
 	if (sfi_use_ioremap)
 		return ioremap_cache(phys, size);
 	else
-		return early_ioremap(phys, size);
+		return early_memremap(phys, size);
 }
 
 static void __ref sfi_unmap_memory(void __iomem *virt, u32 size)
@@ -114,7 +114,7 @@ static void __ref sfi_unmap_memory(void __iomem *virt, u32 size)
 	if (sfi_use_ioremap)
 		iounmap(virt);
 	else
-		early_iounmap(virt, size);
+		early_memunmap(virt, size);
 }
 
 static void sfi_print_table_header(unsigned long long pa,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
