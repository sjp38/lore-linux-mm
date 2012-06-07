Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 923DE6B006C
	for <linux-mm@kvack.org>; Thu,  7 Jun 2012 10:46:00 -0400 (EDT)
Date: Thu, 7 Jun 2012 16:45:56 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC -mm] memcg: prevent from OOM with too many dirty pages
Message-ID: <20120607144556.GC543@tiehlicka.suse.cz>
References: <1338219535-7874-1-git-send-email-mhocko@suse.cz>
 <20120529030857.GA7762@localhost>
 <20120529072853.GD1734@cmpxchg.org>
 <20120529084848.GC10469@localhost>
 <20120529093511.GE1734@cmpxchg.org>
 <20120529135101.GD15293@tiehlicka.suse.cz>
 <20120531090957.GA12809@tiehlicka.suse.cz>
 <20120601083730.GA25986@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120601083730.GA25986@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Fengguang Wu <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>

On Fri 01-06-12 10:37:30, Michal Hocko wrote:
[...]
> More detailed statistics (max/min - the worst/best performance).
> 	comparison (cong is 100%)	comparison (page reclaim 100%)			
> 	max	min	median		max	min	median
> * ext3
> ** Write
> 5M	171.20%	95.33%	98.70%		216.96%	101.99%	103.61%
> 60M	97.56%	98.80%	104.51%		110.09%	100.11%	116.59%
> 300M	99.76%	99.49%	99.35%		99.47%	99.89%	99.57%
> 2G	99.52%	99.53%	99.52%		100.09%	99.07%	100.02%
> 
> ** Read					
> 5M	35.37%	38.70%	39.09%		83.55%	89.85%	86.54%
> 60M	89.70%	102.90%	102.00%		97.71%	101.91%	102.06%
> 300M	92.38%	99.33%	99.14%		80.65%	98.39%	91.23%
> 2G	90.07%	99.92%	100.38%		99.85%	100.75%	99.94%
> 
> * Tmpfs					
> ** write
> 5M	121.85%	99.69%	131.57%		219.22%	99.85%	135.30%
> 60M	140.82%	99.70%	139.57%		98.14%	54.51%	73.65%
> 300M	97.99%	99.54%	99.60%		99.29%	99.57%	99.32%
> 2G	99.37%	99.62%	99.64%		98.72%	99.92%	99.18%
> 
> ** read				
> 5M	85.44%	92.96%	88.92%		129.13%	101.54%	97.87%
> 60M	64.41%	94.35%	88.10%		97.41%	95.75%	96.31%
> 300M	116.89%	106.52%	120.84%		132.17%	104.39%	130.63%
> 2G	86.27%	99.96%	87.47%		60.69%	99.44%	98.49%

I have played with the patch below but it didn't show too much
difference in the end or we end up doing even worse. 

Here is the no_patch/patched comparison:

	comparison (page reclaim is 100%)
* ext3  avg	max	min	median
** Write
5M    	81.49%	77.53%	101.91%	76.60%
60M   	98.60%	95.58%	101.40%	99.62%
300M  	101.68%	102.05%	101.19%	101.73%
2G    	102.20%	102.25%	102.12%	102.22%
				
** Read  				
5M    	103.94%	105.14%	103.95%	103.32%
60M   	105.26%	107.91%	103.15%	104.95%
300M  	104.83%	107.86%	101.65%	104.88%
2G    	102.67%	101.26%	102.83%	103.35%

* Tmpfs
** Write
5M    	107.68%	119.66%	105.26%	102.78%
60M   	122.16%	138.51%	103.62%	121.09%
300M  	101.03%	100.67%	101.11%	101.17%
2G    	101.82%	101.66%	101.87%	101.87%
				
** Read			
5M    	102.47%	124.02%	98.05%	92.57%
60M   	103.62%	121.03%	96.97%	96.52%
300M  	98.90%	118.92%	102.64%	86.19%
2G    	83.50%	76.34%	97.36%	81.92%

I am not sure it really makes sense to play with the priority here. All
the values we would end up with would be just wild guesses or mostly
artificial workloads. So I think it makes some to go with the original
version of the PageReclaim patch without any further fiddling with the
priority.

Is this sufficient to go with the patch or do people still have concerns
which would block the patch from merging?

---
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7cccd81..a240bdf 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -726,7 +726,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			 * writeback from reclaim and there is nothing else to
 			 * reclaim.
 			 */
-			if (PageReclaim(page)
+			if (PageReclaim(page) && sc->priority < DEF_PRIORITY - 3
 					&& may_enter_fs && !global_reclaim(sc))
 				wait_on_page_writeback(page);
 			else {
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
