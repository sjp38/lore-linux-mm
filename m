Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2206683297
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 14:56:17 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a82so44278214pfc.8
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 11:56:17 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0052.outbound.protection.outlook.com. [104.47.38.52])
        by mx.google.com with ESMTPS id a59si2438383plc.496.2017.06.16.11.56.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 16 Jun 2017 11:56:16 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v7 33/36] x86/mm: Use proper encryption attributes with
 /dev/mem
Date: Fri, 16 Jun 2017 13:56:07 -0500
Message-ID: <20170616185607.18967.51412.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170616184947.18967.84890.stgit@tlendack-t1.amdoffice.net>
References: <20170616184947.18967.84890.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

When accessing memory using /dev/mem (or /dev/kmem) use the proper
encryption attributes when mapping the memory.

To insure the proper attributes are applied when reading or writing
/dev/mem, update the xlate_dev_mem_ptr() function to use memremap()
which will essentially perform the same steps of applying __va for
RAM or using ioremap() for if not RAM.

To insure the proper attributes are applied when mmapping /dev/mem,
update the phys_mem_access_prot() to call phys_mem_access_encrypted(),
a new function which will check if the memory should be mapped encrypted
or not. If it is not to be mapped encrypted then the VMA protection
value is updated to remove the encryption bit.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/io.h |    3 +++
 arch/x86/mm/ioremap.c     |   18 +++++++++---------
 arch/x86/mm/pat.c         |    3 +++
 3 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/arch/x86/include/asm/io.h b/arch/x86/include/asm/io.h
index 09c5557..e080a39 100644
--- a/arch/x86/include/asm/io.h
+++ b/arch/x86/include/asm/io.h
@@ -386,4 +386,7 @@ extern bool arch_memremap_can_ram_remap(resource_size_t offset,
 					unsigned long flags);
 #define arch_memremap_can_ram_remap arch_memremap_can_ram_remap
 
+extern bool phys_mem_access_encrypted(unsigned long phys_addr,
+				      unsigned long size);
+
 #endif /* _ASM_X86_IO_H */
diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
index 0254b78..5d8b3cf 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -404,12 +404,10 @@ void *xlate_dev_mem_ptr(phys_addr_t phys)
 	unsigned long offset = phys & ~PAGE_MASK;
 	void *vaddr;
 
-	/* If page is RAM, we can use __va. Otherwise ioremap and unmap. */
-	if (page_is_ram(start >> PAGE_SHIFT))
-		return __va(phys);
+	/* memremap() maps if RAM, otherwise falls back to ioremap() */
+	vaddr = memremap(start, PAGE_SIZE, MEMREMAP_WB);
 
-	vaddr = ioremap_cache(start, PAGE_SIZE);
-	/* Only add the offset on success and return NULL if the ioremap() failed: */
+	/* Only add the offset on success and return NULL if memremap() failed */
 	if (vaddr)
 		vaddr += offset;
 
@@ -418,10 +416,7 @@ void *xlate_dev_mem_ptr(phys_addr_t phys)
 
 void unxlate_dev_mem_ptr(phys_addr_t phys, void *addr)
 {
-	if (page_is_ram(phys >> PAGE_SHIFT))
-		return;
-
-	iounmap((void __iomem *)((unsigned long)addr & PAGE_MASK));
+	memunmap((void *)((unsigned long)addr & PAGE_MASK));
 }
 
 /*
@@ -630,6 +625,11 @@ pgprot_t __init early_memremap_pgprot_adjust(resource_size_t phys_addr,
 	return prot;
 }
 
+bool phys_mem_access_encrypted(unsigned long phys_addr, unsigned long size)
+{
+	return arch_memremap_can_ram_remap(phys_addr, size, 0);
+}
+
 #ifdef CONFIG_ARCH_USE_MEMREMAP_PROT
 /* Remap memory with encryption */
 void __init *early_memremap_encrypted(resource_size_t phys_addr,
diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index 6753d9c..b970c95 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -748,6 +748,9 @@ void arch_io_free_memtype_wc(resource_size_t start, resource_size_t size)
 pgprot_t phys_mem_access_prot(struct file *file, unsigned long pfn,
 				unsigned long size, pgprot_t vma_prot)
 {
+	if (!phys_mem_access_encrypted(pfn << PAGE_SHIFT, size))
+		vma_prot = pgprot_decrypted(vma_prot);
+
 	return vma_prot;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
