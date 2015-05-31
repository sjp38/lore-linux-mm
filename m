From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH 2/4] x86/pat: Merge pat_init_cache_modes() into its caller
Date: Sun, 31 May 2015 12:23:38 +0200
Message-ID: <20150531102338.GB20440@pd.tnic>
References: <20150531094655.GA20440@pd.tnic>
 <1433065686-20922-1-git-send-email-bp@alien8.de>
 <1433065686-20922-2-git-send-email-bp@alien8.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1433065686-20922-2-git-send-email-bp@alien8.de>
Sender: linux-kernel-owner@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, arnd@arndb.de, Elliott@hp.com, hch@lst.de, hmh@hmh.eng.br, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, jgross@suse.com, konrad.wilk@oracle.com, linux-mm <linux-mm@kvack.org>, linux-nvdimm@lists.01.org, "Luis R. Rodriguez" <mcgrof@suse.com>, stefan.bader@canonical.com, Thomas Gleixner <tglx@linutronix.de>, Toshi Kani <toshi.kani@hp.com>, x86-ml <x86@kernel.org>, yigal@plexistor.com, lkml <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

On Sun, May 31, 2015 at 11:48:04AM +0200, Borislav Petkov wrote:
> From: Borislav Petkov <bp@suse.de>
>=20
> This way we can pass pat MSR value directly.

This breaks xen as that function is used there, doh. :-\

J=C3=BCrgen,

can you check the enlighten.c changes below please?

I'm reading xen's PAT config from MSR_IA32_CR_PAT and handing it down t=
o
pat_init_cache_modes(). That shouldn't change current behavior AFAICT
because pat_init_cache_modes() did it itself before.

Right?

Thanks.

---
Author: Borislav Petkov <bp@suse.de>
Date:   Sat May 30 13:09:55 2015 +0200

    x86/pat: Emulate PAT when it is disabled
   =20
    In the case when PAT is disabled on the command line with "nopat" o=
r
    when virtualization doesn't support PAT (correctly) - see
   =20
      9d34cfdf4796 ("x86: Don't rely on VMWare emulating PAT MSR correc=
tly").
   =20
    we emulate it using the PWT and PCD cache attribute bits. Get rid o=
f
    boot_pat_state while at it.
   =20
    Based on a conglomerate patch from Toshi Kani.
   =20
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

diff --git a/arch/x86/include/asm/pat.h b/arch/x86/include/asm/pat.h
index cdcff7f7f694..ca6c228d5e62 100644
--- a/arch/x86/include/asm/pat.h
+++ b/arch/x86/include/asm/pat.h
@@ -6,7 +6,7 @@
=20
 bool pat_enabled(void);
 extern void pat_init(void);
-void pat_init_cache_modes(void);
+void pat_init_cache_modes(u64);
=20
 extern int reserve_memtype(u64 start, u64 end,
 		enum page_cache_mode req_pcm, enum page_cache_mode *ret_pcm);
diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index 1d553186c434..8533b46e6bee 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -40,7 +40,7 @@
  */
 uint16_t __cachemode2pte_tbl[_PAGE_CACHE_MODE_NUM] =3D {
 	[_PAGE_CACHE_MODE_WB      ]	=3D 0         | 0        ,
-	[_PAGE_CACHE_MODE_WC      ]	=3D _PAGE_PWT | 0        ,
+	[_PAGE_CACHE_MODE_WC      ]	=3D 0         | _PAGE_PCD,
 	[_PAGE_CACHE_MODE_UC_MINUS]	=3D 0         | _PAGE_PCD,
 	[_PAGE_CACHE_MODE_UC      ]	=3D _PAGE_PWT | _PAGE_PCD,
 	[_PAGE_CACHE_MODE_WT      ]	=3D 0         | _PAGE_PCD,
@@ -50,11 +50,11 @@ EXPORT_SYMBOL(__cachemode2pte_tbl);
=20
 uint8_t __pte2cachemode_tbl[8] =3D {
 	[__pte2cm_idx( 0        | 0         | 0        )] =3D _PAGE_CACHE_MOD=
E_WB,
-	[__pte2cm_idx(_PAGE_PWT | 0         | 0        )] =3D _PAGE_CACHE_MOD=
E_WC,
+	[__pte2cm_idx(_PAGE_PWT | 0         | 0        )] =3D _PAGE_CACHE_MOD=
E_UC_MINUS,
 	[__pte2cm_idx( 0        | _PAGE_PCD | 0        )] =3D _PAGE_CACHE_MOD=
E_UC_MINUS,
 	[__pte2cm_idx(_PAGE_PWT | _PAGE_PCD | 0        )] =3D _PAGE_CACHE_MOD=
E_UC,
 	[__pte2cm_idx( 0        | 0         | _PAGE_PAT)] =3D _PAGE_CACHE_MOD=
E_WB,
-	[__pte2cm_idx(_PAGE_PWT | 0         | _PAGE_PAT)] =3D _PAGE_CACHE_MOD=
E_WC,
+	[__pte2cm_idx(_PAGE_PWT | 0         | _PAGE_PAT)] =3D _PAGE_CACHE_MOD=
E_UC_MINUS,
 	[__pte2cm_idx(0         | _PAGE_PCD | _PAGE_PAT)] =3D _PAGE_CACHE_MOD=
E_UC_MINUS,
 	[__pte2cm_idx(_PAGE_PWT | _PAGE_PCD | _PAGE_PAT)] =3D _PAGE_CACHE_MOD=
E_UC,
 };
diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index 476d0780560f..6dc7826e4797 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -68,8 +68,6 @@ static int __init pat_debug_setup(char *str)
 }
 __setup("debugpat", pat_debug_setup);
=20
-static u64 __read_mostly boot_pat_state;
-
 #ifdef CONFIG_X86_PAT
 /*
  * X86 PAT uses page flags WC and Uncached together to keep track of
@@ -177,14 +175,12 @@ static enum page_cache_mode pat_get_cache_mode(un=
signed pat_val, char *msg)
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
=20
-	rdmsrl(MSR_IA32_CR_PAT, pat);
 	pat_msg[32] =3D 0;
 	for (i =3D 7; i >=3D 0; i--) {
 		cache =3D pat_get_cache_mode((pat >> (i * 8)) & 7,
@@ -198,24 +194,33 @@ void pat_init_cache_modes(void)
=20
 static void pat_bsp_init(u64 pat)
 {
+	u64 tmp_pat;
+
 	if (!cpu_has_pat) {
 		pat_disable("PAT not supported by CPU.");
 		return;
 	}
=20
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
=20
 	wrmsrl(MSR_IA32_CR_PAT, pat);
=20
-	pat_init_cache_modes();
+done:
+	pat_init_cache_modes(pat);
 }
=20
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
=20
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
-	pat =3D PAT(0, WB) | PAT(1, WC) | PAT(2, UC_MINUS) | PAT(3, UC) |
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
+		pat =3D PAT(0, WB) | PAT(1, WT) | PAT(2, UC_MINUS) | PAT(3, UC) |
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
+		pat =3D PAT(0, WB) | PAT(1, WC) | PAT(2, UC_MINUS) | PAT(3, UC) |
+		      PAT(4, WB) | PAT(5, WC) | PAT(6, UC_MINUS) | PAT(7, UC);
+	}
=20
 	if (!boot_cpu_done) {
 		pat_bsp_init(pat);
diff --git a/arch/x86/xen/enlighten.c b/arch/x86/xen/enlighten.c
index 46957ead3060..53233a9beea9 100644
--- a/arch/x86/xen/enlighten.c
+++ b/arch/x86/xen/enlighten.c
@@ -1467,6 +1467,7 @@ asmlinkage __visible void __init xen_start_kernel=
(void)
 {
 	struct physdev_set_iopl set_iopl;
 	unsigned long initrd_start =3D 0;
+	u64 pat;
 	int rc;
=20
 	if (!xen_start_info)
@@ -1574,8 +1575,8 @@ asmlinkage __visible void __init xen_start_kernel=
(void)
 	 * Modify the cache mode translation tables to match Xen's PAT
 	 * configuration.
 	 */
-
-	pat_init_cache_modes();
+	rdmsrl(MSR_IA32_CR_PAT, pat);
+	pat_init_cache_modes(pat);
=20
 	/* keep using Xen gdt for now; no urgent need to change it */
=20


--=20
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
--
