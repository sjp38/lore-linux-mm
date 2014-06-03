Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f43.google.com (mail-qa0-f43.google.com [209.85.216.43])
	by kanga.kvack.org (Postfix) with ESMTP id 4B2616B0031
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 16:01:28 -0400 (EDT)
Received: by mail-qa0-f43.google.com with SMTP id m5so5702509qaj.2
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 13:01:28 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id m13si369305qar.88.2014.06.03.13.01.26
        for <linux-mm@kvack.org>;
        Tue, 03 Jun 2014 13:01:26 -0700 (PDT)
Message-ID: <538e2996.cd7ae00a.1e64.6067SMTPIN_ADDED_BROKEN@mx.google.com>
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH -mm] mincore: apply page table walker on do_mincore() (Re: [PATCH 00/10] mm: pagewalk: huge page cleanups and VMA passing)
Date: Tue,  3 Jun 2014 16:01:17 -0400
In-Reply-To: <538DEFD8.4050506@intel.com>
References: <20140602213644.925A26D0@viggo.jf.intel.com> <1401745925-l651h3s9@n-horiguchi@ah.jp.nec.com> <538CF25E.8070905@sr71.net> <1401776292-dn0fof8e@n-horiguchi@ah.jp.nec.com> <538DEFD8.4050506@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Jun 03, 2014 at 08:55:04AM -0700, Dave Hansen wrote:
> On 06/02/2014 11:18 PM, Naoya Horiguchi wrote:
> > And for patch 8, 9, and 10, I don't think it's good idea to add a new callback
> > which can handle both pmd and pte (because they are essentially differnt thing).
> > But the underneath idea of doing pmd_trans_huge_lock() in the common code in
> > walk_single_entry_locked() looks nice to me. So it would be great if we can do
> > the same thing in walk_pmd_range() (of linux-mm) to reduce code in callbacks.
> 
> You think they are different, I think they're the same. :)
> 
> What the walkers *really* care about is getting a leaf node in the page
> tables.  They generally don't *care* whether it is a pmd or pte, they
> just want to know what its value is and how large it is.

OK, I see your idea, so I think that we could go to the direction to
unify all p(gd|ud|md|te)_entry() callbacks.
And if we find the leaf entry in whatever level, we call the common entry
handler on the entry, right?
It would takes some time and effort to make all users to fit to this new
scheme, so my suggestion is:
 1. move pmd locking to walk_pmd_range() (then, your locked_single_entry()
    callback is equal to pmd_entry())
 2. let each existing user have its common entry handler, and connect it to
    its pmd_entry() and/or pte_entry() to keep compatibility
 3. apply page table walker to potential users.
    I'd like to keep pmd/pte_entry() until we complete phase 2.,
    because we could find something which let us change core code,
 4. and finaly replace all p(gd|ud|md|te)_entry() with a unified callback.

Could you let me have a few days to work on 1.?
I think that it means your patch 8 is effectively merged on top of mine.
So your current problem will be solved.

> I'd argue that they don't really ever need to actually know at which
> level they are in the page tables, just if they are at the bottom or
> not.  Note that *NOBODY* sets a pud or pgd entry.  That's because the
> walkers are 100% concerned about leaf nodes (pte's) at this point.

Yes. BTW do you think we should pud_entry() and pgd_entry() immediately?
We can do it and it reduces some trivial evaluations, so it's optimized
a little.

> Take a look at my version of gather_stats_locked():
> 
> >  static int gather_stats_locked(pte_t *pte, unsigned long addr,
> >                 unsigned long size, struct mm_walk *walk)
> >  {
> >         struct numa_maps *md = walk->private;
> >         struct page *page = can_gather_numa_stats(*pte, walk->vma, addr);
> >  
> >         if (page)
> >                 gather_stats(page, md, pte_dirty(*pte), size/PAGE_SIZE);
> >  
> >         return 0;
> >  }
> 
> The mmotm version looks _very_ similar to that, *BUT* the mmotm version
> needs to have an entire *EXTRA* 22-line gather_pmd_stats() dealing with
> THP locking, while mine doesn't.

OK, my objection was just on adding a new callback because it introduces
some duplication (3 callbacks for 2 types of entries.) But I agree to do
pmd locking in the common code. It should make both of us happy :)

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
