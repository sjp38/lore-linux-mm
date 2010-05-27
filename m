Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4EFDB600385
	for <linux-mm@kvack.org>; Thu, 27 May 2010 00:01:30 -0400 (EDT)
Date: Thu, 27 May 2010 05:01:20 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 3/5 v2] superblock: introduce per-sb cache shrinker
 infrastructure
Message-ID: <20100527040120.GX31073@ZenIV.linux.org.uk>
References: <1274777588-21494-1-git-send-email-david@fromorbit.com>
 <1274777588-21494-4-git-send-email-david@fromorbit.com>
 <20100526164116.GD22536@laptop>
 <20100526231214.GB1395@dastard>
 <20100527015335.GD1395@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100527015335.GD1395@dastard>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, May 27, 2010 at 11:53:35AM +1000, Dave Chinner wrote:
> On Thu, May 27, 2010 at 09:12:14AM +1000, Dave Chinner wrote:
> > On Thu, May 27, 2010 at 02:41:16AM +1000, Nick Piggin wrote:
> ....
> > > Nitpick but I prefer just the restart label wher it is previously. This
> > > is moving setup for the next iteration into the "error" case.
> > 
> > Ok, will fix.
> ....
> > > Would you just elaborate on the lock order problem somewhere? (the
> > > comment makes it look like we *could* take the mutex if we wanted
> > > to).
> > 
> > The shrinker is unregistered in deactivate_locked_super() which is
> > just before ->kill_sb is called. The sb->s_umount lock is held at
> > this point. hence is the shrinker is operating, we will deadlock if
> > we try to lock it like this:
> > 
> > 	unmount:			shrinker:
> > 					down_read(&shrinker_lock);
> > 	down_write(&sb->s_umount)
> > 	unregister_shrinker()
> > 	down_write(&shrinker_lock)
> > 					prune_super()
> > 					  down_read(&sb->s_umount);
> > 					  (deadlock)
> > 
> > hence if we can't get the sb->s_umount lock in prune_super(), then
> > the superblock must be being unmounted and the shrinker should abort
> > as the ->kill_sb method will clean up everything after the shrinker
> > is unregistered. Hence the down_read_trylock().

Um...  Maybe I'm dumb, but what's wrong with doing unregistration from
deactivate_locked_super(), right after the call of ->kill_sb()?  At that
point ->s_umount is already dropped, so we won't deadlock at all.
Shrinker rwsem will make sure that all shrinkers-in-progress will run
to completion, so we won't get a superblock freed under prune_super().
I don't particulary mind down_try_read() in prune_super(), but why not
make life obviously safer?

Am I missing something here?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
