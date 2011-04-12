Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 803398D003B
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 03:12:50 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 0C8593EE0B5
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 16:12:46 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E5EB245DE5A
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 16:12:45 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id CC3F645DE56
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 16:12:45 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BEFB61DB8046
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 16:12:45 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C8B61DB804E
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 16:12:45 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: mm: convert vma->vm_flags to 64bit
In-Reply-To: <20110411233358.dd400e59.akpm@linux-foundation.org>
References: <20110412151116.B50D.A69D9226@jp.fujitsu.com> <20110411233358.dd400e59.akpm@linux-foundation.org>
Message-Id: <20110412161315.B518.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 12 Apr 2011 16:12:44 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Mundt <lethal@linux-sh.org>, Russell King <linux@arm.linux.org.uk>

Hi

> > For years, powerpc people repeatedly request us to convert vm_flags
> > to 64bit. Because now it has no room to store an addional powerpc
> > specific flags.
> > 
> > Here is previous discussion logs.
> > 
> > 	http://lkml.org/lkml/2009/10/1/202
> > 	http://lkml.org/lkml/2010/4/27/23
> > 
> > But, unforunately they didn't get merged. This is 3rd trial.
> > I've merged previous two posted patches and adapted it for
> > latest tree.
> > 
> > Of cource, this patch has no functional change.
> 
> That's a bit sad, but all 32 bits are used up, so we'll presumably need
> this change pretty soon anyway.
> 
> How the heck did we end up using 32 flags??

Actually, we already have >32 flags by tricky technique.
eg.

1) THP don't support CONFIG_STACK_GROWSUP
#if defined(CONFIG_STACK_GROWSUP) || defined(CONFIG_IA64)
#define VM_GROWSUP      0x00000200
#else
#define VM_GROWSUP      0x00000000
#define VM_NOHUGEPAGE   0x00000200      /* MADV_NOHUGEPAGE marked this vma */
#endif

2) THP don't support nommu
#ifndef CONFIG_TRANSPARENT_HUGEPAGE
#define VM_MAPPED_COPY  0x01000000      /* T if mapped copy of data (nommu mmap) */
#else
#define VM_HUGEPAGE     0x01000000      /* MADV_HUGEPAGE marked this vma */
#endif

3) reuse invalid combination for marking initial stack
#define VM_STACK_INCOMPLETE_SETUP       (VM_RAND_READ | VM_SEQ_READ)


And, Last five users are

1) for KSM
#define VM_MERGEABLE   0x80000000      /* KSM may merge identical pages */

2) for cleanup (gack!)
#define VM_PFN_AT_MMAP 0x40000000      /* PFNMAP vma that is fully mapped at mmap time */

3) for MAP_NORESERVE of hugetlb
#define VM_NORESERVE   0x00200000      /* should the VM suppress accounting */

4) for powerpc spefic quark
+#define VM_SAO         0x20000000      /* Strong Access Ordering (powerpc) */

5) for S390 quark
+#define VM_MIXEDMAP    0x10000000      /* Can contain "struct page" and pure PFN pages */

Strangely, 2) and 4) don't have your S-O-B, hmm. :-|


> 
> > @@ -217,7 +217,7 @@ vivt_flush_cache_range(struct vm_area_struct *vma, unsigned long start, unsigned
> >  {
> >  	if (cpumask_test_cpu(smp_processor_id(), mm_cpumask(vma->vm_mm)))
> >  		__cpuc_flush_user_range(start & PAGE_MASK, PAGE_ALIGN(end),
> > -					vma->vm_flags);
> > +					(unsigned long)vma->vm_flags);
> >  }
> 
> I'm surprised this change (and similar) are needed?
> 
> Is it risky?  What happens if we add yet another vm_flags bit and
> __cpuc_flush_user_range() wants to use it?  I guess when that happens,
> __cpuc_flush_user_range() needs to be changed to take a ull.

Yes. We can't add flags for flush_cache_range() into upper 32bit
until ARM code aware 64bit vm_flags. We certinally need to help 
ARM folks help to convert arm's flush_user_range().


> > -static inline unsigned long arch_calc_vm_prot_bits(unsigned long prot)
> > +static inline unsigned long long arch_calc_vm_prot_bits(unsigned long prot)
> >  {
> > -	return (prot & PROT_SAO) ? VM_SAO : 0;
> > +	return (prot & PROT_SAO) ? VM_SAO : 0ULL;
> >  }
> 
> The patch does a lot of adding "ULL" like this.  But I don't think any
> of it is needed - won't the compiler do the right thing, without
> warning?

To be honest, I merely borrowed this parts from Hugh's patch. My gcc
don't claim even if I remove this. But I have no motivation to modify
it.

If you strongly dislike this part, I'll remove.



> > --- a/arch/x86/mm/hugetlbpage.c
> > +++ b/arch/x86/mm/hugetlbpage.c
> > @@ -26,8 +26,8 @@ static unsigned long page_table_shareable(struct vm_area_struct *svma,
> >  	unsigned long s_end = sbase + PUD_SIZE;
> >  
> >  	/* Allow segments to share if only one is marked locked */
> > -	unsigned long vm_flags = vma->vm_flags & ~VM_LOCKED;
> > -	unsigned long svm_flags = svma->vm_flags & ~VM_LOCKED;
> > +	unsigned long long vm_flags = vma->vm_flags & ~VM_LOCKED;
> > +	unsigned long long svm_flags = svma->vm_flags & ~VM_LOCKED;
> 
> hm, on second thoughts it is safer to add the ULL when we're doing ~ on
> the constants.
> 
> >  static inline int private_mapping_ok(struct vm_area_struct *vma)
> >  {
> > -	return vma->vm_flags & VM_MAYSHARE;
> > +	return !!(vma->vm_flags & VM_MAYSHARE);
> >  }
> 
> Fair enough.

Thanks.

> A problem with this patch is that there might be unconverted code,
> either in-tree or out-of-tree or soon-to-be-in-tree.  If that code
> isn't 64-bit aware then we'll be adding subtle bugs which take a long
> time to discover.
> 
> One way to detect those bugs nice and quickly might be to change some
> of all of these existing constants so they use the upper 32-bits.  But that
> will make __cpuc_flush_user_range() fail ;)
> 

If they are using C, ULL -> UL narrowing conversion makes lower 32bit bitmask,
and then, It's safe because we don't use upepr 32bit yet. And for this year,
upper 32bit is to be expected to used only Benjamin. Then I assume he will 
test enough his own code and he will not touched arch generic code.

After next year? All developers don't have to ignore compiler warnings!




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
