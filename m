Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2309C6B0374
	for <linux-mm@kvack.org>; Wed,  7 Jun 2017 15:16:17 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id s23so7763817pgo.15
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 12:16:17 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0072.outbound.protection.outlook.com. [104.47.38.72])
        by mx.google.com with ESMTPS id k6si2427439pfc.198.2017.06.07.12.16.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 07 Jun 2017 12:16:15 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v6 16/34] efi: Add an EFI table address match function
Date: Wed, 07 Jun 2017 14:16:03 -0500
Message-ID: <20170607191603.28645.2332.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net>
References: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

Add a function that will determine if a supplied physical address matches
the address of an EFI table.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/firmware/efi/efi.c |   33 +++++++++++++++++++++++++++++++++
 include/linux/efi.h        |    7 +++++++
 2 files changed, 40 insertions(+)

diff --git a/drivers/firmware/efi/efi.c b/drivers/firmware/efi/efi.c
index b372aad..983675d 100644
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
@@ -854,6 +873,20 @@ int efi_status_to_err(efi_status_t status)
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
index ec36f42..504fa85 100644
--- a/include/linux/efi.h
+++ b/include/linux/efi.h
@@ -1079,6 +1079,8 @@ static inline bool efi_enabled(int feature)
 	return test_bit(feature, &efi.flags) != 0;
 }
 extern void efi_reboot(enum reboot_mode reboot_mode, const char *__unused);
+
+extern bool efi_is_table_address(unsigned long phys_addr);
 #else
 static inline bool efi_enabled(int feature)
 {
@@ -1092,6 +1094,11 @@ static inline bool efi_enabled(int feature)
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
