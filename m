Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 47D8F6B0070
	for <linux-mm@kvack.org>; Sun,  7 Jun 2015 13:40:07 -0400 (EDT)
Received: by padev16 with SMTP id ev16so22881883pad.0
        for <linux-mm@kvack.org>; Sun, 07 Jun 2015 10:40:07 -0700 (PDT)
Received: from terminus.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id mb4si325185pdb.224.2015.06.07.10.40.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Jun 2015 10:40:06 -0700 (PDT)
Date: Sun, 7 Jun 2015 10:39:22 -0700
From: tip-bot for Borislav Petkov <tipbot@zytor.com>
Message-ID: <tip-9dac6290945142e6b87d9f027edfee676dcfbfda@git.kernel.org>
Reply-To: hpa@zytor.com, mcgrof@suse.com, toshi.kani@hp.com,
        luto@amacapital.net, tglx@linutronix.de, bp@suse.de,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        akpm@linux-foundation.org, torvalds@linux-foundation.org,
        mingo@kernel.org, peterz@infradead.org
In-Reply-To: <1433436928-31903-2-git-send-email-bp@alien8.de>
References: <1433436928-31903-2-git-send-email-bp@alien8.de>
Subject: [tip:x86/mm] x86/mm/pat: Untangle pat_init()
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: toshi.kani@hp.com, hpa@zytor.com, mcgrof@suse.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, luto@amacapital.net, tglx@linutronix.de, bp@suse.de, mingo@kernel.org, torvalds@linux-foundation.org, peterz@infradead.org

Commit-ID:  9dac6290945142e6b87d9f027edfee676dcfbfda
Gitweb:     http://git.kernel.org/tip/9dac6290945142e6b87d9f027edfee676dcfbfda
Author:     Borislav Petkov <bp@suse.de>
AuthorDate: Thu, 4 Jun 2015 18:55:09 +0200
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Sun, 7 Jun 2015 15:28:52 +0200

x86/mm/pat: Untangle pat_init()

Split it into a BSP and AP version which makes the PAT
initialization path actually readable again.

Signed-off-by: Borislav Petkov <bp@suse.de>
Reviewed-by: Toshi Kani <toshi.kani@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Elliott@hp.com
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: arnd@arndb.de
Cc: hch@lst.de
Cc: hmh@hmh.eng.br
Cc: jgross@suse.com
Cc: konrad.wilk@oracle.com
Cc: linux-mm <linux-mm@kvack.org>
Cc: linux-nvdimm@lists.01.org
Cc: stefan.bader@canonical.com
Cc: yigal@plexistor.com
Link: http://lkml.kernel.org/r/1433436928-31903-2-git-send-email-bp@alien8.de
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/x86/mm/pat.c | 69 ++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 40 insertions(+), 29 deletions(-)

diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index a1c9654..476d078 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -36,6 +36,8 @@
 #undef pr_fmt
 #define pr_fmt(fmt) "" fmt
 
+static bool boot_cpu_done;
+
 static int __read_mostly __pat_enabled = IS_ENABLED(CONFIG_X86_PAT);
 
 static inline void pat_disable(const char *reason)
@@ -194,31 +196,47 @@ void pat_init_cache_modes(void)
 
 #define PAT(x, y)	((u64)PAT_ ## y << ((x)*8))
 
-void pat_init(void)
+static void pat_bsp_init(u64 pat)
 {
-	u64 pat;
-	bool boot_cpu = !boot_pat_state;
+	if (!cpu_has_pat) {
+		pat_disable("PAT not supported by CPU.");
+		return;
+	}
 
-	if (!pat_enabled())
+	rdmsrl(MSR_IA32_CR_PAT, boot_pat_state);
+	if (!boot_pat_state) {
+		pat_disable("PAT MSR is 0, disabled.");
 		return;
+	}
 
+	wrmsrl(MSR_IA32_CR_PAT, pat);
+
+	pat_init_cache_modes();
+}
+
+static void pat_ap_init(u64 pat)
+{
 	if (!cpu_has_pat) {
-		if (!boot_pat_state) {
-			pat_disable("PAT not supported by CPU.");
-			return;
-		} else {
-			/*
-			 * If this happens we are on a secondary CPU, but
-			 * switched to PAT on the boot CPU. We have no way to
-			 * undo PAT.
-			 */
-			pr_err("x86/PAT: PAT enabled, but not supported by secondary CPU\n");
-			BUG();
-		}
+		/*
+		 * If this happens we are on a secondary CPU, but switched to
+		 * PAT on the boot CPU. We have no way to undo PAT.
+		 */
+		panic("x86/PAT: PAT enabled, but not supported by secondary CPU\n");
 	}
 
-	/* Set PWT to Write-Combining. All other bits stay the same */
+	wrmsrl(MSR_IA32_CR_PAT, pat);
+}
+
+void pat_init(void)
+{
+	u64 pat;
+
+	if (!pat_enabled())
+		return;
+
 	/*
+	 * Set PWT to Write-Combining. All other bits stay the same:
+	 *
 	 * PTE encoding used in Linux:
 	 *      PAT
 	 *      |PCD
@@ -233,19 +251,12 @@ void pat_init(void)
 	pat = PAT(0, WB) | PAT(1, WC) | PAT(2, UC_MINUS) | PAT(3, UC) |
 	      PAT(4, WB) | PAT(5, WC) | PAT(6, UC_MINUS) | PAT(7, UC);
 
-	/* Boot CPU check */
-	if (!boot_pat_state) {
-		rdmsrl(MSR_IA32_CR_PAT, boot_pat_state);
-		if (!boot_pat_state) {
-			pat_disable("PAT read returns always zero, disabled.");
-			return;
-		}
+	if (!boot_cpu_done) {
+		pat_bsp_init(pat);
+		boot_cpu_done = true;
+	} else {
+		pat_ap_init(pat);
 	}
-
-	wrmsrl(MSR_IA32_CR_PAT, pat);
-
-	if (boot_cpu)
-		pat_init_cache_modes();
 }
 
 #undef PAT

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
