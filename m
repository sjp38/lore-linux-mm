Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id 6C4BC82F7F
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 07:20:20 -0400 (EDT)
Received: by obbzf10 with SMTP id zf10so135556344obb.2
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 04:20:20 -0700 (PDT)
Received: from mail-oi0-x234.google.com (mail-oi0-x234.google.com. [2607:f8b0:4003:c06::234])
        by mx.google.com with ESMTPS id d206si11326770oig.18.2015.10.19.04.20.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Oct 2015 04:20:19 -0700 (PDT)
Received: by oiev17 with SMTP id v17so48634801oie.2
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 04:20:19 -0700 (PDT)
Date: Mon, 19 Oct 2015 04:20:05 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/12] mm: rmap use pte lock not mmap_sem to set
 PageMlocked
In-Reply-To: <56248C5B.3040505@suse.cz>
Message-ID: <alpine.LSU.2.11.1510190341490.3809@eggly.anvils>
References: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils> <alpine.LSU.2.11.1510182148040.2481@eggly.anvils> <56248C5B.3040505@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Davidlohr Bueso <dave@stgolabs.net>, Oleg Nesterov <oleg@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andrey Konovalov <andreyknvl@google.com>, Dmitry Vyukov <dvyukov@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

On Mon, 19 Oct 2015, Vlastimil Babka wrote:
> On 10/19/2015 06:50 AM, Hugh Dickins wrote:
> > KernelThreadSanitizer (ktsan) has shown that the down_read_trylock()
> > of mmap_sem in try_to_unmap_one() (when going to set PageMlocked on
> > a page found mapped in a VM_LOCKED vma) is ineffective against races
> > with exit_mmap()'s munlock_vma_pages_all(), because mmap_sem is not
> > held when tearing down an mm.
> > 
> > But that's okay, those races are benign; and although we've believed
> 
> But didn't Kirill show that it's not so benign, and can leak memory?
> - http://marc.info/?l=linux-mm&m=144196800325498&w=2

Kirill's race was this:

		CPU0				CPU1
exit_mmap()
  // mmap_sem is *not* taken
  munlock_vma_pages_all()
    munlock_vma_pages_range()
    					try_to_unmap_one()
					  down_read_trylock(&vma->vm_mm->mmap_sem))
					  !!(vma->vm_flags & VM_LOCKED) == true
      vma->vm_flags &= ~VM_LOCKED;
      <munlock the page>
      					  mlock_vma_page(page);
					  // mlocked pages is leaked.

Hmm, I pulled that in to say that it looked benign to me, that he was
missing all the subsequent "<munlock the page>" which would correct the
situation.  But now I look at it again, I agree with you both: lacking
any relevant locking on CPU1 at that point (it has already given up the
pte lock there), the whole of "<munlock the page>" could take place on
CPU0, before CPU1 reaches its mlock_vma_page(page), yes.

Oh, hold on, no: doesn't page lock prevent that one?  CPU1 has the page
lock throughout, so CPU0's <munlock the page> cannot complete before
CPU1's mlock_vma_page(page).  So now I disagree with you again!

> Although as I noted, it probably doesn't leak completely. But a page will
> remain unevictable, until its last user unmaps it, which is again not
> completely benign?
> - http://marc.info/?l=linux-mm&m=144198536831589&w=2

I agree that we'd be wrong to leave a page on the unevictable lru
indefinitely once it's actually evictable.  But I think my change is
only making the above case easier to think about: trylock on mmap_sem
is a confusing distraction from where the proper locking is done,
whether it be page lock or pte lock.

> 
> 
> > for years in that ugly down_read_trylock(), it's unsuitable for the job,
> > and frustrates the good intention of setting PageMlocked when it fails.
> > 
> > It just doesn't matter if here we read vm_flags an instant before or
> > after a racing mlock() or munlock() or exit_mmap() sets or clears
> > VM_LOCKED: the syscalls (or exit) work their way up the address space
> > (taking pt locks after updating vm_flags) to establish the final state.
> > 
> > We do still need to be careful never to mark a page Mlocked (hence
> > unevictable) by any race that will not be corrected shortly after.
> 
> And waiting for the last user to unmap the page is not necessarily shortly
> after :)
> 
> Anyway pte lock looks like it could work, but I'll need to think about it
> some more, because...
> 
> > The page lock protects from many of the races, but not all (a page
> > is not necessarily locked when it's unmapped).  But the pte lock we
> > just dropped is good to cover the rest (and serializes even with
> > munlock_vma_pages_all(),
> 
> Note how munlock_vma_pages_range() via __munlock_pagevec() does
> TestClearPageMlocked() without (or "between") pte or page lock. But the pte
> lock is being taken after clearing VM_LOCKED, so perhaps it's safe against
> try_to_unmap_one...

A mind-trick I found helpful for understanding the barriers here, is
to imagine that the munlocker repeats its "vma->vm_flags &= ~VM_LOCKED"
every time it takes the pte lock: it does not actually do that, it
doesn't need to of course; but that does help show that ~VM_LOCKED
must be visible to anyone getting that pte lock afterwards.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
