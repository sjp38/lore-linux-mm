Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0ABC4900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 11:06:13 -0400 (EDT)
Date: Fri, 15 Apr 2011 17:06:06 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: Check if PTE is already allocated during page fault
Message-ID: <20110415150606.GP15707@random.random>
References: <20110415101248.GB22688@suse.de>
 <20110415143916.GN15707@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110415143916.GN15707@random.random>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: akpm@linux-foundation.org, raz ben yehuda <raziebe@gmail.com>, riel@redhat.com, kosaki.motohiro@jp.fujitsu.com, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, stable@kernel.org

On Fri, Apr 15, 2011 at 04:39:16PM +0200, Andrea Arcangeli wrote:
> On Fri, Apr 15, 2011 at 11:12:48AM +0100, Mel Gorman wrote:
> > diff --git a/mm/memory.c b/mm/memory.c
> > index 5823698..1659574 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -3322,7 +3322,7 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> >  	 * run pte_offset_map on the pmd, if an huge pmd could
> >  	 * materialize from under us from a different thread.
> >  	 */
> > -	if (unlikely(__pte_alloc(mm, vma, pmd, address)))
> > +	if (unlikely(pmd_none(*pmd)) && __pte_alloc(mm, vma, pmd, address))

I started hacking on this and I noticed it'd be better to extend the
unlikely through the end. At first review I didn't notice the
parenthesis closure stops after pte_none and __pte_alloc is now
uncovered. I'd prefer this:

    if (unlikely(pmd_none(*pmd) && __pte_alloc(mm, vma, pmd, address)))

I mean the real unlikely thing is that we return VM_FAULT_OOM, if we
end up calling __pte_alloc or not, depends on the app. Generally it
sounds more frequent that the pte is not none, so it's not wrong, but
it's even less likely that __pte_alloc fails so that can be taken into
account too, and __pte_alloc runs still quite frequently. So either
above or:

    if (unlikely(pmd_none(*pmd)) && unlikely(__pte_alloc(mm, vma, pmd, address)))

I generally prefer unlikely only when it's 100% sure thing it's less
likely (like the VM_FAULT_OOM), so the first version I guess it's
enough (I'm afraid unlikely for pte_none too, may make gcc generate a
far away jump possibly going out of l1 icache for a case that is only
512 times less likely at best). My point is that it's certainly hugely
more unlikely that __pte_alloc fails than the pte is none.

This is a real nitpick though ;).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
