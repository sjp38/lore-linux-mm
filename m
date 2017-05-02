Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7D4826B02C4
	for <linux-mm@kvack.org>; Tue,  2 May 2017 16:41:25 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 123so46636118pge.14
        for <linux-mm@kvack.org>; Tue, 02 May 2017 13:41:25 -0700 (PDT)
Received: from mail-pf0-x232.google.com (mail-pf0-x232.google.com. [2607:f8b0:400e:c00::232])
        by mx.google.com with ESMTPS id x130si447124pfd.326.2017.05.02.13.41.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 May 2017 13:41:24 -0700 (PDT)
Received: by mail-pf0-x232.google.com with SMTP id e64so2509822pfd.1
        for <linux-mm@kvack.org>; Tue, 02 May 2017 13:41:24 -0700 (PDT)
Date: Tue, 2 May 2017 13:41:23 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2] mm, vmscan: avoid thrashing anon lru when free + file
 is low
In-Reply-To: <20170502080246.GD14593@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1705021331450.116499@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1704171657550.139497@chino.kir.corp.google.com> <20170418013659.GD21354@bbox> <alpine.DEB.2.10.1704181402510.112481@chino.kir.corp.google.com> <20170419001405.GA13364@bbox> <alpine.DEB.2.10.1704191623540.48310@chino.kir.corp.google.com>
 <20170420060904.GA3720@bbox> <alpine.DEB.2.10.1705011432220.137835@chino.kir.corp.google.com> <20170502080246.GD14593@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 2 May 2017, Michal Hocko wrote:

> I have already asked and my questions were ignored. So let me ask again
> and hopefuly not get ignored this time. So Why do we need a different
> criterion on anon pages than file pages?

The preference in get_scan_count() as already implemented is to reclaim 
from file pages if there is enough memory on the inactive list to reclaim.  
That is unchanged with this patch.

> I do agree that blindly
> scanning anon pages when file pages are low is very suboptimal but this
> adds yet another heuristic without _any_ numbers. Why cannot we simply
> treat anon and file pages equally? Something like the following
> 
> 	if (pgdatfile + pgdatanon + pgdatfree > 2*total_high_wmark) {
> 		scan_balance = SCAN_FILE;
> 		if (pgdatfile < pgdatanon)
> 			scan_balance = SCAN_ANON;
> 		goto out;
> 	}
> 

This would be substantially worse than the current code because it 
thrashes the anon lru when anon out numbers file pages rather than at the 
point we fall under the high watermarks for all eligible zones.  If you 
tested your suggestion, you could see gigabytes of memory left untouched 
on the file lru.  Anonymous memory is more probable to be part of the 
working set.

> Also it would help to describe the workload which can trigger this
> behavior so that we can compare numbers before and after this patch.

Any workload that fills system RAM with anonymous memory that cannot be 
reclaimed will thrash the anon lru without this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
