Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 547B66B037E
	for <linux-mm@kvack.org>; Wed,  7 Jun 2017 15:16:27 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id z6so7757933pgc.13
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 12:16:27 -0700 (PDT)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-sn1nam02on0079.outbound.protection.outlook.com. [104.47.36.79])
        by mx.google.com with ESMTPS id o1si2367726pfg.277.2017.06.07.12.16.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 07 Jun 2017 12:16:26 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v6 17/34] efi: Update efi_mem_type() to return an error
 rather than 0
Date: Wed, 07 Jun 2017 14:16:17 -0500
Message-ID: <20170607191617.28645.8923.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net>
References: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

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
index 43b96f5..a6a26cc 100644
--- a/arch/x86/platform/efi/efi.c
+++ b/arch/x86/platform/efi/efi.c
@@ -1034,12 +1034,12 @@ void __init efi_enter_virtual_mode(void)
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
@@ -1047,7 +1047,7 @@ u32 efi_mem_type(unsigned long phys_addr)
 				  (md->num_pages << EFI_PAGE_SHIFT))))
 			return md->type;
 	}
-	return 0;
+	return -EINVAL;
 }
 
 static int __init arch_parse_efi_cmdline(char *str)
diff --git a/include/linux/efi.h b/include/linux/efi.h
index 504fa85..8bcb271 100644
--- a/include/linux/efi.h
+++ b/include/linux/efi.h
@@ -973,7 +973,7 @@ static inline void efi_esrt_init(void) { }
 extern int efi_config_parse_tables(void *config_tables, int count, int sz,
 				   efi_config_table_type_t *arch_tables);
 extern u64 efi_get_iobase (void);
-extern u32 efi_mem_type (unsigned long phys_addr);
+extern int efi_mem_type(unsigned long phys_addr);
 extern u64 efi_mem_attributes (unsigned long phys_addr);
 extern u64 efi_mem_attribute (unsigned long phys_addr, unsigned long size);
 extern int __init efi_uart_console_only (void);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
