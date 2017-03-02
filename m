Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 55B906B038B
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 10:12:34 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id 71so74164847iol.2
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 07:12:34 -0800 (PST)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0063.outbound.protection.outlook.com. [104.47.32.63])
        by mx.google.com with ESMTPS id m132si9181068ioa.163.2017.03.02.07.12.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 02 Mar 2017 07:12:33 -0800 (PST)
Subject: [RFC PATCH v2 02/32] x86: Secure Encrypted Virtualization (SEV)
 support
From: Brijesh Singh <brijesh.singh@amd.com>
Date: Thu, 2 Mar 2017 10:12:20 -0500
Message-ID: <148846754069.2349.4698319264278045964.stgit@brijesh-build-machine>
In-Reply-To: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, brijesh.singh@amd.com, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

From: Tom Lendacky <thomas.lendacky@amd.com>

Provide support for Secure Encyrpted Virtualization (SEV). This initial
support defines a flag that is used by the kernel to determine if it is
running with SEV active.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/mem_encrypt.h |   14 +++++++++++++-
 arch/x86/mm/mem_encrypt.c          |    3 +++
 include/linux/mem_encrypt.h        |    6 ++++++
 3 files changed, 22 insertions(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
index 1fd5426..9799835 100644
--- a/arch/x86/include/asm/mem_encrypt.h
+++ b/arch/x86/include/asm/mem_encrypt.h
@@ -20,10 +20,16 @@
 #ifdef CONFIG_AMD_MEM_ENCRYPT
 
 extern unsigned long sme_me_mask;
+extern unsigned int sev_enabled;
 
 static inline bool sme_active(void)
 {
-	return (sme_me_mask) ? true : false;
+	return (sme_me_mask && !sev_enabled) ? true : false;
+}
+
+static inline bool sev_active(void)
+{
+	return (sme_me_mask && sev_enabled) ? true : false;
 }
 
 static inline u64 sme_dma_mask(void)
@@ -53,6 +59,7 @@ void swiotlb_set_mem_attributes(void *vaddr, unsigned long size);
 
 #ifndef sme_me_mask
 #define sme_me_mask	0UL
+#define sev_enabled	0
 
 static inline bool sme_active(void)
 {
@@ -64,6 +71,11 @@ static inline u64 sme_dma_mask(void)
 	return 0ULL;
 }
 
+static inline bool sev_active(void)
+{
+	return false;
+}
+
 static inline int set_memory_encrypted(unsigned long vaddr, int numpages)
 {
 	return 0;
diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index c5062e1..090419b 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -34,6 +34,9 @@ void __init __early_pgtable_flush(void);
 unsigned long sme_me_mask __section(.data) = 0;
 EXPORT_SYMBOL_GPL(sme_me_mask);
 
+unsigned int sev_enabled __section(.data) = 0;
+EXPORT_SYMBOL_GPL(sev_enabled);
+
 /* Buffer used for early in-place encryption by BSP, no locking needed */
 static char sme_early_buffer[PAGE_SIZE] __aligned(PAGE_SIZE);
 
diff --git a/include/linux/mem_encrypt.h b/include/linux/mem_encrypt.h
index 913cf80..4b47c73 100644
--- a/include/linux/mem_encrypt.h
+++ b/include/linux/mem_encrypt.h
@@ -23,6 +23,7 @@
 
 #ifndef sme_me_mask
 #define sme_me_mask	0UL
+#define sev_enabled	0
 
 static inline bool sme_active(void)
 {
@@ -34,6 +35,11 @@ static inline u64 sme_dma_mask(void)
 	return 0ULL;
 }
 
+static inline bool sev_active(void)
+{
+	return false;
+}
+
 static inline int set_memory_encrypted(unsigned long vaddr, int numpages)
 {
 	return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
