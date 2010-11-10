Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A9E976B0089
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 00:18:30 -0500 (EST)
Date: Wed, 10 Nov 2010 16:18:13 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [patch] mm: vmscan implement per-zone shrinkers
Message-ID: <20101110051813.GS2715@dastard>
References: <20101109123246.GA11477@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101109123246.GA11477@amd>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@kernel.dk>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 09, 2010 at 11:32:46PM +1100, Nick Piggin wrote:
> Hi,
> 
> I'm doing some works that require per-zone shrinkers, I'd like to get
> the vmscan part signed off and merged by interested mm people, please.
> 

There are still plenty of unresolved issues with this general
approach to scaling object caches that I'd like to see sorted out
before we merge any significant shrinker API changes. Some things of
the top of my head:

	- how to solve impendence mismatches between VM scalability
	  techniques and subsystem scalabilty techniques that result
	  in shrinker cross-muliplication explosions. e.g. XFS
	  tracks reclaimable inodes in per-allocation group trees,
	  so we'd get AG x per-zone LRU trees using this shrinker
	  method.  Think of the overhead on a 1000AG filesystem on a
	  1000 node machine with 3-5 zones per node....

	- changes from global LRU behaviour to something that is not
	  at all global - effect on workloads that depend on large
	  scale caches that span multiple nodes is largely unknown.
	  It will change IO patterns and affect system balance and
	  performance of the system. How do we
	  test/categorise/understand these problems and address such
	  balance issues?

	- your use of this shrinker architecture for VFS
	  inode/dentry cache scalability requires adding lists and
	  locks to the MM struct zone for each object cache type
	  (inode, dentry, etc). As such, it is not a generic
	  solution because it cannot be used for per-instance caches
	  like the per-mount inode caches XFS uses.

	  i.e. nothing can actually use this infrastructure change
	  without tying itself directly into the VM implementation,
	  and even then not every existing shrinker can use this
	  method of scaling. i.e. some level of abstraction from the
	  VM implementation is needed in the shrinker API.

	- it has been pointed out that slab caches are generally
	  allocated out of a single zone per node, so per-zone
	  shrinker granularity seems unnecessary.

	- doesn't solve the unbound direct reclaim shrinker
	  parallelism that is already causing excessive LRU lock
	  contention on 8p single node systems. While
	  per-LRU/per-node solves the larger scalability issue, it
	  doesn't address scalability within the node. This is soon
	  going to be 24p per node and that's more than enough to
	  cause severe problems with a single lock and list...

> [And before anybody else kindly suggests per-node shrinkers, please go
> back and read all the discussion about this first.]

I don't care for any particular solution, but I want these issues
resolved before we make any move forward. per-node abstractions is
just one possible way that has been suggested to address some of
these issues, so it shouldn't be dismissed out of hand like this.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
