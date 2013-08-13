Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 067676B0034
	for <linux-mm@kvack.org>; Tue, 13 Aug 2013 17:29:00 -0400 (EDT)
Received: by mail-lb0-f179.google.com with SMTP id v1so6216801lbd.38
        for <linux-mm@kvack.org>; Tue, 13 Aug 2013 14:28:59 -0700 (PDT)
Date: Wed, 14 Aug 2013 01:28:57 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [patch 2/2] [PATCH] mm: Save soft-dirty bits on file pages
Message-ID: <20130813212857.GI2869@moon>
References: <20130730204154.407090410@gmail.com>
 <20130730204654.966378702@gmail.com>
 <20130807132812.60ad4bfe85127794094d385e@linux-foundation.org>
 <20130808145120.GA1775@moon>
 <20130812145720.3b722b066fe1bd77291331e5@linux-foundation.org>
 <CALCETrUXOoKrOAXhvd=GcK3YpBNWr2rk2ArBBgekXDv9yj7sNg@mail.gmail.com>
 <20130813050213.GA2869@moon>
 <520A4D5F.6020401@zytor.com>
 <20130813153703.GE2869@moon>
 <520A622B.7020900@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <520A622B.7020900@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, xemul@parallels.com, mpm@selenic.com, xiaoguangrong@linux.vnet.ibm.com, mtosatti@redhat.com, kosaki.motohiro@gmail.com, sfr@canb.auug.org.au, peterz@infradead.org, aneesh.kumar@linux.vnet.ibm.com, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>

On Tue, Aug 13, 2013 at 09:43:23AM -0700, H. Peter Anvin wrote:
> On 08/13/2013 08:37 AM, Cyrill Gorcunov wrote:
> >>
> >> Does it actually matter, generated-code-wise, or is the compiler smart
> >> enough to figure it out?  The reason I'm asking is because it makes the
> > 
> > gcc-4.7.2 is smart enough to suppress useless masking (ie ((1u << 31) - 1))
> > completely but I don't know if this can be assumed for all gcc series.
> > 
> 
> I would be highly surprised if it wasn't the case for any gcc we care about.

Does below one looks better? (Btw, what about the snippet we have there as well

#if _PAGE_BIT_FILE < _PAGE_BIT_PROTNONE
#define PTE_FILE_SHIFT2		(_PAGE_BIT_FILE + 1)
#define PTE_FILE_SHIFT3		(_PAGE_BIT_PROTNONE + 1)
#else
#define PTE_FILE_SHIFT2		(_PAGE_BIT_PROTNONE + 1)
#define PTE_FILE_SHIFT3		(_PAGE_BIT_FILE + 1)
#endif

where

#define _PAGE_BIT_PROTNONE	_PAGE_BIT_GLOBAL	-> 8
#define _PAGE_BIT_FILE		_PAGE_BIT_DIRTY		-> 6

so I wonder where the cases on x86 when _PAGE_BIT_FILE > _PAGE_BIT_PROTNONE,
what i'm missing here?)

---
 arch/x86/include/asm/pgtable-2level.h |   37 +++++++++++++++++++---------------
 1 file changed, 21 insertions(+), 16 deletions(-)

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
+#define __bfop(v,r,m,l)		((((v) >> (r)) & (m)) << (l))
 
 #ifdef CONFIG_MEM_SOFT_DIRTY
 
@@ -83,17 +86,17 @@ static inline pmd_t native_pmdp_get_and_
 #define PTE_FILE_LSHIFT4	(PTE_FILE_BITS1 + PTE_FILE_BITS2 + PTE_FILE_BITS3)
 
 #define pte_to_pgoff(pte)							    \
-	(_mfrob((pte).pte_low, PTE_FILE_SHIFT1, PTE_FILE_MASK1, 0)		  + \
-	 _mfrob((pte).pte_low, PTE_FILE_SHIFT2, PTE_FILE_MASK2, PTE_FILE_LSHIFT2) + \
-	 _mfrob((pte).pte_low, PTE_FILE_SHIFT3, PTE_FILE_MASK3, PTE_FILE_LSHIFT3) + \
-	 __frob((pte).pte_low, PTE_FILE_SHIFT4, PTE_FILE_LSHIFT4))
+	(__bfop((pte).pte_low, PTE_FILE_SHIFT1, PTE_FILE_MASK1, 0)		  + \
+	 __bfop((pte).pte_low, PTE_FILE_SHIFT2, PTE_FILE_MASK2, PTE_FILE_LSHIFT2) + \
+	 __bfop((pte).pte_low, PTE_FILE_SHIFT3, PTE_FILE_MASK3, PTE_FILE_LSHIFT3) + \
+	 __bfop((pte).pte_low, PTE_FILE_SHIFT4, PTE_FILE_NOMASK, PTE_FILE_LSHIFT4))
 
 #define pgoff_to_pte(off)							\
 	((pte_t) { .pte_low =							\
-	_mfrob(off,                0, PTE_FILE_MASK1, PTE_FILE_SHIFT1)	+	\
-	_mfrob(off, PTE_FILE_LSHIFT2, PTE_FILE_MASK2, PTE_FILE_SHIFT2)	+	\
-	_mfrob(off, PTE_FILE_LSHIFT3, PTE_FILE_MASK3, PTE_FILE_SHIFT3)	+	\
-	__frob(off, PTE_FILE_LSHIFT4, PTE_FILE_SHIFT4)			+	\
+	__bfop(off,                0, PTE_FILE_MASK1, PTE_FILE_SHIFT1)	+	\
+	__bfop(off, PTE_FILE_LSHIFT2, PTE_FILE_MASK2, PTE_FILE_SHIFT2)	+	\
+	__bfop(off, PTE_FILE_LSHIFT3, PTE_FILE_MASK3, PTE_FILE_SHIFT3)	+	\
+	__bfop(off, PTE_FILE_LSHIFT4, PTE_FILE_NOMASK, PTE_FILE_SHIFT4)	+	\
 	_PAGE_FILE })
 
 #else /* CONFIG_MEM_SOFT_DIRTY */
@@ -121,19 +124,21 @@ static inline pmd_t native_pmdp_get_and_
 #define PTE_FILE_LSHIFT3	(PTE_FILE_BITS1 + PTE_FILE_BITS2)
 
 #define pte_to_pgoff(pte)							    \
-	(_mfrob((pte).pte_low, PTE_FILE_SHIFT1, PTE_FILE_MASK1, 0)		  + \
-	 _mfrob((pte).pte_low, PTE_FILE_SHIFT2, PTE_FILE_MASK2, PTE_FILE_LSHIFT2) + \
-	 __frob((pte).pte_low, PTE_FILE_SHIFT3, PTE_FILE_LSHIFT3))
+	(__bfop((pte).pte_low, PTE_FILE_SHIFT1, PTE_FILE_MASK1, 0)		  + \
+	 __bfop((pte).pte_low, PTE_FILE_SHIFT2, PTE_FILE_MASK2, PTE_FILE_LSHIFT2) + \
+	 __bfop((pte).pte_low, PTE_FILE_SHIFT3, PTE_FILE_NOMASK, PTE_FILE_LSHIFT3))
 
 #define pgoff_to_pte(off)							\
 	((pte_t) { .pte_low =							\
-	_mfrob(off,                0, PTE_FILE_MASK1, PTE_FILE_SHIFT1)	+	\
-	_mfrob(off, PTE_FILE_LSHIFT2, PTE_FILE_MASK2, PTE_FILE_SHIFT2)	+	\
-	__frob(off, PTE_FILE_LSHIFT3, PTE_FILE_SHIFT3)			+	\
+	__bfop(off,                0, PTE_FILE_MASK1, PTE_FILE_SHIFT1)	+	\
+	__bfop(off, PTE_FILE_LSHIFT2, PTE_FILE_MASK2, PTE_FILE_SHIFT2)	+	\
+	__bfop(off, PTE_FILE_LSHIFT3, PTE_FILE_NOMASK, PTE_FILE_SHIFT3)	+	\
 	_PAGE_FILE })
 
 #endif /* CONFIG_MEM_SOFT_DIRTY */
 
+#undef __bfop
+
 /* Encode and de-code a swap entry */
 #if _PAGE_BIT_FILE < _PAGE_BIT_PROTNONE
 #define SWP_TYPE_BITS (_PAGE_BIT_FILE - _PAGE_BIT_PRESENT - 1)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
