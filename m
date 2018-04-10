Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id A617E6B0009
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 05:27:16 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id m6-v6so9063083pln.8
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 02:27:16 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id j69si1525428pgc.697.2018.04.10.02.27.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Apr 2018 02:27:14 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2, RESEND] x86/mm: Do not lose cpuinfo_x86::x86_phys_bits adjustment
Date: Tue, 10 Apr 2018 12:27:04 +0300
Message-Id: <20180410092704.41106-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Some features (Intel MKTME, AMD SME) reduce number of effectively
available physical address bits. We adjust x86_phys_bits accordingly.

If get_cpu_cap() got called more than one time we lose this adjustement.

That's exactly what happens in setup_pku(): it gets called after
detect_tme() and cpuinfo_x86::x86_phys_bits gets overwritten.

Extract address sizes enumeration into a separate routine and get it
called only from early_identify_cpu() and from generic_identify().

It makes get_cpu_cap() safe to be called later during boot proccess
without risk to overwrite cpuinfo_x86::x86_phys_bits.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: Kai Huang <kai.huang@linux.intel.com>
Fixes: cb06d8e3d020 ("x86/tme: Detect if TME and MKTME is activated by BIOS")
---
 arch/x86/kernel/cpu/common.c | 32 ++++++++++++++++++++------------
 1 file changed, 20 insertions(+), 12 deletions(-)

diff --git a/arch/x86/kernel/cpu/common.c b/arch/x86/kernel/cpu/common.c
index 348cf4821240..2981bf287ef5 100644
--- a/arch/x86/kernel/cpu/common.c
+++ b/arch/x86/kernel/cpu/common.c
@@ -848,18 +848,6 @@ void get_cpu_cap(struct cpuinfo_x86 *c)
 		c->x86_power = edx;
 	}
 
-	if (c->extended_cpuid_level >= 0x80000008) {
-		cpuid(0x80000008, &eax, &ebx, &ecx, &edx);
-
-		c->x86_virt_bits = (eax >> 8) & 0xff;
-		c->x86_phys_bits = eax & 0xff;
-		c->x86_capability[CPUID_8000_0008_EBX] = ebx;
-	}
-#ifdef CONFIG_X86_32
-	else if (cpu_has(c, X86_FEATURE_PAE) || cpu_has(c, X86_FEATURE_PSE36))
-		c->x86_phys_bits = 36;
-#endif
-
 	if (c->extended_cpuid_level >= 0x8000000a)
 		c->x86_capability[CPUID_8000_000A_EDX] = cpuid_edx(0x8000000a);
 
@@ -874,6 +862,23 @@ void get_cpu_cap(struct cpuinfo_x86 *c)
 	apply_forced_caps(c);
 }
 
+static void get_cpu_address_sizes(struct cpuinfo_x86 *c)
+{
+	u32 eax, ebx, ecx, edx;
+
+	if (c->extended_cpuid_level >= 0x80000008) {
+		cpuid(0x80000008, &eax, &ebx, &ecx, &edx);
+
+		c->x86_virt_bits = (eax >> 8) & 0xff;
+		c->x86_phys_bits = eax & 0xff;
+		c->x86_capability[CPUID_8000_0008_EBX] = ebx;
+	}
+#ifdef CONFIG_X86_32
+	else if (cpu_has(c, X86_FEATURE_PAE) || cpu_has(c, X86_FEATURE_PSE36))
+		c->x86_phys_bits = 36;
+#endif
+}
+
 static void identify_cpu_without_cpuid(struct cpuinfo_x86 *c)
 {
 #ifdef CONFIG_X86_32
@@ -965,6 +970,7 @@ static void __init early_identify_cpu(struct cpuinfo_x86 *c)
 		cpu_detect(c);
 		get_cpu_vendor(c);
 		get_cpu_cap(c);
+		get_cpu_address_sizes(c);
 		setup_force_cpu_cap(X86_FEATURE_CPUID);
 
 		if (this_cpu->c_early_init)
@@ -1097,6 +1103,8 @@ static void generic_identify(struct cpuinfo_x86 *c)
 
 	get_cpu_cap(c);
 
+	get_cpu_address_sizes(c);
+
 	if (c->cpuid_level >= 0x00000001) {
 		c->initial_apicid = (cpuid_ebx(1) >> 24) & 0xFF;
 #ifdef CONFIG_X86_32
-- 
2.16.3
