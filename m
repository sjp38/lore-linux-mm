From: Borislav Petkov <bp@alien8.de>
Subject: [PATCH 3/4] x86/pat: Emulate PAT when it is disabled
Date: Sun, 31 May 2015 11:48:05 +0200
Message-ID: <1433065686-20922-3-git-send-email-bp@alien8.de>
References: <20150531094655.GA20440@pd.tnic>
 <1433065686-20922-1-git-send-email-bp@alien8.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1433065686-20922-1-git-send-email-bp@alien8.de>
Sender: linux-kernel-owner@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, arnd@arndb.de, Elliott@hp.com, hch@lst.de, hmh@hmh.eng.br, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, jgross@suse.com, konrad.wilk@oracle.com, linux-mm <linux-mm@kvack.org>, linux-nvdimm@lists.01.org, "Luis R. Rodriguez" <mcgrof@suse.com>, stefan.bader@canonical.com, Thomas Gleixner <tglx@linutronix.de>, Toshi Kani <toshi.kani@hp.com>, x86-ml <x86@kernel.org>, yigal@plexistor.com
List-Id: linux-mm.kvack.org

From: Borislav Petkov <bp@suse.de>

In the case when PAT is disabled on the command line with "nopat" or
when virtualization doesn't support PAT (correctly) - see

  9d34cfdf4796 ("x86: Don't rely on VMWare emulating PAT MSR correctly").

we emulate it using the PWT and PCD cache attribute bits. Get rid of
boot_pat_state while at it.

Based on a conglomerate patch from Toshi Kani.

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
 arch/x86/mm/init.c |  6 ++---
 arch/x86/mm/pat.c  | 72 +++++++++++++++++++++++++++++++++++++-----------------
 2 files changed, 52 insertions(+), 26 deletions(-)

diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index 1d553186c434..8533b46e6bee 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -40,7 +40,7 @@
  */
 uint16_t __cachemode2pte_tbl[_PAGE_CACHE_MODE_NUM] = {
 	[_PAGE_CACHE_MODE_WB      ]	= 0         | 0        ,
-	[_PAGE_CACHE_MODE_WC      ]	= _PAGE_PWT | 0        ,
+	[_PAGE_CACHE_MODE_WC      ]	= 0         | _PAGE_PCD,
 	[_PAGE_CACHE_MODE_UC_MINUS]	= 0         | _PAGE_PCD,
 	[_PAGE_CACHE_MODE_UC      ]	= _PAGE_PWT | _PAGE_PCD,
 	[_PAGE_CACHE_MODE_WT      ]	= 0         | _PAGE_PCD,
@@ -50,11 +50,11 @@ EXPORT_SYMBOL(__cachemode2pte_tbl);
 
 uint8_t __pte2cachemode_tbl[8] = {
 	[__pte2cm_idx( 0        | 0         | 0        )] = _PAGE_CACHE_MODE_WB,
-	[__pte2cm_idx(_PAGE_PWT | 0         | 0        )] = _PAGE_CACHE_MODE_WC,
+	[__pte2cm_idx(_PAGE_PWT | 0         | 0        )] = _PAGE_CACHE_MODE_UC_MINUS,
 	[__pte2cm_idx( 0        | _PAGE_PCD | 0        )] = _PAGE_CACHE_MODE_UC_MINUS,
 	[__pte2cm_idx(_PAGE_PWT | _PAGE_PCD | 0        )] = _PAGE_CACHE_MODE_UC,
 	[__pte2cm_idx( 0        | 0         | _PAGE_PAT)] = _PAGE_CACHE_MODE_WB,
-	[__pte2cm_idx(_PAGE_PWT | 0         | _PAGE_PAT)] = _PAGE_CACHE_MODE_WC,
+	[__pte2cm_idx(_PAGE_PWT | 0         | _PAGE_PAT)] = _PAGE_CACHE_MODE_UC_MINUS,
 	[__pte2cm_idx(0         | _PAGE_PCD | _PAGE_PAT)] = _PAGE_CACHE_MODE_UC_MINUS,
 	[__pte2cm_idx(_PAGE_PWT | _PAGE_PCD | _PAGE_PAT)] = _PAGE_CACHE_MODE_UC,
 };
diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index 4d28759f5a1a..62171cb2b0cb 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -68,8 +68,6 @@ static int __init pat_debug_setup(char *str)
 }
 __setup("debugpat", pat_debug_setup);
 
-static u64 __read_mostly boot_pat_state;
-
 #ifdef CONFIG_X86_PAT
 /*
  * X86 PAT uses page flags WC and Uncached together to keep track of
@@ -178,6 +176,7 @@ static void pat_bsp_init(u64 pat)
 {
 	enum page_cache_mode cache;
 	char pat_msg[33];
+	u64 tmp_pat;
 	int i;
 
 	if (!cpu_has_pat) {
@@ -185,14 +184,18 @@ static void pat_bsp_init(u64 pat)
 		return;
 	}
 
-	rdmsrl(MSR_IA32_CR_PAT, boot_pat_state);
-	if (!boot_pat_state) {
+	if (!pat_enabled())
+		goto done;
+
+	rdmsrl(MSR_IA32_CR_PAT, tmp_pat);
+	if (!tmp_pat) {
 		pat_disable("PAT MSR is 0, disabled.");
 		return;
 	}
 
 	wrmsrl(MSR_IA32_CR_PAT, pat);
 
+done:
 	pat_msg[32] = 0;
 
 	/*
@@ -209,6 +212,9 @@ static void pat_bsp_init(u64 pat)
 
 static void pat_ap_init(u64 pat)
 {
+	if (!pat_enabled())
+		return;
+
 	if (!cpu_has_pat) {
 		/*
 		 * If this happens we are on a secondary CPU, but switched to
@@ -224,25 +230,45 @@ void pat_init(void)
 {
 	u64 pat;
 
-	if (!pat_enabled())
-		return;
-
-	/*
-	 * Set PWT to Write-Combining. All other bits stay the same:
-	 *
-	 * PTE encoding used in Linux:
-	 *      PAT
-	 *      |PCD
-	 *      ||PWT
-	 *      |||
-	 *      000 WB		_PAGE_CACHE_WB
-	 *      001 WC		_PAGE_CACHE_WC
-	 *      010 UC-		_PAGE_CACHE_UC_MINUS
-	 *      011 UC		_PAGE_CACHE_UC
-	 * PAT bit unused
-	 */
-	pat = PAT(0, WB) | PAT(1, WC) | PAT(2, UC_MINUS) | PAT(3, UC) |
-	      PAT(4, WB) | PAT(5, WC) | PAT(6, UC_MINUS) | PAT(7, UC);
+	if (!pat_enabled()) {
+		/*
+		 * No PAT. Emulate the PAT table that corresponds to the two
+		 * cache bits, PWT (Write Through) and PCD (Cache Disable). This
+		 * setup is the same as the BIOS default setup when the system
+		 * has PAT but the "nopat" boot option has been specified. This
+		 * emulated PAT table is used when MSR_IA32_CR_PAT returns 0.
+		 *
+		 * PTE encoding used:
+		 *
+		 *       PCD
+		 *       |PWT  PAT
+		 *       ||    slot
+		 *       00    0    WB : _PAGE_CACHE_MODE_WB
+		 *       01    1    WT : _PAGE_CACHE_MODE_WT
+		 *       10    2    UC-: _PAGE_CACHE_MODE_UC_MINUS
+		 *       11    3    UC : _PAGE_CACHE_MODE_UC
+		 *
+		 * NOTE: When WC or WP is used, it is redirected to UC- per
+		 * the default setup in __cachemode2pte_tbl[].
+		 */
+		pat = PAT(0, WB) | PAT(1, WT) | PAT(2, UC_MINUS) | PAT(3, UC) |
+		      PAT(4, WB) | PAT(5, WT) | PAT(6, UC_MINUS) | PAT(7, UC);
+	} else {
+		/*
+		 * PTE encoding used in Linux:
+		 *      PAT
+		 *      |PCD
+		 *      ||PWT
+		 *      |||
+		 *      000 WB          _PAGE_CACHE_WB
+		 *      001 WC          _PAGE_CACHE_WC
+		 *      010 UC-         _PAGE_CACHE_UC_MINUS
+		 *      011 UC          _PAGE_CACHE_UC
+		 * PAT bit unused
+		 */
+		pat = PAT(0, WB) | PAT(1, WC) | PAT(2, UC_MINUS) | PAT(3, UC) |
+		      PAT(4, WB) | PAT(5, WC) | PAT(6, UC_MINUS) | PAT(7, UC);
+	}
 
 	if (!boot_cpu_done) {
 		pat_bsp_init(pat);
-- 
2.3.5
