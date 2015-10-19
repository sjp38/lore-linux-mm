Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 0DA2B82F65
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 15:18:08 -0400 (EDT)
Received: by igbkq10 with SMTP id kq10so57382551igb.0
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 12:18:07 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id 198si27796600ion.108.2015.10.19.12.18.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Oct 2015 12:18:07 -0700 (PDT)
Received: by padhk11 with SMTP id hk11so37840747pad.1
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 12:18:06 -0700 (PDT)
Date: Mon, 19 Oct 2015 12:17:53 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/12] mm: rmap use pte lock not mmap_sem to set
 PageMlocked
In-Reply-To: <5624E31A.9010202@suse.cz>
Message-ID: <alpine.LSU.2.11.1510191204020.4652@eggly.anvils>
References: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils> <alpine.LSU.2.11.1510182148040.2481@eggly.anvils> <56248C5B.3040505@suse.cz> <alpine.LSU.2.11.1510190341490.3809@eggly.anvils> <5624E31A.9010202@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Davidlohr Bueso <dave@stgolabs.net>, Oleg Nesterov <oleg@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andrey Konovalov <andreyknvl@google.com>, Dmitry Vyukov <dvyukov@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

On Mon, 19 Oct 2015, Vlastimil Babka wrote:
> On 10/19/2015 01:20 PM, Hugh Dickins wrote:
> > On Mon, 19 Oct 2015, Vlastimil Babka wrote:
> >> On 10/19/2015 06:50 AM, Hugh Dickins wrote:
> >>> KernelThreadSanitizer (ktsan) has shown that the down_read_trylock()
> >>> of mmap_sem in try_to_unmap_one() (when going to set PageMlocked on
> >>> a page found mapped in a VM_LOCKED vma) is ineffective against races
> >>> with exit_mmap()'s munlock_vma_pages_all(), because mmap_sem is not
> >>> held when tearing down an mm.
> >>>
> >>> But that's okay, those races are benign; and although we've believed
> >>
> >> But didn't Kirill show that it's not so benign, and can leak memory?
> >> - http://marc.info/?l=linux-mm&m=144196800325498&w=2
> > 
> > Kirill's race was this:
> > 
> > 		CPU0				CPU1
> > exit_mmap()
> >    // mmap_sem is *not* taken
> >    munlock_vma_pages_all()
> >      munlock_vma_pages_range()
> >      					try_to_unmap_one()
> > 					  down_read_trylock(&vma->vm_mm->mmap_sem))
> > 					  !!(vma->vm_flags & VM_LOCKED) == true
> >        vma->vm_flags &= ~VM_LOCKED;
> >        <munlock the page>
> >        					  mlock_vma_page(page);
> > 					  // mlocked pages is leaked.
> > 
> > Hmm, I pulled that in to say that it looked benign to me, that he was
> > missing all the subsequent "<munlock the page>" which would correct the
> > situation.  But now I look at it again, I agree with you both: lacking
> > any relevant locking on CPU1 at that point (it has already given up the
> > pte lock there), the whole of "<munlock the page>" could take place on
> > CPU0, before CPU1 reaches its mlock_vma_page(page), yes.
> > 
> > Oh, hold on, no: doesn't page lock prevent that one?  CPU1 has the page
> > lock throughout, so CPU0's <munlock the page> cannot complete before
> > CPU1's mlock_vma_page(page).  So now I disagree with you again!
> 
> 
> I think the page lock doesn't help with munlock_vma_pages_range(). If I
> expand the race above:
> 
> 	CPU0				CPU1
> 					
> exit_mmap()
>   // mmap_sem is *not* taken
>   munlock_vma_pages_all()
>     munlock_vma_pages_range()		
> 					lock_page()
> 					...
>     					try_to_unmap_one()
> 					  down_read_trylock(&vma->vm_mm->mmap_sem))
> 					  !!(vma->vm_flags & VM_LOCKED) == true
>       vma->vm_flags &= ~VM_LOCKED;
>       __munlock_pagevec_fill
>         // this briefly takes pte lock
>       __munlock_pagevec()
> 	// Phase 1
> 	TestClearPageMlocked(page)
> 
>       					  mlock_vma_page(page);
> 					    TestSetPageMlocked(page)
> 					    // page is still mlocked
> 					...
> 					unlock_page()
>         // Phase 2
>         lock_page()
>         if (!__putback_lru_fast_prepare())
>           // true, because page_evictable(page) is false due to PageMlocked
>           __munlock_isolated_page
>           if (page_mapcount(page) > 1)
>              try_to_munlock(page);
>              // this will not help AFAICS
> 
> Now if CPU0 is the last mapper, it will unmap the page anyway
> further in exit_mmap(). If not, it stays mlocked.
> 
> The key problem is that page lock doesn't cover the TestClearPageMlocked(page)
> part on CPU0.

Thank you for expanding: your diagram beats my words.  Yes, I now agree
with you again - but reserve the right the change my mind an infinite
number of times as we look into this for longer.

You can see why mm/mlock.c is not my favourite source file, and every
improvement to it seems to make it worse.  It doesn't help that most of
the functions named "munlock" are about trying to set the mlocked bit.

And while it's there on our screens, let me note that "page_mapcount > 1"
"improvement" of mine is, I believe, less valid in the current multistage
procedure than when I first added it (though perhaps a look back would
prove me just as wrong back then).  But it errs on the safe side (never
marking something unevictable when it's evictable) since PageMlocked has
already been cleared, so I think that it's still an optimization well
worth making for the common case.

> Your patch should help AFAICS. If CPU1 does the mlock under pte lock, the
> TestClear... on CPU0 can happen only after that.
> If CPU0 takes pte lock first, then CPU1 must see the VM_LOCKED flag cleared,
> right?

Right - thanks a lot for giving it more thought.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
