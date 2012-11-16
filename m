Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id D22DF6B005D
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 11:19:18 -0500 (EST)
Date: Fri, 16 Nov 2012 16:19:13 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 06/43] mm: numa: Make pte_numa() and pmd_numa() a generic
 implementation
Message-ID: <20121116161913.GC8218@suse.de>
References: <1353064973-26082-1-git-send-email-mgorman@suse.de>
 <1353064973-26082-7-git-send-email-mgorman@suse.de>
 <50A648FF.2040707@redhat.com>
 <20121116144109.GA8218@suse.de>
 <CA+55aFzH_-6FuwTF1GVDzLK+7c0MGLsLdPFjzzwU78GVUEMbBw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CA+55aFzH_-6FuwTF1GVDzLK+7c0MGLsLdPFjzzwU78GVUEMbBw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Nov 16, 2012 at 07:32:01AM -0800, Linus Torvalds wrote:
> On Fri, Nov 16, 2012 at 6:41 AM, Mel Gorman <mgorman@suse.de> wrote:
> >
> > I would have preferred asm-generic/pgtable.h myself and use
> > __HAVE_ARCH_whatever tricks
> 
> PLEASE NO!
> 
> Dammit, why is this disease still so prevalent, and why do people
> continue to do this crap?
> 

By personal experience because they read the header, see the other examples
and say "fair enough". I'm tempted to...

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index da3e761..572d3f1 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -7,6 +7,12 @@
 #include <linux/mm_types.h>
 #include <linux/bug.h>
 
+/*
+ * NOTE: Do NOT copy the __HAVE_ARCH convention when adding new generic
+ * helpers. You will have to wear a D hat and be called names
+ * https://lkml.org/lkml/2012/11/16/340
+ */
+
 #ifndef __HAVE_ARCH_PTEP_SET_ACCESS_FLAGS
 extern int ptep_set_access_flags(struct vm_area_struct *vma,
 				 unsigned long address, pte_t *ptep,


> __HAVE_ARCH_xyzzy is a f*cking retarded thing to do, and that's
> actually an insult to retarded people.
> 
> Use either:
> 
>  - Kconfig entries for bigger features where that makes sense, and
> using the Kconfig files allows you to use the Kconfig logic for things
> (ie there are dependencies etc, so you can avoid having to have
> complicated conditionals in the #ifdef's, and instead introduce them
> as rules in Kconfig files).
> 
>  - the SAME F*CKING NAME for the #ifdef, not some totally different
> namespace with __HAVE_ARCH_xyzzy crap.
> 
> So if your architecture wants to override one (or more) of the
> pte_*numa() functions, just make it do so. And do it with
> 
>   static inline pmd_t pmd_mknuma(pmd_t pmd)
>   {
>           pmd = pmd_set_flags(pmd, _PAGE_NUMA);
>           return pmd_clear_flags(pmd, _PAGE_PRESENT);
>   }
>   #define pmd_mknuma pmd_mknuma
> 
> and then you can have the generic code have code like
> 
>    #ifndef pmd_mknuma
>    .. generic version goes here ..
>    #endif
> 
> and the advantage is two-fold:
> 
>  - none of the "let's make up another name to test for this"
> 
>  - "git grep" actually _works_, and the end results make sense, and
> you can clearly see the logic of where things are declared, and which
> one is used.
> 

Understood, makes sense and is a straight-forward conversion. Now that I
read this, this explanation feels familiar. Clearly it did not sink in
with me when you shouted at the last person that tried.

> The __ARCH_HAVE_xyzzy (and some places call it __HAVE_ARCH_xyzzy)
> thing is a disease.
> 

And now I have been healed! I've had worse starts to a weekend.

> That said, the __weak thing works too (and greps fine, as long as you
> use the proper K&R C format, not the idiotic "let's put the name of
> the function on a different line than the type of the function"
> format), it just doesn't allow inlining.
> 
> In this case, I suspect the inlined function is generally a single
> instruction, is it not? In which case I really do think that inlining
> makes sense.
> 

I would expect a single instruction for the checks (pte_numa, pmd_numa).
It's probably two for the setters (pte_mknuma, pmd_mknuma, pte_mknonnuma,
pmd_mknonnuma) unless paravirt gets involved. paravirt might add a
function call in there but should be nothing crazy.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
