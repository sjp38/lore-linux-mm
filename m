From: Borislav Petkov <bp@alien8.de>
Subject: [PATCH 1/4] x86/pat: Untangle pat_init()
Date: Sun, 31 May 2015 11:48:03 +0200
Message-ID: <1433065686-20922-1-git-send-email-bp@alien8.de>
References: <20150531094655.GA20440@pd.tnic>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150531094655.GA20440@pd.tnic>
Sender: linux-kernel-owner@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, arnd@arndb.de, Elliott@hp.com, hch@lst.de, hmh@hmh.eng.br, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, jgross@suse.com, konrad.wilk@oracle.com, linux-mm <linux-mm@kvack.org>, linux-nvdimm@lists.01.org, "Luis R. Rodriguez" <mcgrof@suse.com>, stefan.bader@canonical.com, Thomas Gleixner <tglx@linutronix.de>, Toshi Kani <toshi.kani@hp.com>, x86-ml <x86@kernel.org>, yigal@plexistor.com
List-Id: linux-mm.kvack.org

From: Borislav Petkov <bp@suse.de>

Split it into a BSP and AP version which makes the PAT initialization
path actually readable again.

Signed-off-by: Borislav Petkov <bp@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: arnd@arndb.de
Cc: Elliott@hp.com
Cc: hch@lst.de
Cc: hmh@hmh.eng.br
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: jgross@suse.com
Cc: konrad.wilk@oracle.com
Cc: linux-mm <linux-mm@kvack.org>
Cc: linux-nvdimm@lists.01.org
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Cc: stefan.bader@canonical.com
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Toshi Kani <toshi.kani@hp.com>
Cc: x86-ml <x86@kernel.org>
Cc: yigal@plexistor.com
---
 arch/x86/mm/pat.c | 69 ++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 40 insertions(+), 29 deletions(-)

diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index a1c96544099d..476d0780560f 100644
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
2.3.5
