Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id A17176B0269
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 19:24:30 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id c189so37894597oia.1
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 16:24:30 -0700 (PDT)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0043.outbound.protection.outlook.com. [104.47.34.43])
        by mx.google.com with ESMTPS id w56si156643otw.124.2016.08.22.16.24.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 22 Aug 2016 16:24:29 -0700 (PDT)
Subject: [RFC PATCH v1 04/28] x86: Secure Encrypted Virtualization (SEV)
 support
From: Brijesh Singh <brijesh.singh@amd.com>
Date: Mon, 22 Aug 2016 19:24:19 -0400
Message-ID: <147190825949.9523.11406635622434950066.stgit@brijesh-build-machine>
In-Reply-To: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, brijesh.singh@amd.com, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus.walleij@linaro.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, linux-crypto@vger.kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

From: Tom Lendacky <thomas.lendacky@amd.com>

Provide support for Secure Encyrpted Virtualization (SEV). This initial
support defines the SEV active flag in order for the kernel to determine
if it is running with SEV active or not.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/mem_encrypt.h |    3 +++
 arch/x86/kernel/mem_encrypt.S      |    8 ++++++++
 arch/x86/kernel/x8664_ksyms_64.c   |    1 +
 3 files changed, 12 insertions(+)

diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
index e395729..9c592d1 100644
--- a/arch/x86/include/asm/mem_encrypt.h
+++ b/arch/x86/include/asm/mem_encrypt.h
@@ -20,6 +20,7 @@
 #ifdef CONFIG_AMD_MEM_ENCRYPT
 
 extern unsigned long sme_me_mask;
+extern unsigned int sev_active;
 
 u8 sme_get_me_loss(void);
 
@@ -50,6 +51,8 @@ void swiotlb_set_mem_dec(void *vaddr, unsigned long size);
 
 #define sme_me_mask		0UL
 
+#define sev_active		0
+
 static inline u8 sme_get_me_loss(void)
 {
 	return 0;
diff --git a/arch/x86/kernel/mem_encrypt.S b/arch/x86/kernel/mem_encrypt.S
index bf9f6a9..6a8cd18 100644
--- a/arch/x86/kernel/mem_encrypt.S
+++ b/arch/x86/kernel/mem_encrypt.S
@@ -96,6 +96,10 @@ ENDPROC(sme_enable)
 
 ENTRY(sme_encrypt_kernel)
 #ifdef CONFIG_AMD_MEM_ENCRYPT
+	/* If SEV is active then the kernel is already encrypted */
+	cmpl	$0, sev_active(%rip)
+	jnz	.Lencrypt_exit
+
 	/* If SME is not active then no need to encrypt the kernel */
 	cmpq	$0, sme_me_mask(%rip)
 	jz	.Lencrypt_exit
@@ -334,6 +338,10 @@ sme_me_loss:
 	.byte	0x00
 	.align	8
 
+ENTRY(sev_active)
+	.word	0x00000000
+	.align	8
+
 mem_encrypt_enable_option:
 	.asciz "mem_encrypt=on"
 	.align	8
diff --git a/arch/x86/kernel/x8664_ksyms_64.c b/arch/x86/kernel/x8664_ksyms_64.c
index 651c4c8..14bfc0b 100644
--- a/arch/x86/kernel/x8664_ksyms_64.c
+++ b/arch/x86/kernel/x8664_ksyms_64.c
@@ -88,4 +88,5 @@ EXPORT_SYMBOL(___preempt_schedule_notrace);
 #ifdef CONFIG_AMD_MEM_ENCRYPT
 EXPORT_SYMBOL_GPL(sme_me_mask);
 EXPORT_SYMBOL_GPL(sme_get_me_loss);
+EXPORT_SYMBOL_GPL(sev_active);
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
