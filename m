Date: Sat, 17 Apr 2004 11:10:42 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Might refill_inactive_zone () be too aggressive?
Message-ID: <20040417181042.GM743@holomorphy.com>
References: <20040417060920.GC29393@flea> <20040417061847.GC743@holomorphy.com> <20040417175723.GA3235@flea>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040417175723.GA3235@flea>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marc Singer <elf@buici.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Apr 17, 2004 at 10:57:24AM -0700, Marc Singer wrote:
> I don't think that's the whole story.  I printed distress,
> mapped_ratio, and swappiness when vmscan starts trying to reclaim
> mapped pages.
> reclaim_mapped: distress 50  mapped_ratio 0  swappiness 60 
>   50 + 60 > 100 
> So, part of the problem is swappiness.  I could set that value to 25,
> for example, to stop the machine from swapping.
> I'd be fine stopping here, except for you comment about what
> swappiness means.  In my case, nearly none of memory is mapped.  It is
> zone priority which has dropped to 1 that is precipitating the
> eviction.  Is this what you expect and want?

I'm not sure it's expected. Maybe this patch fares better?


-- wli


Index: singer-2.6.5-mm6/mm/vmscan.c
===================================================================
--- singer-2.6.5-mm6.orig/mm/vmscan.c	2004-04-14 23:21:19.000000000 -0700
+++ singer-2.6.5-mm6/mm/vmscan.c	2004-04-17 11:09:35.000000000 -0700
@@ -636,7 +636,7 @@
 	 *
 	 * A 100% value of vm_swappiness overrides this algorithm altogether.
 	 */
-	swap_tendency = mapped_ratio / 2 + distress + vm_swappiness;
+	swap_tendency = mapped_ratio / 2 + max(distress, vm_swappiness);
 
 	/*
 	 * Now use this metric to decide whether to start moving mapped memory
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
