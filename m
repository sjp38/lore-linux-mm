Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7C03644041A
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 14:52:30 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b9so44404393pfl.0
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 11:52:30 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0045.outbound.protection.outlook.com. [104.47.38.45])
        by mx.google.com with ESMTPS id d27si2302699pgn.350.2017.06.16.11.52.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 16 Jun 2017 11:52:29 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v7 13/36] x86/mm: Add support for early encrypt/decrypt of
 memory
Date: Fri, 16 Jun 2017 13:52:20 -0500
Message-ID: <20170616185220.18967.78204.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170616184947.18967.84890.stgit@tlendack-t1.amdoffice.net>
References: <20170616184947.18967.84890.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

Add support to be able to either encrypt or decrypt data in place during
the early stages of booting the kernel. This does not change the memory
encryption attribute - it is used for ensuring that data present in either
an encrypted or decrypted memory area is in the proper state (for example
the initrd will have been loaded by the boot loader and will not be
encrypted, but the memory that it resides in is marked as encrypted).

Reviewed-by: Borislav Petkov <bp@suse.de>
Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/mem_encrypt.h |   10 +++++
 arch/x86/mm/mem_encrypt.c          |   76 ++++++++++++++++++++++++++++++++++++
 2 files changed, 86 insertions(+)

diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
index faae4e1..6508ec9 100644
--- a/arch/x86/include/asm/mem_encrypt.h
+++ b/arch/x86/include/asm/mem_encrypt.h
@@ -21,6 +21,11 @@
 
 extern unsigned long sme_me_mask;
 
+void __init sme_early_encrypt(resource_size_t paddr,
+			      unsigned long size);
+void __init sme_early_decrypt(resource_size_t paddr,
+			      unsigned long size);
+
 void __init sme_early_init(void);
 
 void __init sme_enable(void);
@@ -29,6 +34,11 @@
 
 #define sme_me_mask	0UL
 
+static inline void __init sme_early_encrypt(resource_size_t paddr,
+					    unsigned long size) { }
+static inline void __init sme_early_decrypt(resource_size_t paddr,
+					    unsigned long size) { }
+
 static inline void __init sme_early_init(void) { }
 
 static inline void __init sme_enable(void) { }
diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index b2d1cdf..b7671b9 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -17,6 +17,9 @@
 
 #include <linux/mm.h>
 
+#include <asm/tlbflush.h>
+#include <asm/fixmap.h>
+
 /*
  * Since SME related variables are set early in the boot process they must
  * reside in the .data section so as not to be zeroed out when the .bss
@@ -25,6 +28,79 @@
 unsigned long sme_me_mask __section(.data) = 0;
 EXPORT_SYMBOL_GPL(sme_me_mask);
 
+/* Buffer used for early in-place encryption by BSP, no locking needed */
+static char sme_early_buffer[PAGE_SIZE] __aligned(PAGE_SIZE);
+
+/*
+ * This routine does not change the underlying encryption setting of the
+ * page(s) that map this memory. It assumes that eventually the memory is
+ * meant to be accessed as either encrypted or decrypted but the contents
+ * are currently not in the desired state.
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
+		 * Create mappings for the current and desired format of
+		 * the memory. Use a write-protected mapping for the source.
+		 */
+		src = enc ? early_memremap_decrypted_wp(paddr, len) :
+			    early_memremap_encrypted_wp(paddr, len);
+
+		dst = enc ? early_memremap_encrypted(paddr, len) :
+			    early_memremap_decrypted(paddr, len);
+
+		/*
+		 * If a mapping can't be obtained to perform the operation,
+		 * then eventual access of that area in the desired mode
+		 * will cause a crash.
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
