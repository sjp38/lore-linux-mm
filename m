Date: Mon, 25 Sep 2000 01:19:22 -0400 (EDT)
From: Alexander Viro <viro@math.psu.edu>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2
In-Reply-To: <Pine.LNX.4.10.10009242142510.1224-100000@penguin.transmeta.com>
Message-ID: <Pine.GSO.4.21.0009250101150.14096-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, Alexander Viro <aviro@redhat.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Sun, 24 Sep 2000, Linus Torvalds wrote:

> The remaining part if the directory handling. THAT is very buffer-cache
> intensive, as the directory handling hasn't been moved over to the page
> cache at all for ext2. Doing a large "find" (or even just a "ls -l") will
> basically do purely buffer cache accesses, first for the directory data
> and then for the inode data. With no page cache activity to balance things
> out at all - leading to a potentially quite unbalanced VM that never
> really had a good chance to get rid of dentries etc.

You forgot inode tables themselves.

> Al, if you'd port over the "namei in page-cache" stuff from UFS to ext2, I
> bet that there would be people interested in seeing whether the above
> theory is just another of Linu's whimsies, or whether it really does make
> a difference.. It may not be 2.4.x material, but it won't hurt to have it
> tested some more anyway. Comments?

I'll do it and post the result tomorrow. I bet that there will be issues
I've overlooked (stuff that happens to work on UFS, but needs to be more
general for ext2), so it's going as "very alpha", but hey, it's pretty
straightforward, so there is a chance to debug it fast. Yes, famous last
words and all such...

BTW, we _will_ need it on UFS side in 2.4 anyway. Rationale:
	* UFS _does_ fragments, whether we like it or not.
	* Reallocating fragments for regular files can not be done by
bread()+getblk()+memcpy()+mark_buffer_dirty() - data is in pagecache, so
that's an instant death
	* to get UFS working with pagecache and not eating filesystems we
must do fragment reallocation through pagecache
	* it means that we either duplicate the whole mess both for buffer
cache (directories) and pagecache (inodes) or move directories to
pagecache
	The former (pagecache duplicate of the reallocation code) is
nasty since we have to separate the current realloc stuff from the code
pathes where it sits right now anyway - it's merged into the functions
used by pagecache side. I.e. we would have to
	* do pagecache fragment handling
	* rip the buffer-cache fragment handling out
	* redo it, so that it would live outside of the path used by
pagecache side
	* change the callers.
The last couple means more work than switching directories to pagecache. 

	So some variant of directories in pagecache is needed for 2.4, the
question being whether it's UFS-only or we use its port on ext2... BTW,
minixfs/sysvfs can also use the thing, but that's another story.

	Off to port the bloody thing...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
