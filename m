Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1A0A46B04B2
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 17:12:38 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id s4so1944141pgr.3
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 14:12:38 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0078.outbound.protection.outlook.com. [104.47.33.78])
        by mx.google.com with ESMTPS id z10si170939pgs.544.2017.07.17.14.12.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 17 Jul 2017 14:12:37 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v10 26/38] x86/CPU/AMD: Make the microcode level available earlier in the boot
Date: Mon, 17 Jul 2017 16:10:23 -0500
Message-Id: <7b7525fa12593dac5f4b01fcc25c95f97e93862f.1500319216.git.thomas.lendacky@amd.com>
In-Reply-To: <cover.1500319216.git.thomas.lendacky@amd.com>
References: <cover.1500319216.git.thomas.lendacky@amd.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, kasan-dev@googlegroups.com
Cc: =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Dave Young <dyoung@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, "Michael S. Tsirkin" <mst@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>

Move the setting of the cpuinfo_x86.microcode field from amd_init() to
early_amd_init() so that it is available earlier in the boot process. This
avoids having to read MSR_AMD64_PATCH_LEVEL directly during early boot.

Reviewed-by: Borislav Petkov <bp@suse.de>
Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/kernel/cpu/amd.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/x86/kernel/cpu/amd.c b/arch/x86/kernel/cpu/amd.c
index e41670e..110ca5d 100644
--- a/arch/x86/kernel/cpu/amd.c
+++ b/arch/x86/kernel/cpu/amd.c
@@ -548,8 +548,12 @@ static void bsp_init_amd(struct cpuinfo_x86 *c)
 
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
@@ -751,8 +755,6 @@ static void init_amd_bd(struct cpuinfo_x86 *c)
 
 static void init_amd(struct cpuinfo_x86 *c)
 {
-	u32 dummy;
-
 	early_init_amd(c);
 
 	/*
@@ -814,8 +816,6 @@ static void init_amd(struct cpuinfo_x86 *c)
 	if (c->x86 > 0x11)
 		set_cpu_cap(c, X86_FEATURE_ARAT);
 
-	rdmsr_safe(MSR_AMD64_PATCH_LEVEL, &c->microcode, &dummy);
-
 	/* 3DNow or LM implies PREFETCHW */
 	if (!cpu_has(c, X86_FEATURE_3DNOWPREFETCH))
 		if (cpu_has(c, X86_FEATURE_3DNOW) || cpu_has(c, X86_FEATURE_LM))
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
