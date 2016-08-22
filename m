Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6BFB16B0267
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 19:25:22 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id c189so37959673oia.1
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 16:25:22 -0700 (PDT)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0069.outbound.protection.outlook.com. [104.47.41.69])
        by mx.google.com with ESMTPS id n2si156867otn.138.2016.08.22.16.25.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 22 Aug 2016 16:25:21 -0700 (PDT)
Subject: [RFC PATCH v1 08/28] Access BOOT related data encrypted with SEV
 active
From: Brijesh Singh <brijesh.singh@amd.com>
Date: Mon, 22 Aug 2016 19:25:14 -0400
Message-ID: <147190831414.9523.1885664762210149209.stgit@brijesh-build-machine>
In-Reply-To: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, brijesh.singh@amd.com, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus.walleij@linaro.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, linux-crypto@vger.kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

From: Tom Lendacky <thomas.lendacky@amd.com>

When Secure Encrypted Virtualization (SEV) is active, BOOT data (such as
EFI related data) is encrypted and needs to be access as such. Update the
architecture override in early_memremap to keep the encryption attribute
when mapping this data.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/mm/ioremap.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
index e3bdc5a..2ea6deb 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -429,10 +429,11 @@ pgprot_t __init early_memremap_pgprot_adjust(resource_size_t phys_addr,
 					     pgprot_t prot)
 {
 	/*
-	 * If memory encryption is enabled and BOOT_DATA is being mapped
-	 * then remove the encryption bit.
+	 * If memory encryption is enabled, we are not running with
+	 * SEV active and BOOT_DATA is being mapped then remove the
+	 * encryption bit
 	 */
-	if (_PAGE_ENC && (owner == BOOT_DATA))
+	if (_PAGE_ENC && !sev_active && (owner == BOOT_DATA))
 		prot = __pgprot(pgprot_val(prot) & ~_PAGE_ENC);
 
 	return prot;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
