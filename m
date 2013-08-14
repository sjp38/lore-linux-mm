Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 252136B008A
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 06:02:52 -0400 (EDT)
Received: by mail-lb0-f181.google.com with SMTP id o10so6572806lbi.26
        for <linux-mm@kvack.org>; Wed, 14 Aug 2013 03:02:49 -0700 (PDT)
Date: Wed, 14 Aug 2013 14:02:48 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH -mm] mm: Unify pte_to_pgoff and pgoff_to_pte helpers
Message-ID: <20130814100248.GO2869@moon>
References: <20130814070059.GJ2869@moon>
 <520B303D.2090206@zytor.com>
 <20130814072453.GK2869@moon>
 <520B3240.6030208@zytor.com>
 <20130814003336.0fb2a275.akpm@linux-foundation.org>
 <20130814074333.GM2869@moon>
 <20130814010856.0098398b.akpm@linux-foundation.org>
 <20130814082000.GN2869@moon>
 <20130814095014.GA10849@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130814095014.GA10849@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@amacapital.net>, Pavel Emelyanov <xemul@parallels.com>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Peter Zijlstra <peterz@infradead.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>

On Wed, Aug 14, 2013 at 11:50:14AM +0200, Ingo Molnar wrote:
> > 
> > Well, I'll have to check if it really doesn't generate additional 
> > instructions in generated code, since it's hotpath. I'll ping back once 
> > things are done.
> 
> An __always_inline should never do that.

Here is the final one, please ping me if something looks not as clean
as it wanted to be and i'll tune code up, thanks!

To hpa@: I had to use explicit @mask because it allows to pass -1ul
mask which is optimized off then by a compiler.
---
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [PATCH -mm] mm: Unify pte_to_pgoff and pgoff_to_pte helpers

Use unified pte_bfop helper to manipulate bits in pte/pgoff bitfield,
and convert pte_to_pgoff/pgoff_to_pte to inlines.

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
---
 arch/x86/include/asm/pgtable-2level.h |   70 +++++++++++++++++++++-------------
 1 file changed, 44 insertions(+), 26 deletions(-)

Index: linux-2.6.git/arch/x86/include/asm/pgtable-2level.h
===================================================================
--- linux-2.6.git.orig/arch/x86/include/asm/pgtable-2level.h
+++ linux-2.6.git/arch/x86/include/asm/pgtable-2level.h
@@ -55,8 +55,12 @@ static inline pmd_t native_pmdp_get_and_
 #define native_pmdp_get_and_clear(xp) native_local_pmdp_get_and_clear(xp)
 #endif
 
-#define _mfrob(v,r,m,l)		((((v) >> (r)) & (m)) << (l))
-#define __frob(v,r,l)		(((v) >> (r)) << (l))
+/* Bit manipulation helper on pte/pgoff entry */
+static inline unsigned long pte_bfop(unsigned long value, unsigned int rightshift,
+				     unsigned long mask, unsigned int leftshift)
+{
+	return ((value >> rightshift) & mask) << leftshift;
+}
 
 #ifdef CONFIG_MEM_SOFT_DIRTY
 
@@ -82,19 +86,26 @@ static inline pmd_t native_pmdp_get_and_
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
-	_PAGE_FILE })
+static __always_inline pgoff_t pte_to_pgoff(pte_t pte)
+{
+	return (pgoff_t)
+		(pte_bfop(pte.pte_low, PTE_FILE_SHIFT1, PTE_FILE_MASK1,  0)		   +
+		 pte_bfop(pte.pte_low, PTE_FILE_SHIFT2, PTE_FILE_MASK2,  PTE_FILE_LSHIFT2) +
+		 pte_bfop(pte.pte_low, PTE_FILE_SHIFT3, PTE_FILE_MASK3,  PTE_FILE_LSHIFT3) +
+		 pte_bfop(pte.pte_low, PTE_FILE_SHIFT4,           -1UL,  PTE_FILE_LSHIFT4));
+}
+
+static __always_inline pte_t pgoff_to_pte(pgoff_t off)
+{
+	return (pte_t){
+		.pte_low =
+			pte_bfop(off,                0, PTE_FILE_MASK1,  PTE_FILE_SHIFT1) +
+			pte_bfop(off, PTE_FILE_LSHIFT2, PTE_FILE_MASK2,  PTE_FILE_SHIFT2) +
+			pte_bfop(off, PTE_FILE_LSHIFT3, PTE_FILE_MASK3,  PTE_FILE_SHIFT3) +
+			pte_bfop(off, PTE_FILE_LSHIFT4,           -1UL,  PTE_FILE_SHIFT4) +
+			_PAGE_FILE,
+	};
+}
 
 #else /* CONFIG_MEM_SOFT_DIRTY */
 
@@ -120,17 +131,24 @@ static inline pmd_t native_pmdp_get_and_
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
-	_PAGE_FILE })
+static __always_inline pgoff_t pte_to_pgoff(pte_t pte)
+{
+	return (pgoff_t)
+		(pte_bfop(pte.pte_low, PTE_FILE_SHIFT1, PTE_FILE_MASK1,  0)		   +
+		 pte_bfop(pte.pte_low, PTE_FILE_SHIFT2, PTE_FILE_MASK2,  PTE_FILE_LSHIFT2) +
+		 pte_bfop(pte.pte_low, PTE_FILE_SHIFT3,           -1UL,  PTE_FILE_LSHIFT3));
+}
+
+static __always_inline pte_t pgoff_to_pte(pgoff_t off)
+{
+	return (pte_t){
+		.pte_low =
+			pte_bfop(off,                0, PTE_FILE_MASK1,  PTE_FILE_SHIFT1) +
+			pte_bfop(off, PTE_FILE_LSHIFT2, PTE_FILE_MASK2,  PTE_FILE_SHIFT2) +
+			pte_bfop(off, PTE_FILE_LSHIFT3,           -1UL,  PTE_FILE_SHIFT3) +
+			_PAGE_FILE,
+	};
+}
 
 #endif /* CONFIG_MEM_SOFT_DIRTY */
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
