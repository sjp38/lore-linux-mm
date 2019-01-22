Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6DE838E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 11:46:23 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id a199so22228719qkb.23
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 08:46:23 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r65si5151804qtd.301.2019.01.22.08.46.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 08:46:21 -0800 (PST)
Date: Tue, 22 Jan 2019 11:46:13 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20190122164613.GA3188@redhat.com>
References: <20190112024625.GB5059@redhat.com>
 <b6f4ed36-fc8d-1f9b-8c74-b12f61d496ae@nvidia.com>
 <20190114145447.GJ13316@quack2.suse.cz>
 <20190114172124.GA3702@redhat.com>
 <20190115080759.GC29524@quack2.suse.cz>
 <20190116113819.GD26069@quack2.suse.cz>
 <20190116130813.GA3617@redhat.com>
 <20190117093047.GB9378@quack2.suse.cz>
 <20190117151759.GA3550@redhat.com>
 <20190122152459.GG13149@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190122152459.GG13149@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Tue, Jan 22, 2019 at 04:24:59PM +0100, Jan Kara wrote:
> On Thu 17-01-19 10:17:59, Jerome Glisse wrote:
> > On Thu, Jan 17, 2019 at 10:30:47AM +0100, Jan Kara wrote:
> > > On Wed 16-01-19 08:08:14, Jerome Glisse wrote:
> > > > On Wed, Jan 16, 2019 at 12:38:19PM +0100, Jan Kara wrote:
> > > > > On Tue 15-01-19 09:07:59, Jan Kara wrote:
> > > > > > Agreed. So with page lock it would actually look like:
> > > > > > 
> > > > > > get_page_pin()
> > > > > > 	lock_page(page);
> > > > > > 	wait_for_stable_page();
> > > > > > 	atomic_add(&page->_refcount, PAGE_PIN_BIAS);
> > > > > > 	unlock_page(page);
> > > > > > 
> > > > > > And if we perform page_pinned() check under page lock, then if
> > > > > > page_pinned() returned false, we are sure page is not and will not be
> > > > > > pinned until we drop the page lock (and also until page writeback is
> > > > > > completed if needed).
> > > > > 
> > > > > After some more though, why do we even need wait_for_stable_page() and
> > > > > lock_page() in get_page_pin()?
> > > > > 
> > > > > During writepage page_mkclean() will write protect all page tables. So
> > > > > there can be no new writeable GUP pins until we unlock the page as all such
> > > > > GUPs will have to first go through fault and ->page_mkwrite() handler. And
> > > > > that will wait on page lock and do wait_for_stable_page() for us anyway.
> > > > > Am I just confused?
> > > > 
> > > > Yeah with page lock it should synchronize on the pte but you still
> > > > need to check for writeback iirc the page is unlocked after file
> > > > system has queue up the write and thus the page can be unlock with
> > > > write back pending (and PageWriteback() == trye) and i am not sure
> > > > that in that states we can safely let anyone write to that page. I
> > > > am assuming that in some case the block device also expect stable
> > > > page content (RAID stuff).
> > > > 
> > > > So the PageWriteback() test is not only for racing page_mkclean()/
> > > > test_set_page_writeback() and GUP but also for pending write back.
> > > 
> > > But this is prevented by wait_for_stable_page() that is already present in
> > > ->page_mkwrite() handlers. Look:
> > > 
> > > ->writepage()
> > >   /* Page is locked here */
> > >   clear_page_dirty_for_io(page)
> > >     page_mkclean(page)
> > >       -> page tables get writeprotected
> > >     /* The following line will be added by our patches */
> > >     if (page_pinned(page)) -> bounce
> > >     TestClearPageDirty(page)
> > >   set_page_writeback(page);
> > >   unlock_page(page);
> > >   ...submit_io...
> > > 
> > > IRQ
> > >   - IO completion
> > >   end_page_writeback()
> > > 
> > > So if GUP happens before page_mkclean() writeprotects corresponding PTE
> > > (and these two actions are synchronized on the PTE lock), page_pinned()
> > > will see the increment and report the page as pinned.
> > > 
> > > If GUP happens after page_mkclean() writeprotects corresponding PTE, it
> > > will fault:
> > >   handle_mm_fault()
> > >     do_wp_page()
> > >       wp_page_shared()
> > >         do_page_mkwrite()
> > >           ->page_mkwrite() - that is block_page_mkwrite() or
> > > 	    iomap_page_mkwrite() or whatever filesystem provides
> > > 	  lock_page(page)
> > >           ... prepare page ...
> > > 	  wait_for_stable_page(page) -> this blocks until IO completes
> > > 	    if someone cares about pages not being modified while under IO.
> > 
> > The case i am worried is GUP see pte with write flag set but has not
> > lock the page yet (GUP is get pte first, then pte to page then lock
> > page), then it locks the page but the lock page can make it wait for a
> > racing page_mkclean()...write back that have not yet write protected
> > the pte the GUP just read. So by the time GUP has the page locked the
> > pte it read might no longer have the write flag set. Hence why you need
> > to also check for write back after taking the page lock. Alternatively
> > you could recheck the pte after a successful try_lock on the page.
> 
> This isn't really possible. GUP does:
> 
> get_user_pages()
> ...
>   follow_page_mask()
>   ...
>     follow_page_pte()
>       ptep = pte_offset_map_lock()
>       check permissions and page sanity
>       if (flags & FOLL_GET)
>         get_page(page); -> this would become
> 	  atomic_add(&page->_refcount, PAGE_PIN_BIAS);
>       pte_unmap_unlock(ptep, ptl);
> 
> page_mkclean() on the other hand grabs the same pte lock to change the pte
> to write-protected. So after page_mkclean() has modified the PTE we are
> racing on for access, we are sure to either see increased _refcount or get
> page fault from GUP.
> 
> If we see increased _refcount, we bounce the page and are fine. If GUP
> faults, we will wait for page lock (so wait until page is prepared for IO
> and has PageWriteback set) while handling the fault, then enter
> ->page_mkwrite, which will do wait_for_stable_page() -> wait for
> outstanding writeback to complete.
> 
> So I still conclude - no need for page lock in the GUP path at all AFAICT.
> In fact we rely on the very same page fault vs page writeback synchronization
> for normal user faults as well. And normal user mmap access is even nastier
> than GUP access because the CPU reads page tables without taking PTE lock.

For the "slow" GUP path you are right you do not need a lock as the
page table lock give you the ordering. For the GUP fast path you
would either need the lock or the memory barrier with the test for
page write back.

Maybe an easier thing is to convert GUP fast to try to take the page
table lock if it fails taking the page table lock then we fall back
to slow GUP path. Otherwise then we have the same garantee as the slow
path.

The issue is that i am not sure if the page table directory page and
it's associated spinlock can go in bad state if the directory is being
freed (like a racing munmap). This would need to be check. A scheme
that might protect against that is to take the above lock of each level
before going down one level. Once you are down one level you can unlock
the above level. So at any point in time GUP fast holds the lock to a
current and valid directory and thus no one could race to remove it.

    GUP_fast()
      gup_pgd_range()
        if (p4d_try_map_lock()) {
          gup_p4d_range()
          if (pud_try_map_lock()) {
            p4d_unlock();
            gup_pud_range();
              if (pmd_try_map_lock()) {
                pud_unlock();
                gup_pmd_range();
                  if (pte_try_map_lock()) {
                    pmd_unlock();
                    // Do gup
                  }
             }
          }
       }

Maybe this is worse than taking the mmap_sem and checking for vma.


> > > > > That actually touches on another question I wanted to get opinions on. GUP
> > > > > can be for read and GUP can be for write (that is one of GUP flags).
> > > > > Filesystems with page cache generally have issues only with GUP for write
> > > > > as it can currently corrupt data, unexpectedly dirty page etc.. DAX & memory
> > > > > hotplug have issues with both (DAX cannot truncate page pinned in any way,
> > > > > memory hotplug will just loop in kernel until the page gets unpinned). So
> > > > > we probably want to track both types of GUP pins and page-cache based
> > > > > filesystems will take the hit even if they don't have to for read-pins?
> > > > 
> > > > Yes the distinction between read and write would be nice. With the map
> > > > count solution you can only increment the mapcount for GUP(write=true).
> > > 
> > > Well, but if we track only pins for write, DAX or memory hotplug will not
> > > be able to use this mechanism. So at this point I'm more leaning towards
> > > tracking all pins. It will cost some performance needlessly for read pins
> > > and filesystems using page cache when bouncing such pages but it's not like
> > > writeback of pinned pages is some performance critical operation... But I
> > > wanted to spell this out so that people are aware of this.
> > 
> > No they would know for regular pin, it is just as page migrate code. If
> > the refcount + (extra_ref_by_the_code_checking) > mapcount then you know
> > someone has extra reference on your page.
> > 
> > Those extra references are either some regular fs event taking place (some
> > code doing find_get_page for instance) or a GUP reference (wether it is a
> > write pin or a read pin).
> > 
> > So the only issue is false positive, ie thinking the page is under GUP
> > while it has just elevated refcount because of some other regular fs/mm
> > event. To minimize false positive for a more accurate pin test (write or
> > read) you can enforce few thing:
> > 
> >     1 - first page lock
> >     2 - then freeze the page with expected counted
> > 
> > With that it should minimize false positive. In the end even with the bias
> > case you can also have false positive.
> 
> So this is basically what the code is currently doing. And for DAX it works
> well since the page is being truncated and so essentially nobody is
> touching it. But for hotplug it doesn't work quite well - hotplug would
> like to return EBUSY to userspace when the page is pinned but retry if the
> page reference is just transient.

I do not think there is anyway around transient refcount other
than periodicaly check. Maybe hot unplug (i am assuming we are
talking about unplug here) can set the reserved page flag and
we can change the page get ref to never inc refcount for page
with reserved flag. I see that they have been cleanup on going
around reserved page so it might or might not be possible.

Also it would mean that get_page() could now fail and we would
need to update all path that do that to handle this case. Then
you know that if the freeze fails it must be because of read
GUP (no transient refcount can happen).

Or another way is to record page refcount at time t and then
compare it at time t+timeout and if it matches then consider the
refcount to be from a GUP read and not a transient refcount,
this should at very least drasticly reduce the likely hood of
a false GUP positive because of a transient refcount inc.

Cheers,
Jérôme
