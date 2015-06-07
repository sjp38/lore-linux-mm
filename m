Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id CCFF46B0071
	for <linux-mm@kvack.org>; Sun,  7 Jun 2015 13:40:20 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so43007779pac.2
        for <linux-mm@kvack.org>; Sun, 07 Jun 2015 10:40:20 -0700 (PDT)
Received: from terminus.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id mq6si334072pbb.191.2015.06.07.10.40.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Jun 2015 10:40:19 -0700 (PDT)
Date: Sun, 7 Jun 2015 10:39:43 -0700
From: tip-bot for Borislav Petkov <tipbot@zytor.com>
Message-ID: <tip-9cd25aac1f44f269de5ecea11f7d927f37f1d01c@git.kernel.org>
Reply-To: mcgrof@suse.com, tglx@linutronix.de, hpa@zytor.com, bp@suse.de,
        peterz@infradead.org, jgross@suse.com, akpm@linux-foundation.org,
        toshi.kani@hp.com, torvalds@linux-foundation.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, luto@amacapital.net, mingo@kernel.org
In-Reply-To: <1433436928-31903-3-git-send-email-bp@alien8.de>
References: <1433436928-31903-3-git-send-email-bp@alien8.de>
Subject: [tip:x86/mm] x86/mm/pat: Emulate PAT when it is disabled
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: tglx@linutronix.de, hpa@zytor.com, mcgrof@suse.com, jgross@suse.com, peterz@infradead.org, bp@suse.de, akpm@linux-foundation.org, mingo@kernel.org, luto@amacapital.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, toshi.kani@hp.com

Commit-ID:  9cd25aac1f44f269de5ecea11f7d927f37f1d01c
Gitweb:     http://git.kernel.org/tip/9cd25aac1f44f269de5ecea11f7d927f37f1d01c
Author:     Borislav Petkov <bp@suse.de>
AuthorDate: Thu, 4 Jun 2015 18:55:10 +0200
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Sun, 7 Jun 2015 15:28:52 +0200

x86/mm/pat: Emulate PAT when it is disabled

In the case when PAT is disabled on the command line with
"nopat" or when virtualization doesn't support PAT (correctly) -
see

  9d34cfdf4796 ("x86: Don't rely on VMWare emulating PAT MSR correctly").

we emulate it using the PWT and PCD cache attribute bits. Get
rid of boot_pat_state while at it.

Based on a conglomerate patch from Toshi Kani.

Signed-off-by: Borislav Petkov <bp@suse.de>
Reviewed-by: Toshi Kani <toshi.kani@hp.com>
Acked-by: Juergen Gross <jgross@suse.com>
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
Cc: konrad.wilk@oracle.com
Cc: linux-mm <linux-mm@kvack.org>
Cc: linux-nvdimm@lists.01.org
Cc: stefan.bader@canonical.com
Cc: yigal@plexistor.com
Link: http://lkml.kernel.org/r/1433436928-31903-3-git-send-email-bp@alien8.de
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/x86/include/asm/pat.h |  2 +-
 arch/x86/mm/init.c         |  6 ++--
 arch/x86/mm/pat.c          | 81 ++++++++++++++++++++++++++++++----------------
 arch/x86/xen/enlighten.c   |  5 +--
 4 files changed, 60 insertions(+), 34 deletions(-)

diff --git a/arch/x86/include/asm/pat.h b/arch/x86/include/asm/pat.h
index cdcff7f..ca6c228 100644
--- a/arch/x86/include/asm/pat.h
+++ b/arch/x86/include/asm/pat.h
@@ -6,7 +6,7 @@
 
 bool pat_enabled(void);
 extern void pat_init(void);
-void pat_init_cache_modes(void);
+void pat_init_cache_modes(u64);
 
 extern int reserve_memtype(u64 start, u64 end,
 		enum page_cache_mode req_pcm, enum page_cache_mode *ret_pcm);
diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index 1d55318..8533b46 100644
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
index 476d078..6dc7826 100644
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
@@ -177,14 +175,12 @@ static enum page_cache_mode pat_get_cache_mode(unsigned pat_val, char *msg)
  * configuration.
  * Using lower indices is preferred, so we start with highest index.
  */
-void pat_init_cache_modes(void)
+void pat_init_cache_modes(u64 pat)
 {
-	int i;
 	enum page_cache_mode cache;
 	char pat_msg[33];
-	u64 pat;
+	int i;
 
-	rdmsrl(MSR_IA32_CR_PAT, pat);
 	pat_msg[32] = 0;
 	for (i = 7; i >= 0; i--) {
 		cache = pat_get_cache_mode((pat >> (i * 8)) & 7,
@@ -198,24 +194,33 @@ void pat_init_cache_modes(void)
 
 static void pat_bsp_init(u64 pat)
 {
+	u64 tmp_pat;
+
 	if (!cpu_has_pat) {
 		pat_disable("PAT not supported by CPU.");
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
 
-	pat_init_cache_modes();
+done:
+	pat_init_cache_modes(pat);
 }
 
 static void pat_ap_init(u64 pat)
 {
+	if (!pat_enabled())
+		return;
+
 	if (!cpu_has_pat) {
 		/*
 		 * If this happens we are on a secondary CPU, but switched to
@@ -231,25 +236,45 @@ void pat_init(void)
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
diff --git a/arch/x86/xen/enlighten.c b/arch/x86/xen/enlighten.c
index 46957ea..53233a9 100644
--- a/arch/x86/xen/enlighten.c
+++ b/arch/x86/xen/enlighten.c
@@ -1467,6 +1467,7 @@ asmlinkage __visible void __init xen_start_kernel(void)
 {
 	struct physdev_set_iopl set_iopl;
 	unsigned long initrd_start = 0;
+	u64 pat;
 	int rc;
 
 	if (!xen_start_info)
@@ -1574,8 +1575,8 @@ asmlinkage __visible void __init xen_start_kernel(void)
 	 * Modify the cache mode translation tables to match Xen's PAT
 	 * configuration.
 	 */
-
-	pat_init_cache_modes();
+	rdmsrl(MSR_IA32_CR_PAT, pat);
+	pat_init_cache_modes(pat);
 
 	/* keep using Xen gdt for now; no urgent need to change it */
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
