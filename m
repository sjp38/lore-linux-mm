Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 15E5A6B01EE
	for <linux-mm@kvack.org>; Fri, 14 May 2010 21:30:14 -0400 (EDT)
Date: Sat, 15 May 2010 02:30:05 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 0/5] Per-superblock shrinkers
Message-ID: <20100515013005.GA31073@ZenIV.linux.org.uk>
References: <1273821863-29524-1-git-send-email-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1273821863-29524-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: linux-kernel@vger.kernel.org, xfs@oss.sgi.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 14, 2010 at 05:24:18PM +1000, Dave Chinner wrote:
> 
> This series reworks the filesystem shrinkers. We currently have a
> set of issues with the current filesystem shrinkers:
> 
> 	1. There is an dependency between dentry and inode cache
> 	   shrinking that is only implicitly defined by the order of
> 	   shrinker registration.
> 	2. The shrinkers need to walk the superblock list and pin
> 	   the superblock to avoid unmount races with the sb going
> 	   away.
> 	3. The dentry cache uses per-superblock LRUs and proportions
> 	   reclaim between all the superblocks which means we are
> 	   doing breadth based reclaim. This means we touch every
> 	   superblock for every shrinker call, and may only reclaim
> 	   a single dentry at a time from a given superblock.
> 	4. The inode cache has a global LRU, so it has different
> 	   reclaim patterns to the dentry cache, despite the fact
> 	   that the dentry cache is generally the only thing that
> 	   pins inodes in memory.
> 	5. Filesystems need to register their own shrinkers for
> 	   caches and can't co-ordinate them with the dentry and
> 	   inode cache shrinkers.

NAK in that form; sb refcounting and iterators had been reworked for .34,
so at least it needs rediff on top of that.  What's more, it's very
obviously broken wrt locking - you are unregistering a shrinker
from __put_super().  I.e. grab rwsem exclusively under a spinlock.

Essentially, you've turned dropping a _passive_ reference to superblock
(currently an operation safe in any context) into an operation allowed
only when no fs or vm locks are held by caller.  Not going to work...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
