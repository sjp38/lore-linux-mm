Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id VAA08298
	for <linux-mm@kvack.org>; Fri, 8 Jan 1999 21:13:25 -0500
Date: Sat, 9 Jan 1999 02:13:08 GMT
Message-Id: <199901090213.CAA05306@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: arca-vm-8 [Re: [patch] arca-vm-6, killed kswapd [Re: [patch] new-vm , improvement , [Re: 2.2.0 Bug summary]]]
In-Reply-To: <Pine.LNX.3.95.990107093746.4270H-100000@penguin.transmeta.com>
References: <m1aezvg0vw.fsf@flinx.ccr.net>
	<Pine.LNX.3.95.990107093746.4270H-100000@penguin.transmeta.com>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Eric W. Biederman" <ebiederm+eric@ccr.net>, Andrea Arcangeli <andrea@e-mind.com>, steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 7 Jan 1999 09:56:03 -0800 (PST), Linus Torvalds
<torvalds@transmeta.com> said:

> That way I can be reasonably hopeful that there are no new bugs introduced
> even though performance is very different. I _do_ have some early data
> that seems to say that this _has_ uncovered a very old deadlock condition: 
> something that could happen before but was almost impossible to trigger. 

> The deadlock I suspect is:
>  - we're low on memory
>  - we allocate or look up a new block on the filesystem. This involves
>    getting the ext2 superblock lock, and doing a "bread()" of the free
>    block bitmap block.
>  - this causes us to try to allocate a new buffer, and we are so low on
>    memory that we go into try_to_free_pages() to find some more memory.
>  - try_to_free_pages() finds a shared memory file to page out.
>  - trying to page that out, it looks up the buffers on the filesystem it
>    needs, but deadlocks on the superblock lock.

Hmm, I think that's a new one to me, but add to that one which I think
we've come across before and which I have not even thought about for a
couple of years at least: a large write() to a mmap()ed file can
deadlock for a similar reason, but on the inode write lock instead of
the superblock lock.

> The positive news is that if I'm right in my suspicions it can only happen
> with shared writable mappings or shared memory segments. The bad news is
> that the bug appears rather old, and no immediate solution presents
> itself. 

A couple solutions which come to mind: (1) make the superblock lock
recursive (ugh, horrible and it only works if we have an additional
mechanism to pin down bitmap buffers in the bitmap cache), or (2) allow
load_block_bitmap and friends to drop the superblock if it finds that it
needs to do an IO, and repeat if it happened.  However, what we're
basically saying here is that all operations on the superblock_lock have
to drop the lock if they want to allocate memory, and that's not a great
deal of fun: we might as well use the kernel spinlock.

It gets worse, because of course we cannot even rely on kswapd to
function correctly in this situation --- it will block on the superblock
lock just as happily as the current process's try_to_free_pages call
will.

I think the cleanest solution may be to reimplement some form of the old
GFP_IO flag, to prevent us from trying to use IO inside
try_to_free_pages() if we know we already have a lock which could
deadlock.  The easiest way I can see of achieving something like this is
to set current->flags |= PF_MEMALLOC while we hold the superblock lock,
or create another PF_NOIO flag which prevents try_to_free_pages from
doing anything with dirty pages.  I suspect that the PF_MEMALLOC option
might be good enough for starters; it will only do the wrong thing if we
have entirely exhausted the free page list.

The inode deadlock at least is relatively easy to fix, either by making
the inodelock recursive, or by having a separate sharable truncate lock
to prevent pages from being invalidated in the middle of the pageout
(which was the reason for the down() in the filemap write-page code in
the first place).  The truncate lock (or allocation/deallocation lock,
if you want to do it that way) makes a ton of sense; it avoids
serialising all writes while still making sure that truncates themselves
are exclusively locked.

>> 2) I have tested using PG_dirty from shrink_mmap and it is a
>> performance problem because it loses all locality of reference,
>> and because it forces shrink_mmap into a dual role, of freeing and
>> writing pages, which need seperate tuning.

> Exactly. This is part of the complexity.

> The right solution (I _think_) is to conceptually always mark it PG_dirty
> in vmscan, and basically leave all the nasty cases to the filemap physical
> page scan. But in the simple cases (ie a swap-cached page that is only
> mapped by one process and doesn't have any other users), you'd start the
> IO "early".

The trouble is that when we come to do the physical IO, we really want
to cluster the IOs.  Doing the swap cache allocation from vmscan means
that we'll still be allocating virtually adjacent memory pages to
adjacent swap pages, but if we don't do the IO itself until
shrink_mmap(), we'll lose the IO clustering which we need for good
swapout performance.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
