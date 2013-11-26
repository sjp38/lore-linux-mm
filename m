Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f43.google.com (mail-bk0-f43.google.com [209.85.214.43])
	by kanga.kvack.org (Postfix) with ESMTP id DEC466B00B6
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 18:00:53 -0500 (EST)
Received: by mail-bk0-f43.google.com with SMTP id mz12so2864453bkb.2
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 15:00:52 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id mc8si11393326bkb.216.2013.11.26.15.00.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 26 Nov 2013 15:00:52 -0800 (PST)
Date: Tue, 26 Nov 2013 18:00:10 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 9/9] mm: keep page cache radix tree nodes in check
Message-ID: <20131126230010.GJ22729@cmpxchg.org>
References: <1385336308-27121-1-git-send-email-hannes@cmpxchg.org>
 <1385336308-27121-10-git-send-email-hannes@cmpxchg.org>
 <20131125234921.GK8803@dastard>
 <20131126212725.GG22729@cmpxchg.org>
 <20131126222937.GA10988@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131126222937.GA10988@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Tejun Heo <tj@kernel.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Nov 27, 2013 at 09:29:37AM +1100, Dave Chinner wrote:
> On Tue, Nov 26, 2013 at 04:27:25PM -0500, Johannes Weiner wrote:
> > On Tue, Nov 26, 2013 at 10:49:21AM +1100, Dave Chinner wrote:
> > > On Sun, Nov 24, 2013 at 06:38:28PM -0500, Johannes Weiner wrote:
> > > > Previously, page cache radix tree nodes were freed after reclaim
> > > > emptied out their page pointers.  But now reclaim stores shadow
> > > > entries in their place, which are only reclaimed when the inodes
> > > > themselves are reclaimed.  This is problematic for bigger files that
> > > > are still in use after they have a significant amount of their cache
> > > > reclaimed, without any of those pages actually refaulting.  The shadow
> > > > entries will just sit there and waste memory.  In the worst case, the
> > > > shadow entries will accumulate until the machine runs out of memory.
> ....
> > > ....
> > > > +	radix_tree_replace_slot(slot, page);
> > > > +	if (node) {
> > > > +		node->count++;
> > > > +		/* Installed page, can't be shadow-only anymore */
> > > > +		if (!list_empty(&node->lru))
> > > > +			list_lru_del(&workingset_shadow_nodes, &node->lru);
> > > > +	}
> > > > +	return 0;
> > > 
> > > Hmmmmm - what's the overhead of direct management of LRU removal
> > > here? Most list_lru code uses lazy removal (i.e. via the shrinker)
> > > to avoid having to touch the LRU when adding new references to an
> > > object.....
> > 
> > It's measurable in microbenchmarks, but not when any real IO is
> > involved.  The difference was in the noise even on SSD drives.
> 
> Well, it's not an SSD or two I'm worried about - it's devices that
> can do millions of IOPS where this is likely to be noticable...
> 
> > The other list_lru users see items only once they become unused and
> > subsequent references are expected to be few and temporary, right?
> 
> They go onto the list when the refcount falls to zero, but reuse can
> be frequent when being referenced repeatedly by a single user. That
> avoids every reuse from removing the object from the LRU then
> putting it back on the LRU for every reference cycle...

That's true, but it's less of a concern in the radix_tree_node case
because it takes a full inactive list cycle after a refault before the
node is put back on the LRU.  Or a really unlikely placed partial node
truncation/invalidation (full truncation would just delete the whole
node anyway).

> > We expect pages to refault in spades on certain loads, at which point
> > we may have thousands of those nodes on the list that are no longer
> > reclaimable (10k nodes for about 2.5G of cache).
> 
> Sure, look at the way the inode and dentry caches work - entire
> caches of millions of inodes and dentries often sit on the LRUs. A
> quick look at my workstations dentry cache shows:
> 
> $ at /proc/sys/fs/dentry-state 
> 180108  170596  45      0       0       0
> 
> 180k allocated dentries, 170k sitting on the LRU...

Hm, and a significant amount of those 170k could rotate on the next
shrinker scan due to recent references or do you generally have
smaller spikes?

But as per above I think the case for lazily removing shadow nodes is
less convincing than for inodes and dentries.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
