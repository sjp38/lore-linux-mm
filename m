Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 954CB6B0080
	for <linux-mm@kvack.org>; Thu, 17 Apr 2014 01:58:21 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id w10so11523625pde.24
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 22:58:21 -0700 (PDT)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:4])
        by mx.google.com with ESMTP id ha5si13972243pbc.301.2014.04.16.22.58.18
        for <linux-mm@kvack.org>;
        Wed, 16 Apr 2014 22:58:19 -0700 (PDT)
Date: Thu, 17 Apr 2014 15:58:11 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 16/19] VFS: use GFP_NOFS rather than GFP_KERNEL in
 __d_alloc.
Message-ID: <20140417055811.GX15995@dastard>
References: <20140416033623.10604.69237.stgit@notabene.brown>
 <20140416040337.10604.61837.stgit@notabene.brown>
 <20140416062520.GG15995@dastard>
 <20140416164941.37587da6@notabene.brown>
 <20140416090051.GK15995@dastard>
 <20140417105105.7772d09d@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140417105105.7772d09d@notabene.brown>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, xfs@oss.sgi.com

On Thu, Apr 17, 2014 at 10:51:05AM +1000, NeilBrown wrote:
> On Wed, 16 Apr 2014 19:00:51 +1000 Dave Chinner <david@fromorbit.com> wrote:
> 
> > On Wed, Apr 16, 2014 at 04:49:41PM +1000, NeilBrown wrote:
> > > On Wed, 16 Apr 2014 16:25:20 +1000 Dave Chinner <david@fromorbit.com> wrote:
> > > 
> > > > On Wed, Apr 16, 2014 at 02:03:37PM +1000, NeilBrown wrote:
> > > > > __d_alloc can be called with i_mutex held, so it is safer to
> > > > > use GFP_NOFS.
> > > > > 
> > > > > lockdep reports this can deadlock when loop-back NFS is in use,
> > > > > as nfsd may be required to write out for reclaim, and nfsd certainly
> > > > > takes i_mutex.
> > > > 
> > > > But not the same i_mutex as is currently held. To me, this seems
> > > > like a false positive? If you are holding the i_mutex on an inode,
> > > > then you have a reference to the inode and hence memory reclaim
> > > > won't ever take the i_mutex on that inode.
> > > > 
> > > > FWIW, this sort of false positive was a long stabding problem for
> > > > XFS - we managed to get rid of most of the false positives like this
> > > > by ensuring that only the ilock is taken within memory reclaim and
> > > > memory reclaim can't be entered while we hold the ilock.
> > > > 
> > > > You can't do that with the i_mutex, though....
> > > > 
> > > > Cheers,
> > > > 
> > > > Dave.
> > > 
> > > I'm not sure this is a false positive.
> > > You can call __d_alloc when creating a file and so are holding i_mutex on the
> > > directory.
> > > nfsd might also want to access that directory.
> > > 
> > > If there was only 1 nfsd thread, it would need to get i_mutex and do it's
> > > thing before replying to that request and so before it could handle the
> > > COMMIT which __d_alloc is waiting for.
> > 
> > That seems wrong - the NFS client in __d_alloc holds a mutex on a
> > NFS client directory inode. The NFS server can't access that
> > specific mutex - it's on the other side of the "network". The NFS
> > server accesses mutexs from local filesystems, so __d_alloc would
> > have to be blocked on a local filesystem inode i_mutex for the nfsd
> > to get hung up behind it...
> 
> I'm not thinking of mutexes on the NFS inodes but the local filesystem inodes
> exactly as you describe below.
> 
> > 
> > However, my confusion comes from the fact that we do GFP_KERNEL
> > memory allocation with the i_mutex held all over the place.
> 
> Do we? 

Yes.

A simple example: fs/xattr.c. Setting or removing an xattr is done
under the i_mutex, yet have a look and the simple_xattr_*
implementation that in memory/psuedo filesystems can use. They use
GFP_KERNEL for all their allocations....

> Should we?

No, I don't think so, because it means that under heavy filesystem
memory pressure workloads, direct reclaim can effectively shut off
and only kswapd can free memory. 

> Isn't the whole point of GFP_NOFS to use it when holding
> any filesystem lock?

Not the way I understand it - we've always used it in XFS to prevent
known deadlocks due to recursion, not as a big hammer that we hit
everything with. Every filesystem has different recursion deadlock
triggers, so use GFP_NOFS differently.  using t as a big hammer
doesn't play well with memory reclaim on filesystem memory pressure
generating workloads...

> >           If the
> > problem is:
> > 
> > 	local fs access -> i_mutex
> > .....
> > 	nfsd -> i_mutex (blocked)
> > .....
> > 	local fs access -> kmalloc(GFP_KERNEL)
> > 			-> direct reclaim
> > 			-> nfs_release_page
> > 			-> <send write/commit request to blocked nfsds>
> > 			   <deadlock>
> > 
> > then why is it just __d_alloc that needs this fix?  Either this is a
> > problem *everywhere* or it's not a problem at all.
> 
> I think it is a problem everywhere that it is a problem :-)

<head implosion>

> If you are holding an FS lock, then you should be using GFP_NOFS.

Only if reclaim recursion can cause a deadlock.

> Currently a given filesystem can get away with sometimes using GFP_KERNEL
> because that particular lock never causes contention during reclaim for that
> particular filesystem.

Right, be cause we directly control what recursion can happen.

What you are doing is changing the global reclaim recursion context.
You're introducing recursion loops between filesystems *of different
types*. IOWs, at no point is it safe for anyone to allow any
recursion because we don't have the state available to determine if
recursion is safe or not.

> Adding loop-back NFS into the mix broadens the number of locks which can
> cause a problem as it creates interdependencies between different filesystems.

And that's a major architectural change to the memory reclaim
heirarchy and that means we're going to be breaking assumptions all
over the place, including in places we didn't know we had
dependencies...

> > If it's a problem everywhere it means that we simply can't allow
> > reclaim from localhost NFS mounts to run from contexts that could
> > block an NFSD. i.e. you cannot run NFS client memory reclaim from
> > filesystems that are NFS server exported filesystems.....
> 
> Well.. you cannot allow NFS client memory reclaim *while holding locks in*
> filesystems that are NFS exported.
>
> I think this is most effectively generalised to:
>   you cannot allow FS memory reclaim while holding locks in filesystems which
>   can be NFS exported

Yes, that's exactly what I said yesterday.

> which I think is largely the case already

It most definitely isn't.

> - and lockdep can help us find
> those places where we currently do allow FS reclaim while holding an FS lock.

A pox on lockdep. Lockdep is not a crutch that we can to wave away
problems a architectural change doesn't identify. We need to think
about the architectural impact of the change - if we can't see all
the assumptions we're breaking and the downstream impacts, then we
nee dto think about the problem harder. We should not not wave away
concerns by saying "lockdep will find the things we missed"...

For example, if you make all filesystem allocations GFP_NOFS, then
the only thing that will be able to do reclaim of inodes and
dentries is kswapd, because the shrinkers don't run in GFP_NOFS
context. Hence filesystem memory pressure (e.g. find) won't be able
to directly reclaim the objects that it is generating, and that will
significantly change the behaviour and performance of the system.

IOWs, there are lots of nasty, subtle downstream affects of making a
blanket "filesystems must use GFP_NOFS is they hold any lock" rule
that I can see, so I really think thatwe shoul dbe looking to solve
this problem in the NFS client and exhausting all possibilities
there before we even consider changing something as fundamental as
memory reclaim recursion heirarchies....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
