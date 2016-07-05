Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 81E556B0253
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 04:14:08 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id a66so81992053wme.1
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 01:14:08 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id w65si2741295wme.14.2016.07.05.01.14.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jul 2016 01:14:07 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id CD2781C1E44
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 09:14:06 +0100 (IST)
Date: Tue, 5 Jul 2016 09:14:05 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 01/31] mm, vmstat: add infrastructure for per-node vmstats
Message-ID: <20160705081405.GE11498@techsingularity.net>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <1467403299-25786-2-git-send-email-mgorman@techsingularity.net>
 <20160704235018.GA26749@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160704235018.GA26749@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 05, 2016 at 08:50:18AM +0900, Minchan Kim wrote:
> > @@ -172,13 +174,17 @@ void refresh_zone_stat_thresholds(void)
> >  	int threshold;
> >  
> >  	for_each_populated_zone(zone) {
> > +		struct pglist_data *pgdat = zone->zone_pgdat;
> >  		unsigned long max_drift, tolerate_drift;
> >  
> >  		threshold = calculate_normal_threshold(zone);
> >  
> > -		for_each_online_cpu(cpu)
> > +		for_each_online_cpu(cpu) {
> >  			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
> >  							= threshold;
> > +			per_cpu_ptr(pgdat->per_cpu_nodestats, cpu)->stat_threshold
> > +							= threshold;
> > +		}
> 
> I didn't see other patches yet so it might fix it then.
> 
> per_cpu_nodestats is per node not zone but it use per-zone threshold
> and even overwritten by next zones. I don't think it's not intended.

It was intended that the threshold from one zone would be used but now
that you point it out, it would use the threshold for the smallest zone
in the node which is sub-optimal. I applied the patch below on top to
use the threshold from the largest zone. I considered using the sum of
all thresholds but feared it might allow too much per-cpu drift. It can
be switched to the sum if we find a case where vmstat updates are too
high.

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 90b0737ee4be..3345d396a99b 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -169,10 +169,18 @@ int calculate_normal_threshold(struct zone *zone)
  */
 void refresh_zone_stat_thresholds(void)
 {
+	struct pglist_data *pgdat;
 	struct zone *zone;
 	int cpu;
 	int threshold;
 
+	/* Zero current pgdat thresholds */
+	for_each_online_pgdat(pgdat) {
+		for_each_online_cpu(cpu) {
+			per_cpu_ptr(pgdat->per_cpu_nodestats, cpu)->stat_threshold = 0;
+		}
+	}
+
 	for_each_populated_zone(zone) {
 		struct pglist_data *pgdat = zone->zone_pgdat;
 		unsigned long max_drift, tolerate_drift;
@@ -180,10 +188,15 @@ void refresh_zone_stat_thresholds(void)
 		threshold = calculate_normal_threshold(zone);
 
 		for_each_online_cpu(cpu) {
+			int pgdat_threshold;
+
 			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
 							= threshold;
+
+			/* Base nodestat threshold on the largest populated zone. */
+			pgdat_threshold = per_cpu_ptr(pgdat->per_cpu_nodestats, cpu)->stat_threshold;
 			per_cpu_ptr(pgdat->per_cpu_nodestats, cpu)->stat_threshold
-							= threshold;
+				= max(threshold, pgdat_threshold);
 		}
 
 		/*

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
