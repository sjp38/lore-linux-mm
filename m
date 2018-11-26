Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 087F76B41D5
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 07:37:42 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id s50so9044672edd.11
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 04:37:41 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i18-v6si259666ejy.35.2018.11.26.04.37.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 04:37:12 -0800 (PST)
Subject: Re: [PATCH 1/5] mm, page_alloc: Spread allocations across zones
 before introducing fragmentation
References: <20181123114528.28802-1-mgorman@techsingularity.net>
 <20181123114528.28802-2-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <7a3b2706-8d8c-9233-d6fc-26ace52641e7@suse.cz>
Date: Mon, 26 Nov 2018 13:36:57 +0100
MIME-Version: 1.0
In-Reply-To: <20181123114528.28802-2-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On 11/23/18 12:45 PM, Mel Gorman wrote:
...


> Fault latencies are slightly reduced while allocation success rates remain
> at zero as this configuration does not make any special effort to allocate
> THP and fio is heavily active at the time and either filling memory or
> keeping pages resident. However, a 49% reduction of serious fragmentation
> events reduces the changes of external fragmentation being a problem in
> the future.
> 
> Vlastimil asked during review for a breakdown of the allocation types
> that are falling back.
> 
> vanilla
>    3816 MIGRATE_UNMOVABLE
>  800845 MIGRATE_MOVABLE
>      33 MIGRATE_UNRECLAIMABLE
> 
> patch
>     735 MIGRATE_UNMOVABLE
>  408135 MIGRATE_MOVABLE
>      42 MIGRATE_UNRECLAIMABLE

Nit: it's MIGRATE_RECLAIMABLE :)

> The majority of the fallbacks are due to movable allocations and this is
> consistent for the workload throughout the series so will not be presented
> again as the primary source of fallbacks are movable allocations.

Note that I was more interested in the *reduction* of different kinds of
fallbacks, not their ratios - that the majority is caused by movable
allocations is fully expected.
And the results above actually show that while the reduction for MOVABLE
is ~50%, the reduction for UNMOVABLE is actually 80%! IMHO that's great
(better than I would expect, in fact), and good to know.

...

> Overall, the patch reduces the number of external fragmentation causing
> events so the success of THP over long periods of time would be improved
> for this adverse workload.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>
