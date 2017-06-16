Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A7A2F44041A
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 14:54:00 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id v9so43248820pfk.5
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 11:54:00 -0700 (PDT)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0045.outbound.protection.outlook.com. [104.47.41.45])
        by mx.google.com with ESMTPS id c7si2572138pgt.257.2017.06.16.11.53.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 16 Jun 2017 11:53:59 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v7 21/36] x86/mm: Add support to access persistent memory in
 the clear
Date: Fri, 16 Jun 2017 13:53:49 -0500
Message-ID: <20170616185349.18967.38054.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170616184947.18967.84890.stgit@tlendack-t1.amdoffice.net>
References: <20170616184947.18967.84890.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

Persistent memory is expected to persist across reboots. The encryption
key used by SME will change across reboots which will result in corrupted
persistent memory.  Persistent memory is handed out by block devices
through memory remapping functions, so be sure not to map this memory as
encrypted.

Reviewed-by: Borislav Petkov <bp@suse.de>
Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/mm/ioremap.c |   31 ++++++++++++++++++++++++++++++-
 1 file changed, 30 insertions(+), 1 deletion(-)

diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
index f3fa007..0254b78 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -428,17 +428,46 @@ void unxlate_dev_mem_ptr(phys_addr_t phys, void *addr)
  * Examine the physical address to determine if it is an area of memory
  * that should be mapped decrypted.  If the memory is not part of the
  * kernel usable area it was accessed and created decrypted, so these
- * areas should be mapped decrypted.
+ * areas should be mapped decrypted. And since the encryption key can
+ * change across reboots, persistent memory should also be mapped
+ * decrypted.
  */
 static bool memremap_should_map_decrypted(resource_size_t phys_addr,
 					  unsigned long size)
 {
+	int is_pmem;
+
+	/*
+	 * Check if the address is part of a persistent memory region.
+	 * This check covers areas added by E820, EFI and ACPI.
+	 */
+	is_pmem = region_intersects(phys_addr, size, IORESOURCE_MEM,
+				    IORES_DESC_PERSISTENT_MEMORY);
+	if (is_pmem != REGION_DISJOINT)
+		return true;
+
+	/*
+	 * Check if the non-volatile attribute is set for an EFI
+	 * reserved area.
+	 */
+	if (efi_enabled(EFI_BOOT)) {
+		switch (efi_mem_type(phys_addr)) {
+		case EFI_RESERVED_TYPE:
+			if (efi_mem_attributes(phys_addr) & EFI_MEMORY_NV)
+				return true;
+			break;
+		default:
+			break;
+		}
+	}
+
 	/* Check if the address is outside kernel usable area */
 	switch (e820__get_entry_type(phys_addr, phys_addr + size - 1)) {
 	case E820_TYPE_RESERVED:
 	case E820_TYPE_ACPI:
 	case E820_TYPE_NVS:
 	case E820_TYPE_UNUSABLE:
+	case E820_TYPE_PRAM:
 		return true;
 	default:
 		break;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
