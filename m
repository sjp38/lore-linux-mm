Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D7CF66B02B5
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 12:00:12 -0400 (EDT)
Received: by pzk33 with SMTP id 33so905397pzk.14
        for <linux-mm@kvack.org>; Thu, 19 Aug 2010 09:00:13 -0700 (PDT)
Date: Fri, 20 Aug 2010 01:00:07 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: compaction: trying to understand the code
Message-ID: <20100819160006.GG6805@barrios-desktop>
References: <325E0A25FE724BA18190186F058FF37E@rainbow>
 <20100817111018.GQ19797@csn.ul.ie>
 <4385155269B445AEAF27DC8639A953D7@rainbow>
 <20100818154130.GC9431@localhost>
 <565A4EE71DAC4B1A820B2748F56ABF73@rainbow>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <565A4EE71DAC4B1A820B2748F56ABF73@rainbow>
Sender: owner-linux-mm@kvack.org
To: Iram Shahzad <iram.shahzad@jp.fujitsu.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 19, 2010 at 04:09:38PM +0900, Iram Shahzad wrote:
> >The loop should be waiting for the _other_ processes (doing direct
> >reclaims) to proceed.  When there are _lots of_ ongoing page
> >allocations/reclaims, it makes sense to wait for them to calm down a bit?
> 
> I have noticed that if I run other process, it helps the loop to exit.
> So is this (ie hanging until other process helps) intended behaviour?
> 
> Also, the other process does help the loop to exit, but again it enters
> the loop and the compaction is never finished. That is, the process
> looks like hanging. Is this intended behaviour?
> What will improve this situation?
> 
I don't know why too many pages are isolated.
Could you apply below patch for debugging and report it?

diff --git a/mm/compaction.c b/mm/compaction.c
index 94cce51..17f339f 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -215,6 +215,7 @@ static void acct_isolated(struct zone *zone, struct compact_control *cc)
 static bool too_many_isolated(struct zone *zone)
 {
 
+       int overflow = 0;
        unsigned long inactive, isolated;
 
        inactive = zone_page_state(zone, NR_INACTIVE_FILE) +
@@ -222,7 +223,13 @@ static bool too_many_isolated(struct zone *zone)
        isolated = zone_page_state(zone, NR_ISOLATED_FILE) +
                                        zone_page_state(zone, NR_ISOLATED_ANON);
 
-       return isolated > inactive;
+       if (isolated > inactive)
+               overflow = 1;
+
+       if (overflow)
+               show_mem();     
+
+       return overflow;
 }


> Thanks
> Iram
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
