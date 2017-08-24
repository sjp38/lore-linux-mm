Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 99FA628084D
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 03:22:31 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id q16so32871709pgc.15
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 00:22:31 -0700 (PDT)
Received: from mail-pg0-x230.google.com (mail-pg0-x230.google.com. [2607:f8b0:400e:c05::230])
        by mx.google.com with ESMTPS id u1si2476222plk.370.2017.08.24.00.22.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 00:22:30 -0700 (PDT)
Received: by mail-pg0-x230.google.com with SMTP id s14so12779032pgs.1
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 00:22:30 -0700 (PDT)
Date: Thu, 24 Aug 2017 16:22:20 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/2][v2] mm: make kswapd try harder to keep active pages
 in cache
Message-ID: <20170824072220.GB20463@bgram>
References: <1503430539-2878-1-git-send-email-jbacik@fb.com>
 <1503430539-2878-2-git-send-email-jbacik@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1503430539-2878-2-git-send-email-jbacik@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: josef@toxicpanda.com
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, riel@redhat.com, akpm@linux-foundation.org, david@fromorbit.com, kernel-team@fb.com, aryabinin@virtuozzo.com, Josef Bacik <jbacik@fb.com>

On Tue, Aug 22, 2017 at 03:35:39PM -0400, josef@toxicpanda.com wrote:
> From: Josef Bacik <jbacik@fb.com>
> 
> While testing slab reclaim I noticed that if we were running a workload
> that used most of the system memory for it's working set and we start
> putting a lot of reclaimable slab pressure on the system (think find /,
> or some other silliness), we will happily evict the active pages over
> the slab cache.  This is kind of backwards as we want to do all that we
> can to keep the active working set in memory, and instead evict these
> short lived objects.  The same thing occurs when say you do a yum
> update of a few packages while your working set takes up most of RAM,
> you end up with inactive lists being relatively small and so we reclaim
> active pages even though we could reclaim these short lived inactive
> pages.

The fundament problem is we cannot identify what are working set and
short-lived objects in adavnce without enough aging so such workload
transition in a short time is really hard to catch up.

A idea in my mind is to create two level list(active, inactive list)
like LRU pages. Then, starts objects inactive list and doesn't promote
the object into active list unless it touches.

Once we see refault of page cache, it would be a good signal to
accelerate slab shrinking. Or, reclaim shrinker's inactive list firstly
before the shrinking page cache active list.
Same way have been used for page cache's inactive list to prevent
anonymous page reclaiming. See get_scan_count.

It's non trivial but worth to try if system with heavy slab objects
would be popular, IMHO.

> 
> My approach here is twofold.  First, keep track of the difference in
> inactive and slab pages since the last time kswapd ran.  In the first
> run this will just be the overall counts of inactive and slab, but for
> each subsequent run we'll have a good idea of where the memory pressure
> is coming from.  Then we use this information to put pressure on either
> the inactive lists or the slab caches, depending on where the pressure
> is coming from.

I don't like this idea.

The pressure should be fair if possible and victim decision should come
from the aging. If we want to put more pressure, it should come from
some feedback loop. And I don't think diff of allocation would be a good
factor for that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
