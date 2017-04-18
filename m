Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4A3E52806D9
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 17:19:21 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id v20so3089818pgn.2
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 14:19:21 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0053.outbound.protection.outlook.com. [104.47.38.53])
        by mx.google.com with ESMTPS id n85si273363pfi.356.2017.04.18.14.19.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 18 Apr 2017 14:19:20 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v5 16/32] x86/efi: Update EFI pagetable creation to work
 with SME
Date: Tue, 18 Apr 2017 16:19:10 -0500
Message-ID: <20170418211910.10190.38527.stgit@tlendack-t1.amdoffice.net>
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

When SME is active, pagetable entries created for EFI need to have the
encryption mask set as necessary.

When the new pagetable pages are allocated they are mapped encrypted. So,
update the efi_pgt value that will be used in cr3 to include the encryption
mask so that the PGD table can be read successfully. The pagetable mapping
as well as the kernel are also added to the pagetable mapping as encrypted.
All other EFI mappings are mapped decrypted (tables, etc.).

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/platform/efi/efi_64.c |   15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/arch/x86/platform/efi/efi_64.c b/arch/x86/platform/efi/efi_64.c
index c488625..685881a 100644
--- a/arch/x86/platform/efi/efi_64.c
+++ b/arch/x86/platform/efi/efi_64.c
@@ -264,7 +264,7 @@ void efi_sync_low_kernel_mappings(void)
 
 int __init efi_setup_page_tables(unsigned long pa_memmap, unsigned num_pages)
 {
-	unsigned long pfn, text;
+	unsigned long pfn, text, pf;
 	struct page *page;
 	unsigned npages;
 	pgd_t *pgd;
@@ -272,7 +272,12 @@ int __init efi_setup_page_tables(unsigned long pa_memmap, unsigned num_pages)
 	if (efi_enabled(EFI_OLD_MEMMAP))
 		return 0;
 
-	efi_scratch.efi_pgt = (pgd_t *)__pa(efi_pgd);
+	/*
+	 * Since the PGD is encrypted, set the encryption mask so that when
+	 * this value is loaded into cr3 the PGD will be decrypted during
+	 * the pagetable walk.
+	 */
+	efi_scratch.efi_pgt = (pgd_t *)__sme_pa(efi_pgd);
 	pgd = efi_pgd;
 
 	/*
@@ -282,7 +287,8 @@ int __init efi_setup_page_tables(unsigned long pa_memmap, unsigned num_pages)
 	 * phys_efi_set_virtual_address_map().
 	 */
 	pfn = pa_memmap >> PAGE_SHIFT;
-	if (kernel_map_pages_in_pgd(pgd, pfn, pa_memmap, num_pages, _PAGE_NX | _PAGE_RW)) {
+	pf = _PAGE_NX | _PAGE_RW | _PAGE_ENC;
+	if (kernel_map_pages_in_pgd(pgd, pfn, pa_memmap, num_pages, pf)) {
 		pr_err("Error ident-mapping new memmap (0x%lx)!\n", pa_memmap);
 		return 1;
 	}
@@ -325,7 +331,8 @@ int __init efi_setup_page_tables(unsigned long pa_memmap, unsigned num_pages)
 	text = __pa(_text);
 	pfn = text >> PAGE_SHIFT;
 
-	if (kernel_map_pages_in_pgd(pgd, pfn, text, npages, _PAGE_RW)) {
+	pf = _PAGE_RW | _PAGE_ENC;
+	if (kernel_map_pages_in_pgd(pgd, pfn, text, npages, pf)) {
 		pr_err("Failed to map kernel text 1:1\n");
 		return 1;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
