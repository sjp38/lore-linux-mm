Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1DF566B0253
	for <linux-mm@kvack.org>; Fri, 29 Jul 2016 10:11:38 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id p129so40308379wmp.3
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 07:11:38 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id tn19si19071969wjb.284.2016.07.29.07.11.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jul 2016 07:11:36 -0700 (PDT)
Date: Fri, 29 Jul 2016 10:11:30 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC] mm: bail out in shrin_inactive_list
Message-ID: <20160729141130.GC2034@cmpxchg.org>
References: <1469433119-1543-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1469433119-1543-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 25, 2016 at 04:51:59PM +0900, Minchan Kim wrote:
> With node-lru, if there are enough reclaimable pages in highmem
> but nothing in lowmem, VM can try to shrink inactive list although
> the requested zone is lowmem.
> 
> The problem is direct reclaimer scans inactive list is fulled with
> highmem pages to find a victim page at a reqested zone or lower zones
> but the result is that VM should skip all of pages. It just burns out
> CPU. Even, many direct reclaimers are stalled by too_many_isolated
> if lots of parallel reclaimer are going on although there are no
> reclaimable memory in inactive list.
> 
> I tried the experiment 4 times in 32bit 2G 8 CPU KVM machine
> to get elapsed time.
> 
> 	hackbench 500 process 2
> 
> = Old =
> 
> 1st: 289s 2nd: 310s 3rd: 112s 4th: 272s
> 
> = Now =
> 
> 1st: 31s  2nd: 132s 3rd: 162s 4th: 50s.
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
> I believe proper fix is to modify get_scan_count. IOW, I think
> we should introduce lruvec_reclaimable_lru_size with proper
> classzone_idx but I don't know how we can fix it with memcg
> which doesn't have zone stat now. should introduce zone stat
> back to memcg? Or, it's okay to ignore memcg?

You can fully ignore memcg and kmemcg. They only care about the
balance sheet - page in, page out - never mind the type of page.

If you are allocating a slab object and there is no physical memory,
you'll wake kswapd or enter direct reclaim with the restricted zone
index. If you then try to charge the freshly allocated page or object
but hit the limit, kmem or otherwise, you'll enter memcg reclaim that
is not restricted and only cares about getting usage + pages < limit.

I agree that it might be better to put this logic in get_scan_count()
and set both nr[lru] as well as *lru_pages according to the pages that
are eligible for the given reclaim index.

if (global_reclaim(sc))
  add zone stats from 0 to sc->reclaim_idx
else
  use lruvec_lru_size()

It's a bit unfortunate that abstractions like the lruvec fall apart
when we have to reconstruct zones ad-hoc now, but I don't see any
obvious way around it...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
