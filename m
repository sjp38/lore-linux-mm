Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 64F626B0005
	for <linux-mm@kvack.org>; Fri, 19 Feb 2016 15:21:02 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id a4so86345778wme.1
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 12:21:02 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id y125si14991745wmy.113.2016.02.19.12.21.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Feb 2016 12:21:01 -0800 (PST)
Date: Fri, 19 Feb 2016 15:20:00 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: scale kswapd watermarks in proportion to memory
Message-ID: <20160219202000.GB17342@cmpxchg.org>
References: <1455813719-2395-1-git-send-email-hannes@cmpxchg.org>
 <20160219112543.GJ4763@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160219112543.GJ4763@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Feb 19, 2016 at 11:25:43AM +0000, Mel Gorman wrote:
> On Thu, Feb 18, 2016 at 11:41:59AM -0500, Johannes Weiner wrote:
> > In machines with 140G of memory and enterprise flash storage, we have
> > seen read and write bursts routinely exceed the kswapd watermarks and
> > cause thundering herds in direct reclaim. Unfortunately, the only way
> > to tune kswapd aggressiveness is through adjusting min_free_kbytes -
> > the system's emergency reserves - which is entirely unrelated to the
> > system's latency requirements. In order to get kswapd to maintain a
> > 250M buffer of free memory, the emergency reserves need to be set to
> > 1G. That is a lot of memory wasted for no good reason.
> > 
> > On the other hand, it's reasonable to assume that allocation bursts
> > and overall allocation concurrency scale with memory capacity, so it
> > makes sense to make kswapd aggressiveness a function of that as well.
> > 
> > Change the kswapd watermark scale factor from the currently fixed 25%
> > of the tunable emergency reserve to a tunable 0.001% of memory.
> > 
> > On a 140G machine, this raises the default watermark steps - the
> > distance between min and low, and low and high - from 16M to 143M.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Intuitively, the patch makes sense although Rik's comments should be
> addressed.
> 
> The caveat will be that there will be workloads that used to fit into
> memory without reclaim that now have kswapd activity. It might manifest
> as continual reclaim with some thrashing but it should only apply to
> workloads that are exactly sized to fit in memory which in my experience
> are relatively rare. It should be "obvious" when occurs at least.

This is a problem only in theory, I think, because I doubt anybody is
able to keep a workingset reliably at a margin of less than 0.001% of
memory. I'd expect few users to even go within single digit margins
without eventually thrashing anyway.

It certainly becomes a real issue when users tune the scale factor,
but then it will be a deliberate act with known consequences. That's
what I choose to believe in.

> Acked-by: Mel Gorman <mgorman@suse.de>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
