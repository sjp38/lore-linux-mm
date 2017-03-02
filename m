Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E56E16B0038
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 00:25:45 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id x63so4623205pfx.7
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 21:25:45 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id a74si6509343pfe.100.2017.03.01.21.25.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Mar 2017 21:25:45 -0800 (PST)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v3 1/4] sparc64: NG4 memset 32 bits overflow
Date: Thu,  2 Mar 2017 00:33:42 -0500
Message-Id: <1488432825-92126-2-git-send-email-pasha.tatashin@oracle.com>
In-Reply-To: <1488432825-92126-1-git-send-email-pasha.tatashin@oracle.com>
References: <1488432825-92126-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-fsdevel@vger.kernel.org

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
 arch/sparc/lib/NG4memset.S |   26 +++++++++++++-------------
 1 files changed, 13 insertions(+), 13 deletions(-)

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
