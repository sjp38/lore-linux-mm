Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 71A2A6B0062
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 12:59:13 -0400 (EDT)
Date: Thu, 11 Oct 2012 18:58:47 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 05/33] autonuma: pte_numa() and pmd_numa()
Message-ID: <20121011165847.GO1818@redhat.com>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
 <1349308275-2174-6-git-send-email-aarcange@redhat.com>
 <20121011111545.GR3317@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121011111545.GR3317@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Thu, Oct 11, 2012 at 12:15:45PM +0100, Mel Gorman wrote:
> huh?
> 
> #define _PAGE_NUMA     _PAGE_PROTNONE
> 
> so this is effective _PAGE_PRESENT | _PAGE_PROTNONE | _PAGE_PROTNONE
> 
> I suspect you are doing this because there is no requirement for
> _PAGE_NUMA == _PAGE_PROTNONE for other architectures and it was best to
> describe your intent. Is that really the case or did I miss something
> stupid?

Exactly.

It reminds that we need to return true in pte_present when the NUMA
hinting page fault is on.

Hardwiring _PAGE_NUMA to _PAGE_PROTNONE conceptually is not necessary
and it's actually an artificial restrictions. Other archs without a
bitflag for _PAGE_PROTNONE, may want to use something else and they'll
have to deal with pte_present too, somehow. So this is a reminder for
them as well.

> >  static inline int pte_hidden(pte_t pte)
> > @@ -420,7 +421,63 @@ static inline int pmd_present(pmd_t pmd)
> >  	 * the _PAGE_PSE flag will remain set at all times while the
> >  	 * _PAGE_PRESENT bit is clear).
> >  	 */
> > -	return pmd_flags(pmd) & (_PAGE_PRESENT | _PAGE_PROTNONE | _PAGE_PSE);
> > +	return pmd_flags(pmd) & (_PAGE_PRESENT | _PAGE_PROTNONE | _PAGE_PSE |
> > +				 _PAGE_NUMA);
> > +}
> > +
> > +#ifdef CONFIG_AUTONUMA
> > +/*
> > + * _PAGE_NUMA works identical to _PAGE_PROTNONE (it's actually the
> > + * same bit too). It's set only when _PAGE_PRESET is not set and it's
> 
> same bit on x86, not necessarily anywhere else.

Yep. In fact before using _PAGE_PRESENT the two bits were different
even on x86. But I unified them. If I vary them then they will become
_PAGE_PTE_NUMA/_PAGE_PMD_NUMA and the above will fail to build without
risk of errors.

> 
> _PAGE_PRESENT?

good eye ;) corrected.

> > +/*
> > + * pte/pmd_mknuma sets the _PAGE_ACCESSED bitflag automatically
> > + * because they're called by the NUMA hinting minor page fault.
> 
> automatically or atomically?
> 
> I assume you meant atomically but what stops two threads faulting at the
> same time and doing to the same update? mmap_sem will be insufficient in
> that case so what is guaranteeing the atomicity. PTL?

I meant automatically. I explained myself wrong and automatically may
be the wrong word. It also is atomic of course but it wasn't about the
atomic part.

So the thing is: the numa hinting page fault hooking point is this:

	if (pte_numa(entry))
		return pte_numa_fixup(mm, vma, address, entry, pte, pmd);

It won't get this far:

	entry = pte_mkyoung(entry);
	if (ptep_set_access_flags(vma, address, pte, entry, flags & FAULT_FLAG_WRITE)) {

So if I don't set _PAGE_ACCESSED in pte/pmd_mknuma, the TLB miss
handler will have to set _PAGE_ACCESSED itself with an additional
write on the pte/pmd later when userland touches the page. And that
will slow us down for no good.

Because mknuma is only called in the numa hinting page fault context,
it's optimal to set _PAGE_ACCESSED too, not only _PAGE_PRESENT (and
clearing _PAGE_NUMA of course).

The basic idea, is that the numa hinting page fault can only trigger
if userland touches the page, and after such an event, _PAGE_ACCESSED
would be set by the hardware no matter if there is a NUMA hinting page
fault or not (so we can optimize away the hardware action when the NUMA
hinting page fault triggers).

I tried to reword it:

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index cf1d3f0..3dc6a9b 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -449,12 +449,12 @@ static inline int pmd_numa(pmd_t pmd)
 #endif
 
 /*
- * pte/pmd_mknuma sets the _PAGE_ACCESSED bitflag automatically
- * because they're called by the NUMA hinting minor page fault. If we
- * wouldn't set the _PAGE_ACCESSED bitflag here, the TLB miss handler
- * would be forced to set it later while filling the TLB after we
- * return to userland. That would trigger a second write to memory
- * that we optimize away by setting _PAGE_ACCESSED here.
+ * pte/pmd_mknuma sets the _PAGE_ACCESSED bitflag too because they're
+ * only called by the NUMA hinting minor page fault. If we wouldn't
+ * set the _PAGE_ACCESSED bitflag here, the TLB miss handler would be
+ * forced to set it later while filling the TLB after we return to
+ * userland. That would trigger a second write to memory that we
+ * optimize away by setting _PAGE_ACCESSED here.
  */
 static inline pte_t pte_mknonnuma(pte_t pte)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
