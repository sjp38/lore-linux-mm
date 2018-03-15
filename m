Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id A3EED6B0005
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 09:49:15 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 60-v6so3238371plf.19
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 06:49:15 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id m1si3577625pff.43.2018.03.15.06.49.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Mar 2018 06:49:14 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 2/2] x86/mm: Do not lose cpuinfo_x86:x86_phys_bits adjustment
Date: Thu, 15 Mar 2018 16:49:07 +0300
Message-Id: <20180315134907.9311-3-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180315134907.9311-1-kirill.shutemov@linux.intel.com>
References: <20180315134907.9311-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Some features (Intel MKTME, AMD SME) may reduce number of effectively
available physical address bits. We adjust x86_phys_bits accordingly.

But if get_cpu_cap() got called more than one time we may lose this
information.

That's exactly what happens in setup_pku(): it gets called after
detect_tme() and x86_phys_bits gets overwritten.

Add x86_phys_bits_adj which stores by how many bits we should reduce
x86_phys_bits comparing to what CPUID returns.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: Kai Huang <kai.huang@linux.intel.com>
Fixes: cb06d8e3d020 ("x86/tme: Detect if TME and MKTME is activated by BIOS")
---
 arch/x86/include/asm/processor.h |  1 +
 arch/x86/kernel/cpu/amd.c        |  3 ++-
 arch/x86/kernel/cpu/common.c     | 14 ++++++++++++++
 arch/x86/kernel/cpu/intel.c      |  1 +
 4 files changed, 18 insertions(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/processor.h b/arch/x86/include/asm/processor.h
index b0ccd4847a58..1250547c8eb7 100644
--- a/arch/x86/include/asm/processor.h
+++ b/arch/x86/include/asm/processor.h
@@ -98,6 +98,7 @@ struct cpuinfo_x86 {
 #endif
 	__u8			x86_virt_bits;
 	__u8			x86_phys_bits;
+	__u8			x86_phys_bits_adj;
 	/* CPUID returned core id bits: */
 	__u8			x86_coreid_bits;
 	__u8			cu_id;
diff --git a/arch/x86/kernel/cpu/amd.c b/arch/x86/kernel/cpu/amd.c
index 12bc0a1139da..4d0ec075f99e 100644
--- a/arch/x86/kernel/cpu/amd.c
+++ b/arch/x86/kernel/cpu/amd.c
@@ -583,7 +583,8 @@ static void early_detect_mem_encrypt(struct cpuinfo_x86 *c)
 		 * will be a value above 32-bits this is still done for
 		 * CONFIG_X86_32 so that accurate values are reported.
 		 */
-		c->x86_phys_bits -= (cpuid_ebx(0x8000001f) >> 6) & 0x3f;
+		c->x86_phys_bits_adj = (cpuid_ebx(0x8000001f) >> 6) & 0x3f;
+		c->x86_phys_bits -= c->x86_phys_bits_adj;
 
 		if (IS_ENABLED(CONFIG_X86_32))
 			goto clear_all;
diff --git a/arch/x86/kernel/cpu/common.c b/arch/x86/kernel/cpu/common.c
index 348cf4821240..d2e3dd827691 100644
--- a/arch/x86/kernel/cpu/common.c
+++ b/arch/x86/kernel/cpu/common.c
@@ -854,6 +854,20 @@ void get_cpu_cap(struct cpuinfo_x86 *c)
 		c->x86_virt_bits = (eax >> 8) & 0xff;
 		c->x86_phys_bits = eax & 0xff;
 		c->x86_capability[CPUID_8000_0008_EBX] = ebx;
+
+		/*
+		 * Some features (Intel MKTME, AMD SME) may reduce number
+		 * of effectively available physical address bits.
+		 *
+		 * We adjust x86_phys_bits accordingly.
+		 *
+		 * But if get_cpu_cap() got called more than one time we
+		 * may lose this information.
+		 *
+		 * x86_phys_bits_adj stores by how many bits we should
+		 * reduce x86_phys_bits comparing to what CPUID returns.
+		 */
+		c->x86_phys_bits -= c->x86_phys_bits_adj;
 	}
 #ifdef CONFIG_X86_32
 	else if (cpu_has(c, X86_FEATURE_PAE) || cpu_has(c, X86_FEATURE_PSE36))
diff --git a/arch/x86/kernel/cpu/intel.c b/arch/x86/kernel/cpu/intel.c
index fd379358c58d..801c2e42b87d 100644
--- a/arch/x86/kernel/cpu/intel.c
+++ b/arch/x86/kernel/cpu/intel.c
@@ -623,6 +623,7 @@ static void detect_tme(struct cpuinfo_x86 *c)
 	 * Let's update cpuinfo_x86::x86_phys_bits to reflect the fact.
 	 */
 	c->x86_phys_bits -= keyid_bits;
+	c->x86_phys_bits_adj = keyid_bits;
 }
 
 static void init_intel_energy_perf(struct cpuinfo_x86 *c)
-- 
2.16.1
