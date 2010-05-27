Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 831806B01C7
	for <linux-mm@kvack.org>; Thu, 27 May 2010 02:18:00 -0400 (EDT)
Date: Thu, 27 May 2010 16:17:51 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 3/5 v2] superblock: introduce per-sb cache shrinker
 infrastructure
Message-ID: <20100527061751.GK12087@dastard>
References: <1274777588-21494-1-git-send-email-david@fromorbit.com>
 <1274777588-21494-4-git-send-email-david@fromorbit.com>
 <20100526164116.GD22536@laptop>
 <20100526231214.GB1395@dastard>
 <20100527015335.GD1395@dastard>
 <20100527040120.GX31073@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100527040120.GX31073@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, May 27, 2010 at 05:01:20AM +0100, Al Viro wrote:
> On Thu, May 27, 2010 at 11:53:35AM +1000, Dave Chinner wrote:
> > On Thu, May 27, 2010 at 09:12:14AM +1000, Dave Chinner wrote:
> > > On Thu, May 27, 2010 at 02:41:16AM +1000, Nick Piggin wrote:
> > ....
> > > > Nitpick but I prefer just the restart label wher it is previously. This
> > > > is moving setup for the next iteration into the "error" case.
> > > 
> > > Ok, will fix.
> > ....
> > > > Would you just elaborate on the lock order problem somewhere? (the
> > > > comment makes it look like we *could* take the mutex if we wanted
> > > > to).
> > > 
> > > The shrinker is unregistered in deactivate_locked_super() which is
> > > just before ->kill_sb is called. The sb->s_umount lock is held at
> > > this point. hence is the shrinker is operating, we will deadlock if
> > > we try to lock it like this:
> > > 
> > > 	unmount:			shrinker:
> > > 					down_read(&shrinker_lock);
> > > 	down_write(&sb->s_umount)
> > > 	unregister_shrinker()
> > > 	down_write(&shrinker_lock)
> > > 					prune_super()
> > > 					  down_read(&sb->s_umount);
> > > 					  (deadlock)
> > > 
> > > hence if we can't get the sb->s_umount lock in prune_super(), then
> > > the superblock must be being unmounted and the shrinker should abort
> > > as the ->kill_sb method will clean up everything after the shrinker
> > > is unregistered. Hence the down_read_trylock().
> 
> Um...  Maybe I'm dumb, but what's wrong with doing unregistration from
> deactivate_locked_super(), right after the call of ->kill_sb()?  At that
> point ->s_umount is already dropped, so we won't deadlock at all.
> Shrinker rwsem will make sure that all shrinkers-in-progress will run
> to completion, so we won't get a superblock freed under prune_super().
> I don't particulary mind down_try_read() in prune_super(), but why not
> make life obviously safer?
> 
> Am I missing something here?

I was worried about memory allocation in the ->kill_sb path
deadlocking on the s_umount lock if it enters reclaim. e.g.  XFS
inodes can still be dirty even after the VFS has disposed of them,
and writing them back can require page cache allocation for the
backing buffers. If allocation recurses back into the shrinker, we
can deadlock on the s_umount lock.  This doesn't seem like an XFS
specific problem, so I used a trylock to avoid that whole class of
problems (same way the current shrinkers do).

>From there, we can unregister the shrinker before calling ->kill_sb
as per above. That, in turn, means that the unmount
invalidate_inodes() vs shrinker race goes away and the iprune_sem is
not needed in the new prune_icache_sb() function.  I'm pretty sure
that I can now remove the iprune_sem, but I haven't written the
patch to do that yet.

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
