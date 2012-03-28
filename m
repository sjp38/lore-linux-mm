Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 082006B00F5
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 07:54:43 -0400 (EDT)
Date: Wed, 28 Mar 2012 13:54:30 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [Lsf-pc] [TOPIC] Last iput() from flusher thread, last fput()
 from munmap()...
Message-ID: <20120328115430.GF18751@quack.suse.cz>
References: <20120327210858.GH5020@quack.suse.cz>
 <20120328023852.GP6589@ZenIV.linux.org.uk>
 <1332925455.2728.19.camel@menhir>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1332925455.2728.19.camel@menhir>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Whitehouse <swhiteho@redhat.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, Jan Kara <jack@suse.cz>

  Hi,

On Wed 28-03-12 10:04:15, Steven Whitehouse wrote:
> On Wed, 2012-03-28 at 03:38 +0100, Al Viro wrote:
> > On Tue, Mar 27, 2012 at 11:08:58PM +0200, Jan Kara wrote:
> > >   Hello,
> > > 
> > >   maybe the name of this topic could be "How hard should be life of
> > > filesystems?" but that's kind of broad topic and suggests too much of
> > > bikeshedding. I'd like to concentrate on concrete possible pain points
> > > between filesystems & VFS (possibly writeback or even generally MM).
> > > Lately, I've myself came across the two issues in $SUBJECT:
> > > 1) dropping of last file reference can happen from munmap() and in that
> > >    case mmap_sem will be held when ->release() is called. Even more it
> > >    could be held when ->evict_inode() is called to delete inode because
> > >    inode was unlinked.
> > 
> > Yes, it can.
> > 
> > > 2) since flusher thread takes inode reference when writing inode out, the
> > >    last inode reference can be dropped from flusher thread. Thus inode may
> > >    get deleted in the flusher thread context. This does not seem that
> > >    problematic on its own but if we realize progress of memory reclaim
> > >    depends (at least from a longterm perspective) on flusher thread making
> > >    progress, things start looking a bit uncertain. Even more so when we
> > >    would like avoid ->writepage() calls from reclaim and let flusher thread
> > >    do the work instead. That would then require filesystems to carefully
> > >    design their ->evict_inode() routines so that things are not
> > >    deadlockable.
> > 
> > You mean "use GFP_NOIO for allocations when holding fs-internal locks"?
> > 
> > >   Both these issues should be avoidable (we can postpone fput() after we
> > > drop mmap_sem; we can tweak inode refcounting to avoid last iput() from
> > > flusher thread) but obviously there's some cost in the complexity of generic
> > > layer. So the question is, is it worth it?
> > 
> > I don't thing it is.  ->i_mutex in ->release() is never needed; existing
> > cases are racy and dropping preallocation that way is simply wrong.  And
> > ->evict_inode() is a non-issue, since it has no reason whatsoever to take
> > *any* locks in mutex - the damn thing is called when nobody has references
> > to struct inode anymore.  Deadlocks with flusher... that's what NOIO and
> > NOFS are for.
> > 
> For cluster filesystems, we have to take locks (cluster wide) in
> ->evict_inode() in order to establish for certain whether we are the
> last opener of the inode. Just because there are no references on the
> local node, doesn't mean that a remote node doesn't hold the file open
> still.
> 
> We do always use GFP_NOFS when allocating memory while holding such
> locks, so I'm not quite sure from the above whether or not that will be
> an issue,
  Yeah, but you have to use networking to communicate with other nodes
about locks and this creates another interesting dependecy.

Currently, everything seems to work out just fine and I don't say I know
about a particular deadlock. I just say that the dependencies are so
complex that I don't know whether things will work OK e.g. if we change
page reclaim to offload more to flusher thread. And that's what I feel
uneasy about.

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
