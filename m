In-reply-to: <48FCCC72.5020202@linux-foundation.org> (message from Christoph
	Lameter on Mon, 20 Oct 2008 13:22:42 -0500)
Subject: Re: SLUB defrag pull request?
References: <1223883004.31587.15.camel@penberg-laptop> <1223883164.31587.16.camel@penberg-laptop> <Pine.LNX.4.64.0810131227120.20511@blonde.site> <200810132354.30789.nickpiggin@yahoo.com.au> <E1KpNwq-0003OW-8f@pomaz-ex.szeredi.hu> <E1KpOOL-0003Vf-9y@pomaz-ex.szeredi.hu> <48F378C6.7030206@linux-foundation.org> <E1KpOjX-0003dt-AY@pomaz-ex.szeredi.hu> <48FC9CCC.3040006@linux-foundation.org> <E1Krz4o-0002Fi-Pu@pomaz-ex.szeredi.hu> <48FCCC72.5020202@linux-foundation.org>
Message-Id: <E1KrzgK-0002QS-Os@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 20 Oct 2008 20:40:44 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: cl@linux-foundation.org
Cc: miklos@szeredi.hu, penberg@cs.helsinki.fi, nickpiggin@yahoo.com.au, hugh@veritas.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, 20 Oct 2008, Christoph Lameter wrote:
> Miklos Szeredi wrote:
> >>> Yes, but I'm not at all sure that calling remove_inode_buffers() or
> >>> invalidate_mapping_pages() is OK on a live inode.  They should be done
> >>> after checking the refcount, just like prune_icache() does.
> >> Dont we do the same on a truncate?
> > 
> > Yes, with i_mutex and i_alloc_sem held.
> 
> There is another call to invalidate_mapping_pages() in prune_icache (that is
> where this code originates). No i_mutex and i_alloc. Only iprune_mutex held
> and that seems to be for the protection of the list. So just checking
> inode->i_count would do the trick?

Yes, that's what I was saying.

> > The big issue is dealing with umount.  You could do something like
> > grab_super() on sb before getting a ref on the inode/dentry.  But I'm
> > not sure this is a good idea.  There must be a simpler way to achieve
> > this..
> 
> Taking a lock on vfsmount_lock? But that would make dentry reclaim a pain.

No, I mean simpler than having to do this two stage stuff.

> We are only interested in the reclaim a dentry if its currently unused. If so
> then why does unmount matter? Both unmount and reclaim will attempt to remove
> the dentry.
> 
> Have a look at get_dentries(). It takes the dcache_lock and checks the dentry
> state. Either the entry is ignored or dget_locked() removes it from the lru.
> If its off the LRU then it can no longer be reclaimed by umount.

How is that better?  You will still get busy inodes on umount.

And anyway the dentry could be put back onto the LRU by somebody else
between get_dentries() and kick_dentries().  So I don't even see how
taking the dentry off the LRU helps _anything_.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
