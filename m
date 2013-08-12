Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id C12886B0062
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 17:57:22 -0400 (EDT)
Date: Mon, 12 Aug 2013 14:57:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/2] [PATCH] mm: Save soft-dirty bits on file pages
Message-Id: <20130812145720.3b722b066fe1bd77291331e5@linux-foundation.org>
In-Reply-To: <20130808145120.GA1775@moon>
References: <20130730204154.407090410@gmail.com>
	<20130730204654.966378702@gmail.com>
	<20130807132812.60ad4bfe85127794094d385e@linux-foundation.org>
	<20130808145120.GA1775@moon>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, luto@amacapital.net, xemul@parallels.com, mpm@selenic.com, xiaoguangrong@linux.vnet.ibm.com, mtosatti@redhat.com, kosaki.motohiro@gmail.com, sfr@canb.auug.org.au, peterz@infradead.org, aneesh.kumar@linux.vnet.ibm.com, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>

On Thu, 8 Aug 2013 18:51:20 +0400 Cyrill Gorcunov <gorcunov@gmail.com> wrote:

> On Wed, Aug 07, 2013 at 01:28:12PM -0700, Andrew Morton wrote:
> > 
> > Good god.
> > 
> > I wonder if these can be turned into out-of-line functions in some form
> > which humans can understand.
> > 
> > or
> > 
> > #define pte_to_pgoff(pte)
> > 	frob(pte, PTE_FILE_SHIFT1, PTE_FILE_BITS1) +
> > 	frob(PTE_FILE_SHIFT2, PTE_FILE_BITS2) +
> > 	frob(PTE_FILE_SHIFT3, PTE_FILE_BITS3) +
> > 	frob(PTE_FILE_SHIFT4, PTE_FILE_BITS1 + PTE_FILE_BITS2 + PTE_FILE_BITS3)
> 
> Hi, here is what I ended up with. Please take a look (I decided to post
> patch in the thread since it's related to the context of the mails).

You could have #undefed _mfrob and __frob after using them, but whatever.  

I saved this patch to wave at the x86 guys for 3.12.  I plan to merge
mm-save-soft-dirty-bits-on-file-pages.patch for 3.11.

> Guys, is there a reason for "if _PAGE_BIT_FILE < _PAGE_BIT_PROTNONE"
> test present in this pgtable-2level.h file at all? I can't imagine
> where it can be false on x86.

I doubt if "Guys" read this.  x86 maintainers cc'ed.





From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: arch/x86/include/asm/pgtable-2level.h: clean up pte_to_pgoff and pgoff_to_pte helpers

Andrew asked if there a way to make pte_to_pgoff and pgoff_to_pte macro
helpers somehow more readable.

With this patch it should be more understandable what is happening with
bits when they come to and from pte entry.

Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/x86/include/asm/pgtable-2level.h |   82 ++++++++++++------------
 1 file changed, 41 insertions(+), 41 deletions(-)

diff -puN arch/x86/include/asm/pgtable-2level.h~arch-x86-include-asm-pgtable-2levelh-clean-up-pte_to_pgoff-and-pgoff_to_pte-helpers arch/x86/include/asm/pgtable-2level.h
--- a/arch/x86/include/asm/pgtable-2level.h~arch-x86-include-asm-pgtable-2levelh-clean-up-pte_to_pgoff-and-pgoff_to_pte-helpers
+++ a/arch/x86/include/asm/pgtable-2level.h
@@ -55,6 +55,9 @@ static inline pmd_t native_pmdp_get_and_
 #define native_pmdp_get_and_clear(xp) native_local_pmdp_get_and_clear(xp)
 #endif
 
+#define _mfrob(v,r,m,l)		((((v) >> (r)) & (m)) << (l))
+#define __frob(v,r,l)		(((v) >> (r)) << (l))
+
 #ifdef CONFIG_MEM_SOFT_DIRTY
 
 /*
@@ -71,31 +74,27 @@ static inline pmd_t native_pmdp_get_and_
 #define PTE_FILE_BITS2		(PTE_FILE_SHIFT3 - PTE_FILE_SHIFT2 - 1)
 #define PTE_FILE_BITS3		(PTE_FILE_SHIFT4 - PTE_FILE_SHIFT3 - 1)
 
-#define pte_to_pgoff(pte)						\
-	((((pte).pte_low >> (PTE_FILE_SHIFT1))				\
-	  & ((1U << PTE_FILE_BITS1) - 1)))				\
-	+ ((((pte).pte_low >> (PTE_FILE_SHIFT2))			\
-	    & ((1U << PTE_FILE_BITS2) - 1))				\
-	   << (PTE_FILE_BITS1))						\
-	+ ((((pte).pte_low >> (PTE_FILE_SHIFT3))			\
-	    & ((1U << PTE_FILE_BITS3) - 1))				\
-	   << (PTE_FILE_BITS1 + PTE_FILE_BITS2))			\
-	+ ((((pte).pte_low >> (PTE_FILE_SHIFT4)))			\
-	    << (PTE_FILE_BITS1 + PTE_FILE_BITS2 + PTE_FILE_BITS3))
-
-#define pgoff_to_pte(off)						\
-	((pte_t) { .pte_low =						\
-	 ((((off)) & ((1U << PTE_FILE_BITS1) - 1)) << PTE_FILE_SHIFT1)	\
-	 + ((((off) >> PTE_FILE_BITS1)					\
-	     & ((1U << PTE_FILE_BITS2) - 1))				\
-	    << PTE_FILE_SHIFT2)						\
-	 + ((((off) >> (PTE_FILE_BITS1 + PTE_FILE_BITS2))		\
-	     & ((1U << PTE_FILE_BITS3) - 1))				\
-	    << PTE_FILE_SHIFT3)						\
-	 + ((((off) >>							\
-	      (PTE_FILE_BITS1 + PTE_FILE_BITS2 + PTE_FILE_BITS3)))	\
-	    << PTE_FILE_SHIFT4)						\
-	 + _PAGE_FILE })
+#define PTE_FILE_MASK1		((1U << PTE_FILE_BITS1) - 1)
+#define PTE_FILE_MASK2		((1U << PTE_FILE_BITS2) - 1)
+#define PTE_FILE_MASK3		((1U << PTE_FILE_BITS3) - 1)
+
+#define PTE_FILE_LSHIFT2	(PTE_FILE_BITS1)
+#define PTE_FILE_LSHIFT3	(PTE_FILE_BITS1 + PTE_FILE_BITS2)
+#define PTE_FILE_LSHIFT4	(PTE_FILE_BITS1 + PTE_FILE_BITS2 + PTE_FILE_BITS3)
+
+#define pte_to_pgoff(pte)							    \
+	(_mfrob((pte).pte_low, PTE_FILE_SHIFT1, PTE_FILE_MASK1, 0)		  + \
+	 _mfrob((pte).pte_low, PTE_FILE_SHIFT2, PTE_FILE_MASK2, PTE_FILE_LSHIFT2) + \
+	 _mfrob((pte).pte_low, PTE_FILE_SHIFT3, PTE_FILE_MASK3, PTE_FILE_LSHIFT3) + \
+	 __frob((pte).pte_low, PTE_FILE_SHIFT4, PTE_FILE_LSHIFT4))
+
+#define pgoff_to_pte(off)							\
+	((pte_t) { .pte_low =							\
+	_mfrob(off,                0, PTE_FILE_MASK1, PTE_FILE_SHIFT1)	+	\
+	_mfrob(off, PTE_FILE_LSHIFT2, PTE_FILE_MASK2, PTE_FILE_SHIFT2)	+	\
+	_mfrob(off, PTE_FILE_LSHIFT3, PTE_FILE_MASK3, PTE_FILE_SHIFT3)	+	\
+	__frob(off, PTE_FILE_LSHIFT4, PTE_FILE_SHIFT4)			+	\
+	_PAGE_FILE })
 
 #else /* CONFIG_MEM_SOFT_DIRTY */
 
@@ -115,22 +114,23 @@ static inline pmd_t native_pmdp_get_and_
 #define PTE_FILE_BITS1		(PTE_FILE_SHIFT2 - PTE_FILE_SHIFT1 - 1)
 #define PTE_FILE_BITS2		(PTE_FILE_SHIFT3 - PTE_FILE_SHIFT2 - 1)
 
-#define pte_to_pgoff(pte)						\
-	((((pte).pte_low >> PTE_FILE_SHIFT1)				\
-	  & ((1U << PTE_FILE_BITS1) - 1))				\
-	 + ((((pte).pte_low >> PTE_FILE_SHIFT2)				\
-	     & ((1U << PTE_FILE_BITS2) - 1)) << PTE_FILE_BITS1)		\
-	 + (((pte).pte_low >> PTE_FILE_SHIFT3)				\
-	    << (PTE_FILE_BITS1 + PTE_FILE_BITS2)))
-
-#define pgoff_to_pte(off)						\
-	((pte_t) { .pte_low =						\
-	 (((off) & ((1U << PTE_FILE_BITS1) - 1)) << PTE_FILE_SHIFT1)	\
-	 + ((((off) >> PTE_FILE_BITS1) & ((1U << PTE_FILE_BITS2) - 1))	\
-	    << PTE_FILE_SHIFT2)						\
-	 + (((off) >> (PTE_FILE_BITS1 + PTE_FILE_BITS2))		\
-	    << PTE_FILE_SHIFT3)						\
-	 + _PAGE_FILE })
+#define PTE_FILE_MASK1		((1U << PTE_FILE_BITS1) - 1)
+#define PTE_FILE_MASK2		((1U << PTE_FILE_BITS2) - 1)
+
+#define PTE_FILE_LSHIFT2	(PTE_FILE_BITS1)
+#define PTE_FILE_LSHIFT3	(PTE_FILE_BITS1 + PTE_FILE_BITS2)
+
+#define pte_to_pgoff(pte)							    \
+	(_mfrob((pte).pte_low, PTE_FILE_SHIFT1, PTE_FILE_MASK1, 0)		  + \
+	 _mfrob((pte).pte_low, PTE_FILE_SHIFT2, PTE_FILE_MASK2, PTE_FILE_LSHIFT2) + \
+	 __frob((pte).pte_low, PTE_FILE_SHIFT3, PTE_FILE_LSHIFT3))
+
+#define pgoff_to_pte(off)							\
+	((pte_t) { .pte_low =							\
+	_mfrob(off,                0, PTE_FILE_MASK1, PTE_FILE_SHIFT1)	+	\
+	_mfrob(off, PTE_FILE_LSHIFT2, PTE_FILE_MASK2, PTE_FILE_SHIFT2)	+	\
+	__frob(off, PTE_FILE_LSHIFT3, PTE_FILE_SHIFT3)			+	\
+	_PAGE_FILE })
 
 #endif /* CONFIG_MEM_SOFT_DIRTY */
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
