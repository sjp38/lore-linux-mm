Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 285F36B0261
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 08:06:55 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id j16so12808610pgn.14
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 05:06:55 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q14si10842801pgc.775.2017.11.21.05.06.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 21 Nov 2017 05:06:53 -0800 (PST)
Date: Tue, 21 Nov 2017 14:06:52 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/1] mm/cma: fix alloc_contig_range ret code/potential
 leak
Message-ID: <20171121130652.pdgsswo63o4tfcee@dhcp22.suse.cz>
References: <20171120193930.23428-1-mike.kravetz@oracle.com>
 <20171120193930.23428-2-mike.kravetz@oracle.com>
 <b63d2f48-ee19-20ca-e870-76fb4cd9e09f@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b63d2f48-ee19-20ca-e870-76fb4cd9e09f@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On Tue 21-11-17 08:53:11, Vlastimil Babka wrote:
> On 11/20/2017 08:39 PM, Mike Kravetz wrote:
> > If the call __alloc_contig_migrate_range() in alloc_contig_range
> > returns -EBUSY, processing continues so that test_pages_isolated()
> > is called where there is a tracepoint to identify the busy pages.
> > However, it is possible for busy pages to become available between
> > the calls to these two routines.  In this case, the range of pages
> > may be allocated.   Unfortunately, the original return code (ret
> > == -EBUSY) is still set and returned to the caller.  Therefore,
> > the caller believes the pages were not allocated and they are leaked.
> > 
> > Update the return code with the value from test_pages_isolated().
> 
> Good catch and seems ok for a stable fix. But it's another indication
> that this area needs some larger rewrite.

Absolutely. The whole thing is subtle as hell. And shaping the code just
around the tracepoint here smells like the whole design could be thought
through much more.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
