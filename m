Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id D06916B0387
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 17:11:09 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id o5so871220qki.2
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 14:11:09 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0050.outbound.protection.outlook.com. [104.47.33.50])
        by mx.google.com with ESMTPS id r36si251357qtc.252.2017.07.17.14.11.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 17 Jul 2017 14:11:09 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v10 05/38] x86/CPU/AMD: Handle SME reduction in physical address size
Date: Mon, 17 Jul 2017 16:10:02 -0500
Message-Id: <593c037a3cad85ba92f3d061ffa7462e9ce3531d.1500319216.git.thomas.lendacky@amd.com>
In-Reply-To: <cover.1500319216.git.thomas.lendacky@amd.com>
References: <cover.1500319216.git.thomas.lendacky@amd.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, kasan-dev@googlegroups.com
Cc: =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Dave Young <dyoung@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, "Michael S. Tsirkin" <mst@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>

When System Memory Encryption (SME) is enabled, the physical address
space is reduced. Adjust the x86_phys_bits value to reflect this
reduction.

Reviewed-by: Borislav Petkov <bp@suse.de>
Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/kernel/cpu/amd.c | 24 +++++++++++++-----------
 1 file changed, 13 insertions(+), 11 deletions(-)

diff --git a/arch/x86/kernel/cpu/amd.c b/arch/x86/kernel/cpu/amd.c
index 7f658d0..e41670e 100644
--- a/arch/x86/kernel/cpu/amd.c
+++ b/arch/x86/kernel/cpu/amd.c
@@ -614,21 +614,23 @@ static void early_init_amd(struct cpuinfo_x86 *c)
 		set_cpu_bug(c, X86_BUG_AMD_E400);
 
 	/*
-	 * BIOS support is required for SME. If BIOS has not enabled SME
-	 * then don't advertise the feature (set in scattered.c). Also,
-	 * since the SME support requires long mode, don't advertise the
-	 * feature under CONFIG_X86_32.
+	 * BIOS support is required for SME. If BIOS has enabled SME then
+	 * adjust x86_phys_bits by the SME physical address space reduction
+	 * value. If BIOS has not enabled SME then don't advertise the
+	 * feature (set in scattered.c). Also, since the SME support requires
+	 * long mode, don't advertise the feature under CONFIG_X86_32.
 	 */
 	if (cpu_has(c, X86_FEATURE_SME)) {
-		if (IS_ENABLED(CONFIG_X86_32)) {
-			clear_cpu_cap(c, X86_FEATURE_SME);
-		} else {
-			u64 msr;
+		u64 msr;
 
-			/* Check if SME is enabled */
-			rdmsrl(MSR_K8_SYSCFG, msr);
-			if (!(msr & MSR_K8_SYSCFG_MEM_ENCRYPT))
+		/* Check if SME is enabled */
+		rdmsrl(MSR_K8_SYSCFG, msr);
+		if (msr & MSR_K8_SYSCFG_MEM_ENCRYPT) {
+			c->x86_phys_bits -= (cpuid_ebx(0x8000001f) >> 6) & 0x3f;
+			if (IS_ENABLED(CONFIG_X86_32))
 				clear_cpu_cap(c, X86_FEATURE_SME);
+		} else {
+			clear_cpu_cap(c, X86_FEATURE_SME);
 		}
 	}
 }
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
