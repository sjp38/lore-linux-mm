Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8D3886B0047
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 00:03:09 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id o8T4372t012824
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 21:03:07 -0700
Received: from pxi17 (pxi17.prod.google.com [10.243.27.17])
	by wpaz29.hot.corp.google.com with ESMTP id o8T4332K000521
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 21:03:06 -0700
Received: by pxi17 with SMTP id 17so93619pxi.29
        for <linux-mm@kvack.org>; Tue, 28 Sep 2010 21:03:03 -0700 (PDT)
Date: Tue, 28 Sep 2010 21:02:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: zone state overhead
In-Reply-To: <20100928133059.GL8187@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1009282024570.31551@chino.kir.corp.google.com>
References: <20100928050801.GA29021@sli10-conroe.sh.intel.com> <alpine.DEB.2.00.1009280736020.4144@router.home> <20100928133059.GL8187@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Lameter <cl@linux.com>, Shaohua Li <shaohua.li@intel.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 28 Sep 2010, Mel Gorman wrote:

> This is true. It's helpful to remember why this patch exists. Under heavy
> memory pressure, large machines run the risk of live-locking because the
> NR_FREE_PAGES gets out of sync. The test case mentioned above is under
> memory pressure so it is potentially at risk. Ordinarily, we would be less
> concerned with performance under heavy memory pressure and more concerned with
> correctness of behaviour. The percpu_drift_mark is set at a point where the
> risk is "real".  Lowering it will help performance but increase risk. Reducing
> stat_threshold shifts the cost elsewhere by increasing the frequency the
> vmstat counters are updated which I considered to be worse overall.
> 
> Which of these is better or is there an alternative suggestion on how
> this livelock can be avoided?
> 

I don't think the risk is quite real based on the calculation of 
percpu_drift_mark using the high watermark instead of the min watermark.  
For Shaohua's 64 cpu system:

Node 3, zone   Normal
pages free     2055926
        min      1441
        low      1801
        high     2161
        scanned  0
        spanned  2097152
        present  2068480
  vm stats threshold: 98

It's possible that we'll be 98 pages/cpu * 64 cpus = 6272 pages off in the 
NR_FREE_PAGES accounting at any given time.  So to avoid depleting memory 
reserves at the min watermark, which is livelock, and unnecessarily 
spending time doing reclaim, percpu_drift_mark should be
1801 + 6272 = 8073 pages.  Instead, we're currently using the high 
watermark, so percpu_drift_mark is 8433 pages.

It's plausible that we never reclaim sufficient memory that we ever get 
above the high watermark since we only trigger reclaim when we can't 
allocate above low, so we may be stuck calling zone_page_state_snapshot() 
constantly.

I'd be interested to see if this patch helps.
---
diff --git a/mm/vmstat.c b/mm/vmstat.c
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -154,7 +154,7 @@ static void refresh_zone_stat_thresholds(void)
 		tolerate_drift = low_wmark_pages(zone) - min_wmark_pages(zone);
 		max_drift = num_online_cpus() * threshold;
 		if (max_drift > tolerate_drift)
-			zone->percpu_drift_mark = high_wmark_pages(zone) +
+			zone->percpu_drift_mark = low_wmark_pages(zone) +
 					max_drift;
 	}
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
