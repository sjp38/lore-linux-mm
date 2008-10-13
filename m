In-reply-to: <48F378C6.7030206@linux-foundation.org> (message from Christoph
	Lameter on Mon, 13 Oct 2008 09:35:18 -0700)
Subject: Re: SLUB defrag pull request?
References: <1223883004.31587.15.camel@penberg-laptop> <1223883164.31587.16.camel@penberg-laptop> <Pine.LNX.4.64.0810131227120.20511@blonde.site> <200810132354.30789.nickpiggin@yahoo.com.au> <E1KpNwq-0003OW-8f@pomaz-ex.szeredi.hu> <E1KpOOL-0003Vf-9y@pomaz-ex.szeredi.hu> <48F378C6.7030206@linux-foundation.org>
Message-Id: <E1KpOjX-0003dt-AY@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 13 Oct 2008 16:49:19 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: cl@linux-foundation.org
Cc: miklos@szeredi.hu, penberg@cs.helsinki.fi, nickpiggin@yahoo.com.au, hugh@veritas.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, 13 Oct 2008, Christoph Lameter wrote:
> Miklos Szeredi wrote:
> > And the things kick_inodes() does without any sort of locking look
> > even more dangerous.
> >
> > It should be the other way round: first make sure nothing is
> > referencing the inode, and _then_ start cleaning it up with
> > appropriate locks held.  See prune_icache().
> >
> >   
> kick_inodes() only works on inodes that first have undergone 
> get_inodes() where we establish a refcount under inode_lock(). The final 
> cleanup in kick_inodes() is done under iprune_mutex. You are looking at 
> the loop that does writeback and invalidates attached dentries. This can 
> fail for various reasons.

Yes, but I'm not at all sure that calling remove_inode_buffers() or
invalidate_mapping_pages() is OK on a live inode.  They should be done
after checking the refcount, just like prune_icache() does.

Also, while d_invalidate() is not actually wrong here, because you
check S_ISDIR(), but it's still the wrong function to use.  You really
just want to shrink the children.  Invalidation means: the filesystem
found out that the cached inode is invalid, so we want to throw it
away.  In the future it might actually be able to do it for
directories as well, but currently it cannot because of possible
mounts on the dentry.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
