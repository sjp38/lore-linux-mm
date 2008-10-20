In-reply-to: <48FCD7CB.4060505@linux-foundation.org> (message from Christoph
	Lameter on Mon, 20 Oct 2008 14:11:07 -0500)
Subject: Re: SLUB defrag pull request?
References: <1223883004.31587.15.camel@penberg-laptop> <1223883164.31587.16.camel@penberg-laptop> <Pine.LNX.4.64.0810131227120.20511@blonde.site> <200810132354.30789.nickpiggin@yahoo.com.au> <E1KpNwq-0003OW-8f@pomaz-ex.szeredi.hu> <E1KpOOL-0003Vf-9y@pomaz-ex.szeredi.hu> <48F378C6.7030206@linux-foundation.org> <E1KpOjX-0003dt-AY@pomaz-ex.szeredi.hu> <48FC9CCC.3040006@linux-foundation.org> <E1Krz4o-0002Fi-Pu@pomaz-ex.szeredi.hu> <48FCCC72.5020202@linux-foundation.org> <E1KrzgK-0002QS-Os@pomaz-ex.szeredi.hu> <48FCD7CB.4060505@linux-foundation.org>
Message-Id: <E1Ks0QX-0002aC-SQ@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 20 Oct 2008 21:28:29 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: cl@linux-foundation.org
Cc: miklos@szeredi.hu, penberg@cs.helsinki.fi, nickpiggin@yahoo.com.au, hugh@veritas.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, 20 Oct 2008, Christoph Lameter wrote:
> >>> The big issue is dealing with umount.  You could do something like
> >>> grab_super() on sb before getting a ref on the inode/dentry.  But I'm
> >>> not sure this is a good idea.  There must be a simpler way to achieve
> >>> this..
> >> Taking a lock on vfsmount_lock? But that would make dentry reclaim a pain.
> > 
> > No, I mean simpler than having to do this two stage stuff.
> 
> How could it be simpler? First you need to establish a secure
> reference to the object so that it cannot vanish from under us. Then
> all the references can be checked and possibly removed. If we do not
> need a secure reference then the get_dentries() etc method can be
> NULL.

So, isn't it possible to do without get_dentries()?  What's the
fundamental difference between this and regular cache shrinking?

> Those inodes are going to be freed by the reclaim code. Why would
> they be busy (unless the case below occurs of course).

Case below was brainfart, please ignore.  But that doesn't really
help: the VFS assumes that you cannot umount while there are busy
dentries/inodes.  Usually it works this way: VFS first gets vfsmount
ref, then gets dentry ref, and releases them in the opposite order.
And umount is not allowed if vfsmount has a non-zero refcount (it's a
bit more complicated, but the essense is the same).

The current SLUB defrag violates this: it gets dentry or inode ref
without getting a ref on the vfsmount or the super block as well.
This means that the umount will succeed (that's OK), but also the
super block will be going away and that's bad.  See
generic_shutdown_super().

> > And anyway the dentry could be put back onto the LRU by somebody else
> > between get_dentries() and kick_dentries().  So I don't even see how
> > taking the dentry off the LRU helps _anything_.
> 
> get_dentries() gets a reference. dput will not put the dentry back
> onto the LRU.

Right.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
