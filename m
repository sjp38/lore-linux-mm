Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6D5296B0261
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 19:50:32 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ug1so50945419pab.3
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 16:50:32 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id z1si3950628pac.214.2016.06.06.16.50.31
        for <linux-mm@kvack.org>;
        Mon, 06 Jun 2016 16:50:31 -0700 (PDT)
Message-ID: <1465257023.22178.205.camel@linux.intel.com>
Subject: Re: [PATCH 10/10] mm: balance LRU lists based on relative thrashing
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Mon, 06 Jun 2016 16:50:23 -0700
In-Reply-To: <20160606194836.3624-11-hannes@cmpxchg.org>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
	 <20160606194836.3624-11-hannes@cmpxchg.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, kernel-team@fb.com

On Mon, 2016-06-06 at 15:48 -0400, Johannes Weiner wrote:
> Since the LRUs were split into anon and file lists, the VM has been
> balancing between page cache and anonymous pages based on per-list
> ratios of scanned vs. rotated pages. In most cases that tips page
> reclaim towards the list that is easier to reclaim and has the fewest
> actively used pages, but there are a few problems with it:
> 
> 1. Refaults and in-memory rotations are weighted the same way, even
> A A A though one costs IO and the other costs CPU. When the balance is
> A A A off, the page cache can be thrashing while anonymous pages are aged
> A A A comparably slower and thus have more time to get even their coldest
> A A A pages referenced. The VM would consider this a fair equilibrium.
> 
> 2. The page cache has usually a share of use-once pages that will
> A A A further dilute its scanned/rotated ratio in the above-mentioned
> A A A scenario. This can cease scanning of the anonymous list almost
> A A A entirely - again while the page cache is thrashing and IO-bound.
> 
> Historically, swap has been an emergency overflow for high memory
> pressure, and we avoided using it as long as new page allocations
> could be served from recycling page cache. However, when recycling
> page cache incurs a higher cost in IO than swapping out a few unused
> anonymous pages would, it makes sense to increase swap pressure.
> 
> In order to accomplish this, we can extend the thrash detection code
> that currently detects workingset changes within the page cache: when
> inactive cache pages are thrashing, the VM raises LRU pressure on the
> otherwise protected active file list to increase competition. However,
> when active pages begin refaulting as well, it means that the page
> cache is thrashing as a whole and the LRU balance should tip toward
> anonymous. This is what this patch implements.
> 
> To tell inactive from active refaults, a page flag is introduced that
> marks pages that have been on the active list in their lifetime. This
> flag is remembered in the shadow page entry on reclaim, and restored
> when the page refaults. It is also set on anonymous pages during
> swapin. When a page with that flag set is added to the LRU, the LRU
> balance is adjusted for the IO cost of reclaiming the thrashing list.

Johannes,

It seems like you are saying that the shadow entry is also present
for anonymous pages that are swapped out. A But once a page is swapped
out, its entry is removed from the radix tree and we won't be able
to store the shadow page entry as for file mapped pageA 
in __remove_mapping. A Or are you thinking of modifying
the current code to keep the radix tree entry? I may be missing something
so will appreciate if you can clarify.

Thanks.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
