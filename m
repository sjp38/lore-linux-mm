Date: Mon, 2 Oct 2000 23:57:03 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [highmem bug report against -test5 and -test6] Re: [PATCH] Re:
 simple FS application that hangs 2.4-test5, mem mgmt problem or FS buffer
 cache mgmt problem? (fwd)
In-Reply-To: <Pine.LNX.4.10.10010021417200.826-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0010022337030.13733-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, MM mailing list <linux-mm@kvack.org>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Oct 2000, Linus Torvalds wrote:

> > except for writes, there we cache the block # in the bh and do not have to
> > call the lowlevel FS repeatedly to calculate the FS position of the page.
> 
> Oh, I agree 100%.
> 
> Note that this is why I think we should just do it the way we used to
> handle it: we keep the buffer heads around "indefinitely" (because we
> _may_ need them - we don't know a priori one way or the other), but
> because they _do_ potentially use up a lot of memory we do free them in
> the normal aging process when we're low on memory.

yep, this would be nice, but i think it will be quite tough to balance
this properly. There are two kinds of bhs in this aging scheme: 'normal'
bhs (metadata), and 'virtual' bhs (aliased to a page). Freeing a 'normal'
bh will get rid of the bh, and will (statistically) free the data buffer
behind. A 'virtual' bh on the other hand has only sizeof(*bh) bytes worth
of RAM footprint.

another thing is the complexity of marking a page dirty - right now we can
assume that page->buffers holds all the blocks. With aging we must check
wether a bh is there or not, which further complicates the block_*()
functions in buffer.c. Plus some sort of locking has to be added as well -
right now we dont have to care about anyone else accessing page->buffers
if the PG_lock held - with an aging mechanizm this could get tougher.
(unless the buffer-cache aging mechanizm 'knows' about pages and locks
them - this is what my former hash-all-buffers scheme did :-)

but i agree, currently even in the 4k filesystem case the per-page bh
causes +2.0% data-cache RAM footprint. (struct page accounts for ~1.7%)

> So if we have "lots" of memory, we basically optimize for speed (leave
> the cached mapping around), while if we get low on memory we
> automatically optimize for space (get rid of bh's when we don't know
> that we'll need them).

i'd love to have all the cached objects within the system on a global,
size-neutral LRU list. (or at least attach a last-accessed timestamp to
them.) This way we could synchronize the pagecache, inode/dentry and
buffer-cache LRU lists.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
