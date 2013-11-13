Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f77.google.com (mail-qa0-f77.google.com [209.85.216.77])
	by kanga.kvack.org (Postfix) with ESMTP id 15AFE6B0037
	for <linux-mm@kvack.org>; Sat, 16 Nov 2013 09:44:40 -0500 (EST)
Received: by mail-qa0-f77.google.com with SMTP id cm18so5308qab.0
        for <linux-mm@kvack.org>; Sat, 16 Nov 2013 06:44:39 -0800 (PST)
Received: from psmtp.com ([74.125.245.192])
        by mx.google.com with SMTP id n8si1951110pax.276.2013.11.13.07.24.22
        for <linux-mm@kvack.org>;
        Wed, 13 Nov 2013 07:24:23 -0800 (PST)
Date: Wed, 13 Nov 2013 10:24:12 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm, vmscan: abort futile reclaim if we've been oom killed
Message-ID: <20131113152412.GH707@cmpxchg.org>
References: <alpine.DEB.2.02.1311121801200.18803@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1311121801200.18803@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Nov 12, 2013 at 06:02:18PM -0800, David Rientjes wrote:
> The oom killer is only invoked when reclaim has already failed and it
> only kills processes if the victim is also oom.  In other words, the oom
> killer does not select victims when a process tries to allocate from a
> disjoint cpuset or allocate DMA memory, for example.
> 
> Therefore, it's pointless for an oom killed process to continue
> attempting to reclaim memory in a loop when it has been granted access to
> memory reserves.  It can simply return to the page allocator and allocate
> memory.

On the other hand, finishing reclaim of 32 pages should not be a
problem.

> If there is a very large number of processes trying to reclaim memory,
> the cond_resched() in shrink_slab() becomes troublesome since it always
> forces a schedule to other processes also trying to reclaim memory.
> Compounded by many reclaim loops, it is possible for a process to sit in
> do_try_to_free_pages() for a very long time when reclaim is pointless and
> it could allocate if it just returned to the page allocator.

"Very large number of processes"

"sit in do_try_to_free_pages() for a very long time"

Can you quantify this a bit more?

And how common are OOM kills on your setups that you need to optimize
them on this level?

It sounds like your problem could be solved by having cond_resched()
not schedule away from TIF_MEMDIE processes, which would be much
preferable to oom-killed checks in random places.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
