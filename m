Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 198A66B0025
	for <linux-mm@kvack.org>; Tue, 17 May 2011 15:26:06 -0400 (EDT)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id p4HJPmfU000316
	for <linux-mm@kvack.org>; Tue, 17 May 2011 12:25:48 -0700
Received: from pvg16 (pvg16.prod.google.com [10.241.210.144])
	by kpbe17.cbf.corp.google.com with ESMTP id p4HJPXhJ006333
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 17 May 2011 12:25:42 -0700
Received: by pvg16 with SMTP id 16so485595pvg.15
        for <linux-mm@kvack.org>; Tue, 17 May 2011 12:25:41 -0700 (PDT)
Date: Tue, 17 May 2011 12:25:39 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/3] mm: slub: Default slub_max_order to 0
In-Reply-To: <20110517094845.GK5279@suse.de>
Message-ID: <alpine.DEB.2.00.1105171220400.5438@chino.kir.corp.google.com>
References: <1305127773-10570-1-git-send-email-mgorman@suse.de> <1305127773-10570-4-git-send-email-mgorman@suse.de> <alpine.DEB.2.00.1105111314310.9346@chino.kir.corp.google.com> <20110512173628.GJ11579@random.random> <alpine.DEB.2.00.1105161356140.4353@chino.kir.corp.google.com>
 <20110517094845.GK5279@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, James Bottomley <James.Bottomley@hansenpartnership.com>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Tue, 17 May 2011, Mel Gorman wrote:

> > The fragmentation isn't the only issue with the netperf TCP_RR benchmark, 
> > the problem is that the slub slowpath is being used >95% of the time on 
> > every allocation and free for the very large number of kmalloc-256 and 
> > kmalloc-2K caches. 
> 
> Ok, that makes sense as I'd full expect that benchmark to exhaust
> the per-cpu page (high order or otherwise) of slab objects routinely
> during default and I'd also expect the freeing on the other side to
> be releasing slabs frequently to the partial or empty lists.
> 

That's most of the problem, but it's compounded on this benchmark because 
the slab pulled from the partial list to replace the per-cpu page 
typically only has a very minimal number (2 or 3) of free objects, so it 
can only serve one allocation and then require the allocation slowpath to 
pull yet another slab from the partial list the next time around.  I had a 
patchset that addressed that, which I called "slab thrashing", by only 
pulling a slab from the partial list when it had a pre-defined proportion 
of available objects and otherwise skipping it, and that ended up helping 
the benchmark by 5-7%.  Smaller orders will make this worse, as well, 
since if there were only 2 or 3 free objects on an order-3 slab before, 
there's no chance that's going to be equivalent on an order-0 slab.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
