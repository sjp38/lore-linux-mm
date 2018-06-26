Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 77BEC6B027D
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 10:23:04 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id d4-v6so8875568pfn.9
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 07:23:04 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id l190-v6si1524248pgd.375.2018.06.26.07.22.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jun 2018 07:22:56 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 14/18] x86/mm: Detect MKTME early
Date: Tue, 26 Jun 2018 17:22:41 +0300
Message-Id: <20180626142245.82850-15-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180626142245.82850-1-kirill.shutemov@linux.intel.com>
References: <20180626142245.82850-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We need to know number of KeyIDs before KALSR is initialized. Number of
KeyIDs would determinate how much address space would be needed for
per-KeyID direct mapping.

KALSR initialization happens before full CPU initizliation is complete.
Move detect_tme() call to early_init_intel().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/kernel/cpu/intel.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/arch/x86/kernel/cpu/intel.c b/arch/x86/kernel/cpu/intel.c
index 75e3b2602b4a..39830806dd42 100644
--- a/arch/x86/kernel/cpu/intel.c
+++ b/arch/x86/kernel/cpu/intel.c
@@ -158,6 +158,8 @@ static bool bad_spectre_microcode(struct cpuinfo_x86 *c)
 	return false;
 }
 
+static void detect_tme(struct cpuinfo_x86 *c);
+
 static void early_init_intel(struct cpuinfo_x86 *c)
 {
 	u64 misc_enable;
@@ -301,6 +303,9 @@ static void early_init_intel(struct cpuinfo_x86 *c)
 	}
 
 	check_mpx_erratum(c);
+
+	if (cpu_has(c, X86_FEATURE_TME))
+		detect_tme(c);
 }
 
 #ifdef CONFIG_X86_32
@@ -766,9 +771,6 @@ static void init_intel(struct cpuinfo_x86 *c)
 	if (cpu_has(c, X86_FEATURE_VMX))
 		detect_vmx_virtcap(c);
 
-	if (cpu_has(c, X86_FEATURE_TME))
-		detect_tme(c);
-
 	init_intel_energy_perf(c);
 
 	init_intel_misc_features(c);
-- 
2.18.0
