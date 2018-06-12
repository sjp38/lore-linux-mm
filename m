Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 139626B000D
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 10:39:29 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id q18-v6so9397983pll.3
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 07:39:29 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id d191-v6si257904pga.192.2018.06.12.07.39.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jun 2018 07:39:27 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 13/17] x86/mm: Detect MKTME early
Date: Tue, 12 Jun 2018 17:39:11 +0300
Message-Id: <20180612143915.68065-14-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
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
index fb58776513e6..3322b0125353 100644
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
@@ -762,9 +767,6 @@ static void init_intel(struct cpuinfo_x86 *c)
 	if (cpu_has(c, X86_FEATURE_VMX))
 		detect_vmx_virtcap(c);
 
-	if (cpu_has(c, X86_FEATURE_TME))
-		detect_tme(c);
-
 	init_intel_energy_perf(c);
 
 	init_intel_misc_features(c);
-- 
2.17.1
