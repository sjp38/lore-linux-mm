Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id CEF046B0315
	for <linux-mm@kvack.org>; Fri,  7 Jul 2017 09:39:37 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id c18so14540325qkb.10
        for <linux-mm@kvack.org>; Fri, 07 Jul 2017 06:39:37 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0042.outbound.protection.outlook.com. [104.47.33.42])
        by mx.google.com with ESMTPS id s27si3229953qtg.103.2017.07.07.06.39.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 07 Jul 2017 06:39:36 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v9 07/38] x86/mm: Remove phys_to_virt() usage in ioremap()
Date: Fri, 07 Jul 2017 08:39:26 -0500
Message-ID: <20170707133925.29711.39301.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170707133804.29711.1616.stgit@tlendack-t1.amdoffice.net>
References: <20170707133804.29711.1616.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

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
 arch/x86/mm/ioremap.c |    7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
index 4c1b5fd..bfc3e2d 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -13,6 +13,7 @@
 #include <linux/slab.h>
 #include <linux/vmalloc.h>
 #include <linux/mmiotrace.h>
+#include <linux/mem_encrypt.h>
 
 #include <asm/set_memory.h>
 #include <asm/e820/api.h>
@@ -106,12 +107,6 @@ static void __iomem *__ioremap_caller(resource_size_t phys_addr,
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
