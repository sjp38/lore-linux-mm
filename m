In-reply-to: <48FC9CCC.3040006@linux-foundation.org> (message from Christoph
	Lameter on Mon, 20 Oct 2008 09:59:24 -0500)
Subject: Re: SLUB defrag pull request?
References: <1223883004.31587.15.camel@penberg-laptop> <1223883164.31587.16.camel@penberg-laptop> <Pine.LNX.4.64.0810131227120.20511@blonde.site> <200810132354.30789.nickpiggin@yahoo.com.au> <E1KpNwq-0003OW-8f@pomaz-ex.szeredi.hu> <E1KpOOL-0003Vf-9y@pomaz-ex.szeredi.hu> <48F378C6.7030206@linux-foundation.org> <E1KpOjX-0003dt-AY@pomaz-ex.szeredi.hu> <48FC9CCC.3040006@linux-foundation.org>
Message-Id: <E1Krz4o-0002Fi-Pu@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 20 Oct 2008 20:01:58 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: cl@linux-foundation.org
Cc: miklos@szeredi.hu, penberg@cs.helsinki.fi, nickpiggin@yahoo.com.au, hugh@veritas.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, 20 Oct 2008, Christoph Lameter wrote:
> >> kick_inodes() only works on inodes that first have undergone 
> >> get_inodes() where we establish a refcount under inode_lock(). The final 
> >> cleanup in kick_inodes() is done under iprune_mutex. You are looking at 
> >> the loop that does writeback and invalidates attached dentries. This can 
> >> fail for various reasons.
> > 
> > Yes, but I'm not at all sure that calling remove_inode_buffers() or
> > invalidate_mapping_pages() is OK on a live inode.  They should be done
> > after checking the refcount, just like prune_icache() does.
> 
> Dont we do the same on a truncate?

Yes, with i_mutex and i_alloc_sem held.

> 
> > Also, while d_invalidate() is not actually wrong here, because you
> > check S_ISDIR(), but it's still the wrong function to use.  You really
> > just want to shrink the children.  Invalidation means: the filesystem
> > found out that the cached inode is invalid, so we want to throw it
> > away.  In the future it might actually be able to do it for
> > directories as well, but currently it cannot because of possible
> > mounts on the dentry.
> 
> Thats the same issue as with the dentries. The new function could deal with
> both situations?

Sure.

The big issue is dealing with umount.  You could do something like
grab_super() on sb before getting a ref on the inode/dentry.  But I'm
not sure this is a good idea.  There must be a simpler way to achieve
this...

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
