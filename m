Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2C6AE6B02FA
	for <linux-mm@kvack.org>; Wed,  7 Jun 2017 15:14:16 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id k26so6505513iti.5
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 12:14:16 -0700 (PDT)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0044.outbound.protection.outlook.com. [104.47.32.44])
        by mx.google.com with ESMTPS id o12si3260562itc.68.2017.06.07.12.14.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 07 Jun 2017 12:14:15 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v6 05/34] x86/CPU/AMD: Handle SME reduction in physical
 address size
Date: Wed, 07 Jun 2017 14:14:04 -0500
Message-ID: <20170607191404.28645.41148.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net>
References: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

When System Memory Encryption (SME) is enabled, the physical address
space is reduced. Adjust the x86_phys_bits value to reflect this
reduction.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/kernel/cpu/amd.c |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/arch/x86/kernel/cpu/amd.c b/arch/x86/kernel/cpu/amd.c
index c47ceee..5bdcbd4 100644
--- a/arch/x86/kernel/cpu/amd.c
+++ b/arch/x86/kernel/cpu/amd.c
@@ -613,15 +613,19 @@ static void early_init_amd(struct cpuinfo_x86 *c)
 		set_cpu_bug(c, X86_BUG_AMD_E400);
 
 	/*
-	 * BIOS support is required for SME. If BIOS has not enabled SME
-	 * then don't advertise the feature (set in scattered.c)
+	 * BIOS support is required for SME. If BIOS has enabld SME then
+	 * adjust x86_phys_bits by the SME physical address space reduction
+	 * value. If BIOS has not enabled SME then don't advertise the
+	 * feature (set in scattered.c).
 	 */
 	if (cpu_has(c, X86_FEATURE_SME)) {
 		u64 msr;
 
 		/* Check if SME is enabled */
 		rdmsrl(MSR_K8_SYSCFG, msr);
-		if (!(msr & MSR_K8_SYSCFG_MEM_ENCRYPT))
+		if (msr & MSR_K8_SYSCFG_MEM_ENCRYPT)
+			c->x86_phys_bits -= (cpuid_ebx(0x8000001f) >> 6) & 0x3f;
+		else
 			clear_cpu_cap(c, X86_FEATURE_SME);
 	}
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
