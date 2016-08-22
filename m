Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id CB8C86B0270
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 19:25:37 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id e63so1019111ith.1
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 16:25:37 -0700 (PDT)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0050.outbound.protection.outlook.com. [104.47.40.50])
        by mx.google.com with ESMTPS id o91si140311oik.236.2016.08.22.16.25.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 22 Aug 2016 16:25:37 -0700 (PDT)
Subject: [RFC PATCH v1 09/28] x86/efi: Access EFI data as encrypted when SEV
 is active
From: Brijesh Singh <brijesh.singh@amd.com>
Date: Mon, 22 Aug 2016 19:25:25 -0400
Message-ID: <147190832511.9523.10850626471583956499.stgit@brijesh-build-machine>
In-Reply-To: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, brijesh.singh@amd.com, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus.walleij@linaro.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, linux-crypto@vger.kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

From: Tom Lendacky <thomas.lendacky@amd.com>

EFI data is encrypted when the kernel is run under SEV. Update the
page table references to be sure the EFI memory areas are accessed
encrypted.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/platform/efi/efi_64.c |   14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/arch/x86/platform/efi/efi_64.c b/arch/x86/platform/efi/efi_64.c
index 0871ea4..98363f3 100644
--- a/arch/x86/platform/efi/efi_64.c
+++ b/arch/x86/platform/efi/efi_64.c
@@ -213,7 +213,7 @@ void efi_sync_low_kernel_mappings(void)
 
 int __init efi_setup_page_tables(unsigned long pa_memmap, unsigned num_pages)
 {
-	unsigned long pfn, text;
+	unsigned long pfn, text, flags;
 	efi_memory_desc_t *md;
 	struct page *page;
 	unsigned npages;
@@ -230,6 +230,10 @@ int __init efi_setup_page_tables(unsigned long pa_memmap, unsigned num_pages)
 	efi_scratch.efi_pgt = (pgd_t *)__sme_pa(efi_pgd);
 	pgd = efi_pgd;
 
+	flags = _PAGE_NX | _PAGE_RW;
+	if (sev_active)
+		flags |= _PAGE_ENC;
+
 	/*
 	 * It can happen that the physical address of new_memmap lands in memory
 	 * which is not mapped in the EFI page table. Therefore we need to go
@@ -237,7 +241,7 @@ int __init efi_setup_page_tables(unsigned long pa_memmap, unsigned num_pages)
 	 * phys_efi_set_virtual_address_map().
 	 */
 	pfn = pa_memmap >> PAGE_SHIFT;
-	if (kernel_map_pages_in_pgd(pgd, pfn, pa_memmap, num_pages, _PAGE_NX | _PAGE_RW)) {
+	if (kernel_map_pages_in_pgd(pgd, pfn, pa_memmap, num_pages, flags)) {
 		pr_err("Error ident-mapping new memmap (0x%lx)!\n", pa_memmap);
 		return 1;
 	}
@@ -302,6 +306,9 @@ static void __init __map_region(efi_memory_desc_t *md, u64 va)
 	if (!(md->attribute & EFI_MEMORY_WB))
 		flags |= _PAGE_PCD;
 
+	if (sev_active)
+		flags |= _PAGE_ENC;
+
 	pfn = md->phys_addr >> PAGE_SHIFT;
 	if (kernel_map_pages_in_pgd(pgd, pfn, va, md->num_pages, flags))
 		pr_warn("Error mapping PA 0x%llx -> VA 0x%llx!\n",
@@ -426,6 +433,9 @@ void __init efi_runtime_update_mappings(void)
 			(md->type != EFI_RUNTIME_SERVICES_CODE))
 			pf |= _PAGE_RW;
 
+		if (sev_active)
+			pf |= _PAGE_ENC;
+
 		/* Update the 1:1 mapping */
 		pfn = md->phys_addr >> PAGE_SHIFT;
 		if (kernel_map_pages_in_pgd(pgd, pfn, md->phys_addr, md->num_pages, pf))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
