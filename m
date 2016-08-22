Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 718066B026A
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 18:37:21 -0400 (EDT)
Received: by mail-yb0-f197.google.com with SMTP id g67so270787257ybi.0
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 15:37:21 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0041.outbound.protection.outlook.com. [104.47.38.41])
        by mx.google.com with ESMTPS id u28si246876qkl.71.2016.08.22.15.37.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 22 Aug 2016 15:37:20 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v2 09/20] x86: Add support for early
 encryption/decryption of memory
Date: Mon, 22 Aug 2016 17:37:10 -0500
Message-ID: <20160822223710.29880.23936.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek
 Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy
 Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

This adds support to be able to either encrypt or decrypt data during
the early stages of booting the kernel. This does not change the memory
encryption attribute - it is used for ensuring that data present in
either an encrypted or un-encrypted memory area is in the proper state
(for example the initrd will have been loaded by the boot loader and
will not be encrypted, but the memory that it resides in is marked as
encrypted).

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/mem_encrypt.h |   15 +++++
 arch/x86/mm/mem_encrypt.c          |  101 ++++++++++++++++++++++++++++++++++++
 2 files changed, 116 insertions(+)

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
index 00eb705..f35a646 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -14,6 +14,107 @@
 #include <linux/mm.h>
 
 #include <asm/mem_encrypt.h>
+#include <asm/tlbflush.h>
+#include <asm/fixmap.h>
+
+/* Buffer used for early in-place encryption by BSP, no locking needed */
+static char me_early_buffer[PAGE_SIZE] __aligned(PAGE_SIZE);
+
+/*
+ * This routine does not change the underlying encryption setting of the
+ * page(s) that map this memory. It assumes that eventually the memory is
+ * meant to be accessed as encrypted but the contents are currently not
+ * encyrpted.
+ */
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
+/*
+ * This routine does not change the underlying encryption setting of the
+ * page(s) that map this memory. It assumes that eventually the memory is
+ * meant to be accessed as not encrypted but the contents are currently
+ * encyrpted.
+ */
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
