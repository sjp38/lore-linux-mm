Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 930D3900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 06:23:07 -0400 (EDT)
Date: Mon, 18 Apr 2011 11:23:00 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: Check if PTE is already allocated during page fault
Message-ID: <20110418102300.GA16908@suse.de>
References: <20110415101248.GB22688@suse.de>
 <20110415143916.GN15707@random.random>
 <20110415150606.GP15707@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110415150606.GP15707@random.random>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: akpm@linux-foundation.org, raz ben yehuda <raziebe@gmail.com>, riel@redhat.com, kosaki.motohiro@jp.fujitsu.com, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, stable@kernel.org

On Fri, Apr 15, 2011 at 05:06:06PM +0200, Andrea Arcangeli wrote:
> On Fri, Apr 15, 2011 at 04:39:16PM +0200, Andrea Arcangeli wrote:
> > On Fri, Apr 15, 2011 at 11:12:48AM +0100, Mel Gorman wrote:
> > > diff --git a/mm/memory.c b/mm/memory.c
> > > index 5823698..1659574 100644
> > > --- a/mm/memory.c
> > > +++ b/mm/memory.c
> > > @@ -3322,7 +3322,7 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> > >  	 * run pte_offset_map on the pmd, if an huge pmd could
> > >  	 * materialize from under us from a different thread.
> > >  	 */
> > > -	if (unlikely(__pte_alloc(mm, vma, pmd, address)))
> > > +	if (unlikely(pmd_none(*pmd)) && __pte_alloc(mm, vma, pmd, address))
> 
> I started hacking on this and I noticed it'd be better to extend the
> unlikely through the end. At first review I didn't notice the
> parenthesis closure stops after pte_none and __pte_alloc is now
> uncovered. I'd prefer this:
> 
>     if (unlikely(pmd_none(*pmd) && __pte_alloc(mm, vma, pmd, address)))
> 

I had this at one point and then decided to match what we do for
pte_alloc_map(). My reasoning was that the most important part of this
check is pmd_none(). It's relatively unlikely we even call __pte_alloc
which is why I didn't think it belonged in the unlikely block. I also
preferred being consistent with pte_alloc_map.

> I mean the real unlikely thing is that we return VM_FAULT_OOM, if we
> end up calling __pte_alloc or not, depends on the app. Generally it
> sounds more frequent that the pte is not none, so it's not wrong, but
> it's even less likely that __pte_alloc fails so that can be taken into
> account too, and __pte_alloc runs still quite frequently. So either
> above or:
> 
>     if (unlikely(pmd_none(*pmd)) && unlikely(__pte_alloc(mm, vma, pmd, address)))
> 

I'd prefer this than putting everything inside the same unlikely block.
But if this makes a noticeable, why do we not do it for pte_alloc_map,
pmd_alloc and other similar functions?

> I generally prefer unlikely only when it's 100% sure thing it's less
> likely (like the VM_FAULT_OOM), so the first version I guess it's
> enough (I'm afraid unlikely for pte_none too, may make gcc generate a
> far away jump possibly going out of l1 icache for a case that is only
> 512 times less likely at best). My point is that it's certainly hugely
> more unlikely that __pte_alloc fails than the pte is none.
> 

For the bug fix, it's best to match what pte_alloc_map, pmd_alloc,
pud_alloc and others do in terms of how it uses unlikely. If what we are
currently doing is sub-optimal, a single patch should change all the
helpers.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
