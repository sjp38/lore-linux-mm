Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 8CCFE6B0031
	for <linux-mm@kvack.org>; Sun,  9 Feb 2014 19:24:21 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id md12so5508941pbc.12
        for <linux-mm@kvack.org>; Sun, 09 Feb 2014 16:24:21 -0800 (PST)
Received: from LGEMRELSE1Q.lge.com (LGEMRELSE1Q.lge.com. [156.147.1.111])
        by mx.google.com with ESMTP id i4si13252781pad.54.2014.02.09.16.24.19
        for <linux-mm@kvack.org>;
        Sun, 09 Feb 2014 16:24:20 -0800 (PST)
Date: Mon, 10 Feb 2014 09:24:26 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 0/5] compaction related commits
Message-ID: <20140210002426.GA12049@lge.com>
References: <1391749726-28910-1-git-send-email-iamjoonsoo.kim@lge.com>
 <52F4A3F2.1050809@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52F4A3F2.1050809@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Feb 07, 2014 at 10:14:26AM +0100, Vlastimil Babka wrote:
> On 02/07/2014 06:08 AM, Joonsoo Kim wrote:
> > This patchset is related to the compaction.
> > 
> > patch 1 fixes contrary implementation of the purpose of compaction.
> > patch 2~4 are for optimization.
> > patch 5 is just for clean-up.
> > 
> > I tested this patchset with stress-highalloc benchmark on Mel's mmtest
> > and cannot find any regression in terms of success rate. And I find
> > much reduced system time. Below is result of 3 runs.
> 
> What was the memory size? Mel told me this test shouldn't be run with more than 4GB.

Yep, I know!
My system is 4GB quad core system.

> > * Before
> > time :: stress-highalloc 3276.26 user 740.52 system 1664.79 elapsed
> > time :: stress-highalloc 3640.71 user 771.32 system 1633.83 elapsed
> > time :: stress-highalloc 3691.64 user 775.44 system 1638.05 elapsed
> > 
> > avg system: 1645 s
> > 
> > * After
> > time :: stress-highalloc 3225.51 user 732.40 system 1542.76 elapsed
> > time :: stress-highalloc 3524.31 user 749.63 system 1512.88 elapsed
> > time :: stress-highalloc 3610.55 user 757.20 system 1505.70 elapsed
> > 
> > avg system: 1519 s
> > 
> > That is 7% reduced system time.

Oops, It should be elapsed time ;)

> Why not post the whole compare-mmtests output? There are more metrics in there and extra
> eyes never hurt.
> 

Reason is that I can't average the result of 10 runs easily, since I'm not
familiar to mmtest. Do you share your method to get the average of 10 runs?
Anyway, I did it manually and below is the average result of 10 runs.

compaction-base+ is based on 3.13.0 with Vlastimil's recent fixes.
compaction-fix+ has this patch series on top of compaction-base+.

Thanks.
							
stress-highalloc	
			3.13.0			3.13.0
			compaction-base+	compaction-fix+
Success 1		14.10				15.00
Success 2		20.20				20.00
Success 3		68.30				73.40
																			
			3.13.0			3.13.0
			compaction-base+	compaction-fix+
User			3486.02				3437.13
System			757.92				741.15
Elapsed			1638.52				1488.32
																			
			3.13.0			3.13.0
			compaction-base+	compaction-fix+
Minor Faults 			172591561		167116621
Major Faults 			     984		     859
Swap Ins 			     743		     653
Swap Outs 			    3657		    3535
Direct pages scanned 		  129742		  127344
Kswapd pages scanned 		 1852277		 1817825
Kswapd pages reclaimed 		 1838000		 1804212
Direct pages reclaimed 		  129719		  127327
Kswapd efficiency 		     98%		     98%
Kswapd velocity 		1130.066		1221.296
Direct efficiency 		     99%		     99%
Direct velocity 		  79.367		  85.585
Percentage direct scans 	      6%		      6%
Zone normal velocity 		 231.829		 246.097
Zone dma32 velocity 		 972.589		1055.158
Zone dma velocity 		   5.015		   5.626
Page writes by reclaim 		    6287		    6534
Page writes file 		    2630		    2999
Page writes anon 		    3657		    3535
Page reclaim immediate 		    2187		    2080
Sector Reads 			 2917808		 2877336
Sector Writes 			11477891		11206722
Page rescued immediate 		       0		       0
Slabs scanned 			 2214118		 2168524
Direct inode steals 		   12181		    9788
Kswapd inode steals 		  144830		  132109
Kswapd skipped wait 		       0		       0
THP fault alloc 		       0		       0
THP collapse alloc 		       0		       0
THP splits 			       0		       0
THP fault fallback 		       0		       0
THP collapse fail 		       0		       0
Compaction stalls 		     738		     714
Compaction success 		     194		     207
Compaction failures 		     543		     507
Page migrate success 		 1806083		 1464014
Page migrate failure 		       0		       0
Compaction pages isolated 	 3873329	 	 3162974
Compaction migrate scanned 	74594862	 	59874420
Compaction free scanned 	125888854	 	110868637
Compaction cost 		    2469		    1998

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
