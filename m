Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E28B8280244
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 06:33:06 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id 194so732461wmv.9
        for <linux-mm@kvack.org>; Thu, 04 Jan 2018 03:33:06 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a98si2510283wrc.299.2018.01.04.03.33.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 04 Jan 2018 03:33:05 -0800 (PST)
Date: Thu, 4 Jan 2018 12:33:01 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: Filesystem crashes due to pages without buffers
Message-ID: <20180104113301.GE29010@quack2.suse.cz>
References: <20180103100430.GE4911@quack2.suse.cz>
 <CAPcyv4grBxGs0cnFVyRx29t0xhG5EBTy_nP=qhsVh5=8nusNsw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4grBxGs0cnFVyRx29t0xhG5EBTy_nP=qhsVh5=8nusNsw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jan Kara <jack@suse.cz>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-xfs <linux-xfs@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Wed 03-01-18 20:56:32, Dan Williams wrote:
> On Wed, Jan 3, 2018 at 2:04 AM, Jan Kara <jack@suse.cz> wrote:
> > Hello,
> >
> > Over the years I have seen so far unexplained crashed in filesystem's
> > (ext4, xfs) writeback path due to dirty pages without buffers attached to
> > them (see [1] and [2] for relatively recent reports). This was confusing as
> > reclaim takes care not to strip buffers from a dirty page and both
> > filesystems do add buffers to a page when it is first written to - in
> > ->page_mkwrite() and ->write_begin callbacks.
> >
> > Recently I have come across a code path that is probably leading to this
> > inconsistent state and I'd like to discuss how to best fix the problem
> > because it's not obvious to me. Consider the following race:
> >
> > CPU1                                    CPU2
> >
> > addr = mmap(file1, MAP_SHARED, ...);
> > fd2 = open(file2, O_DIRECT | O_RDONLY);
> > read(fd2, addr, len)
> >   do_direct_IO()
> >     page = dio_get_page()
> >       dio_refill_pages()
> >         iov_iter_get_pages()
> >           get_user_pages_fast()
> >             - page fault
> >               ->page_mkwrite()
> >                 block_page_mkwrite()
> >                   lock_page(page);
> >                   - attaches buffers to page
> >                   - makes sure blocks are allocated
> >                   set_page_dirty(page)
> >               - install writeable PTE
> >               unlock_page(page);
> >     submit_page_section(page)
> >       - submits bio with 'page' as a buffer
> >                                         kswapd reclaims pages:
> >                                         ...
> >                                         shrink_page_list()
> >                                           trylock_page(page) - this is the
> >                                             page CPU1 has just faulted in
> >                                           try_to_unmap(page)
> >                                           pageout(page);
> >                                             clear_page_dirty_for_io(page);
> >                                             ->writepage()
> >                                           - let's assume page got written
> >                                             out fast enough, alternatively
> >                                             we could get to the same path as
> >                                             soon as the page IO completes
> >                                           if (page_has_private(page)) {
> >                                             try_to_release_page(page)
> >                                               - reclaims buffers from the
> >                                                 page
> >                                            __remove_mapping(page)
> >                                              - fails as DIO code still
> >                                                holds page reference
> > ...
> >
> > eventually read completes
> >   dio_bio_complete(bio)
> >     set_page_dirty_lock(page)
> >       Bummer, we've just marked the page as dirty without having buffers.
> >       Eventually writeback will find it and filesystem will complain...
> >
> > Am I missing something?
> >
> > The problem here is that filesystems fundamentally assume that a page can
> > be written to only between ->write_begin - ->write_end (in this interval
> > the page is locked), or between ->page_mkwrite - ->writepage and above is
> > an example where this does not hold because when a page reference is
> > acquired through get_user_pages(), page can get written to by the holder of
> > the reference and dirtied even after it has been unmapped from page tables
> > and ->writepage has been called. This is not only a cosmetic issue leading
> > to assertion failure but it can also lead to data loss, data corruption, or
> > other unpleasant surprises as filesystems assume page contents cannot be
> > modified until either ->write_begin() or ->page_mkwrite gets called and
> > those calls are serialized by proper locking with problematic operations
> > such as hole punching etc.
> >
> > I'm not sure how to fix this problem. We could 'simulate' a writeable page
> > fault in set_page_dirty_lock(). It is a bit ugly since we don't have a
> > virtual address of the fault, don't hold mmap_sem, etc., possibly
> > expensive, but it would make filesystems happy. Data stored by GUP user
> > (e.g. read by DIO in the above case) could still get lost if someone e.g.
> > punched hole under the buffer or otherwise messed with the underlying
> > storage of the page while DIO was running but arguably users could expect
> > such outcome.
> >
> > Another possible solution would be to make sure page is writeably mapped
> > until GUP user drops its reference. That would be arguably cleaner but
> > probably that would mean we have to track number of writeable GUP page
> > references separately (no space space in struct page is a problem here) and
> > block page_mkclean() until they are dropped. Also for long term GUP users
> > like Infiniband or V4L we'd have to come up with some solution as we should
> > not block page_mkclean() for so long.
> 
> Do we need to block page_mkclean, or could we defer buffer reclaiming
> to the last put of the page?

As I wrote to Dave the problem is no so much with reclaiming of buffers but
with the fact filesystems don't expect page can be dirtied after
page_mkclean() is finished.

> I think once we have the "register memory with lease" mechanism for
> Infiniband we could expand it to the page cache case. The problem is
> the regression this would cause with userspace that expects it can
> maintain file backed memory registrations indefinitely.
> 
> What are the implications of holding off page_mkclean or release
> buffers indefinitely?

Bad. You cannot write the page to disk until page_mkclean() finishes as
page_mkclean() is part of clear_page_dirty_for_io(). And we really do need
that functionality there e.g. to make sure tail of the last page in the
file is properly zeroed out, storage with DIF/DIX can compute checksum of
the data safely before submitting it to the device etc.

> Is an indefinite / interruptible sleep waiting for the 'put' event of
> a get_user_pages() page unacceptable? The current case that the file
> contents will not be coherent with respect to in-flight RDMA, perhaps
> waiting for that to complete is better than cleaning buffers from the
> page prematurely.

Yeah, indefinite sleep is really a no-go.

> > As a side note DAX needs some solution for GUP users as well. The problems
> > are similar there in nature, just much easier to hit. So at least a
> > solution for long-term GUP users can (and I strongly believe should) be
> > shared between standard and DAX paths.
> 
> In the DAX case we rely on the fact that when the page goes idle we
> only need to worry about the filesytem block map changing, the page
> won't get reallocated somewhere else. We can't use page idle as an
> event in this case, however, if the page reference count is one then
> the DIO code can know that it has the page exclusively, so maybe DAX
> and non-DAX can share the page count == 1 event notification.

The races I describe do not need to involve truncate / hole punching. It is
just enough to race with page writeback. So page references are of no use
here. We would have to specifically track number of references acquired by
GUP or something like that. So what I wanted to share with DAX is the
long-term pin handling, the rest is unclear for now.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
