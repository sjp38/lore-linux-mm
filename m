Date: Tue, 12 Jun 2007 22:32:03 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH] slob: poor man's NUMA, take 2.
Message-ID: <20070613033203.GO11115@waste.org>
References: <20070613031203.GB15009@linux-sh.org> <466F6351.9040503@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <466F6351.9040503@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Paul Mundt <lethal@linux-sh.org>, Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 13, 2007 at 01:24:01PM +1000, Nick Piggin wrote:
> Paul Mundt wrote:
> >Here's an updated copy of the patch adding simple NUMA support to SLOB,
> >against the current -mm version of SLOB this time.
> >
> >I've tried to address all of the comments on the initial version so far,
> >but there's obviously still room for improvement.
> >
> >This approach is not terribly scalable in that we still end up using a
> >global freelist (and a global spinlock!) across all nodes, making the
> >partial free page lookup rather expensive. The next step after this will
> >be moving towards split freelists with finer grained locking.
> 
> I just think that this is not really a good intermediate step because
> you only get NUMA awareness from the first allocation out of a page. I
> guess that's an easy no-brainer for bigblock allocations, but for SLUB
> proper, it seems not so good.
> 
> For a lot of workloads you will have a steady state where allocation and
> freeing rates match pretty well and there won't be much movement of pages
> in and out of the allocator. In this case it will be back to random
> allocations, won't it?

Hmmm, probably.

Perhaps we can have a single list (or ring, rather) with per-node
insertion points. Then we can start node-local searches at the
insertion points..?

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
