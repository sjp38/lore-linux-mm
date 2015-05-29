Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id 46F716B006E
	for <linux-mm@kvack.org>; Fri, 29 May 2015 19:18:50 -0400 (EDT)
Received: by oihd6 with SMTP id d6so67567140oih.2
        for <linux-mm@kvack.org>; Fri, 29 May 2015 16:18:50 -0700 (PDT)
Received: from g9t5008.houston.hp.com (g9t5008.houston.hp.com. [15.240.92.66])
        by mx.google.com with ESMTPS id f4si4406205oeu.54.2015.05.29.16.18.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 May 2015 16:18:49 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v11 1/12] x86, mm, pat: Cleanup init flags in pat_init()
Date: Fri, 29 May 2015 16:58:59 -0600
Message-Id: <1432940350-1802-2-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1432940350-1802-1-git-send-email-toshi.kani@hp.com>
References: <1432940350-1802-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bp@alien8.de, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-nvdimm@lists.01.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com, mcgrof@suse.com, hch@lst.de, Toshi Kani <toshi.kani@hp.com>

From: Toshi Kani <toshi.kani@hp.com>

pat_init() uses two flags, 'boot_cpu' and 'boot_pat_state', for
tracking the boot CPU's initialization status.  'boot_pat_state'
is also overloaded to carry the boot PAT value.

This patch cleans this up by replacing them with a new single
flag, 'boot_cpu_done', to track the boot CPU's initialization
status.  'boot_pat_state' is only used to carry the boot PAT
value as a result.

Suggested-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 arch/x86/mm/pat.c |   40 +++++++++++++++++++---------------------
 1 file changed, 19 insertions(+), 21 deletions(-)

diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index a1c9654..e1ec6a7 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -197,24 +197,29 @@ void pat_init_cache_modes(void)
 void pat_init(void)
 {
 	u64 pat;
-	bool boot_cpu = !boot_pat_state;
+	static bool boot_cpu_done;
 
 	if (!pat_enabled())
 		return;
 
-	if (!cpu_has_pat) {
-		if (!boot_pat_state) {
+	if (!boot_cpu_done) {
+		if (!cpu_has_pat) {
 			pat_disable("PAT not supported by CPU.");
 			return;
-		} else {
-			/*
-			 * If this happens we are on a secondary CPU, but
-			 * switched to PAT on the boot CPU. We have no way to
-			 * undo PAT.
-			 */
-			pr_err("x86/PAT: PAT enabled, but not supported by secondary CPU\n");
-			BUG();
 		}
+
+		rdmsrl(MSR_IA32_CR_PAT, boot_pat_state);
+		if (!boot_pat_state) {
+			pat_disable("PAT read returns always zero, disabled.");
+			return;
+		}
+	} else if (!cpu_has_pat) {
+		/*
+		 * If this happens we are on a secondary CPU, but
+		 * switched to PAT on the boot CPU. We have no way to
+		 * undo PAT.
+		 */
+		panic("PAT enabled, but not supported by secondary CPU\n");
 	}
 
 	/* Set PWT to Write-Combining. All other bits stay the same */
@@ -233,19 +238,12 @@ void pat_init(void)
 	pat = PAT(0, WB) | PAT(1, WC) | PAT(2, UC_MINUS) | PAT(3, UC) |
 	      PAT(4, WB) | PAT(5, WC) | PAT(6, UC_MINUS) | PAT(7, UC);
 
-	/* Boot CPU check */
-	if (!boot_pat_state) {
-		rdmsrl(MSR_IA32_CR_PAT, boot_pat_state);
-		if (!boot_pat_state) {
-			pat_disable("PAT read returns always zero, disabled.");
-			return;
-		}
-	}
-
 	wrmsrl(MSR_IA32_CR_PAT, pat);
 
-	if (boot_cpu)
+	if (!boot_cpu_done) {
 		pat_init_cache_modes();
+		boot_cpu_done = true;
+	}
 }
 
 #undef PAT

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
