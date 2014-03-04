Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 0E1006B0037
	for <linux-mm@kvack.org>; Mon,  3 Mar 2014 19:22:49 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id z10so4364377pdj.4
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 16:22:49 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id mp8si12220756pbc.172.2014.03.03.16.22.47
        for <linux-mm@kvack.org>;
        Mon, 03 Mar 2014 16:22:49 -0800 (PST)
Date: Tue, 4 Mar 2014 09:23:26 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 0/5] compaction related commits
Message-ID: <20140304002326.GA32172@lge.com>
References: <1392360843-22261-1-git-send-email-iamjoonsoo.kim@lge.com>
 <53146128.1010802@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53146128.1010802@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Mar 03, 2014 at 12:02:00PM +0100, Vlastimil Babka wrote:
> On 02/14/2014 07:53 AM, Joonsoo Kim wrote:
> > changes for v2
> > o include more experiment data in cover letter
> > o deal with vlastimil's comments mostly about commit description on 4/5
> > 
> > This patchset is related to the compaction.
> > 
> > patch 1 fixes contrary implementation of the purpose of compaction.
> > patch 2~4 are for optimization.
> > patch 5 is just for clean-up.
> > 
> > I tested this patchset with stress-highalloc benchmark on Mel's mmtest
> > and cannot find any regression in terms of success rate. And I find
> > much reduced(9%) elapsed time.
> > 
> > Below is the average result of 10 runs on my 4GB quad core system.
> > 
> > compaction-base+ is based on 3.13.0 with Vlastimil's recent fixes.
> > compaction-fix+ has this patch series on top of compaction-base+.
> > 
> > Thanks.
> > 
> > 
> > stress-highalloc	
> > 			3.13.0			3.13.0
> > 			compaction-base+	compaction-fix+
> > Success 1		14.10				15.00
> > Success 2		20.20				20.00
> > Success 3		68.30				73.40
> > 																			
> > 			3.13.0			3.13.0
> > 			compaction-base+	compaction-fix+
> > User			3486.02				3437.13
> > System			757.92				741.15
> > Elapsed			1638.52				1488.32
> > 
> > 			3.13.0			3.13.0
> > 			compaction-base+	compaction-fix+
> > Minor Faults 			172591561		167116621
> > Major Faults 			     984		     859
> > Swap Ins 			     743		     653
> > Swap Outs 			    3657		    3535
> > Direct pages scanned 		  129742		  127344
> > Kswapd pages scanned 		 1852277		 1817825
> > Kswapd pages reclaimed 		 1838000		 1804212
> > Direct pages reclaimed 		  129719		  127327
> > Kswapd efficiency 		     98%		     98%
> > Kswapd velocity 		1130.066		1221.296
> > Direct efficiency 		     99%		     99%
> > Direct velocity 		  79.367		  85.585
> > Percentage direct scans 	      6%		      6%
> > Zone normal velocity 		 231.829		 246.097
> > Zone dma32 velocity 		 972.589		1055.158
> > Zone dma velocity 		   5.015		   5.626
> > Page writes by reclaim 		    6287		    6534
> > Page writes file 		    2630		    2999
> > Page writes anon 		    3657		    3535
> > Page reclaim immediate 		    2187		    2080
> > Sector Reads 			 2917808		 2877336
> > Sector Writes 			11477891		11206722
> > Page rescued immediate 		       0		       0
> > Slabs scanned 			 2214118		 2168524
> > Direct inode steals 		   12181		    9788
> > Kswapd inode steals 		  144830		  132109
> > Kswapd skipped wait 		       0		       0
> > THP fault alloc 		       0		       0
> > THP collapse alloc 		       0		       0
> > THP splits 			       0		       0
> > THP fault fallback 		       0		       0
> > THP collapse fail 		       0		       0
> > Compaction stalls 		     738		     714
> > Compaction success 		     194		     207
> > Compaction failures 		     543		     507
> > Page migrate success 		 1806083		 1464014
> > Page migrate failure 		       0		       0
> > Compaction pages isolated 	 3873329	 	 3162974
> > Compaction migrate scanned 	74594862	 	59874420
> > Compaction free scanned 	125888854	 	110868637
> > Compaction cost 		    2469		    1998
> 
> FWIW, I've let a machine run the series with individual patches applied
> on 3.13 with my compaction patches, so 6 is the end of my series and 7-11 yours:
> The average is of 10 runs (in case you wonder how that's done, the success rates are
> calculated with a new R support that's pending Mel's merge; system time and vmstats
> are currently a hack, but I hope to add R support for them as well, and maybe publish
> to github or something if there's interest).

Good! I have an interest on it.

> 
> Interestingly, you have a much lower success rate and also much lower compaction cost
> and, well, even the benchmark times. Wonder what difference in config or hw causes this.
> You seem to have THP disabled, I enabled, but that would be weird to cause this.

My 10 runs are continuous 10 runs without reboot. It makes compaction success
rate decline on every trial and therefore average result is so low than yours.
I heard that you did 10 runs because of large stdev, so I thought that continuous 10 runs
also can makes the result reliable. Therefore I decided this method although it is not
proper method to get the average. I had to notify about it. If it confuses you,
sorry about that.

Anyway, noticeable point of continuous 10 runs is that success rate decrease continuously
and significantly. I attach the rate of success 3 on every trial on below.

Base
% Success:            80
% Success:            60
% Success:            76
% Success:            74
% Success:            70
% Success:            68
% Success:            66
% Success:            65
% Success:            63
% Success:            61


Applied with my patches
% Success:            81
% Success:            78
% Success:            75
% Success:            74
% Success:            71
% Success:            72
% Success:            73
% Success:            70
% Success:            70
% Success:            70

It means that memory is fragmented continously. I didn't dig into this problem, but
it would be good subject to investigate.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
