Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 601D76B027B
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 07:21:58 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id b9-v6so325200pgq.17
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 04:21:58 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id u7-v6si691565pgn.194.2018.07.17.04.21.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 04:21:57 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 15/19] x86/mm: Detect MKTME early
Date: Tue, 17 Jul 2018 14:20:25 +0300
Message-Id: <20180717112029.42378-16-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
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
