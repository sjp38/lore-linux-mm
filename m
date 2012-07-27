Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 1D03D6B0069
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 06:24:03 -0400 (EDT)
Date: Fri, 27 Jul 2012 11:23:56 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH -alternative] mm: hugetlbfs: Close race during teardown
 of hugetlbfs shared page tables V2 (resend)
Message-ID: <20120727102356.GD612@suse.de>
References: <20120720134937.GG9222@suse.de>
 <20120720141108.GH9222@suse.de>
 <20120720143635.GE12434@tiehlicka.suse.cz>
 <20120720145121.GJ9222@suse.de>
 <alpine.LSU.2.00.1207222033030.6810@eggly.anvils>
 <50118E7F.8000609@redhat.com>
 <50120FA8.20409@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <50120FA8.20409@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Larry Woodman <lwoodman@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, David Gibson <david@gibson.dropbear.id.au>, Ken Chen <kenchen@google.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 26, 2012 at 11:48:56PM -0400, Larry Woodman wrote:
> On 07/26/2012 02:37 PM, Rik van Riel wrote:
> >On 07/23/2012 12:04 AM, Hugh Dickins wrote:
> >
> >>I spent hours trying to dream up a better patch, trying various
> >>approaches.  I think I have a nice one now, what do you think?  And
> >>more importantly, does it work?  I have not tried to test it at all,
> >>that I'm hoping to leave to you, I'm sure you'll attack it with gusto!
> >>
> >>If you like it, please take it over and add your comments and signoff
> >>and send it in.  The second part won't come up in your testing,
> >>and could
> >>be made a separate patch if you prefer: it's a related point that struck
> >>me while I was playing with a different approach.
> >>
> >>I'm sorely tempted to leave a dangerous pair of eyes off the Cc,
> >>but that too would be unfair.
> >>
> >>Subject-to-your-testing-
> >>Signed-off-by: Hugh Dickins <hughd@google.com>
> >
> >This patch looks good to me.
> >
> >Larry, does Hugh's patch survive your testing?
> >
> >
>
> Like I said earlier, no. 

That is a surprise. Can you try your test case on 3.4 and tell us if the
patch fixes the problem there? I would like to rule out the possibility
that the locking rules are slightly different in RHEL. If it hits on 3.4
then it's also possible you are seeing a different bug, more on this later.

> However, I finally set up a reproducer
> that only takes a few seconds
> on a large system and this totally fixes the problem:
> 

The other possibility is that your reproducer case is triggering a
different race to mine. Would it be possible to post?

> -------------------------------------------------------------------------------------------------------------------------
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index c36febb..cc023b8 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2151,7 +2151,7 @@ int copy_hugetlb_page_range(struct mm_struct
> *dst, struct mm_struct *src,
>                         goto nomem;
> 
>                 /* If the pagetables are shared don't copy or take references */
> -               if (dst_pte == src_pte)
> +               if (*(unsigned long *)dst_pte == *(unsigned long *)src_pte)
>                         continue;
> 
>                 spin_lock(&dst->page_table_lock);
> ---------------------------------------------------------------------------------------------------------------------------
> 
> When we compare what the src_pte & dst_pte point to instead of their
> addresses everything works,

The dst_pte and src_pte are pointing to the PMD page though which is what
we're meant to be checking. Your patch appears to change that to check if
they are sharing data which is quite different. This is functionally
similar to if you just checked VM_MAYSHARE at the start of the function
and bailed if so. The PTEs would be populated at fault time instead.

> I suspect there is a missing memory barrier somewhere ???
> 

Possibly but hard to tell whether it's barriers that are the real
problem during fork. The copy routine is suspicious.

On the barrier side - in normal PTE alloc routines there is a write
barrier which is documented in __pte_alloc. If hugepage table sharing is
successful, there is no similar barrier in huge_pmd_share before the PUD
is populated. By rights, there should be a smp_wmb() before the page table
spinlock is taken in huge_pmd_share().

The lack of a write barrier leads to a possible snarls between fork()
and fault. Take three processes, parent, child and other. Parent is
forking to create child. Other is calling fault.

Other faults
	hugetlb_fault()->huge_pte_alloc->allocate a PMD (write barrier)
	It is about to enter hugetlb_no_fault()

Parent forks() runs at the same time
	Child shares a page table page but NOT with the forking process (dst_pte
	!= src_pte) and calls huge_pte_offset.

As it's not reading the contents of the PMD page, there is no implicit read
barrier to pair with the write barrier from hugetlb_fault that updates
the PMD page and they are not serialised by the page table lock. Hard to
see exactly where that would cause a problem though.

Thing is, in this scenario I think it's possible that page table sharing
is not correctly detected by that dst_pte == src_pte check.  dst_pte !=
src_pte but that does not mean it's not sharing with somebody! If it's
sharing and it falls though then it copies the src PTE even though the
dst PTE could already be populated and updates the mapcount accordingly.
That would be a mess in its own right.

There might be two bugs here.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
