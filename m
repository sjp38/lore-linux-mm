Date: Fri, 5 Jul 2002 02:27:37 -0400 (EDT)
From: Alexander Viro <viro@math.psu.edu>
Subject: Re: vm lock contention reduction
In-Reply-To: <Pine.LNX.4.44.0207042257210.7465-100000@home.transmeta.com>
Message-ID: <Pine.GSO.4.21.0207050218520.14718-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Andrew Morton <akpm@zip.com.au>, Rik van Riel <riel@conectiva.com.br>, Andrea Arcangeli <andrea@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Thu, 4 Jul 2002, Linus Torvalds wrote:

> In particular, the ext2 superblock lock at least used to be horribly
> broken and held in a lot of "bad" places: I doubt Al has gotten far enough
> to fix that brokenness. The superblock lock used to cause one process that

As the matter of fact, I did.  If you want lock_super() to be killed in ext2
(2.5) - just say so and I'll do the rest.

Right now both ext2_new_block() and ext2_new_inode() look through the
group descriptors for good one and reserve (block|inode) in it.  That
can be easily done under a spinlock.  After that we read a bitmap
(no need for any locks) and grab a bit in it (we are guaranteed to
have one).  The latter can be either done under a spinlock or by being
clever and noticing that amount of contenders is always less or equal
the number of free bits (with minimal use of set_bit()/etc. atomicity
we can do that without spinlocks).  After that we don't need any locks
whatsoever.

Andrew had just killed the last bit of crap there - LRU used to be protected
by lock_super() and since it's no more...

Rewrite of balloc.c and ialloc.c was done with killing lock_super() in mind -
I didn't want to do that in 2.4 for obvious reasons, but for 2.5 it's very
easy...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
