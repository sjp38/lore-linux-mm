Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 07D4B6B03A3
	for <linux-mm@kvack.org>; Fri,  7 Jul 2017 09:41:12 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id r4so51390244ith.7
        for <linux-mm@kvack.org>; Fri, 07 Jul 2017 06:41:12 -0700 (PDT)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0048.outbound.protection.outlook.com. [104.47.37.48])
        by mx.google.com with ESMTPS id l144si3499895ita.21.2017.07.07.06.41.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 07 Jul 2017 06:41:10 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v9 16/38] efi: Add an EFI table address match function
Date: Fri, 07 Jul 2017 08:41:00 -0500
Message-ID: <20170707134100.29711.4834.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170707133804.29711.1616.stgit@tlendack-t1.amdoffice.net>
References: <20170707133804.29711.1616.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

Add a function that will determine if a supplied physical address matches
the address of an EFI table.

Reviewed-by: Matt Fleming <matt@codeblueprint.co.uk>
Reviewed-by: Borislav Petkov <bp@suse.de>
Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/firmware/efi/efi.c |   33 +++++++++++++++++++++++++++++++++
 include/linux/efi.h        |    7 +++++++
 2 files changed, 40 insertions(+)

diff --git a/drivers/firmware/efi/efi.c b/drivers/firmware/efi/efi.c
index 045d6d3..69d4d13 100644
--- a/drivers/firmware/efi/efi.c
+++ b/drivers/firmware/efi/efi.c
@@ -55,6 +55,25 @@ struct efi __read_mostly efi = {
 };
 EXPORT_SYMBOL(efi);
 
+static unsigned long *efi_tables[] = {
+	&efi.mps,
+	&efi.acpi,
+	&efi.acpi20,
+	&efi.smbios,
+	&efi.smbios3,
+	&efi.sal_systab,
+	&efi.boot_info,
+	&efi.hcdp,
+	&efi.uga,
+	&efi.uv_systab,
+	&efi.fw_vendor,
+	&efi.runtime,
+	&efi.config_table,
+	&efi.esrt,
+	&efi.properties_table,
+	&efi.mem_attr_table,
+};
+
 static bool disable_runtime;
 static int __init setup_noefi(char *arg)
 {
@@ -855,6 +874,20 @@ int efi_status_to_err(efi_status_t status)
 	return err;
 }
 
+bool efi_is_table_address(unsigned long phys_addr)
+{
+	unsigned int i;
+
+	if (phys_addr == EFI_INVALID_TABLE_ADDR)
+		return false;
+
+	for (i = 0; i < ARRAY_SIZE(efi_tables); i++)
+		if (*(efi_tables[i]) == phys_addr)
+			return true;
+
+	return false;
+}
+
 #ifdef CONFIG_KEXEC
 static int update_efi_random_seed(struct notifier_block *nb,
 				  unsigned long code, void *unused)
diff --git a/include/linux/efi.h b/include/linux/efi.h
index 8269bcb..8e24f09 100644
--- a/include/linux/efi.h
+++ b/include/linux/efi.h
@@ -1091,6 +1091,8 @@ static inline bool efi_enabled(int feature)
 	return test_bit(feature, &efi.flags) != 0;
 }
 extern void efi_reboot(enum reboot_mode reboot_mode, const char *__unused);
+
+extern bool efi_is_table_address(unsigned long phys_addr);
 #else
 static inline bool efi_enabled(int feature)
 {
@@ -1104,6 +1106,11 @@ static inline bool efi_enabled(int feature)
 {
 	return false;
 }
+
+static inline bool efi_is_table_address(unsigned long phys_addr)
+{
+	return false;
+}
 #endif
 
 extern int efi_status_to_err(efi_status_t status);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
