Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id BB7D16B0279
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 06:32:34 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y39so4445583wry.10
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 03:32:34 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y2si4945646wmb.39.2017.06.08.03.32.32
        for <linux-mm@kvack.org>;
        Thu, 08 Jun 2017 03:32:33 -0700 (PDT)
Date: Thu, 8 Jun 2017 11:31:47 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH 1/3] mm: numa: avoid waiting on freed migrated pages
Message-ID: <20170608103147.GB5765@leverpostej>
References: <1496771916-28203-1-git-send-email-will.deacon@arm.com>
 <1496771916-28203-2-git-send-email-will.deacon@arm.com>
 <c7000523-7b2b-06ed-6273-886978efaab5@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c7000523-7b2b-06ed-6273-886978efaab5@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, Punit.Agrawal@arm.com, mgorman@suse.de, steve.capper@arm.com

On Thu, Jun 08, 2017 at 11:04:05AM +0200, Vlastimil Babka wrote:
> On 06/06/2017 07:58 PM, Will Deacon wrote:
> > From: Mark Rutland <mark.rutland@arm.com>
> > 
> > In do_huge_pmd_numa_page(), we attempt to handle a migrating thp pmd by
> > waiting until the pmd is unlocked before we return and retry. However,
> > we can race with migrate_misplaced_transhuge_page():
> > 
> > // do_huge_pmd_numa_page                // migrate_misplaced_transhuge_page()
> > // Holds 0 refs on page                 // Holds 2 refs on page
> > 
> > vmf->ptl = pmd_lock(vma->vm_mm, vmf->pmd);
> > /* ... */
> > if (pmd_trans_migrating(*vmf->pmd)) {
> >         page = pmd_page(*vmf->pmd);
> >         spin_unlock(vmf->ptl);
> >                                         ptl = pmd_lock(mm, pmd);
> >                                         if (page_count(page) != 2)) {
> >                                                 /* roll back */
> >                                         }
> >                                         /* ... */
> >                                         mlock_migrate_page(new_page, page);
> >                                         /* ... */
> >                                         spin_unlock(ptl);
> >                                         put_page(page);
> >                                         put_page(page); // page freed here
> >         wait_on_page_locked(page);
> >         goto out;
> > }
> > 
> > This can result in the freed page having its waiters flag set
> > unexpectedly, which trips the PAGE_FLAGS_CHECK_AT_PREP checks in the
> > page alloc/free functions. This has been observed on arm64 KVM guests.
> > 
> > We can avoid this by having do_huge_pmd_numa_page() take a reference on
> > the page before dropping the pmd lock, mirroring what we do in
> > __migration_entry_wait().
> > 
> > When we hit the race, migrate_misplaced_transhuge_page() will see the
> > reference and abort the migration, as it may do today in other cases.
> > 
> > Acked-by: Steve Capper <steve.capper@arm.com>
> > Signed-off-by: Mark Rutland <mark.rutland@arm.com>
> > Signed-off-by: Will Deacon <will.deacon@arm.com>
> 
> Nice catch! Stable candidate?

I think so, given I can hit this in practice.

> Fixes: the commit that added waiters flag?

I think we need:

Fixes: b8916634b77bffb2 ("mm: Prevent parallel splits during THP migration")

... which introduced the potential for the huge page to be freed (and
potentially reallocated) before we wait on it. The waiters flag issue is
a result of this, rather than the underlying issue.

> Assuming it was harmless before that?

I'm not entirely sure. I suspect that there are other issues that might
result, e.g. if the page were reallocated before we wait on it.

> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Cheers!

Mark.

> > ---
> >  mm/huge_memory.c | 8 +++++++-
> >  1 file changed, 7 insertions(+), 1 deletion(-)
> > 
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index a84909cf20d3..88c6167f194d 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -1426,8 +1426,11 @@ int do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t pmd)
> >  	 */
> >  	if (unlikely(pmd_trans_migrating(*vmf->pmd))) {
> >  		page = pmd_page(*vmf->pmd);
> > +		if (!get_page_unless_zero(page))
> > +			goto out_unlock;
> >  		spin_unlock(vmf->ptl);
> >  		wait_on_page_locked(page);
> > +		put_page(page);
> >  		goto out;
> >  	}
> >  
> > @@ -1459,9 +1462,12 @@ int do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t pmd)
> >  
> >  	/* Migration could have started since the pmd_trans_migrating check */
> >  	if (!page_locked) {
> > +		page_nid = -1;
> > +		if (!get_page_unless_zero(page))
> > +			goto out_unlock;
> >  		spin_unlock(vmf->ptl);
> >  		wait_on_page_locked(page);
> > -		page_nid = -1;
> > +		put_page(page);
> >  		goto out;
> >  	}
> >  
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
