Date: Sun, 24 Sep 2000 17:09:40 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2
In-Reply-To: <20000924231240.D5571@athlon.random>
Message-ID: <Pine.LNX.4.10.10009241646560.974-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Sun, 24 Sep 2000, Andrea Arcangeli wrote:
>
> On Sun, Sep 24, 2000 at 10:26:11PM +0200, Ingo Molnar wrote:
> > where will it deadlock?
> 
> ext2_new_block (or whatever that runs getblk with the superlock lock
> acquired)->getblk->GFP->shrink_dcache_memory->prune_dcache->
> prune_one_dentry->dput->dentry_iput->iput->inode->i_sb->s_op->
> put_inode->ext2_discard_prealloc->ext2_free_blocks->lock_super->D

Whee..

Good that you remembered (now that you mention it, I recollect that we had
this bug and discussion earlier).

I added a comment to the effect, although I still moved the __GFP_IO test
into the icache and dcache shrink functions, because as with the
shm_swap() thing this is probably something we do want to fix eventually.

The icache shrinker probably has similar problems with clear_inode.

I suspect that it might be a good idea to try to fix this issue, because
it will probably keep coming up otherwise. And it's likely to be fairly
easily debugged, by just making getblk() have some debugging code that
basically says something like

	lock_super()
	{
		.. do the lock ..
+		current->super_locked++;
	}

	unlock_super()
	{
+		if (current->super_locked < 1)
+			BUG();
+		current->super_locked--;
		.. do the unlock ..
	}

	getblk()
	{
+		if (current->super_locked)
+			BUG();
		.. do the getblk ..
	}

and just making it a new rule that you cannot call getblk() with any locks
held.

It should be fairly easy to make the callers well-behaved: the hard part
is probably just enumerating and finding the suckers, which is why the
above debug code would make people aware of it..

(We definitely don't want to wait for the deadlock to happen and trap that
one: the above code will BUG() out in any normal situation regardless of
whether it would actually trigger a deadlock or even allocate memory or
not. Which is what we'd want if we want to fix this).

On the whole, fixing the cases would probably imply dropping the lock,
doing the read, re-aquireing the lock, and then going back and seeing if
maybe somebody else already filled in the bitmap cache or whatever. So not
one-liners by any means, but we'll probably want to do it at some point
(the superblock lock is quite contended right now, and the reason for that
may well be that it's just so badly done for historical reasons).

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
