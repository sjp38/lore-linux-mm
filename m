Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9F1C02806D9
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 17:19:40 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id k14so3077404pga.5
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 14:19:40 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0070.outbound.protection.outlook.com. [104.47.38.70])
        by mx.google.com with ESMTPS id t16si278987pfl.290.2017.04.18.14.19.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 18 Apr 2017 14:19:39 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v5 18/32] x86,
 mpparse: Use memremap to map the mpf and mpc data
Date: Tue, 18 Apr 2017 16:19:30 -0500
Message-ID: <20170418211930.10190.62640.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

The SMP MP-table is built by UEFI and placed in memory in a decrypted
state. These tables are accessed using a mix of early_memremap(),
early_memunmap(), phys_to_virt() and virt_to_phys(). Change all accesses
to use early_memremap()/early_memunmap(). This allows for proper setting
of the encryption mask so that the data can be successfully accessed when
SME is active.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/kernel/mpparse.c |  102 +++++++++++++++++++++++++++++++--------------
 1 file changed, 71 insertions(+), 31 deletions(-)

diff --git a/arch/x86/kernel/mpparse.c b/arch/x86/kernel/mpparse.c
index fd37f39..afbda41d 100644
--- a/arch/x86/kernel/mpparse.c
+++ b/arch/x86/kernel/mpparse.c
@@ -429,7 +429,21 @@ static inline void __init construct_default_ISA_mptable(int mpc_default_type)
 	}
 }
 
-static struct mpf_intel *mpf_found;
+static unsigned long mpf_base;
+
+static void __init unmap_mpf(struct mpf_intel *mpf)
+{
+	early_memunmap(mpf, sizeof(*mpf));
+}
+
+static struct mpf_intel * __init map_mpf(unsigned long paddr)
+{
+	struct mpf_intel *mpf;
+
+	mpf = early_memremap(paddr, sizeof(*mpf));
+
+	return mpf;
+}
 
 static unsigned long __init get_mpc_size(unsigned long physptr)
 {
@@ -444,13 +458,21 @@ static unsigned long __init get_mpc_size(unsigned long physptr)
 	return size;
 }
 
+static void __init unmap_mpc(struct mpc_table *mpc)
+{
+	early_memunmap(mpc, mpc->length);
+}
+
+static struct mpc_table * __init map_mpc(unsigned long paddr)
+{
+	return early_memremap(paddr, get_mpc_size(paddr));
+}
+
 static int __init check_physptr(struct mpf_intel *mpf, unsigned int early)
 {
 	struct mpc_table *mpc;
-	unsigned long size;
 
-	size = get_mpc_size(mpf->physptr);
-	mpc = early_memremap(mpf->physptr, size);
+	mpc = map_mpc(mpf->physptr);
 	/*
 	 * Read the physical hardware table.  Anything here will
 	 * override the defaults.
@@ -461,10 +483,10 @@ static int __init check_physptr(struct mpf_intel *mpf, unsigned int early)
 #endif
 		pr_err("BIOS bug, MP table errors detected!...\n");
 		pr_cont("... disabling SMP support. (tell your hw vendor)\n");
-		early_memunmap(mpc, size);
+		unmap_mpc(mpc);
 		return -1;
 	}
-	early_memunmap(mpc, size);
+	unmap_mpc(mpc);
 
 	if (early)
 		return -1;
@@ -497,12 +519,12 @@ static int __init check_physptr(struct mpf_intel *mpf, unsigned int early)
  */
 void __init default_get_smp_config(unsigned int early)
 {
-	struct mpf_intel *mpf = mpf_found;
+	struct mpf_intel *mpf;
 
 	if (!smp_found_config)
 		return;
 
-	if (!mpf)
+	if (!mpf_base)
 		return;
 
 	if (acpi_lapic && early)
@@ -515,6 +537,8 @@ void __init default_get_smp_config(unsigned int early)
 	if (acpi_lapic && acpi_ioapic)
 		return;
 
+	mpf = map_mpf(mpf_base);
+
 	pr_info("Intel MultiProcessor Specification v1.%d\n",
 		mpf->specification);
 #if defined(CONFIG_X86_LOCAL_APIC) && defined(CONFIG_X86_32)
@@ -542,8 +566,10 @@ void __init default_get_smp_config(unsigned int early)
 		construct_default_ISA_mptable(mpf->feature1);
 
 	} else if (mpf->physptr) {
-		if (check_physptr(mpf, early))
+		if (check_physptr(mpf, early)) {
+			unmap_mpf(mpf);
 			return;
+		}
 	} else
 		BUG();
 
@@ -552,6 +578,8 @@ void __init default_get_smp_config(unsigned int early)
 	/*
 	 * Only use the first configuration found.
 	 */
+
+	unmap_mpf(mpf);
 }
 
 static void __init smp_reserve_memory(struct mpf_intel *mpf)
@@ -561,15 +589,16 @@ static void __init smp_reserve_memory(struct mpf_intel *mpf)
 
 static int __init smp_scan_config(unsigned long base, unsigned long length)
 {
-	unsigned int *bp = phys_to_virt(base);
+	unsigned int *bp;
 	struct mpf_intel *mpf;
-	unsigned long mem;
+	int ret = 0;
 
 	apic_printk(APIC_VERBOSE, "Scan for SMP in [mem %#010lx-%#010lx]\n",
 		    base, base + length - 1);
 	BUILD_BUG_ON(sizeof(*mpf) != 16);
 
 	while (length > 0) {
+		bp = early_memremap(base, length);
 		mpf = (struct mpf_intel *)bp;
 		if ((*bp == SMP_MAGIC_IDENT) &&
 		    (mpf->length == 1) &&
@@ -579,24 +608,26 @@ static int __init smp_scan_config(unsigned long base, unsigned long length)
 #ifdef CONFIG_X86_LOCAL_APIC
 			smp_found_config = 1;
 #endif
-			mpf_found = mpf;
+			mpf_base = base;
 
-			pr_info("found SMP MP-table at [mem %#010llx-%#010llx] mapped at [%p]\n",
-				(unsigned long long) virt_to_phys(mpf),
-				(unsigned long long) virt_to_phys(mpf) +
-				sizeof(*mpf) - 1, mpf);
+			pr_info("found SMP MP-table at [mem %#010lx-%#010lx] mapped at [%p]\n",
+				base, base + sizeof(*mpf) - 1, mpf);
 
-			mem = virt_to_phys(mpf);
-			memblock_reserve(mem, sizeof(*mpf));
+			memblock_reserve(base, sizeof(*mpf));
 			if (mpf->physptr)
 				smp_reserve_memory(mpf);
 
-			return 1;
+			ret = 1;
 		}
-		bp += 4;
+		early_memunmap(bp, length);
+
+		if (ret)
+			break;
+
+		base += 16;
 		length -= 16;
 	}
-	return 0;
+	return ret;
 }
 
 void __init default_find_smp_config(void)
@@ -842,25 +873,26 @@ static int __init update_mp_table(void)
 	if (!enable_update_mptable)
 		return 0;
 
-	mpf = mpf_found;
-	if (!mpf)
+	if (!mpf_base)
 		return 0;
 
+	mpf = map_mpf(mpf_base);
+
 	/*
 	 * Now see if we need to go further.
 	 */
 	if (mpf->feature1 != 0)
-		return 0;
+		goto do_unmap_mpf;
 
 	if (!mpf->physptr)
-		return 0;
+		goto do_unmap_mpf;
 
-	mpc = phys_to_virt(mpf->physptr);
+	mpc = map_mpc(mpf->physptr);
 
 	if (!smp_check_mpc(mpc, oem, str))
-		return 0;
+		goto do_unmap_mpc;
 
-	pr_info("mpf: %llx\n", (u64)virt_to_phys(mpf));
+	pr_info("mpf: %llx\n", (u64)mpf_base);
 	pr_info("physptr: %x\n", mpf->physptr);
 
 	if (mpc_new_phys && mpc->length > mpc_new_length) {
@@ -878,21 +910,23 @@ static int __init update_mp_table(void)
 		new = mpf_checksum((unsigned char *)mpc, mpc->length);
 		if (old == new) {
 			pr_info("mpc is readonly, please try alloc_mptable instead\n");
-			return 0;
+			goto do_unmap_mpc;
 		}
 		pr_info("use in-position replacing\n");
 	} else {
 		mpf->physptr = mpc_new_phys;
-		mpc_new = phys_to_virt(mpc_new_phys);
+		mpc_new = map_mpc(mpc_new_phys);
 		memcpy(mpc_new, mpc, mpc->length);
+		unmap_mpc(mpc);
 		mpc = mpc_new;
 		/* check if we can modify that */
 		if (mpc_new_phys - mpf->physptr) {
 			struct mpf_intel *mpf_new;
 			/* steal 16 bytes from [0, 1k) */
 			pr_info("mpf new: %x\n", 0x400 - 16);
-			mpf_new = phys_to_virt(0x400 - 16);
+			mpf_new = map_mpf(0x400 - 16);
 			memcpy(mpf_new, mpf, 16);
+			unmap_mpf(mpf);
 			mpf = mpf_new;
 			mpf->physptr = mpc_new_phys;
 		}
@@ -909,6 +943,12 @@ static int __init update_mp_table(void)
 	 */
 	replace_intsrc_all(mpc, mpc_new_phys, mpc_new_length);
 
+do_unmap_mpc:
+	unmap_mpc(mpc);
+
+do_unmap_mpf:
+	unmap_mpf(mpf);
+
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
