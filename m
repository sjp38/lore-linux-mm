Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 87BB26B0071
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 17:26:52 -0500 (EST)
Date: Fri, 19 Nov 2010 14:25:52 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Pass priority to shrink_slab
Message-Id: <20101119142552.df0e351c.akpm@linux-foundation.org>
In-Reply-To: <20101118085921.GA11314@amd>
References: <1290054891-6097-1-git-send-email-yinghan@google.com>
	<20101118085921.GA11314@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@kernel.dk>
Cc: Ying Han <yinghan@google.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Nick Piggin <npiggin@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Nov 2010 19:59:21 +1100
Nick Piggin <npiggin@kernel.dk> wrote:

> On Wed, Nov 17, 2010 at 08:34:51PM -0800, Ying Han wrote:
> > Pass the reclaim priority down to the shrink_slab() which passes to the
> > shrink_icache_memory() for inode cache. It helps the situation when
> > shrink_slab() is being too agressive, it removes the inode as well as all
> > the pages associated with the inode. Especially when single inode has lots
> > of pages points to it. The application encounters performance hit when
> > that happens.
> > 
> > The problem was observed on some workload we run, where it has small number
> > of large files. Page reclaim won't blow away the inode which is pinned by
> > dentry which in turn is pinned by open file descriptor. But if the application
> > is openning and closing the fds, it has the chance to trigger the issue.
> > 
> > I have a script which reproduce the issue. The test is creating 1500 empty
> > files and one big file in a cgroup. Then it starts adding memory pressure
> > in the cgroup. Both before/after the patch we see the slab drops (inode) in
> > slabinfo but the big file clean pages being preserves only after the change.
> 
> I was going to do this as a flag when nearing OOM. Is there a reason
> to have it priority based? That seems a little arbitrary to me...
> 

There are subtleties here.

Take the case of a machine with 1MB lowmem and 8GB highmem.  It has a
million cached inodes, each one with a single attached pagecache page. 
The fairly common lots-of-small-files workload.

The inodes are all in lowmem.  Most of their pagecache is in highmem.

To satisfy a GFP_KERNEL or GFP_USER allocation request, we need to free
up some of that lowmem.  But none of those inodes are reclaimable,
because of their attached highmem pagecache.  So in this case we very
much want to shoot down those inodes' pagecache within the icache
shrinker, so we can get those inodes reclaimed.

With the proposed change, that reclaim won't be happening until vmscan
has reached a higher priority.  Which means that the VM will instead go
nuts reclaiming *other* lowmem objects.  That means all the other slabs
which have shrinkers.  It also means lowmem pagecache: those inodes
will cause all your filesystem metadata to get evicted.  It also means
that anonymous memory which happened to land in lowmem will get swapped
out, and program text which is in lowmem will be unmapped and evicted.

There may be other undesirable interactions as well - I'm not thinking
too hard at present ;)  Thinking caps on, please.


I think the patch needs to be smarter.  It should at least take
into account the *amount* of memory attached to the inode -
address_space.nr_pages.

Where "amount" is a fuzzy concept - the shrinkers try to account for
seek cost and not just number-of-bytes, so that needs thinking about as
well.


So what to do?  I don't immediately see any alternative to implementing
reasonably comprehensive aging for inodes.  Each time around the LRU
the inode gets aged.  Each time it or its pages get touched, it gets
unaged.  When considering an inode for eviction we look to see if

  fn(inode age) > fn(number of seeks to reestablish inode and its pagecache)

Which is an interesting project ;)




And yes, we need a struct shrinker_control so we can fiddle with the
argument passing without having to edit lots of files each time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
