Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0C2196B0022
	for <linux-mm@kvack.org>; Tue, 17 May 2011 05:48:52 -0400 (EDT)
Date: Tue, 17 May 2011 10:48:45 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 3/3] mm: slub: Default slub_max_order to 0
Message-ID: <20110517094845.GK5279@suse.de>
References: <1305127773-10570-1-git-send-email-mgorman@suse.de>
 <1305127773-10570-4-git-send-email-mgorman@suse.de>
 <alpine.DEB.2.00.1105111314310.9346@chino.kir.corp.google.com>
 <20110512173628.GJ11579@random.random>
 <alpine.DEB.2.00.1105161356140.4353@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1105161356140.4353@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, James Bottomley <James.Bottomley@hansenpartnership.com>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Mon, May 16, 2011 at 02:03:33PM -0700, David Rientjes wrote:
> On Thu, 12 May 2011, Andrea Arcangeli wrote:
> 
> > On Wed, May 11, 2011 at 01:38:47PM -0700, David Rientjes wrote:
> > > kswapd and doing compaction for the higher order allocs before falling 
> > 
> > Note that patch 2 disabled compaction by clearing __GFP_WAIT.
> > 
> > What you describe here would be patch 2 without the ~__GFP_WAIT
> > addition (so keeping only ~GFP_NOFAIL).
> > 
> 
> It's out of context, my sentence was:
> 
> "With the previous changes in this patchset, specifically avoiding waking 
> kswapd and doing compaction for the higher order allocs before falling 
> back to the min order..."
> 
> meaning this patchset avoids waking kswapd and avoids doing compaction.
> 

Ok.

> > Not clearing __GFP_WAIT when compaction is enabled is possible and
> > shouldn't result in bad behavior (if compaction is not enabled with
> > current SLUB it's hard to imagine how it could perform decently if
> > there's fragmentation). You should try to benchmark to see if it's
> > worth it on the large NUMA systems with heavy network traffic (for
> > normal systems I doubt compaction is worth it but I'm not against
> > trying to keep it enabled just in case).
> > 
> 
> The fragmentation isn't the only issue with the netperf TCP_RR benchmark, 
> the problem is that the slub slowpath is being used >95% of the time on 
> every allocation and free for the very large number of kmalloc-256 and 
> kmalloc-2K caches. 

Ok, that makes sense as I'd full expect that benchmark to exhaust
the per-cpu page (high order or otherwise) of slab objects routinely
during default and I'd also expect the freeing on the other side to
be releasing slabs frequently to the partial or empty lists.

> Those caches are order 1 and 3, respectively, on my 
> system by default, but the page allocator seldomly gets invoked for such a 
> benchmark after the partial lists are populated: the overhead is from the 
> per-node locking required in the slowpath to traverse the partial lists.  
> See the data I presented two years ago: http://lkml.org/lkml/2009/3/30/15.

Ok, I can see how this patch would indeed make the situation worse. I
vaguely recall that there were other patches that would increase the
per-cpu lists of objects but have no recollection as to what happened
them.

Maybe Christoph remembers but one way or the other, it's out of scope
for James' and Colin's bug.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
