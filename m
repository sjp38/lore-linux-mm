Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C94CE6B037E
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 10:59:32 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j79so27843243pfj.9
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 07:59:32 -0700 (PDT)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0071.outbound.protection.outlook.com. [104.47.34.71])
        by mx.google.com with ESMTPS id o61si2250657plb.154.2017.06.27.07.59.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 27 Jun 2017 07:59:31 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v8 18/38] x86/efi: Update EFI pagetable creation to work
 with SME
Date: Tue, 27 Jun 2017 09:59:22 -0500
Message-ID: <20170627145922.15908.65516.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170627145607.15908.26571.stgit@tlendack-t1.amdoffice.net>
References: <20170627145607.15908.26571.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

When SME is active, pagetable entries created for EFI need to have the
encryption mask set as necessary.

When the new pagetable pages are allocated they are mapped encrypted. So,
update the efi_pgt value that will be used in cr3 to include the encryption
mask so that the PGD table can be read successfully. The pagetable mapping
as well as the kernel are also added to the pagetable mapping as encrypted.
All other EFI mappings are mapped decrypted (tables, etc.).

Reviewed-by: Matt Fleming <matt@codeblueprint.co.uk>
Reviewed-by: Borislav Petkov <bp@suse.de>
Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/platform/efi/efi_64.c |   15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/arch/x86/platform/efi/efi_64.c b/arch/x86/platform/efi/efi_64.c
index 9bf72f5..12e8388 100644
--- a/arch/x86/platform/efi/efi_64.c
+++ b/arch/x86/platform/efi/efi_64.c
@@ -327,7 +327,7 @@ void efi_sync_low_kernel_mappings(void)
 
 int __init efi_setup_page_tables(unsigned long pa_memmap, unsigned num_pages)
 {
-	unsigned long pfn, text;
+	unsigned long pfn, text, pf;
 	struct page *page;
 	unsigned npages;
 	pgd_t *pgd;
@@ -335,7 +335,12 @@ int __init efi_setup_page_tables(unsigned long pa_memmap, unsigned num_pages)
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
@@ -345,7 +350,8 @@ int __init efi_setup_page_tables(unsigned long pa_memmap, unsigned num_pages)
 	 * phys_efi_set_virtual_address_map().
 	 */
 	pfn = pa_memmap >> PAGE_SHIFT;
-	if (kernel_map_pages_in_pgd(pgd, pfn, pa_memmap, num_pages, _PAGE_NX | _PAGE_RW)) {
+	pf = _PAGE_NX | _PAGE_RW | _PAGE_ENC;
+	if (kernel_map_pages_in_pgd(pgd, pfn, pa_memmap, num_pages, pf)) {
 		pr_err("Error ident-mapping new memmap (0x%lx)!\n", pa_memmap);
 		return 1;
 	}
@@ -388,7 +394,8 @@ int __init efi_setup_page_tables(unsigned long pa_memmap, unsigned num_pages)
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
