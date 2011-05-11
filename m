Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id DD0026B0012
	for <linux-mm@kvack.org>; Wed, 11 May 2011 16:53:17 -0400 (EDT)
Subject: Re: [PATCH 3/3] mm: slub: Default slub_max_order to 0
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <alpine.DEB.2.00.1105111314310.9346@chino.kir.corp.google.com>
References: <1305127773-10570-1-git-send-email-mgorman@suse.de>
	 <1305127773-10570-4-git-send-email-mgorman@suse.de>
	 <alpine.DEB.2.00.1105111314310.9346@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 11 May 2011 15:53:11 -0500
Message-ID: <1305147191.2606.51.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Wed, 2011-05-11 at 13:38 -0700, David Rientjes wrote:
> On Wed, 11 May 2011, Mel Gorman wrote:
> 
> > To avoid locking and per-cpu overhead, SLUB optimisically uses
> > high-order allocations up to order-3 by default and falls back to
> > lower allocations if they fail. While care is taken that the caller
> > and kswapd take no unusual steps in response to this, there are
> > further consequences like shrinkers who have to free more objects to
> > release any memory. There is anecdotal evidence that significant time
> > is being spent looping in shrinkers with insufficient progress being
> > made (https://lkml.org/lkml/2011/4/28/361) and keeping kswapd awake.
> > 
> > SLUB is now the default allocator and some bug reports have been
> > pinned down to SLUB using high orders during operations like
> > copying large amounts of data. SLUBs use of high-orders benefits
> > applications that are sized to memory appropriately but this does not
> > necessarily apply to large file servers or desktops.  This patch
> > causes SLUB to use order-0 pages like SLAB does by default.
> > There is further evidence that this keeps kswapd's usage lower
> > (https://lkml.org/lkml/2011/5/10/383).
> > 
> 
> This is going to severely impact slub's performance for applications on 
> machines with plenty of memory available where fragmentation isn't a 
> concern when allocating from caches with large object sizes (even 
> changing the min order of kamlloc-256 from 1 to 0!) by default for users 
> who don't use slub_max_order=3 on the command line.  SLUB relies heavily 
> on allocating from the cpu slab and freeing to the cpu slab to avoid the 
> slowpaths, so higher order slabs are important for its performance.
> 
> I can get numbers for a simple netperf TCP_RR benchmark with this change 
> applied to show the degradation on a server with >32GB of RAM with this 
> patch applied.
> 
> It would be ideal if this default could be adjusted based on the amount of 
> memory available in the smallest node to determine whether we're concerned 
> about making higher order allocations.  (Using the smallest node as a 
> metric so that mempolicies and cpusets don't get unfairly biased against.)  
> With the previous changes in this patchset, specifically avoiding waking 
> kswapd and doing compaction for the higher order allocs before falling 
> back to the min order, it shouldn't be devastating to try an order-3 alloc 
> that will fail quickly.

So my testing has shown that simply booting the kernel with
slub_max_order=0 makes the hang I'm seeing go away.  This definitely
implicates the higher order allocations in the kswapd problem.  I think
it would be wise not to make it the default until we can sort out the
root cause.

James




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
