Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3FD836B026C
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 18:57:29 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u190so57344766pfb.0
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 15:57:29 -0700 (PDT)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1on0056.outbound.protection.outlook.com. [157.56.110.56])
        by mx.google.com with ESMTPS id o9si1068924pao.185.2016.04.26.15.57.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Apr 2016 15:57:28 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v1 08/18] x86: Add support for early
 encryption/decryption of memory
Date: Tue, 26 Apr 2016 17:57:18 -0500
Message-ID: <20160426225718.13567.92281.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
References: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek
 Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Ingo
 Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander
 Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry
 Vyukov <dvyukov@google.com>

This adds support to be able to either encrypt or decrypt data during
the early stages of booting the kernel. This does not change the memory
encryption attribute - it is used for ensuring that data present in
either an encrypted or un-encrypted memory area is in the proper state
(for example the initrd will have been loaded by the boot loader and
will not be encrypted, but the memory that it resides in is marked as
encrypted).

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/mem_encrypt.h |   15 ++++++
 arch/x86/mm/mem_encrypt.c          |   89 ++++++++++++++++++++++++++++++++++++
 2 files changed, 104 insertions(+)

diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
index 9f3e762..2785493 100644
--- a/arch/x86/include/asm/mem_encrypt.h
+++ b/arch/x86/include/asm/mem_encrypt.h
@@ -23,6 +23,11 @@ extern unsigned long sme_me_mask;
 
 u8 sme_get_me_loss(void);
 
+void __init sme_early_mem_enc(resource_size_t paddr,
+			      unsigned long size);
+void __init sme_early_mem_dec(resource_size_t paddr,
+			      unsigned long size);
+
 void __init sme_early_init(void);
 
 #define __sme_pa(x)		(__pa((x)) | sme_me_mask)
@@ -39,6 +44,16 @@ static inline u8 sme_get_me_loss(void)
 	return 0;
 }
 
+static inline void __init sme_early_mem_enc(resource_size_t paddr,
+					    unsigned long size)
+{
+}
+
+static inline void __init sme_early_mem_dec(resource_size_t paddr,
+					    unsigned long size)
+{
+}
+
 static inline void __init sme_early_init(void)
 {
 }
diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index 00eb705..5f19ede 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -14,6 +14,95 @@
 #include <linux/mm.h>
 
 #include <asm/mem_encrypt.h>
+#include <asm/tlbflush.h>
+#include <asm/fixmap.h>
+
+/* Buffer used for early in-place encryption by BSP, no locking needed */
+static char me_early_buffer[PAGE_SIZE] __aligned(PAGE_SIZE);
+
+void __init sme_early_mem_enc(resource_size_t paddr, unsigned long size)
+{
+	void *src, *dst;
+	size_t len;
+
+	if (!sme_me_mask)
+		return;
+
+	local_flush_tlb();
+	wbinvd();
+
+	/*
+	 * There are limited number of early mapping slots, so map (at most)
+	 * one page at time.
+	 */
+	while (size) {
+		len = min_t(size_t, sizeof(me_early_buffer), size);
+
+		/* Create a mapping for non-encrypted write-protected memory */
+		src = early_memremap_dec_wp(paddr, len);
+
+		/* Create a mapping for encrypted memory */
+		dst = early_memremap_enc(paddr, len);
+
+		/*
+		 * If a mapping can't be obtained to perform the encryption,
+		 * then encrypted access to that area will end up causing
+		 * a crash.
+		 */
+		BUG_ON(!src || !dst);
+
+		memcpy(me_early_buffer, src, len);
+		memcpy(dst, me_early_buffer, len);
+
+		early_memunmap(dst, len);
+		early_memunmap(src, len);
+
+		paddr += len;
+		size -= len;
+	}
+}
+
+void __init sme_early_mem_dec(resource_size_t paddr, unsigned long size)
+{
+	void *src, *dst;
+	size_t len;
+
+	if (!sme_me_mask)
+		return;
+
+	local_flush_tlb();
+	wbinvd();
+
+	/*
+	 * There are limited number of early mapping slots, so map (at most)
+	 * one page at time.
+	 */
+	while (size) {
+		len = min_t(size_t, sizeof(me_early_buffer), size);
+
+		/* Create a mapping for encrypted write-protected memory */
+		src = early_memremap_enc_wp(paddr, len);
+
+		/* Create a mapping for non-encrypted memory */
+		dst = early_memremap_dec(paddr, len);
+
+		/*
+		 * If a mapping can't be obtained to perform the decryption,
+		 * then un-encrypted access to that area will end up causing
+		 * a crash.
+		 */
+		BUG_ON(!src || !dst);
+
+		memcpy(me_early_buffer, src, len);
+		memcpy(dst, me_early_buffer, len);
+
+		early_memunmap(dst, len);
+		early_memunmap(src, len);
+
+		paddr += len;
+		size -= len;
+	}
+}
 
 void __init sme_early_init(void)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
