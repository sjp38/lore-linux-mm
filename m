Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4BE9F6B03BB
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 09:47:46 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 6so16506045pfd.6
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 06:47:46 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id m124si1973413pgm.123.2017.02.28.06.47.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 06:47:44 -0800 (PST)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v1 1/3] sparc64: NG4 memset/memcpy 32 bits overflow
Date: Tue, 28 Feb 2017 09:55:44 -0500
Message-Id: <1488293746-965735-2-git-send-email-pasha.tatashin@oracle.com>
In-Reply-To: <1488293746-965735-1-git-send-email-pasha.tatashin@oracle.com>
References: <1488293746-965735-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, sparclinux@vger.kernel.org

Early in boot Linux patches memset and memcpy to branch to platform
optimized versions of these routines. The NG4 (Niagra 4) versions are
currently used on  all platforms starting from T4. Recently, there were M7
optimized routines added into UEK4 but not into mainline yet. So, even with
M7 optimized routines NG4 are still going to be used on T4, T5, M5, and M6
processors.

While investigating how to improve initialization time of dentry_hashtable
which is 8G long on M6 ldom with 7T of main memory, I noticed that memset()
does not reset all the memory in this array, after studying the code, I
realized that NG4memset() branches use %icc register instead of %xcc to
check compare, so if value of length is over 32-bit long, which is true for
8G array, these routines fail to work properly.

The fix is to replace all %icc with %xcc in these routines. (Alternative is
to use %ncc, but this is misleading, as the code already has sparcv9 only
instructions, and cannot be compiled on 32-bit).

This is important to fix this bug, because even older T4-4 can have 2T of
memory, and there are large memory proportional data structures in kernel
which can be larger than 4G in size. The failing of memset() is silent and
corruption is hard to detect.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Reviewed-by: Babu Moger <babu.moger@oracle.com>
---
 arch/sparc/lib/NG4memcpy.S |   71 ++++++++++++++++++++------------------------
 arch/sparc/lib/NG4memset.S |   26 ++++++++--------
 2 files changed, 45 insertions(+), 52 deletions(-)

diff --git a/arch/sparc/lib/NG4memcpy.S b/arch/sparc/lib/NG4memcpy.S
index 75bb93b..60ccb46 100644
--- a/arch/sparc/lib/NG4memcpy.S
+++ b/arch/sparc/lib/NG4memcpy.S
@@ -18,7 +18,7 @@
 #define FPU_ENTER			\
 	rd	%fprs, %o5;		\
 	andcc	%o5, FPRS_FEF, %g0;	\
-	be,a,pn	%icc, 999f;		\
+	be,a,pn	%xcc, 999f;		\
 	 wr	%g0, FPRS_FEF, %fprs;	\
 	999:
 
@@ -84,10 +84,6 @@
 #define PREAMBLE
 #endif
 
-#ifndef XCC
-#define XCC xcc
-#endif
-
 	.register	%g2,#scratch
 	.register	%g3,#scratch
 
@@ -252,19 +248,16 @@ FUNC_NAME:	/* %o0=dst, %o1=src, %o2=len */
 #ifdef MEMCPY_DEBUG
 	wr		%g0, 0x80, %asi
 #endif
-	srlx		%o2, 31, %g2
-	cmp		%g2, 0
-	tne		%XCC, 5
 	PREAMBLE
 	mov		%o0, %o3
 	brz,pn		%o2, .Lexit
 	 cmp		%o2, 3
-	ble,pn		%icc, .Ltiny
+	ble,pn		%xcc, .Ltiny
 	 cmp		%o2, 19
-	ble,pn		%icc, .Lsmall
+	ble,pn		%xcc, .Lsmall
 	 or		%o0, %o1, %g2
 	cmp		%o2, 128
-	bl,pn		%icc, .Lmedium
+	bl,pn		%xcc, .Lmedium
 	 nop
 
 .Llarge:/* len >= 0x80 */
@@ -279,7 +272,7 @@ FUNC_NAME:	/* %o0=dst, %o1=src, %o2=len */
 	add		%o1, 1, %o1
 	subcc		%g1, 1, %g1
 	add		%o0, 1, %o0
-	bne,pt		%icc, 1b
+	bne,pt		%xcc, 1b
 	 EX_ST(STORE(stb, %g2, %o0 - 0x01), NG4_retl_o2_plus_g1_plus_1)
 
 51:	LOAD(prefetch, %o1 + 0x040, #n_reads_strong)
@@ -295,7 +288,7 @@ FUNC_NAME:	/* %o0=dst, %o1=src, %o2=len */
 	 * loop, or we require the alignaddr/faligndata variant.
 	 */
 	andcc		%o1, 0x7, %o5
-	bne,pn		%icc, .Llarge_src_unaligned
+	bne,pn		%xcc, .Llarge_src_unaligned
 	 sub		%g0, %o0, %g1
 
 	/* Legitimize the use of initializing stores by getting dest
@@ -309,7 +302,7 @@ FUNC_NAME:	/* %o0=dst, %o1=src, %o2=len */
 	add		%o1, 8, %o1
 	subcc		%g1, 8, %g1
 	add		%o0, 8, %o0
-	bne,pt		%icc, 1b
+	bne,pt		%xcc, 1b
 	 EX_ST(STORE(stx, %g2, %o0 - 0x08), NG4_retl_o2_plus_g1_plus_8)
 
 .Llarge_aligned:
@@ -343,16 +336,16 @@ FUNC_NAME:	/* %o0=dst, %o1=src, %o2=len */
 	add		%o0, 0x08, %o0
 	EX_ST(STORE_INIT(GLOBAL_SPARE, %o0), NG4_retl_o2_plus_o4_plus_8)
 	add		%o0, 0x08, %o0
-	bne,pt		%icc, 1b
+	bne,pt		%xcc, 1b
 	 LOAD(prefetch, %o1 + 0x200, #n_reads_strong)
 
 	membar		#StoreLoad | #StoreStore
 
 	brz,pn		%o2, .Lexit
 	 cmp		%o2, 19
-	ble,pn		%icc, .Lsmall_unaligned
+	ble,pn		%xcc, .Lsmall_unaligned
 	 nop
-	ba,a,pt		%icc, .Lmedium_noprefetch
+	ba,a,pt		%xcc, .Lmedium_noprefetch
 
 .Lexit:	retl
 	 mov		EX_RETVAL(%o3), %o0
@@ -395,7 +388,7 @@ FUNC_NAME:	/* %o0=dst, %o1=src, %o2=len */
 	EX_ST_FP(STORE(std, %f28, %o0 + 0x30), NG4_retl_o2_plus_o4_plus_16)
 	EX_ST_FP(STORE(std, %f30, %o0 + 0x38), NG4_retl_o2_plus_o4_plus_8)
 	add		%o0, 0x40, %o0
-	bne,pt		%icc, 1b
+	bne,pt		%xcc, 1b
 	 LOAD(prefetch, %g1 + 0x200, #n_reads_strong)
 #ifdef NON_USER_COPY
 	VISExitHalfFast
@@ -404,9 +397,9 @@ FUNC_NAME:	/* %o0=dst, %o1=src, %o2=len */
 #endif
 	brz,pn		%o2, .Lexit
 	 cmp		%o2, 19
-	ble,pn		%icc, .Lsmall_unaligned
+	ble,pn		%xcc, .Lsmall_unaligned
 	 nop
-	ba,a,pt		%icc, .Lmedium_unaligned
+	ba,a,pt		%xcc, .Lmedium_unaligned
 
 #ifdef NON_USER_COPY
 .Lmedium_vis_entry_fail:
@@ -415,11 +408,11 @@ FUNC_NAME:	/* %o0=dst, %o1=src, %o2=len */
 .Lmedium:
 	LOAD(prefetch, %o1 + 0x40, #n_reads_strong)
 	andcc		%g2, 0x7, %g0
-	bne,pn		%icc, .Lmedium_unaligned
+	bne,pn		%xcc, .Lmedium_unaligned
 	 nop
 .Lmedium_noprefetch:
 	andncc		%o2, 0x20 - 1, %o5
-	be,pn		%icc, 2f
+	be,pn		%xcc, 2f
 	 sub		%o2, %o5, %o2
 1:	EX_LD(LOAD(ldx, %o1 + 0x00, %g1), NG4_retl_o2_plus_o5)
 	EX_LD(LOAD(ldx, %o1 + 0x08, %g2), NG4_retl_o2_plus_o5)
@@ -431,29 +424,29 @@ FUNC_NAME:	/* %o0=dst, %o1=src, %o2=len */
 	EX_ST(STORE(stx, %g2, %o0 + 0x08), NG4_retl_o2_plus_o5_plus_24)
 	EX_ST(STORE(stx, GLOBAL_SPARE, %o0 + 0x10), NG4_retl_o2_plus_o5_plus_24)
 	EX_ST(STORE(stx, %o4, %o0 + 0x18), NG4_retl_o2_plus_o5_plus_8)
-	bne,pt		%icc, 1b
+	bne,pt		%xcc, 1b
 	 add		%o0, 0x20, %o0
 2:	andcc		%o2, 0x18, %o5
-	be,pt		%icc, 3f
+	be,pt		%xcc, 3f
 	 sub		%o2, %o5, %o2
 
 1:	EX_LD(LOAD(ldx, %o1 + 0x00, %g1), NG4_retl_o2_plus_o5)
 	add		%o1, 0x08, %o1
 	add		%o0, 0x08, %o0
 	subcc		%o5, 0x08, %o5
-	bne,pt		%icc, 1b
+	bne,pt		%xcc, 1b
 	 EX_ST(STORE(stx, %g1, %o0 - 0x08), NG4_retl_o2_plus_o5_plus_8)
 3:	brz,pt		%o2, .Lexit
 	 cmp		%o2, 0x04
-	bl,pn		%icc, .Ltiny
+	bl,pn		%xcc, .Ltiny
 	 nop
 	EX_LD(LOAD(lduw, %o1 + 0x00, %g1), NG4_retl_o2)
 	add		%o1, 0x04, %o1
 	add		%o0, 0x04, %o0
 	subcc		%o2, 0x04, %o2
-	bne,pn		%icc, .Ltiny
+	bne,pn		%xcc, .Ltiny
 	 EX_ST(STORE(stw, %g1, %o0 - 0x04), NG4_retl_o2_plus_4)
-	ba,a,pt		%icc, .Lexit
+	ba,a,pt		%xcc, .Lexit
 .Lmedium_unaligned:
 	/* First get dest 8 byte aligned.  */
 	sub		%g0, %o0, %g1
@@ -465,7 +458,7 @@ FUNC_NAME:	/* %o0=dst, %o1=src, %o2=len */
 	add		%o1, 1, %o1
 	subcc		%g1, 1, %g1
 	add		%o0, 1, %o0
-	bne,pt		%icc, 1b
+	bne,pt		%xcc, 1b
 	 EX_ST(STORE(stb, %g2, %o0 - 0x01), NG4_retl_o2_plus_g1_plus_1)
 2:
 	and		%o1, 0x7, %g1
@@ -485,30 +478,30 @@ FUNC_NAME:	/* %o0=dst, %o1=src, %o2=len */
 	or		GLOBAL_SPARE, %o4, GLOBAL_SPARE
 	EX_ST(STORE(stx, GLOBAL_SPARE, %o0 + 0x00), NG4_retl_o2_plus_o5_plus_8)
 	add		%o0, 0x08, %o0
-	bne,pt		%icc, 1b
+	bne,pt		%xcc, 1b
 	 sllx		%g3, %g1, %o4
 	srl		%g1, 3, %g1
 	add		%o1, %g1, %o1
 	brz,pn		%o2, .Lexit
 	 nop
-	ba,pt		%icc, .Lsmall_unaligned
+	ba,pt		%xcc, .Lsmall_unaligned
 
 .Ltiny:
 	EX_LD(LOAD(ldub, %o1 + 0x00, %g1), NG4_retl_o2)
 	subcc		%o2, 1, %o2
-	be,pn		%icc, .Lexit
+	be,pn		%xcc, .Lexit
 	 EX_ST(STORE(stb, %g1, %o0 + 0x00), NG4_retl_o2_plus_1)
 	EX_LD(LOAD(ldub, %o1 + 0x01, %g1), NG4_retl_o2)
 	subcc		%o2, 1, %o2
-	be,pn		%icc, .Lexit
+	be,pn		%xcc, .Lexit
 	 EX_ST(STORE(stb, %g1, %o0 + 0x01), NG4_retl_o2_plus_1)
 	EX_LD(LOAD(ldub, %o1 + 0x02, %g1), NG4_retl_o2)
-	ba,pt		%icc, .Lexit
+	ba,pt		%xcc, .Lexit
 	 EX_ST(STORE(stb, %g1, %o0 + 0x02), NG4_retl_o2)
 
 .Lsmall:
 	andcc		%g2, 0x3, %g0
-	bne,pn		%icc, .Lsmall_unaligned
+	bne,pn		%xcc, .Lsmall_unaligned
 	 andn		%o2, 0x4 - 1, %o5
 	sub		%o2, %o5, %o2
 1:
@@ -516,18 +509,18 @@ FUNC_NAME:	/* %o0=dst, %o1=src, %o2=len */
 	add		%o1, 0x04, %o1
 	subcc		%o5, 0x04, %o5
 	add		%o0, 0x04, %o0
-	bne,pt		%icc, 1b
+	bne,pt		%xcc, 1b
 	 EX_ST(STORE(stw, %g1, %o0 - 0x04), NG4_retl_o2_plus_o5_plus_4)
 	brz,pt		%o2, .Lexit
 	 nop
-	ba,a,pt		%icc, .Ltiny
+	ba,a,pt		%xcc, .Ltiny
 
 .Lsmall_unaligned:
 1:	EX_LD(LOAD(ldub, %o1 + 0x00, %g1), NG4_retl_o2)
 	add		%o1, 1, %o1
 	add		%o0, 1, %o0
 	subcc		%o2, 1, %o2
-	bne,pt		%icc, 1b
+	bne,pt		%xcc, 1b
 	 EX_ST(STORE(stb, %g1, %o0 - 0x01), NG4_retl_o2_plus_1)
-	ba,a,pt		%icc, .Lexit
+	ba,a,pt		%xcc, .Lexit
 	.size		FUNC_NAME, .-FUNC_NAME
diff --git a/arch/sparc/lib/NG4memset.S b/arch/sparc/lib/NG4memset.S
index 41da4bd..e7c2e70 100644
--- a/arch/sparc/lib/NG4memset.S
+++ b/arch/sparc/lib/NG4memset.S
@@ -13,14 +13,14 @@
 	.globl		NG4memset
 NG4memset:
 	andcc		%o1, 0xff, %o4
-	be,pt		%icc, 1f
+	be,pt		%xcc, 1f
 	 mov		%o2, %o1
 	sllx		%o4, 8, %g1
 	or		%g1, %o4, %o2
 	sllx		%o2, 16, %g1
 	or		%g1, %o2, %o2
 	sllx		%o2, 32, %g1
-	ba,pt		%icc, 1f
+	ba,pt		%xcc, 1f
 	 or		%g1, %o2, %o4
 	.size		NG4memset,.-NG4memset
 
@@ -29,7 +29,7 @@ NG4memset:
 NG4bzero:
 	clr		%o4
 1:	cmp		%o1, 16
-	ble		%icc, .Ltiny
+	ble		%xcc, .Ltiny
 	 mov		%o0, %o3
 	sub		%g0, %o0, %g1
 	and		%g1, 0x7, %g1
@@ -37,7 +37,7 @@ NG4bzero:
 	 sub		%o1, %g1, %o1
 1:	stb		%o4, [%o0 + 0x00]
 	subcc		%g1, 1, %g1
-	bne,pt		%icc, 1b
+	bne,pt		%xcc, 1b
 	 add		%o0, 1, %o0
 .Laligned8:
 	cmp		%o1, 64 + (64 - 8)
@@ -48,7 +48,7 @@ NG4bzero:
 	 sub		%o1, %g1, %o1
 1:	stx		%o4, [%o0 + 0x00]
 	subcc		%g1, 8, %g1
-	bne,pt		%icc, 1b
+	bne,pt		%xcc, 1b
 	 add		%o0, 0x8, %o0
 .Laligned64:
 	andn		%o1, 64 - 1, %g1
@@ -58,30 +58,30 @@ NG4bzero:
 1:	stxa		%o4, [%o0 + %g0] ASI_BLK_INIT_QUAD_LDD_P
 	subcc		%g1, 0x40, %g1
 	stxa		%o4, [%o0 + %g2] ASI_BLK_INIT_QUAD_LDD_P
-	bne,pt		%icc, 1b
+	bne,pt		%xcc, 1b
 	 add		%o0, 0x40, %o0
 .Lpostloop:
 	cmp		%o1, 8
-	bl,pn		%icc, .Ltiny
+	bl,pn		%xcc, .Ltiny
 	 membar		#StoreStore|#StoreLoad
 .Lmedium:
 	andn		%o1, 0x7, %g1
 	sub		%o1, %g1, %o1
 1:	stx		%o4, [%o0 + 0x00]
 	subcc		%g1, 0x8, %g1
-	bne,pt		%icc, 1b
+	bne,pt		%xcc, 1b
 	 add		%o0, 0x08, %o0
 	andcc		%o1, 0x4, %g1
-	be,pt		%icc, .Ltiny
+	be,pt		%xcc, .Ltiny
 	 sub		%o1, %g1, %o1
 	stw		%o4, [%o0 + 0x00]
 	add		%o0, 0x4, %o0
 .Ltiny:
 	cmp		%o1, 0
-	be,pn		%icc, .Lexit
+	be,pn		%xcc, .Lexit
 1:	 subcc		%o1, 1, %o1
 	stb		%o4, [%o0 + 0x00]
-	bne,pt		%icc, 1b
+	bne,pt		%xcc, 1b
 	 add		%o0, 1, %o0
 .Lexit:
 	retl
@@ -99,7 +99,7 @@ NG4bzero:
 	stxa		%o4, [%o0 + %g2] ASI_BLK_INIT_QUAD_LDD_P
 	stxa		%o4, [%o0 + %g3] ASI_BLK_INIT_QUAD_LDD_P
 	stxa		%o4, [%o0 + %o5] ASI_BLK_INIT_QUAD_LDD_P
-	bne,pt		%icc, 1b
+	bne,pt		%xcc, 1b
 	 add		%o0, 0x30, %o0
-	ba,a,pt		%icc, .Lpostloop
+	ba,a,pt		%xcc, .Lpostloop
 	.size		NG4bzero,.-NG4bzero
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
