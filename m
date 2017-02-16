Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 63396680FF1
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 10:44:08 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id e4so26116035pfg.4
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 07:44:08 -0800 (PST)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0051.outbound.protection.outlook.com. [104.47.40.51])
        by mx.google.com with ESMTPS id b5si4787476ple.313.2017.02.16.07.44.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 16 Feb 2017 07:44:07 -0800 (PST)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v4 09/28] x86: Add support for early
 encryption/decryption of memory
Date: Thu, 16 Feb 2017 09:43:58 -0600
Message-ID: <20170216154358.19244.6082.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

Add support to be able to either encrypt or decrypt data in place during
the early stages of booting the kernel. This does not change the memory
encryption attribute - it is used for ensuring that data present in either
an encrypted or decrypted memory area is in the proper state (for example
the initrd will have been loaded by the boot loader and will not be
encrypted, but the memory that it resides in is marked as encrypted).

The early_memmap support is enhanced to specify encrypted and decrypted
mappings with and without write-protection. The use of write-protection is
necessary when encrypting data "in place". The write-protect attribute is
considered cacheable for loads, but not stores. This implies that the
hardware will never give the core a dirty line with this memtype.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/mem_encrypt.h |   15 +++++++
 arch/x86/mm/mem_encrypt.c          |   79 ++++++++++++++++++++++++++++++++++++
 2 files changed, 94 insertions(+)

diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
index 547989d..3c9052c 100644
--- a/arch/x86/include/asm/mem_encrypt.h
+++ b/arch/x86/include/asm/mem_encrypt.h
@@ -26,6 +26,11 @@ static inline bool sme_active(void)
 	return (sme_me_mask) ? true : false;
 }
 
+void __init sme_early_encrypt(resource_size_t paddr,
+			      unsigned long size);
+void __init sme_early_decrypt(resource_size_t paddr,
+			      unsigned long size);
+
 void __init sme_early_init(void);
 
 #define __sme_pa(x)		(__pa((x)) | sme_me_mask)
@@ -42,6 +47,16 @@ static inline bool sme_active(void)
 }
 #endif
 
+static inline void __init sme_early_encrypt(resource_size_t paddr,
+					    unsigned long size)
+{
+}
+
+static inline void __init sme_early_decrypt(resource_size_t paddr,
+					    unsigned long size)
+{
+}
+
 static inline void __init sme_early_init(void)
 {
 }
diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index d71df97..ac3565c 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -14,6 +14,9 @@
 #include <linux/init.h>
 #include <linux/mm.h>
 
+#include <asm/tlbflush.h>
+#include <asm/fixmap.h>
+
 extern pmdval_t early_pmd_flags;
 
 /*
@@ -24,6 +27,82 @@
 unsigned long sme_me_mask __section(.data) = 0;
 EXPORT_SYMBOL_GPL(sme_me_mask);
 
+/* Buffer used for early in-place encryption by BSP, no locking needed */
+static char sme_early_buffer[PAGE_SIZE] __aligned(PAGE_SIZE);
+
+/*
+ * This routine does not change the underlying encryption setting of the
+ * page(s) that map this memory. It assumes that eventually the memory is
+ * meant to be accessed as either encrypted or decrypted but the contents
+ * are currently not in the desired stated.
+ *
+ * This routine follows the steps outlined in the AMD64 Architecture
+ * Programmer's Manual Volume 2, Section 7.10.8 Encrypt-in-Place.
+ */
+static void __init __sme_early_enc_dec(resource_size_t paddr,
+				       unsigned long size, bool enc)
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
+		len = min_t(size_t, sizeof(sme_early_buffer), size);
+
+		/*
+		 * Create write protected mappings for the current format
+		 * of the memory.
+		 */
+		src = enc ? early_memremap_decrypted_wp(paddr, len) :
+			    early_memremap_encrypted_wp(paddr, len);
+
+		/*
+		 * Create mappings for the desired format of the memory.
+		 */
+		dst = enc ? early_memremap_encrypted(paddr, len) :
+			    early_memremap_decrypted(paddr, len);
+
+		/*
+		 * If a mapping can't be obtained to perform the operation,
+		 * then eventual access of that area will in the desired
+		 * mode will cause a crash.
+		 */
+		BUG_ON(!src || !dst);
+
+		/*
+		 * Use a temporary buffer, of cache-line multiple size, to
+		 * avoid data corruption as documented in the APM.
+		 */
+		memcpy(sme_early_buffer, src, len);
+		memcpy(dst, sme_early_buffer, len);
+
+		early_memunmap(dst, len);
+		early_memunmap(src, len);
+
+		paddr += len;
+		size -= len;
+	}
+}
+
+void __init sme_early_encrypt(resource_size_t paddr, unsigned long size)
+{
+	__sme_early_enc_dec(paddr, size, true);
+}
+
+void __init sme_early_decrypt(resource_size_t paddr, unsigned long size)
+{
+	__sme_early_enc_dec(paddr, size, false);
+}
+
 void __init sme_early_init(void)
 {
 	unsigned int i;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
