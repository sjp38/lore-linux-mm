From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] rd: Use a private inode for backing storage
References: <200710151028.34407.borntraeger@de.ibm.com>
	<200710210928.58265.borntraeger@de.ibm.com>
	<m1zlycc1ut.fsf@ebiederm.dsl.xmission.com>
	<200710211956.50624.nickpiggin@yahoo.com.au>
Date: Sun, 21 Oct 2007 12:39:30 -0600
In-Reply-To: <200710211956.50624.nickpiggin@yahoo.com.au> (Nick Piggin's
	message of "Sun, 21 Oct 2007 19:56:50 +1000")
Message-ID: <m1d4v8b9ct.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

Nick Piggin <nickpiggin@yahoo.com.au> writes:

> On Sunday 21 October 2007 18:23, Eric W. Biederman wrote:
>> Christian Borntraeger <borntraeger@de.ibm.com> writes:
>
>> Let me put it another way.  Looking at /proc/slabinfo I can get
>> 37 buffer_heads per page.  I can allocate 10% of memory in
>> buffer_heads before we start to reclaim them.  So it requires just
>> over 3.7 buffer_heads on very page of low memory to even trigger
>> this case.  That is a large 1k filesystem or a weird sized partition,
>> that we have written to directly.
>
> On a highmem machine it it could be relatively common.

Possibly.  But the same proportions still hold.  1k filesystems
are not the default these days and ramdisks are relatively uncommon.
The memory quantities involved are all low mem.

This is an old problem.  If it was common I suspect we would have
noticed and fixed it long ago.  As far as I can tell this problem dates
back to 2.5.13 in the commit below (which starts clearing the dirty
bit in try_to_free_buffers).  The rd.c had earlier made the transition
from using BH_protected to using the dirty bit to lock it into the
page cache sometime earlier.

>commit acc98edfe3abf531df6cc0ba87f857abdd3552ad
>Author: akpm <akpm>
>Date:   Tue Apr 30 20:52:10 2002 +0000
>
>    [PATCH] writeback from address spaces
>    
>    [ I reversed the order in which writeback walks the superblock's
>      dirty inodes.  It sped up dbench's unlink phase greatly.  I'm
>      such a sleaze ]
>    
>    The core writeback patch.  Switches file writeback from the dirty
>    buffer LRU over to address_space.dirty_pages.
>    
>    - The buffer LRU is removed
>    
>    - The buffer hash is removed (uses blockdev pagecache lookups)
>    
>    - The bdflush and kupdate functions are implemented against
>      address_spaces, via pdflush.
>    
>    - The relationship between pages and buffers is changed.
>    
>      - If a page has dirty buffers, it is marked dirty
>      - If a page is marked dirty, it *may* have dirty buffers.
>      - A dirty page may be "partially dirty".  block_write_full_page
>        discovers this.
>    
>    - A bunch of consistency checks of the form
>    
>        if (!something_which_should_be_true())
>                buffer_error();
>    
>      have been introduced.  These fog the code up but are important for
>      ensuring that the new buffer/page code is working correctly.
>    
>    - New locking (inode.i_bufferlist_lock) is introduced for exclusion
>      from try_to_free_buffers().  This is needed because set_page_dirty
>      is called under spinlock, so it cannot lock the page.  But it
>      needs access to page->buffers to set them all dirty.
>
>      i_bufferlist_lock is also used to protect inode.i_dirty_buffers.
>    
>    - fs/inode.c has been split: all the code related to file data writeback
>      has been moved into fs/fs-writeback.c
>    
>    - Code related to file data writeback at the address_space level is in
>      the new mm/page-writeback.c
>    
>    - try_to_free_buffers() is now non-blocking
>    
>    - Switches vmscan.c over to understand that all pages with dirty data
>      are now marked dirty.
>    
>    - Introduces a new a_op for VM writeback:
>    
>        ->vm_writeback(struct page *page, int *nr_to_write)
>    
>      this is a bit half-baked at present.  The intent is that the address_space
>      is given the opportunity to perform clustered writeback.  To allow it to
>      opportunistically write out disk-contiguous dirty data which may be in other zones.
>      To allow delayed-allocate filesystems to get good disk layout.
>    
>    - Added address_space.io_pages.  Pages which are being prepared for
>      writeback.  This is here for two reasons:
>    
>      1: It will be needed later, when BIOs are assembled direct
>         against pagecache, bypassing the buffer layer.  It avoids a
>         deadlock which would occur if someone moved the page back onto the
>         dirty_pages list after it was added to the BIO, but before it was
>         submitted.  (hmm.  This may not be a problem with PG_writeback logic).
>    
>      2: Avoids a livelock which would occur if some other thread is continually
>         redirtying pages.
>    
>    - There are two known performance problems in this code:
>    
>      1: Pages which are locked for writeback cause undesirable
>         blocking when they are being overwritten.  A patch which leaves
>         pages unlocked during writeback comes later in the series.
>    
>
>  2: While inodes are under writeback, they are locked.  This
>         causes namespace lookups against the file to get unnecessarily
>         blocked in wait_on_inode().  This is a fairly minor problem.
>    
>         I don't have a fix for this at present - I'll fix this when I
>         attach dirty address_spaces direct to super_blocks.
>    
>    - The patch vastly increases the amount of dirty data which the
>      kernel permits highmem machines to maintain.  This is because the
>      balancing decisions are made against the amount of memory in the
>      2: While inodes are under writeback, they are locked.  This
>         causes namespace lookups against the file to get unnecessarily
>         blocked in wait_on_inode().  This is a fairly minor problem.
>    
>         I don't have a fix for this at present - I'll fix this when I
>         attach dirty address_spaces direct to super_blocks.
>    
>    - The patch vastly increases the amount of dirty data which the
>      kernel permits highmem machines to maintain.  This is because the
>      balancing decisions are made against the amount of memory in the
>      machine, not against the amount of buffercache-allocatable memory.
>    
>      This may be very wrong, although it works fine for me (2.5 gigs).
>    
>      We can trivially go back to the old-style throttling with
>      s/nr_free_pagecache_pages/nr_free_buffer_pages/ in
>      balance_dirty_pages().  But better would be to allow blockdev
>      mappings to use highmem (I'm thinking about this one, slowly).  And
>      to move writer-throttling and writeback decisions into the VM (modulo
>      the file-overwriting problem).
>    
>    - Drops 24 bytes from struct buffer_head.  More to come.
>    
>    - There's some gunk like super_block.flags:MS_FLUSHING which needs to
>      be killed.  Need a better way of providing collision avoidance
>      between pdflush threads, to prevent more than one pdflush thread
>      working a disk at the same time.
>    
>      The correct way to do that is to put a flag in the request queue to
>      say "there's a pdlfush thread working this disk".  This is easy to
>      do: just generalise the "ra_pages" pointer to point at a struct which
>      includes ra_pages and the new collision-avoidance flag.
>    
>    BKrev: 3ccf03faM0no6SEm3ltNUkHf4BH1ag


> You don't want to change that for a stable patch, however.
> It fixes the bug.

No it avoids the bug which is something slightly different.
Further I contend that it is not obviously correct that there
are no other side effects (because it doesn't actually fix the
bug), and that makes it of dubious value for a backport.

If I had to slap a patch on there at this point just implementing
an empty try_to_release_page (which disables try_to_free_buffers)
would be my choice.  I just think something that has existed
at least potentially for the entire 2.6 series, and is easy
to avoid is a bit dubious to fix now.

> I just don't think what you have is the proper fix. Calling
> into the core vfs and vm because right now it does something
> that works for you but is completely unrelated to what you
> are conceptually doing is not the right fix.

I think there is a strong conceptual relation and other code
doing largely the same thing is already in the kernel (ramfs).  Plus
my gut feel says shared code will make maintenance easier.

You do have a point that the reuse may not be perfect and if that
is the case we need to watch out for the potential to mess things
up.

So far I don't see any problems with the reuse.

> Also, the patch I posted is big because it did other stuff
> with dynamically allocated ramdisks from loop (ie. a modern
> rewrite). As it is applied to rd.c and split into chunks, the
> actual patch to switch to the new backing store isn't actually
> that big. I'll submit it to -mm after things stabilise after
> the merge window too.

Sounds like a plan.

Eric


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
