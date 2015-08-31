Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id F2ED96B0254
	for <linux-mm@kvack.org>; Mon, 31 Aug 2015 04:53:44 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so67747425wic.0
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 01:53:44 -0700 (PDT)
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com. [209.85.212.174])
        by mx.google.com with ESMTPS id p11si25634451wjw.192.2015.08.31.01.53.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Aug 2015 01:53:43 -0700 (PDT)
Received: by wicfv10 with SMTP id fv10so56414909wic.1
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 01:53:42 -0700 (PDT)
Date: Mon, 31 Aug 2015 10:53:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v8 3/6] mm: Introduce VM_LOCKONFAULT
Message-ID: <20150831085341.GB29723@dhcp22.suse.cz>
References: <1440613465-30393-1-git-send-email-emunson@akamai.com>
 <1440613465-30393-4-git-send-email-emunson@akamai.com>
 <20150828141829.GD5301@dhcp22.suse.cz>
 <20150828193454.GC7925@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150828193454.GC7925@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Fri 28-08-15 15:34:54, Eric B Munson wrote:
> On Fri, 28 Aug 2015, Michal Hocko wrote:
> 
> > On Wed 26-08-15 14:24:22, Eric B Munson wrote:
> > > The cost of faulting in all memory to be locked can be very high when
> > > working with large mappings.  If only portions of the mapping will be
> > > used this can incur a high penalty for locking.
> > > 
> > > For the example of a large file, this is the usage pattern for a large
> > > statical language model (probably applies to other statical or graphical
> > > models as well).  For the security example, any application transacting
> > > in data that cannot be swapped out (credit card data, medical records,
> > > etc).
> > > 
> > > This patch introduces the ability to request that pages are not
> > > pre-faulted, but are placed on the unevictable LRU when they are finally
> > > faulted in.  The VM_LOCKONFAULT flag will be used together with
> > > VM_LOCKED and has no effect when set without VM_LOCKED.  Setting the
> > > VM_LOCKONFAULT flag for a VMA will cause pages faulted into that VMA to
> > > be added to the unevictable LRU when they are faulted or if they are
> > > already present, but will not cause any missing pages to be faulted in.
> > 
> > OK, I can live with this. Thank you for removing the part which exports
> > the flag to the userspace.
> >  
> > > Exposing this new lock state means that we cannot overload the meaning
> > > of the FOLL_POPULATE flag any longer.  Prior to this patch it was used
> > > to mean that the VMA for a fault was locked.  This means we need the
> > > new FOLL_MLOCK flag to communicate the locked state of a VMA.
> > > FOLL_POPULATE will now only control if the VMA should be populated and
> > > in the case of VM_LOCKONFAULT, it will not be set.
> > 
> > I thinking that this part is really unnecessary. populate_vma_page_range
> > could have simply returned without calling gup for VM_LOCKONFAULT
> > vmas. You would save the pte walk and the currently mapped pages would
> > be still protected from the reclaim. The side effect would be that they
> > would litter the regular LRUs and mlock/unevictable counters wouldn't be
> > updated until those pages are encountered during the reclaim and culled
> > to unevictable list.
> > 
> > I would expect that mlock with this flag would be typically called
> > on mostly unpopulated mappings so the side effects would be barely
> > noticeable while the lack of pte walk would be really nice (especially
> > for the large mappings).
> > 
> > This would be a nice optimization and minor code reduction but I am not
> > going to insist on it. I will leave the decision to you.
> 
> If I am understanding you correctly, this is how the lock on fault set
> started.  Jon Corbet pointed out that this would leave pages which were
> present when mlock2(MLOCK_ONFAULT) was called in an unlocked state, only
> locking them after they were reclaimed and then refaulted.

Not really. They would be lazily locked during the reclaim. Have a look
at try_to_unmap -> try_to_unmap_one path. So those pages will be
effectively locked - just not accounted for that fact yet. 

> Even if this was never the case, we scan the entire range for a call to
> mlock() and will lock the pages which are present.  Why would we pay the
> cost of getting the accounting right on the present pages for mlock, but
> not lock on fault?

Because mlock() has a different semantic and you _have_ to walk the whole
range just to pre-fault memory. Mlocking the already present pages is
not really adding much on top. Situation is different with lock on
fault because pre-faulting doesn't happen and crawling the whole range
just to find present pages sounds like a wasted time when the same can
be handled lazily.

But as I've said, I will not insist...

> > > Signed-off-by: Eric B Munson <emunson@akamai.com>
> > > Cc: Michal Hocko <mhocko@suse.cz>
> > > Cc: Vlastimil Babka <vbabka@suse.cz>
> > > Cc: Jonathan Corbet <corbet@lwn.net>
> > > Cc: "Kirill A. Shutemov" <kirill@shutemov.name>
> > > Cc: linux-kernel@vger.kernel.org
> > > Cc: linux-mm@kvack.org
> > > Cc: linux-api@vger.kernel.org
> > 
> > Acked-by: Michal Hocko <mhocko@suse.com>
> > 
> > One note below:
> > 
> > > ---
> > > Changes from v7:
> > > *Drop entries in smaps and dri code to avoid exposing VM_LOCKONFAULT to
> > >  userspace.  VM_LOCKONFAULT is still exposed via mm/debug.c
> > > *Create VM_LOCKED_CLEAR_MASK to be used anywhere we want to clear all
> > >  flags relating to locked VMAs
> > > 
> > >  include/linux/mm.h |  5 +++++
> > >  kernel/fork.c      |  2 +-
> > >  mm/debug.c         |  1 +
> > >  mm/gup.c           | 10 ++++++++--
> > >  mm/huge_memory.c   |  2 +-
> > >  mm/hugetlb.c       |  4 ++--
> > >  mm/mlock.c         |  2 +-
> > >  mm/mmap.c          |  2 +-
> > >  mm/rmap.c          |  6 ++++--
> > >  9 files changed, 24 insertions(+), 10 deletions(-)
> > [...]
> > > diff --git a/mm/rmap.c b/mm/rmap.c
> > > index 171b687..14ce002 100644
> > > --- a/mm/rmap.c
> > > +++ b/mm/rmap.c
> > > @@ -744,7 +744,8 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
> > >  
> > >  		if (vma->vm_flags & VM_LOCKED) {
> > >  			spin_unlock(ptl);
> > > -			pra->vm_flags |= VM_LOCKED;
> > > +			pra->vm_flags |=
> > > +				(vma->vm_flags & (VM_LOCKED | VM_LOCKONFAULT));
> > >  			return SWAP_FAIL; /* To break the loop */
> > >  		}
> > >  
> > > @@ -765,7 +766,8 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
> > >  
> > >  		if (vma->vm_flags & VM_LOCKED) {
> > >  			pte_unmap_unlock(pte, ptl);
> > > -			pra->vm_flags |= VM_LOCKED;
> > > +			pra->vm_flags |=
> > > +				(vma->vm_flags & (VM_LOCKED | VM_LOCKONFAULT));
> > >  			return SWAP_FAIL; /* To break the loop */
> > >  		}
> > 
> > Why do we need to export this? Neither of the consumers care and should
> > care. VM_LOCKONFAULT should never be set without VM_LOCKED which is the
> > only thing that we should care about.
> 
> I exported VM_LOCKONFAULT because this is an internal interface and I
> saw no harm in doing so.  I do not have a use case for it at the moment,
> so I would be fine dropping this hunk.
 
I was objecting because nobody except for the population path should
really care about this flag. The real locking semantic is already
described by VM_LOCKED. If there ever is a user of VM_LOCKONFAULT from
those paths it should be added explicitly. So please drop these two.
The fewer instances of VM_LOCKONFAULT we have the easier this will be to
maintain.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
