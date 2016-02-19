Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id C58C66B0005
	for <linux-mm@kvack.org>; Fri, 19 Feb 2016 06:25:48 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id c200so70852301wme.0
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 03:25:48 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a10si12113770wmc.91.2016.02.19.03.25.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 Feb 2016 03:25:47 -0800 (PST)
Date: Fri, 19 Feb 2016 11:25:43 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: scale kswapd watermarks in proportion to memory
Message-ID: <20160219112543.GJ4763@suse.de>
References: <1455813719-2395-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1455813719-2395-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Feb 18, 2016 at 11:41:59AM -0500, Johannes Weiner wrote:
> In machines with 140G of memory and enterprise flash storage, we have
> seen read and write bursts routinely exceed the kswapd watermarks and
> cause thundering herds in direct reclaim. Unfortunately, the only way
> to tune kswapd aggressiveness is through adjusting min_free_kbytes -
> the system's emergency reserves - which is entirely unrelated to the
> system's latency requirements. In order to get kswapd to maintain a
> 250M buffer of free memory, the emergency reserves need to be set to
> 1G. That is a lot of memory wasted for no good reason.
> 
> On the other hand, it's reasonable to assume that allocation bursts
> and overall allocation concurrency scale with memory capacity, so it
> makes sense to make kswapd aggressiveness a function of that as well.
> 
> Change the kswapd watermark scale factor from the currently fixed 25%
> of the tunable emergency reserve to a tunable 0.001% of memory.
> 
> On a 140G machine, this raises the default watermark steps - the
> distance between min and low, and low and high - from 16M to 143M.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Intuitively, the patch makes sense although Rik's comments should be
addressed.

The caveat will be that there will be workloads that used to fit into
memory without reclaim that now have kswapd activity. It might manifest
as continual reclaim with some thrashing but it should only apply to
workloads that are exactly sized to fit in memory which in my experience
are relatively rare. It should be "obvious" when occurs at least.

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
