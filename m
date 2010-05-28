Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 7E5BB6B01BB
	for <linux-mm@kvack.org>; Fri, 28 May 2010 06:07:27 -0400 (EDT)
Date: Fri, 28 May 2010 20:07:19 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 1/5] inode: Make unused inode LRU per superblock
Message-ID: <20100528100719.GC22536@laptop>
References: <1274777588-21494-1-git-send-email-david@fromorbit.com>
 <1274777588-21494-2-git-send-email-david@fromorbit.com>
 <20100527133230.780be6c7.akpm@linux-foundation.org>
 <20100527225418.GP12087@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100527225418.GP12087@dastard>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>

On Fri, May 28, 2010 at 08:54:18AM +1000, Dave Chinner wrote:
> On Thu, May 27, 2010 at 01:32:30PM -0700, Andrew Morton wrote:
> > On Tue, 25 May 2010 18:53:04 +1000
> > Dave Chinner <david@fromorbit.com> wrote:
> > 
> > > From: Dave Chinner <dchinner@redhat.com>
> > > 
> > > The inode unused list is currently a global LRU. This does not match
> > > the other global filesystem cache - the dentry cache - which uses
> > > per-superblock LRU lists. Hence we have related filesystem object
> > > types using different LRU reclaimatin schemes.
> > > 
> > > To enable a per-superblock filesystem cache shrinker, both of these
> > > caches need to have per-sb unused object LRU lists. Hence this patch
> > > converts the global inode LRU to per-sb LRUs.
> > > 
> > > The patch only does rudimentary per-sb propotioning in the shrinker
> > > infrastructure, as this gets removed when the per-sb shrinker
> > > callouts are introduced later on.
> > > 
> > > ...
> > >
> > > +			list_move(&inode->i_list, &inode->i_sb->s_inode_lru);
> > 
> > It's a shape that s_inode_lru is still protected by inode_lock.  One
> > day we're going to get in trouble over that lock.  Migrating to a
> > per-sb lock would be logical and might help.
> > 
> > Did you look into this? 
> 
> Yes, I have. Yes, it's possible.  It's solving a different problem,
> so I figured it can be done in a different patch set.

It almost all goes away in my inode lock splitup patches. Inode lru
and dirty lists were the last things protected by the global lock
there.

I am actually going to do per-zone lrus for these guys and per-zone
locks (which is actually better than per-sb because it gives NUMA
scalability within a single sb).

The dirty/writeback lists should probably be per-bdi locked.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
