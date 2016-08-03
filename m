Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4F7106B0005
	for <linux-mm@kvack.org>; Wed,  3 Aug 2016 15:13:22 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id p85so119692763lfg.3
        for <linux-mm@kvack.org>; Wed, 03 Aug 2016 12:13:22 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id q63si28183398wmd.131.2016.08.03.12.13.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Aug 2016 12:13:20 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u73J42bd005777
	for <linux-mm@kvack.org>; Wed, 3 Aug 2016 15:13:19 -0400
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0b-001b2d01.pphosted.com with ESMTP id 24kkah8jhh-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 03 Aug 2016 15:13:19 -0400
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Wed, 3 Aug 2016 13:13:18 -0600
Date: Wed, 3 Aug 2016 14:13:10 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [PATCH 01/34] mm, vmstat: add infrastructure for per-node vmstats
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-2-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <1467970510-21195-2-git-send-email-mgorman@techsingularity.net>
Message-Id: <20160803191310.GB28305@arbab-laptop.austin.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 08, 2016 at 10:34:37AM +0100, Mel Gorman wrote:
> void refresh_zone_stat_thresholds(void)
> {
[...]
>+	/* Zero current pgdat thresholds */
>+	for_each_online_pgdat(pgdat) {
>+		for_each_online_cpu(cpu) {
>+			per_cpu_ptr(pgdat->per_cpu_nodestats, cpu)->stat_threshold = 0;
>+		}
>+	}

I am oopsing here, for a node whose pgdat->per_cpu_nodestats is NULL.

The node in question is memoryless, so in setup_per_cpu_pageset(), the 
loop over its populated zones doesn't run, and the per_cpu_nodestat 
struct isn't allocated.

This patch fixes things for me:

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ea759b9..5221e17 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5271,9 +5271,17 @@ static void __meminit setup_zone_pageset(struct zone *zone)
  void __init setup_per_cpu_pageset(void)
  {
  	struct zone *zone;
+	struct pglist_data *pgdat;
  
  	for_each_populated_zone(zone)
  		setup_zone_pageset(zone);
+
+	for_each_online_pgdat(pgdat) {
+		if (!pgdat->per_cpu_nodestats) {
+			pgdat->per_cpu_nodestats =
+				alloc_percpu(struct per_cpu_nodestat);
+		}
+	}
  }
  
  static noinline __init_refok


-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
