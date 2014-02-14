Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 9A2976B0031
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 01:54:07 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id p10so11589698pdj.29
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 22:54:07 -0800 (PST)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id xk2si4652379pab.71.2014.02.13.22.54.05
        for <linux-mm@kvack.org>;
        Thu, 13 Feb 2014 22:54:06 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 0/5] compaction related commits
Date: Fri, 14 Feb 2014 15:53:58 +0900
Message-Id: <1392360843-22261-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

changes for v2
o include more experiment data in cover letter
o deal with vlastimil's comments mostly about commit description on 4/5

This patchset is related to the compaction.

patch 1 fixes contrary implementation of the purpose of compaction.
patch 2~4 are for optimization.
patch 5 is just for clean-up.

I tested this patchset with stress-highalloc benchmark on Mel's mmtest
and cannot find any regression in terms of success rate. And I find
much reduced(9%) elapsed time.

Below is the average result of 10 runs on my 4GB quad core system.

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



Joonsoo Kim (5):
  mm/compaction: disallow high-order page for migration target
  mm/compaction: do not call suitable_migration_target() on every page
  mm/compaction: change the timing to check to drop the spinlock
  mm/compaction: check pageblock suitability once per pageblock
  mm/compaction: clean-up code on success of ballon isolation

 mm/compaction.c |   75 ++++++++++++++++++++++++++++---------------------------
 1 file changed, 38 insertions(+), 37 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
