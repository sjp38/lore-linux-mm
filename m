Date: Sun, 24 Sep 2000 21:53:33 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2
In-Reply-To: <Pine.LNX.4.10.10009241646560.974-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0009242143040.2029-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 24 Sep 2000, Linus Torvalds wrote:

> 
> 
> On Sun, 24 Sep 2000, Andrea Arcangeli wrote:
> >
> > On Sun, Sep 24, 2000 at 10:26:11PM +0200, Ingo Molnar wrote:
> > > where will it deadlock?
> > 
> > ext2_new_block (or whatever that runs getblk with the superlock lock
> > acquired)->getblk->GFP->shrink_dcache_memory->prune_dcache->
> > prune_one_dentry->dput->dentry_iput->iput->inode->i_sb->s_op->
> > put_inode->ext2_discard_prealloc->ext2_free_blocks->lock_super->D
> 
> Whee..
> 
> Good that you remembered (now that you mention it, I recollect that we had
> this bug and discussion earlier).
> 
> I added a comment to the effect, although I still moved the __GFP_IO test
> into the icache and dcache shrink functions, because as with the
> shm_swap() thing this is probably something we do want to fix eventually.

Btw, why we need kmem_cache_shrink() inside shrink_{i,d}cache_memory ?  

Since refill_inactive and do_try_to_free_pages (the only functions which
calls shrink_{i,d}cache_memory) already shrink the SLAB cache (with
kmem_cache_reap), I dont think its needed.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
