Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 852626B0038
	for <linux-mm@kvack.org>; Wed,  3 May 2017 03:06:59 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id u65so4645154wmu.12
        for <linux-mm@kvack.org>; Wed, 03 May 2017 00:06:59 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y1si22658888wra.133.2017.05.03.00.06.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 03 May 2017 00:06:58 -0700 (PDT)
Date: Wed, 3 May 2017 09:06:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch v2] mm, vmscan: avoid thrashing anon lru when free + file
 is low
Message-ID: <20170503070656.GA8836@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1704171657550.139497@chino.kir.corp.google.com>
 <20170418013659.GD21354@bbox>
 <alpine.DEB.2.10.1704181402510.112481@chino.kir.corp.google.com>
 <20170419001405.GA13364@bbox>
 <alpine.DEB.2.10.1704191623540.48310@chino.kir.corp.google.com>
 <20170420060904.GA3720@bbox>
 <alpine.DEB.2.10.1705011432220.137835@chino.kir.corp.google.com>
 <20170502080246.GD14593@dhcp22.suse.cz>
 <alpine.DEB.2.10.1705021331450.116499@chino.kir.corp.google.com>
 <20170503061528.GB1236@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170503061528.GB1236@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 03-05-17 08:15:28, Michal Hocko wrote:
> On Tue 02-05-17 13:41:23, David Rientjes wrote:
> > On Tue, 2 May 2017, Michal Hocko wrote:
[...]
> > > I do agree that blindly
> > > scanning anon pages when file pages are low is very suboptimal but this
> > > adds yet another heuristic without _any_ numbers. Why cannot we simply
> > > treat anon and file pages equally? Something like the following
> > > 
> > > 	if (pgdatfile + pgdatanon + pgdatfree > 2*total_high_wmark) {
> > > 		scan_balance = SCAN_FILE;
> > > 		if (pgdatfile < pgdatanon)
> > > 			scan_balance = SCAN_ANON;
> > > 		goto out;
> > > 	}
> > > 
> > 
> > This would be substantially worse than the current code because it 
> > thrashes the anon lru when anon out numbers file pages rather than at the 
> > point we fall under the high watermarks for all eligible zones.  If you 
> > tested your suggestion, you could see gigabytes of memory left untouched 
> > on the file lru.  Anonymous memory is more probable to be part of the 
> > working set.
> 
> This was supposed to be more an example of a direction I was thinking,
> definitely not a final patch. I will think more to come up with a
> more complete proposal.

This is still untested but should be much closer to what I've had in
mind.
---
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 24efcc20af91..bcdad30f942d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2174,8 +2174,14 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 		}
 
 		if (unlikely(pgdatfile + pgdatfree <= total_high_wmark)) {
-			scan_balance = SCAN_ANON;
-			goto out;
+			unsigned long pgdatanon;
+
+			pgdatanon = node_page_state(pgdat, NR_ACTIVE_ANON) +
+				node_page_state(pgdat, NR_INACTIVE_ANON);
+			if (pgdatanon + pgdatfree > total_high_wmark) {
+				scan_balance = SCAN_ANON;
+				goto out;
+			}
 		}
 	}
 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
