Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 0AEAF6B0078
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 15:38:19 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id kx10so8290444pab.17
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 12:38:19 -0700 (PDT)
Received: from mail-pd0-x232.google.com (mail-pd0-x232.google.com [2607:f8b0:400e:c02::232])
        by mx.google.com with ESMTPS id uj6si29282373pab.63.2014.09.10.12.38.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 12:38:18 -0700 (PDT)
Received: by mail-pd0-f178.google.com with SMTP id p10so8769667pdj.23
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 12:38:18 -0700 (PDT)
Date: Wed, 10 Sep 2014 12:36:30 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: mm: BUG in unmap_page_range
In-Reply-To: <20140910124732.GT17501@suse.de>
Message-ID: <alpine.LSU.2.11.1409101210520.1744@eggly.anvils>
References: <53E989FB.5000904@oracle.com> <53FD4D9F.6050500@oracle.com> <20140827152622.GC12424@suse.de> <540127AC.4040804@oracle.com> <54082B25.9090600@oracle.com> <20140908171853.GN17501@suse.de> <540DEDE7.4020300@oracle.com> <20140909213309.GQ17501@suse.de>
 <540F7D42.1020402@oracle.com> <alpine.LSU.2.11.1409091903390.10989@eggly.anvils> <20140910124732.GT17501@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>, Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Cyrill Gorcunov <gorcunov@gmail.com>

On Wed, 10 Sep 2014, Mel Gorman wrote:
> On Tue, Sep 09, 2014 at 07:45:26PM -0700, Hugh Dickins wrote:
> > 
> > I've been rather assuming that the 9d340902 seen in many of the
> > registers in that Aug26 dump is the pte val in question: that's
> > SOFT_DIRTY|PROTNONE|RW.

The 900s in the latest dumps imply that that 902 was not important.
(If any of them are in fact the pte val.)

> > 
> > I think RW on PROTNONE is unusual but not impossible (migration entry
> > replacement racing with mprotect setting PROT_NONE, after it's updated
> > vm_page_prot, before it's reached the page table). 
> 
> At the risk of sounding thick, I need to spell this out because I'm
> having trouble seeing exactly what race you are thinking of. 
> 
> Migration entry replacement is protected against parallel NUMA hinting
> updates by the page table lock (either PMD or PTE level). It's taken by
> remove_migration_pte on one side and lock_pte_protection on the other.
> 
> For the mprotect case racing again migration, migration entries are not
> present so change_pte_range() should ignore it. On migration completion
> the VMA flags determine the permissions of the new PTE. Parallel faults
> wait on the migration entry and see the correct value afterwards.
> 
> When creating migration entries, try_to_unmap calls page_check_address
> which takes the PTL before doing anything. On the mprotect side,
> lock_pte_protection will block before seeing PROTNONE.
> 
> I think the race you are thinking of is a migration entry created for write,
> parallel mprotect(PROTNONE) and migration completion. The migration entry
> was created for write but remove_migration_pte does not double check the VMA
> protections and mmap_sem is not taken for write across a full migration to
> protect against changes to vm_page_prot.

Yes, the "if (is_write_migration_entry(entry)) pte = pte_mkwrite(pte);"
arguably should take the latest value of vma->vm_page_prot into account.

> However, change_pte_range checks
> for migration entries marked for write under the PTL and marks them read if
> one is encountered. The consequence is that we potentially take a spurious
> fault to mark the PTE write again after migration completes but I can't
> see how that causes a problem as such.

Yes, once mprotect's page table walk reaches that pte, it updates it
correctly along with all the others nearby (which were not migrated),
removing the temporary oddity.

> 
> I'm missing some part of your reasoning that leads to the RW|PROTNONE :(

You don't appear to be missing it at all, you are seeing the possibility
of an RW|PROTNONE yourself, and how it gets "corrected" afterwards
("corrected" in quotes because without the present bit, it's not an error).

> 
> > But exciting though
> > that line of thought is, I cannot actually bring it to a pte_mknuma bug,
> > or any bug at all.
> > 

And I wasn't saying that it led to this bug, just that it was an oddity
worth thinking about, and worth mentioning to you, in case you could work
out a way it might lead to the bug, when I had failed to do so.

But we now (almost) know that 902 is irrelevant to this bug anyway.

> 
> On x86, PROTNONE|RW translates as GLOBAL|RW which would be unexpected. It

GLOBAL once PRESENT is set, but PROTNONE so long as it is not.

> wouldn't cause this bug but it's sufficiently suspicious to be worth
> correcting. In case this is the race you're thinking of, the patch is below.
> Unfortunately, I cannot see how it would affect this problem but worth
> giving a whirl anyway.
> 
> > Mel, no way can it be the cause of this bug - unless Sasha's later
> > traces actually show a different stack - but I don't see the call
> > to change_prot_numa() from queue_pages_range() sharing the same
> > avoidance of PROT_NONE that task_numa_work() has (though it does
> > have an outdated comment about PROT_NONE which should be removed).
> > So I think that site probably does need PROT_NONE checking added.
> > 
> 
> That site should have checked PROT_NONE but it can't be the same bug
> that trinity is seeing. Minimally trinity is unaware of MPOL_MF_LAZY
> according to git grep of the trinity source.

Yes, queue_pages_range() is not implicated in any of Sasha's traces.
Something to fix, but not relevant to this bug.

> 
> Worth adding this to the debugging mix? It should warn if it encounters
> the problem but avoid adding the problematic RW bit.
> 
> ---8<---
> migrate: debug patch to try identify race between migration completion and mprotect
> 
> A migration entry is marked as write if pte_write was true at the
> time the entry was created. The VMA protections are not double checked
> when migration entries are being removed but mprotect itself will mark
> write-migration-entries as read to avoid problems. It means we potentially
> take a spurious fault to mark these ptes write again but otherwise it's
> harmless.  Still, one dump indicates that this situation can actually
> happen so this debugging patch spits out a warning if the situation occurs
> and hopefully the resulting warning will contain a clue as to how exactly
> it happens
> 
> Not-signed-off
> ---
>  mm/migrate.c | 12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 09d489c..631725c 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -146,8 +146,16 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
>  	pte = pte_mkold(mk_pte(new, vma->vm_page_prot));
>  	if (pte_swp_soft_dirty(*ptep))
>  		pte = pte_mksoft_dirty(pte);
> -	if (is_write_migration_entry(entry))
> -		pte = pte_mkwrite(pte);
> +	if (is_write_migration_entry(entry)) {
> +		/*
> +		 * This WARN_ON_ONCE is temporary for the purposes of seeing if
> +		 * it's a case encountered by trinity in Sasha's testing
> +		 */
> +		if (!(vma->vm_flags & (VM_WRITE)))
> +			WARN_ON_ONCE(1);
> +		else
> +			pte = pte_mkwrite(pte);
> +	}
>  #ifdef CONFIG_HUGETLB_PAGE
>  	if (PageHuge(new)) {
>  		pte = pte_mkhuge(pte);
> 

Right, and Sasha  reports that that can fire, but he sees the bug
with this patch in and without that firing.

Consider 902 of no interest, it was just something worth mentioning
before we got more info.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
