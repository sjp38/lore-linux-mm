Date: Sun, 24 Sep 2000 20:49:12 -0400 (EDT)
From: Alexander Viro <viro@math.psu.edu>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2
In-Reply-To: <Pine.LNX.4.10.10009241646560.974-100000@penguin.transmeta.com>
Message-ID: <Pine.GSO.4.21.0009242034440.14096-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Sun, 24 Sep 2000, Linus Torvalds wrote:

> > ext2_new_block (or whatever that runs getblk with the superlock lock
> > acquired)->getblk->GFP->shrink_dcache_memory->prune_dcache->
> > prune_one_dentry->dput->dentry_iput->iput->inode->i_sb->s_op->
> > put_inode->ext2_discard_prealloc->ext2_free_blocks->lock_super->D
> 
> Whee..
[snip] 

> On the whole, fixing the cases would probably imply dropping the lock,
> doing the read, re-aquireing the lock, and then going back and seeing if
> maybe somebody else already filled in the bitmap cache or whatever. So not
> one-liners by any means, but we'll probably want to do it at some point
> (the superblock lock is quite contended right now, and the reason for that
> may well be that it's just so badly done for historical reasons).

Nope. Solution is to kill the silly "hold super_block lock during the
allocation" completely. Right now the main problem making us use it at all
is the following: dquot_alloc_block() is a blocking operation. If that
gets fixed - that's it. We simply don't need anything more fancy than
rwlock on access to bitmap + rwlock or plain spinlock on access to group
descriptors cache. End of problem.

Remember that off-list thread in July when you asked what could be done
with lock_super()? I did the analysis, all right - list of ext2 races was
a side effect of that. Now we have that crap fixed, so getting rid of
lock_super() in ext2 (in clear way) is possible. So if you still want it -
tell. ext2 part is very easy, it's quota part that needs serious work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
