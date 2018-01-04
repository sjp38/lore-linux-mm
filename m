Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 35E4A6B04C0
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 00:59:25 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id p1so479640pfp.13
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 21:59:25 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id b60si1834468plc.309.2018.01.03.21.59.23
        for <linux-mm@kvack.org>;
        Wed, 03 Jan 2018 21:59:24 -0800 (PST)
Date: Thu, 4 Jan 2018 16:59:19 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Filesystem crashes due to pages without buffers
Message-ID: <20180104055919.GG30682@dastard>
References: <20180103100430.GE4911@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180103100430.GE4911@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>

On Wed, Jan 03, 2018 at 11:04:30AM +0100, Jan Kara wrote:
> Hello,
> 
> Over the years I have seen so far unexplained crashed in filesystem's
> (ext4, xfs) writeback path due to dirty pages without buffers attached to
> them (see [1] and [2] for relatively recent reports). This was confusing as
> reclaim takes care not to strip buffers from a dirty page and both
> filesystems do add buffers to a page when it is first written to - in
> ->page_mkwrite() and ->write_begin callbacks.
> 
> Recently I have come across a code path that is probably leading to this
> inconsistent state and I'd like to discuss how to best fix the problem
> because it's not obvious to me. Consider the following race:
> 
> CPU1					CPU2
> 
> addr = mmap(file1, MAP_SHARED, ...);
> fd2 = open(file2, O_DIRECT | O_RDONLY);
> read(fd2, addr, len)
>   do_direct_IO()
>     page = dio_get_page()
>       dio_refill_pages()
>         iov_iter_get_pages()
> 	  get_user_pages_fast()
>             - page fault
>               ->page_mkwrite()
>                 block_page_mkwrite()
>                   lock_page(page);
>                   - attaches buffers to page
>                   - makes sure blocks are allocated
>                   set_page_dirty(page)
>               - install writeable PTE
>               unlock_page(page);
>     submit_page_section(page)
>       - submits bio with 'page' as a buffer
> 					kswapd reclaims pages:
> 					...
> 					shrink_page_list()
> 					  trylock_page(page) - this is the
> 					    page CPU1 has just faulted in
> 					  try_to_unmap(page)
> 					  pageout(page);
> 					    clear_page_dirty_for_io(page);
> 					    ->writepage()
> 					  - let's assume page got written
> 					    out fast enough, alternatively
> 					    we could get to the same path as
> 					    soon as the page IO completes
> 					  if (page_has_private(page)) {
> 					    try_to_release_page(page)
> 					      - reclaims buffers from the
> 					        page
> 					   __remove_mapping(page)
> 					     - fails as DIO code still
> 					       holds page reference
> ...
> 
> eventually read completes
>   dio_bio_complete(bio)
>     set_page_dirty_lock(page)
>       Bummer, we've just marked the page as dirty without having buffers.
>       Eventually writeback will find it and filesystem will complain...
> 
> Am I missing something?

My first question is why is kswapd trying to reclaim a page with an
elevated active reference count? i.e. there are active references
the VM *doesn't own* to the page, which means that there may well
a user that expects the state on the page (e.g. the page private
data that the active reference instantiated!) to remain intact until
it drops it's active reference.

That seems like really basic reference counting/reclaim bug to me:
we shouldn't ever attempt to reclaim and free an object while there
are active external references to it that object, regardless of the
subsystem the object belongs to....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
