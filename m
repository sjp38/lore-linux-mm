Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 933352806D9
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 17:19:09 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 194so2685944pfv.11
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 14:19:09 -0700 (PDT)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0074.outbound.protection.outlook.com. [104.47.40.74])
        by mx.google.com with ESMTPS id q11si277880pli.266.2017.04.18.14.19.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 18 Apr 2017 14:19:08 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v5 15/32] efi: Update efi_mem_type() to return an error
 rather than 0
Date: Tue, 18 Apr 2017 16:19:00 -0500
Message-ID: <20170418211900.10190.98158.stgit@tlendack-t1.amdoffice.net>
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

The efi_mem_type() function currently returns a 0, which maps to
EFI_RESERVED_TYPE, if the function is unable to find a memmap entry for
the supplied physical address. Returning EFI_RESERVED_TYPE implies that
a memmap entry exists, when it doesn't.  Instead of returning 0, change
the function to return a negative error value when no memmap entry is
found.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/ia64/kernel/efi.c      |    4 ++--
 arch/x86/platform/efi/efi.c |    6 +++---
 include/linux/efi.h         |    2 +-
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
index 1212956..8141600 100644
--- a/arch/ia64/kernel/efi.c
+++ b/arch/ia64/kernel/efi.c
@@ -757,14 +757,14 @@ static void __init handle_palo(unsigned long phys_addr)
 	return 0;
 }
 
-u32
+int
 efi_mem_type (unsigned long phys_addr)
 {
 	efi_memory_desc_t *md = efi_memory_descriptor(phys_addr);
 
 	if (md)
 		return md->type;
-	return 0;
+	return -EINVAL;
 }
 
 u64
diff --git a/arch/x86/platform/efi/efi.c b/arch/x86/platform/efi/efi.c
index a15cf81..f9b0b7a 100644
--- a/arch/x86/platform/efi/efi.c
+++ b/arch/x86/platform/efi/efi.c
@@ -1032,12 +1032,12 @@ void __init efi_enter_virtual_mode(void)
 /*
  * Convenience functions to obtain memory types and attributes
  */
-u32 efi_mem_type(unsigned long phys_addr)
+int efi_mem_type(unsigned long phys_addr)
 {
 	efi_memory_desc_t *md;
 
 	if (!efi_enabled(EFI_MEMMAP))
-		return 0;
+		return -ENOTSUPP;
 
 	for_each_efi_memory_desc(md) {
 		if ((md->phys_addr <= phys_addr) &&
@@ -1045,7 +1045,7 @@ u32 efi_mem_type(unsigned long phys_addr)
 				  (md->num_pages << EFI_PAGE_SHIFT))))
 			return md->type;
 	}
-	return 0;
+	return -EINVAL;
 }
 
 static int __init arch_parse_efi_cmdline(char *str)
diff --git a/include/linux/efi.h b/include/linux/efi.h
index cd768a1..a27bb3f 100644
--- a/include/linux/efi.h
+++ b/include/linux/efi.h
@@ -973,7 +973,7 @@ static inline void efi_esrt_init(void) { }
 extern int efi_config_parse_tables(void *config_tables, int count, int sz,
 				   efi_config_table_type_t *arch_tables);
 extern u64 efi_get_iobase (void);
-extern u32 efi_mem_type (unsigned long phys_addr);
+extern int efi_mem_type (unsigned long phys_addr);
 extern u64 efi_mem_attributes (unsigned long phys_addr);
 extern u64 efi_mem_attribute (unsigned long phys_addr, unsigned long size);
 extern int __init efi_uart_console_only (void);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
