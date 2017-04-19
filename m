Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 602E16B03AB
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 03:04:30 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id d79so850599wma.0
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 00:04:30 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l41si2100329wrl.237.2017.04.19.00.04.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Apr 2017 00:04:28 -0700 (PDT)
Date: Wed, 19 Apr 2017 09:04:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, vmscan: avoid thrashing anon lru when free + file is
 low
Message-ID: <20170419070424.GA28263@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1704171657550.139497@chino.kir.corp.google.com>
 <20170418013659.GD21354@bbox>
 <alpine.DEB.2.10.1704181402510.112481@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1704181402510.112481@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 18-04-17 14:32:56, David Rientjes wrote:
[...]
> If the suggestion is checking
> NR_ACTIVE_ANON + NR_INACTIVE_ANON > total_high_wmark pages, it would be a 
> separate heurstic to address a problem that I'm not having :)  My issue is 
> specifically when NR_ACTIVE_FILE + NR_INACTIVE_FILE < total_high_wmark, 
> NR_ACTIVE_ANON + NR_INACTIVE_ANON is very large, but all not on this 
> lruvec's evictable lrus.

Hmm, why are those pages not moved to the unevictable LRU lists?

> This is the reason why I chose lruvec_lru_size() rather than per-node 
> statistics.  The argument could also be made for the file lrus in the 
> get_scan_count() heuristic that forces SCAN_ANON, but I have not met such 
> an issue (yet).  I could follow-up with that change or incorporate it into 
> a v2 of this patch if you'd prefer.
> 
> In other words, I want get_scan_count() to not force SCAN_ANON and 
> fallback to SCAN_FRACT, absent other heuristics, if the amount of 
> evictable anon is below a certain threshold for this lruvec.  I 
> arbitrarily chose SWAP_CLUSTER_MAX to be conservative, but I could easily 
> compare to total_high_wmark as well, although I would consider that more 
> aggressive.
> 
> So we're in global reclaim, our file lrus are below thresholds, but we 
> don't want to force SCAN_ANON for all lruvecs if there's not enough to 
> reclaim from evictable anon.  Do you have a suggestion for how to 
> implement this logic other than this patch?

I agree that forcing SCAN_ANON without looking at the ANON lru size is
not optimal but I would rather see the same criterion for both anon and
file. get_scan_count is full of magic heuristics which tend to break for
different workloads. Let's not add another magic on top please.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
