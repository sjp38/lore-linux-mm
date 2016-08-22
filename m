Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8F0C46B026D
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 19:25:15 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id f6so6761687ith.2
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 16:25:15 -0700 (PDT)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0082.outbound.protection.outlook.com. [104.47.34.82])
        by mx.google.com with ESMTPS id 188si162472oid.1.2016.08.22.16.25.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 22 Aug 2016 16:25:15 -0700 (PDT)
Subject: [RFC PATCH v1 07/28] x86: Do not encrypt memory areas if SEV is
 enabled
From: Brijesh Singh <brijesh.singh@amd.com>
Date: Mon, 22 Aug 2016 19:24:59 -0400
Message-ID: <147190829935.9523.3097284272847092359.stgit@brijesh-build-machine>
In-Reply-To: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, brijesh.singh@amd.com, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus.walleij@linaro.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, linux-crypto@vger.kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

From: Tom Lendacky <thomas.lendacky@amd.com>

When running under SEV, some memory areas that were originally not
encrypted under SME are already encrypted. In these situations do not
attempt to encrypt them.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/kernel/head64.c |    4 ++--
 arch/x86/kernel/setup.c  |    7 ++++---
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index 358d7bc..4a15def 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -114,7 +114,7 @@ static void __init create_unencrypted_mapping(void *address, unsigned long size)
 	unsigned long physaddr = (unsigned long)address - __PAGE_OFFSET;
 	pmdval_t pmd_flags, pmd;
 
-	if (!sme_me_mask)
+	if (!sme_me_mask || sev_active)
 		return;
 
 	/* Clear the encryption mask from the early_pmd_flags */
@@ -165,7 +165,7 @@ static void __init __clear_mapping(unsigned long address)
 
 static void __init clear_mapping(void *address, unsigned long size)
 {
-	if (!sme_me_mask)
+	if (!sme_me_mask || sev_active)
 		return;
 
 	do {
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index cec8a63..9c10383 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -380,10 +380,11 @@ static void __init reserve_initrd(void)
 
 	/*
 	 * This memory is marked encrypted by the kernel but the ramdisk
-	 * was loaded in the clear by the bootloader, so make sure that
-	 * the ramdisk image is encrypted.
+	 * was loaded in the clear by the bootloader (unless SEV is active),
+	 * so make sure that the ramdisk image is encrypted.
 	 */
-	sme_early_mem_enc(ramdisk_image, ramdisk_end - ramdisk_image);
+	if (!sev_active)
+		sme_early_mem_enc(ramdisk_image, ramdisk_end - ramdisk_image);
 
 	initrd_start = 0;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
