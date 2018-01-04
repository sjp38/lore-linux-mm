Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0B638280245
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 03:52:48 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id g33so771735plb.13
        for <linux-mm@kvack.org>; Thu, 04 Jan 2018 00:52:48 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j33si2003126pld.699.2018.01.04.00.52.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 04 Jan 2018 00:52:46 -0800 (PST)
Date: Thu, 4 Jan 2018 09:52:44 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: Filesystem crashes due to pages without buffers
Message-ID: <20180104085244.GA29010@quack2.suse.cz>
References: <20180103100430.GE4911@quack2.suse.cz>
 <20180104055919.GG30682@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180104055919.GG30682@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>

On Thu 04-01-18 16:59:19, Dave Chinner wrote:
> On Wed, Jan 03, 2018 at 11:04:30AM +0100, Jan Kara wrote:
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
> > CPU1					CPU2
> > 
> > addr = mmap(file1, MAP_SHARED, ...);
> > fd2 = open(file2, O_DIRECT | O_RDONLY);
> > read(fd2, addr, len)
> >   do_direct_IO()
> >     page = dio_get_page()
> >       dio_refill_pages()
> >         iov_iter_get_pages()
> > 	  get_user_pages_fast()
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
> > 					kswapd reclaims pages:
> > 					...
> > 					shrink_page_list()
> > 					  trylock_page(page) - this is the
> > 					    page CPU1 has just faulted in
> > 					  try_to_unmap(page)
> > 					  pageout(page);
> > 					    clear_page_dirty_for_io(page);
> > 					    ->writepage()
> > 					  - let's assume page got written
> > 					    out fast enough, alternatively
> > 					    we could get to the same path as
> > 					    soon as the page IO completes
> > 					  if (page_has_private(page)) {
> > 					    try_to_release_page(page)
> > 					      - reclaims buffers from the
> > 					        page
> > 					   __remove_mapping(page)
> > 					     - fails as DIO code still
> > 					       holds page reference
> > ...
> > 
> > eventually read completes
> >   dio_bio_complete(bio)
> >     set_page_dirty_lock(page)
> >       Bummer, we've just marked the page as dirty without having buffers.
> >       Eventually writeback will find it and filesystem will complain...
> > 
> > Am I missing something?
> 
> My first question is why is kswapd trying to reclaim a page with an
> elevated active reference count? i.e. there are active references
> the VM *doesn't own* to the page, which means that there may well
> a user that expects the state on the page (e.g. the page private
> data that the active reference instantiated!) to remain intact until
> it drops it's active reference.

Page private data (and most of page state) is protected by a page lock, not
by a page reference. So reclaim (which is holding the page lock) is free to
try to reclaim page private data by calling ->releasepage callback.

That being said you are right that the attempt to reclaim a page with
active references is futile. But the problem is that we don't know how many
page references are actually left before we unmap the page from page tables
(each page table entry holds a page reference) and free page private data
(as that may hold page reference as well - e.g. attach_page_buffers()
acquires page reference). So checking page references in advance is
difficult.

Furthermore the core of the problem is not in the fact that page buffers
are reclaimed. That just makes it visible. The real problem is that page can
be written to by a GUP user while it is neither writeably mapped in page
tables nor prepared with ->write_begin. So a similar race violating
filesystem's assumptions can be like:

CPU1					CPU2

addr = mmap(file1, MAP_SHARED, ...);
fd2 = open(file2, O_DIRECT | O_RDONLY);
read(fd2, addr, len)
  do_direct_IO()
    ...
    page = get_user_pages_fast()
      - page fault handled
    submit_page_section(page)
      - submits bio with 'page' as a buffer
					ordinary writeback:
					writepages(file1)
					  clear_page_dirty_for_io(page)
					    - page gets writeprotected in
					      page tables
...
eventually read completes
  dio_bio_complete(bio)
    set_page_dirty_lock(page)

And a race like this is enough to cause data corruption if we are unlucky.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
