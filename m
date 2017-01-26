Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 350976B0253
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 13:50:34 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id kq3so41701572wjc.1
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 10:50:34 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id d2si3012519wrc.260.2017.01.26.10.50.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 10:50:32 -0800 (PST)
Date: Thu, 26 Jan 2017 13:50:27 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/5] mm: vmscan: remove old flusher wakeup from direct
 reclaim path
Message-ID: <20170126185027.GB30636@cmpxchg.org>
References: <20170123181641.23938-1-hannes@cmpxchg.org>
 <20170123181641.23938-4-hannes@cmpxchg.org>
 <20170126100509.gbf6rxao6gsmqyq3@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170126100509.gbf6rxao6gsmqyq3@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Jan 26, 2017 at 10:05:09AM +0000, Mel Gorman wrote:
> On Mon, Jan 23, 2017 at 01:16:39PM -0500, Johannes Weiner wrote:
> > Direct reclaim has been replaced by kswapd reclaim in pretty much all
> > common memory pressure situations, so this code most likely doesn't
> > accomplish the described effect anymore. The previous patch wakes up
> > flushers for all reclaimers when we encounter dirty pages at the tail
> > end of the LRU. Remove the crufty old direct reclaim invocation.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> In general I like this. I worried first that if kswapd is blocked
> writing pages that it won't reach the wakeup_flusher_threads but the
> previous patch handles it.
> 
> Now though, it occurs to me with the last patch that we always writeout
> the world when flushing threads. This may not be a great idea. Consider
> for example if there is a heavy writer of short-lived tmp files. In such a
> case, it is possible for the files to be truncated before they even hit the
> disk. However, if there are multiple "writeout the world" calls, these may
> now be hitting the disk. Furthermore, multiplle kswapd and direct reclaimers
> could all be requested to writeout the world and each request unplugs.
> 
> Is it possible to maintain the property of writing back pages relative
> to the numbers of pages scanned or have you determined already that it's
> not necessary?

That's what I started out with - waking the flushers for nr_taken. I
was using a silly test case that wrote < dirty background limit and
then allocated a burst of anon memory. When the dirty data is linear,
the bigger IO requests are beneficial. They don't exhaust struct
request (like kswapd 4k IO routinely does, and SWAP_CLUSTER_MAX is
only 32), and they require less frequent plugging.

Force-flushing temporary files under memory pressure is a concern -
although the most recently dirtied files would get queued last, giving
them still some time to get truncated - but I'm wary about splitting
the flush requests too aggressively when we DO sustain throngs of
dirty pages hitting the reclaim scanners.

I didn't test this with the real workload that gave us problems yet,
though, because deploying enough machines to get a good sample size
takes 1-2 days and to run through the full load spectrum another 4-5.
So it's harder to fine-tune these patches.

But this is a legit concern. I'll try to find out what happens when we
reduce the wakeups to nr_taken.

Given the problem these patches address, though, would you be okay
with keeping this patch in -mm? We're too far into 4.10 to merge it
upstream now, and I should have data on more precise wakeups before
the next merge window.

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
