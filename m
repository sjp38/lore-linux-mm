Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 81F6C83296
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 11:12:27 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id m188so30049122pgm.2
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 08:12:27 -0700 (PDT)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0050.outbound.protection.outlook.com. [104.47.40.50])
        by mx.google.com with ESMTPS id 74si2076127pfj.30.2017.06.27.08.12.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 27 Jun 2017 08:12:26 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v8 RESEND 26/38] x86/CPU/AMD: Make the microcode level
 available earlier in the boot
Date: Tue, 27 Jun 2017 10:12:18 -0500
Message-ID: <20170627151218.17428.25499.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170627150718.17428.81813.stgit@tlendack-t1.amdoffice.net>
References: <20170627150718.17428.81813.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

Move the setting of the cpuinfo_x86.microcode field from amd_init() to
early_amd_init() so that it is available earlier in the boot process. This
avoids having to read MSR_AMD64_PATCH_LEVEL directly during early boot.

Reviewed-by: Borislav Petkov <bp@suse.de>
Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/kernel/cpu/amd.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/x86/kernel/cpu/amd.c b/arch/x86/kernel/cpu/amd.c
index 5bdcbd4..fdcf305 100644
--- a/arch/x86/kernel/cpu/amd.c
+++ b/arch/x86/kernel/cpu/amd.c
@@ -547,8 +547,12 @@ static void bsp_init_amd(struct cpuinfo_x86 *c)
 
 static void early_init_amd(struct cpuinfo_x86 *c)
 {
+	u32 dummy;
+
 	early_init_amd_mc(c);
 
+	rdmsr_safe(MSR_AMD64_PATCH_LEVEL, &c->microcode, &dummy);
+
 	/*
 	 * c->x86_power is 8000_0007 edx. Bit 8 is TSC runs at constant rate
 	 * with P/T states and does not stop in deep C-states
@@ -746,8 +750,6 @@ static void init_amd_bd(struct cpuinfo_x86 *c)
 
 static void init_amd(struct cpuinfo_x86 *c)
 {
-	u32 dummy;
-
 	early_init_amd(c);
 
 	/*
@@ -809,8 +811,6 @@ static void init_amd(struct cpuinfo_x86 *c)
 	if (c->x86 > 0x11)
 		set_cpu_cap(c, X86_FEATURE_ARAT);
 
-	rdmsr_safe(MSR_AMD64_PATCH_LEVEL, &c->microcode, &dummy);
-
 	/* 3DNow or LM implies PREFETCHW */
 	if (!cpu_has(c, X86_FEATURE_3DNOWPREFETCH))
 		if (cpu_has(c, X86_FEATURE_3DNOW) || cpu_has(c, X86_FEATURE_LM))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
