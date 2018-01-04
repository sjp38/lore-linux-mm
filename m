Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id C50A06B049E
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 19:11:44 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id i12so55313plk.5
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 16:11:44 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id t14si1403462plo.822.2018.01.03.16.11.42
        for <linux-mm@kvack.org>;
        Wed, 03 Jan 2018 16:11:43 -0800 (PST)
Date: Thu, 4 Jan 2018 11:08:56 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC] Heuristic for inode/dentry fragmentation prevention
Message-ID: <20180104000856.GA32627@dastard>
References: <alpine.DEB.2.20.1801031332230.10522@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1801031332230.10522@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Dave Chinner <dchinner@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, Pekka Enberg <penberg@cs.helsinki.fi>

On Wed, Jan 03, 2018 at 01:39:27PM -0600, Christopher Lameter wrote:
> I was looking at the inode/dentry reclaim code today and I thought there
> is an obvious and easy to implement way to avoid fragmentation by checking
> the number of objects in a slab page.
> 
> 
> Subject: Heuristic for fragmentation prevention for inode and dentry caches
> 
> When freeing dentries and inodes we often get to the situation
> that a slab page cannot be freed because there is only a single
> object left in that slab page.
> 
> We add a new function to the slab allocators that returns the
> number of objects in the same slab page.
> 
> Then the dentry and inode logic can check if such a situation
> exits and take measures to try to reclaim that entry sooner.
> 
> In this patch the check if an inode or dentry has been referenced
> (and thus should be kept) is skipped if the freeing of the object
> would result in the slab page becoming available.
> 
> That will cause overhead in terms of having to re-allocate and
> generate the inoden or dentry but in all likelyhood the inode
> or dentry will then be allocated in a slab page that already
> contains other inodes or dentries. Thus fragmentation is reduced.

Please quantify the difference this makes to inode/dentry cache
fragmentation, as well as the overhead of the
kobjects_left_in_slab_page() check on every referenced inode and
dentry we scan.

Basically, if we can't reliably produce and quantify inode/dentry
cache fragmentation on demand, then we've go no way to evaluate the
effect of such heuristics will on cache footprint. I'm happy to run
tests to help develop heuristics, but I don't have time to create
tests to reproduce cache fragmentation issues myself.

IOWs, before we start down this path, we need to create workloads
that reproduce inode/dentry cache fragmentation issues....

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
