Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B590090010D
	for <linux-mm@kvack.org>; Mon, 16 May 2011 17:04:07 -0400 (EDT)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id p4GL3ojZ029652
	for <linux-mm@kvack.org>; Mon, 16 May 2011 14:03:50 -0700
Received: from pzk1 (pzk1.prod.google.com [10.243.19.129])
	by hpaq5.eem.corp.google.com with ESMTP id p4GL3TnO030208
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 16 May 2011 14:03:43 -0700
Received: by pzk1 with SMTP id 1so3158958pzk.16
        for <linux-mm@kvack.org>; Mon, 16 May 2011 14:03:35 -0700 (PDT)
Date: Mon, 16 May 2011 14:03:33 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/3] mm: slub: Default slub_max_order to 0
In-Reply-To: <20110512173628.GJ11579@random.random>
Message-ID: <alpine.DEB.2.00.1105161356140.4353@chino.kir.corp.google.com>
References: <1305127773-10570-1-git-send-email-mgorman@suse.de> <1305127773-10570-4-git-send-email-mgorman@suse.de> <alpine.DEB.2.00.1105111314310.9346@chino.kir.corp.google.com> <20110512173628.GJ11579@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, James Bottomley <James.Bottomley@hansenpartnership.com>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Thu, 12 May 2011, Andrea Arcangeli wrote:

> On Wed, May 11, 2011 at 01:38:47PM -0700, David Rientjes wrote:
> > kswapd and doing compaction for the higher order allocs before falling 
> 
> Note that patch 2 disabled compaction by clearing __GFP_WAIT.
> 
> What you describe here would be patch 2 without the ~__GFP_WAIT
> addition (so keeping only ~GFP_NOFAIL).
> 

It's out of context, my sentence was:

"With the previous changes in this patchset, specifically avoiding waking 
kswapd and doing compaction for the higher order allocs before falling 
back to the min order..."

meaning this patchset avoids waking kswapd and avoids doing compaction.

> Not clearing __GFP_WAIT when compaction is enabled is possible and
> shouldn't result in bad behavior (if compaction is not enabled with
> current SLUB it's hard to imagine how it could perform decently if
> there's fragmentation). You should try to benchmark to see if it's
> worth it on the large NUMA systems with heavy network traffic (for
> normal systems I doubt compaction is worth it but I'm not against
> trying to keep it enabled just in case).
> 

The fragmentation isn't the only issue with the netperf TCP_RR benchmark, 
the problem is that the slub slowpath is being used >95% of the time on 
every allocation and free for the very large number of kmalloc-256 and 
kmalloc-2K caches.  Those caches are order 1 and 3, respectively, on my 
system by default, but the page allocator seldomly gets invoked for such a 
benchmark after the partial lists are populated: the overhead is from the 
per-node locking required in the slowpath to traverse the partial lists.  
See the data I presented two years ago: http://lkml.org/lkml/2009/3/30/15.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
