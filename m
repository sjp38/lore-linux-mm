Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id A87636B03AB
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 17:11:17 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id r14so565972qte.11
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 14:11:17 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0043.outbound.protection.outlook.com. [104.47.33.43])
        by mx.google.com with ESMTPS id o2si231483qkc.372.2017.07.17.14.11.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 17 Jul 2017 14:11:16 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v10 07/38] x86/mm: Remove phys_to_virt() usage in ioremap()
Date: Mon, 17 Jul 2017 16:10:04 -0500
Message-Id: <88ada7b09c6568c61cd696351eb59fb15a82ce1a.1500319216.git.thomas.lendacky@amd.com>
In-Reply-To: <cover.1500319216.git.thomas.lendacky@amd.com>
References: <cover.1500319216.git.thomas.lendacky@amd.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, kasan-dev@googlegroups.com
Cc: =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Dave Young <dyoung@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, "Michael S. Tsirkin" <mst@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>

Currently there is a check if the address being mapped is in the ISA
range (is_ISA_range()), and if it is, then phys_to_virt() is used to
perform the mapping. When SME is active, the default is to add pagetable
mappings with the encryption bit set unless specifically overridden. The
resulting pagetable mapping from phys_to_virt() will result in a mapping
that has the encryption bit set. With SME, the use of ioremap() is
intended to generate pagetable mappings that do not have the encryption
bit set through the use of the PAGE_KERNEL_IO protection value.

Rather than special case the SME scenario, remove the ISA range check and
usage of phys_to_virt() and have ISA range mappings continue through the
remaining ioremap() path.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/mm/ioremap.c | 18 ++++++++----------
 1 file changed, 8 insertions(+), 10 deletions(-)

diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
index 4c1b5fd..66ddf5e 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -106,12 +106,6 @@ static void __iomem *__ioremap_caller(resource_size_t phys_addr,
 	}
 
 	/*
-	 * Don't remap the low PCI/ISA area, it's always mapped..
-	 */
-	if (is_ISA_range(phys_addr, last_addr))
-		return (__force void __iomem *)phys_to_virt(phys_addr);
-
-	/*
 	 * Don't allow anybody to remap normal RAM that we're using..
 	 */
 	pfn      = phys_addr >> PAGE_SHIFT;
@@ -340,13 +334,17 @@ void iounmap(volatile void __iomem *addr)
 		return;
 
 	/*
-	 * __ioremap special-cases the PCI/ISA range by not instantiating a
-	 * vm_area and by simply returning an address into the kernel mapping
-	 * of ISA space.   So handle that here.
+	 * The PCI/ISA range special-casing was removed from __ioremap()
+	 * so this check, in theory, can be removed. However, there are
+	 * cases where iounmap() is called for addresses not obtained via
+	 * ioremap() (vga16fb for example). Add a warning so that these
+	 * cases can be caught and fixed.
 	 */
 	if ((void __force *)addr >= phys_to_virt(ISA_START_ADDRESS) &&
-	    (void __force *)addr < phys_to_virt(ISA_END_ADDRESS))
+	    (void __force *)addr < phys_to_virt(ISA_END_ADDRESS)) {
+		WARN(1, "iounmap() called for ISA range not obtained using ioremap()\n");
 		return;
+	}
 
 	addr = (volatile void __iomem *)
 		(PAGE_MASK & (unsigned long __force)addr);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
