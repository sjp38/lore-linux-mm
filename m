From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14430.51369.57387.224846@dukat.scot.redhat.com>
Date: Tue, 21 Dec 1999 00:24:09 +0000 (GMT)
Subject: RFC: Re: journal ports for 2.3?
In-Reply-To: <000c01bf472c$8ad8cb60$8edb1581@isc.rit.edu>
References: <000c01bf472c$8ad8cb60$8edb1581@isc.rit.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Mason <clmsys@osfmail.isc.rit.edu>
Cc: sct@redhat.com, reiserfs@devlinux.com, linux-fsdevel@vger.rutgers.edu, linux-mm@kvack.org, Andrea Arcangeli <andrea@suse.de>, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Hi,

All comments welcome: this is a first draft outline of what I _think_
Linus is asking for from journaling for mainline kernels.

On Wed, 15 Dec 1999 13:45:22 -0500, Chris Mason
<clmsys@osfmail.isc.rit.edu> said:

> What is your current plan for porting ext3 into 2.3/2.4?  Are you still
> going to be buffer cache based, or do you plan on moving every thing into
> the page cache?

For 2.4 the first release will probably still be in the buffer cache,
but I'm resigned to the fact that Linus won't accept it for a final
merge until it uses an alternative method.

I'd like to talk to you about that if possible.  Right now, it looks
as if the following is the absolute minimum required to make ext3,
reiserfs and any unknown future journaled fs'es work properly in 2.3:

  * Add an extra "async" parameter to super_operations->write_super()
    to distinguish between bdflush and sync()

  * Clean up the rules for allowing the raid5 code to snoop the buffer
    cache: raid5 should consider a buffer locked and transient if it
    has b_count raised

  * The raid resync code needs to be atomic wrt. ll_rw_block()

  * Whatever caching mechanism we use --- page cache or something else
    --- we *must* allow the VM to make callbacks into the filesystem
    to indicate memory pressure.  There are two cases: first, when
    memory gets short, we need to be able to request flush-from-memory
    (including clean pages) secondly, if we detect too many dirty
    buffers, we need to be able to request flush-to-disk (without
    necessarily reclaiming memory, but causing a stall on the calling
    process to act as a throttle on heavy write traffic).

    For the out-of-memory pressure, ideally all we need is a callback on
    the page->mapping address_space.  We have one address space per
    inode, so adding a struct as_operations to the address_space would
    only grow our tables by one pointer per inode, not one pointer per
    pages.

    Shrink_mmap() can easily use such a pointer to perform any
    filesystem-specific tearing-down of the page.

    
    The second case is a little more tricky: currently the only
    mechanism we have for write throttling under heavy write load is the
    refile_buffer() checks in buffer.c.  Ideally there should be a
    system-wide upper bound on dirty data: if each different filesystem
    starts to throttle writes at 50% of physical memory then you only
    need two different filesystems to overcommit your memory badly.

    A PG_Dirty flag, a global counter of dirty pages and a system-wide
    dirty memory threshold would be enough to allow ext3 and reiserfs to
    perform their own write throttling in a way which wouldn't fall
    apart if both ext3 and reiserfs were rpesent in the system at the
    same time.  Making the refile_buffer() checks honour that global
    threshold would be trivial.  

    The PG_Dirty flag would also allow for VM callbacks to be made to
    the filesystems if it was determined that we needed the dirty memory
    pages for some other use (as already happens in the buffer cache if
    try_to_free_buffers fails and wakes up bdflush).  Such a callback
    should also be triggered off the address_space.

There are lots of other things which would be useful to journaling, such
as the ll_rw_block-level write ordering enforcement and write barrier,
but the above is really the minimum necessary to actually get the things
to _work_ without intruding into the buffer cache and without destroying
the system's performance if journaled transactions are allowed to grow
without VM back-pressure.


Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
