Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 831616B0038
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 21:28:55 -0400 (EDT)
Received: by iecvj10 with SMTP id vj10so83301758iec.0
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 18:28:55 -0700 (PDT)
Received: from mail-ig0-x22f.google.com (mail-ig0-x22f.google.com. [2607:f8b0:4001:c05::22f])
        by mx.google.com with ESMTPS id s10si3593656igg.4.2015.03.27.18.28.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Mar 2015 18:28:55 -0700 (PDT)
Received: by igcxg11 with SMTP id xg11so34536474igc.0
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 18:28:54 -0700 (PDT)
Date: Fri, 27 Mar 2015 18:28:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: Move zone lock to a different cache line than order-0
 free page lists
In-Reply-To: <20150327095413.GO4701@suse.de>
Message-ID: <alpine.DEB.2.10.1503271828400.5628@chino.kir.corp.google.com>
References: <20150327095413.GO4701@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, LKML <linux-kernel@vger.kernel.org>, LKP ML <lkp@01.org>, linux-mm@kvack.org

On Fri, 27 Mar 2015, Mel Gorman wrote:

> Huang Ying reported the following problem due to commit 3484b2de9499
> ("mm: rearrange zone fields into read-only, page alloc, statistics and
> page reclaim lines") from the Intel performance tests
> 
>     24b7e5819ad5cbef  3484b2de9499df23c4604a513b
>     ----------------  --------------------------
>              %stddev     %change         %stddev
>                  \          |                \
>         152288 \261  0%     -46.2%      81911 \261  0%  aim7.jobs-per-min
>            237 \261  0%     +85.6%        440 \261  0%  aim7.time.elapsed_time
>            237 \261  0%     +85.6%        440 \261  0%  aim7.time.elapsed_time.max
>          25026 \261  0%     +70.7%      42712 \261  0%  aim7.time.system_time
>        2186645 \261  5%     +32.0%    2885949 \261  4%  aim7.time.voluntary_context_switches
>        4576561 \261  1%     +24.9%    5715773 \261  0%  aim7.time.involuntary_context_switches
> 
> The problem is specific to very large machines under stress. It was not
> reproducible with the machines I had used to justify the original patch
> because large numbers of CPUs are required. When pressure is high enough,
> the cache line is bouncing between CPUs trying to acquire the lock and
> the holder of the lock adjusting free lists. The intention was that the
> acquirer of the lock would automatically have the cache line holding the
> free lists but according to Huang, this is not a universal win.
> 
> One possibility is to move the zone lock to its own cache line but it
> increases the size of the zone. This patch moves the lock to the other
> end of the free lists where they do not contend under high pressure. It
> does mean the page allocator paths now require more cache lines but Huang
> reports that it restores performance to previous levels on large machines
> 
>              %stddev     %change         %stddev
>                  \          |                \
>          84568 \261  1%     +94.3%     164280 \261  1%  aim7.jobs-per-min
>        2881944 \261  2%     -35.1%    1870386 \261  8%  aim7.time.voluntary_context_switches
>            681 \261  1%      -3.4%        658 \261  0%  aim7.time.user_time
>        5538139 \261  0%     -12.1%    4867884 \261  0%  aim7.time.involuntary_context_switches
>          44174 \261  1%     -46.0%      23848 \261  1%  aim7.time.system_time
>            426 \261  1%     -48.4%        219 \261  1%  aim7.time.elapsed_time
>            426 \261  1%     -48.4%        219 \261  1%  aim7.time.elapsed_time.max
>            468 \261  1%     -43.1%        266 \261  2%  uptime.boot
> 
> Reported-and-tested-by: Huang Ying <ying.huang@intel.com>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
