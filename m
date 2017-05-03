Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id E54D16B02EE
	for <linux-mm@kvack.org>; Wed,  3 May 2017 02:15:35 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id g67so17004638wrd.0
        for <linux-mm@kvack.org>; Tue, 02 May 2017 23:15:35 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 89si21566831wrk.321.2017.05.02.23.15.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 02 May 2017 23:15:34 -0700 (PDT)
Date: Wed, 3 May 2017 08:15:29 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch v2] mm, vmscan: avoid thrashing anon lru when free + file
 is low
Message-ID: <20170503061528.GB1236@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1704171657550.139497@chino.kir.corp.google.com>
 <20170418013659.GD21354@bbox>
 <alpine.DEB.2.10.1704181402510.112481@chino.kir.corp.google.com>
 <20170419001405.GA13364@bbox>
 <alpine.DEB.2.10.1704191623540.48310@chino.kir.corp.google.com>
 <20170420060904.GA3720@bbox>
 <alpine.DEB.2.10.1705011432220.137835@chino.kir.corp.google.com>
 <20170502080246.GD14593@dhcp22.suse.cz>
 <alpine.DEB.2.10.1705021331450.116499@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1705021331450.116499@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 02-05-17 13:41:23, David Rientjes wrote:
> On Tue, 2 May 2017, Michal Hocko wrote:
> 
> > I have already asked and my questions were ignored. So let me ask again
> > and hopefuly not get ignored this time. So Why do we need a different
> > criterion on anon pages than file pages?
> 
> The preference in get_scan_count() as already implemented is to reclaim 
> from file pages if there is enough memory on the inactive list to reclaim.  
> That is unchanged with this patch.

My fault, I was too vague. My question was basically why should we use
a different criterion to SCAN_ANON than SCAN_FILE.

> > I do agree that blindly
> > scanning anon pages when file pages are low is very suboptimal but this
> > adds yet another heuristic without _any_ numbers. Why cannot we simply
> > treat anon and file pages equally? Something like the following
> > 
> > 	if (pgdatfile + pgdatanon + pgdatfree > 2*total_high_wmark) {
> > 		scan_balance = SCAN_FILE;
> > 		if (pgdatfile < pgdatanon)
> > 			scan_balance = SCAN_ANON;
> > 		goto out;
> > 	}
> > 
> 
> This would be substantially worse than the current code because it 
> thrashes the anon lru when anon out numbers file pages rather than at the 
> point we fall under the high watermarks for all eligible zones.  If you 
> tested your suggestion, you could see gigabytes of memory left untouched 
> on the file lru.  Anonymous memory is more probable to be part of the 
> working set.

This was supposed to be more an example of a direction I was thinking,
definitely not a final patch. I will think more to come up with a
more complete proposal.

> > Also it would help to describe the workload which can trigger this
> > behavior so that we can compare numbers before and after this patch.
> 
> Any workload that fills system RAM with anonymous memory that cannot be 
> reclaimed will thrash the anon lru without this patch.

I have already asked, but I do not understand why this anon memory
couldn't be reclaimed. Who is pinning it? Why cannot it be swapped out?
If it is mlocked it should be moved to unevictable LRU. What am I
missing?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
