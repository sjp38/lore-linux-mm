Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 9BD7A6B0068
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 03:01:03 -0400 (EDT)
Received: by mail-la0-f54.google.com with SMTP id ea20so6540663lab.13
        for <linux-mm@kvack.org>; Wed, 14 Aug 2013 00:01:01 -0700 (PDT)
Date: Wed, 14 Aug 2013 11:00:59 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [PATCH -mm] mm: Unify pte_to_pgoff and pgoff_to_pte helpers
Message-ID: <20130814070059.GJ2869@moon>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@amacapital.net>, Pavel Emelyanov <xemul@parallels.com>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Peter Zijlstra <peterz@infradead.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>

Use unified pte_bfop helper to manipulate bits in pte/pgoff bitfield.

Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Pavel Emelyanov <xemul@parallels.com>
Cc: Matt Mackall <mpm@selenic.com>
Cc: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Marcelo Tosatti <mtosatti@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@elte.hu>
---
 arch/x86/include/asm/pgtable-2level.h |   51 ++++++++++++++++++----------------
 1 file changed, 27 insertions(+), 24 deletions(-)

Index: linux-2.6.git/arch/x86/include/asm/pgtable-2level.h
===================================================================
--- linux-2.6.git.orig/arch/x86/include/asm/pgtable-2level.h
+++ linux-2.6.git/arch/x86/include/asm/pgtable-2level.h
@@ -55,8 +55,11 @@ static inline pmd_t native_pmdp_get_and_
 #define native_pmdp_get_and_clear(xp) native_local_pmdp_get_and_clear(xp)
 #endif
 
-#define _mfrob(v,r,m,l)		((((v) >> (r)) & (m)) << (l))
-#define __frob(v,r,l)		(((v) >> (r)) << (l))
+/*
+ * For readable bitfield manipulations.
+ */
+#define PTE_FILE_NOMASK		(-1U)
+#define pte_bfop(v,r,m,l)	((((v) >> (r)) & (m)) << (l))
 
 #ifdef CONFIG_MEM_SOFT_DIRTY
 
@@ -82,18 +85,18 @@ static inline pmd_t native_pmdp_get_and_
 #define PTE_FILE_LSHIFT3	(PTE_FILE_BITS1 + PTE_FILE_BITS2)
 #define PTE_FILE_LSHIFT4	(PTE_FILE_BITS1 + PTE_FILE_BITS2 + PTE_FILE_BITS3)
 
-#define pte_to_pgoff(pte)							    \
-	(_mfrob((pte).pte_low, PTE_FILE_SHIFT1, PTE_FILE_MASK1, 0)		  + \
-	 _mfrob((pte).pte_low, PTE_FILE_SHIFT2, PTE_FILE_MASK2, PTE_FILE_LSHIFT2) + \
-	 _mfrob((pte).pte_low, PTE_FILE_SHIFT3, PTE_FILE_MASK3, PTE_FILE_LSHIFT3) + \
-	 __frob((pte).pte_low, PTE_FILE_SHIFT4, PTE_FILE_LSHIFT4))
-
-#define pgoff_to_pte(off)							\
-	((pte_t) { .pte_low =							\
-	_mfrob(off,                0, PTE_FILE_MASK1, PTE_FILE_SHIFT1)	+	\
-	_mfrob(off, PTE_FILE_LSHIFT2, PTE_FILE_MASK2, PTE_FILE_SHIFT2)	+	\
-	_mfrob(off, PTE_FILE_LSHIFT3, PTE_FILE_MASK3, PTE_FILE_SHIFT3)	+	\
-	__frob(off, PTE_FILE_LSHIFT4, PTE_FILE_SHIFT4)			+	\
+#define pte_to_pgoff(pte)								  \
+	(pte_bfop((pte).pte_low, PTE_FILE_SHIFT1, PTE_FILE_MASK1, 0)			+ \
+	 pte_bfop((pte).pte_low, PTE_FILE_SHIFT2, PTE_FILE_MASK2, PTE_FILE_LSHIFT2)	+ \
+	 pte_bfop((pte).pte_low, PTE_FILE_SHIFT3, PTE_FILE_MASK3, PTE_FILE_LSHIFT3)	+ \
+	 pte_bfop((pte).pte_low, PTE_FILE_SHIFT4, PTE_FILE_NOMASK, PTE_FILE_LSHIFT4))
+
+#define pgoff_to_pte(off)							  \
+	((pte_t) { .pte_low =							  \
+	pte_bfop(off,                0, PTE_FILE_MASK1, PTE_FILE_SHIFT1)	+ \
+	pte_bfop(off, PTE_FILE_LSHIFT2, PTE_FILE_MASK2, PTE_FILE_SHIFT2)	+ \
+	pte_bfop(off, PTE_FILE_LSHIFT3, PTE_FILE_MASK3, PTE_FILE_SHIFT3)	+ \
+	pte_bfop(off, PTE_FILE_LSHIFT4, PTE_FILE_NOMASK, PTE_FILE_SHIFT4)	+ \
 	_PAGE_FILE })
 
 #else /* CONFIG_MEM_SOFT_DIRTY */
@@ -120,16 +123,16 @@ static inline pmd_t native_pmdp_get_and_
 #define PTE_FILE_LSHIFT2	(PTE_FILE_BITS1)
 #define PTE_FILE_LSHIFT3	(PTE_FILE_BITS1 + PTE_FILE_BITS2)
 
-#define pte_to_pgoff(pte)							    \
-	(_mfrob((pte).pte_low, PTE_FILE_SHIFT1, PTE_FILE_MASK1, 0)		  + \
-	 _mfrob((pte).pte_low, PTE_FILE_SHIFT2, PTE_FILE_MASK2, PTE_FILE_LSHIFT2) + \
-	 __frob((pte).pte_low, PTE_FILE_SHIFT3, PTE_FILE_LSHIFT3))
-
-#define pgoff_to_pte(off)							\
-	((pte_t) { .pte_low =							\
-	_mfrob(off,                0, PTE_FILE_MASK1, PTE_FILE_SHIFT1)	+	\
-	_mfrob(off, PTE_FILE_LSHIFT2, PTE_FILE_MASK2, PTE_FILE_SHIFT2)	+	\
-	__frob(off, PTE_FILE_LSHIFT3, PTE_FILE_SHIFT3)			+	\
+#define pte_to_pgoff(pte)								  \
+	(pte_bfop((pte).pte_low, PTE_FILE_SHIFT1, PTE_FILE_MASK1, 0)			+ \
+	 pte_bfop((pte).pte_low, PTE_FILE_SHIFT2, PTE_FILE_MASK2, PTE_FILE_LSHIFT2)	+ \
+	 pte_bfop((pte).pte_low, PTE_FILE_SHIFT3, PTE_FILE_NOMASK, PTE_FILE_LSHIFT3))
+
+#define pgoff_to_pte(off)							  \
+	((pte_t) { .pte_low =							  \
+	pte_bfop(off,                0, PTE_FILE_MASK1, PTE_FILE_SHIFT1)	+ \
+	pte_bfop(off, PTE_FILE_LSHIFT2, PTE_FILE_MASK2, PTE_FILE_SHIFT2)	+ \
+	pte_bfop(off, PTE_FILE_LSHIFT3, PTE_FILE_NOMASK, PTE_FILE_SHIFT3)	+ \
 	_PAGE_FILE })
 
 #endif /* CONFIG_MEM_SOFT_DIRTY */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
