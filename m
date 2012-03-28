Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id F359D6B00F6
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 08:10:30 -0400 (EDT)
Date: Wed, 28 Mar 2012 14:10:18 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [Lsf-pc] [TOPIC] Last iput() from flusher thread, last fput()
 from munmap()...
Message-ID: <20120328121018.GG18751@quack.suse.cz>
References: <20120327210858.GH5020@quack.suse.cz>
 <20120328023852.GP6589@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120328023852.GP6589@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org

On Wed 28-03-12 03:38:52, Al Viro wrote:
> On Tue, Mar 27, 2012 at 11:08:58PM +0200, Jan Kara wrote:
> >   Hello,
> > 
> >   maybe the name of this topic could be "How hard should be life of
> > filesystems?" but that's kind of broad topic and suggests too much of
> > bikeshedding. I'd like to concentrate on concrete possible pain points
> > between filesystems & VFS (possibly writeback or even generally MM).
> > Lately, I've myself came across the two issues in $SUBJECT:
> > 1) dropping of last file reference can happen from munmap() and in that
> >    case mmap_sem will be held when ->release() is called. Even more it
> >    could be held when ->evict_inode() is called to delete inode because
> >    inode was unlinked.
> 
> Yes, it can.
> 
> > 2) since flusher thread takes inode reference when writing inode out, the
> >    last inode reference can be dropped from flusher thread. Thus inode may
> >    get deleted in the flusher thread context. This does not seem that
> >    problematic on its own but if we realize progress of memory reclaim
> >    depends (at least from a longterm perspective) on flusher thread making
> >    progress, things start looking a bit uncertain. Even more so when we
> >    would like avoid ->writepage() calls from reclaim and let flusher thread
> >    do the work instead. That would then require filesystems to carefully
> >    design their ->evict_inode() routines so that things are not
> >    deadlockable.
> 
> You mean "use GFP_NOIO for allocations when holding fs-internal locks"?
  Well, but in ->evict_inode filesystem isn't necessarily holding any
internal locks it knows about. So it should be perfectly fine doing
GFP_KERNEL allocation. But if ->evict_inode is called from flusher thread
and we do GFP_KERNEL allocation, things start to be a bit uncertain IMHO.

> >   Both these issues should be avoidable (we can postpone fput() after we
> > drop mmap_sem; we can tweak inode refcounting to avoid last iput() from
> > flusher thread) but obviously there's some cost in the complexity of generic
> > layer. So the question is, is it worth it?
> 
> I don't thing it is.  ->i_mutex in ->release() is never needed; existing
> cases are racy and dropping preallocation that way is simply wrong.
  Yes. And my point really is, if fs developers get this often wrong,
shouldn't we change the interface so that it's harder to get it wrong? In
this particular case it shouldn't be a big burden on VFS.

> And ->evict_inode() is a non-issue, since it has no reason whatsoever to
> take *any* locks in mutex - the damn thing is called when nobody has
> references to struct inode anymore.
  As Steven pointed out, at least clustered filesystems need to do complex
synchronization in ->evict_inode(). I think OCFS2 offloads some of this
stuff to separate kernel thread to avoid deadlocks (at least the obvious
ones which you can hit during testing / which lockdep can catch).

> Deadlocks with flusher... that's what NOIO and NOFS are for.
> 
> As for the IMA issues...  We probably ought to use a separate mutex for
> xattr and relying on ->i_mutex for its internal locking is unconvincing,
> to put it mildly...
  Agreed.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
