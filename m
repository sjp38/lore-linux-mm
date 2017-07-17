Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id ABFB86B04A0
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 17:11:56 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id s20so440536qki.12
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 14:11:56 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0045.outbound.protection.outlook.com. [104.47.33.45])
        by mx.google.com with ESMTPS id a5si280736qkg.33.2017.07.17.14.11.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 17 Jul 2017 14:11:55 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v10 17/38] efi: Update efi_mem_type() to return an error rather than 0
Date: Mon, 17 Jul 2017 16:10:14 -0500
Message-Id: <7fbf40a9dc414d5da849e1ddcd7f7c1285e4e181.1500319216.git.thomas.lendacky@amd.com>
In-Reply-To: <cover.1500319216.git.thomas.lendacky@amd.com>
References: <cover.1500319216.git.thomas.lendacky@amd.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, kasan-dev@googlegroups.com
Cc: =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Dave Young <dyoung@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, "Michael S. Tsirkin" <mst@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>

The efi_mem_type() function currently returns a 0, which maps to
EFI_RESERVED_TYPE, if the function is unable to find a memmap entry for
the supplied physical address. Returning EFI_RESERVED_TYPE implies that
a memmap entry exists, when it doesn't.  Instead of returning 0, change
the function to return a negative error value when no memmap entry is
found.

Reviewed-by: Matt Fleming <matt@codeblueprint.co.uk>
Reviewed-by: Borislav Petkov <bp@suse.de>
Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/ia64/kernel/efi.c      | 4 ++--
 arch/x86/platform/efi/efi.c | 6 +++---
 include/linux/efi.h         | 2 +-
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
index f084d87..6217b23 100644
--- a/arch/x86/platform/efi/efi.c
+++ b/arch/x86/platform/efi/efi.c
@@ -1035,12 +1035,12 @@ void __init efi_enter_virtual_mode(void)
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
@@ -1048,7 +1048,7 @@ u32 efi_mem_type(unsigned long phys_addr)
 				  (md->num_pages << EFI_PAGE_SHIFT))))
 			return md->type;
 	}
-	return 0;
+	return -EINVAL;
 }
 
 static int __init arch_parse_efi_cmdline(char *str)
diff --git a/include/linux/efi.h b/include/linux/efi.h
index 8e24f09..4e47f78 100644
--- a/include/linux/efi.h
+++ b/include/linux/efi.h
@@ -985,7 +985,7 @@ static inline void efi_esrt_init(void) { }
 extern int efi_config_parse_tables(void *config_tables, int count, int sz,
 				   efi_config_table_type_t *arch_tables);
 extern u64 efi_get_iobase (void);
-extern u32 efi_mem_type (unsigned long phys_addr);
+extern int efi_mem_type(unsigned long phys_addr);
 extern u64 efi_mem_attributes (unsigned long phys_addr);
 extern u64 efi_mem_attribute (unsigned long phys_addr, unsigned long size);
 extern int __init efi_uart_console_only (void);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
