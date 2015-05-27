Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id BB22A6B0106
	for <linux-mm@kvack.org>; Wed, 27 May 2015 11:39:09 -0400 (EDT)
Received: by obbea2 with SMTP id ea2so10512985obb.3
        for <linux-mm@kvack.org>; Wed, 27 May 2015 08:39:09 -0700 (PDT)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id c2si30110oih.6.2015.05.27.08.39.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 May 2015 08:39:09 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v10 10/12] x86, mm, pat: Cleanup init flags in pat_init()
Date: Wed, 27 May 2015 09:19:02 -0600
Message-Id: <1432739944-22633-11-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1432739944-22633-1-git-send-email-toshi.kani@hp.com>
References: <1432739944-22633-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-nvdimm@lists.01.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com, mcgrof@suse.com, hch@lst.de, Toshi Kani <toshi.kani@hp.com>

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
 arch/x86/mm/pat.c |   42 ++++++++++++++++++++----------------------
 1 file changed, 20 insertions(+), 22 deletions(-)

diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index 92fc635..7cfd995 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -201,26 +201,31 @@ void pat_init_cache_modes(void)
 void pat_init(void)
 {
 	u64 pat;
-	bool boot_cpu = !boot_pat_state;
 	struct cpuinfo_x86 *c = &boot_cpu_data;
+	static bool boot_cpu_done;
 
 	if (!pat_enabled)
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
-			printk(KERN_ERR "PAT enabled, "
-			       "but not supported by secondary CPU\n");
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
+		pr_err("PAT enabled, but not supported by secondary CPU\n");
+		BUG();
 	}
 
 	if ((c->x86_vendor == X86_VENDOR_INTEL) &&
@@ -279,19 +284,12 @@ void pat_init(void)
 		      PAT(4, WB) | PAT(5, WC) | PAT(6, UC_MINUS) | PAT(7, WT);
 	}
 
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
