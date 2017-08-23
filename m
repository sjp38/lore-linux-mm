Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 36E8D28074D
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 21:15:49 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id e2so3524504pgf.7
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 18:15:49 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id w14si187532pfl.677.2017.08.22.18.15.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Aug 2017 18:15:47 -0700 (PDT)
From: kemi <kemi.wang@intel.com>
Subject: Re: [PATCH 0/2] Separate NUMA statistics from zone statistics
References: <1502786736-21585-1-git-send-email-kemi.wang@intel.com>
 <alpine.DEB.2.20.1708221620060.18344@nuc-kabylake>
Message-ID: <403c809c-cd37-db66-5f33-3ea6b6bee52d@intel.com>
Date: Wed, 23 Aug 2017 09:14:17 +0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1708221620060.18344@nuc-kabylake>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>



On 2017a1'08ae??23ae?JPY 05:22, Christopher Lameter wrote:
> Can we simple get rid of the stats or make then configurable (off by
> defaut)? I agree they are rarely used and have been rarely used in the past.
> 

I agree that we can make numa stats as well as other stats items that are rarely
used configurable. Perhaps we can introduce a general mechanism to hide such unimportant
stats(suggested by *Dave Hansen* initially), it works like this:

when performance is not important and when you want all tooling to work, you set:

	sysctl vm.strict_stats=1

but if you can tolerate some possible tool breakage and some decreased
counter precision, you can do:

	sysctl vm.strict_stats=0

What's your idea for that? I can help to implement it later.

But it may not a good idea to simply get rid of such kinds of stats.

> Maybe some instrumentation for perf etc will allow
> similar statistics these days? Thus its possible to drop them?
> 
> The space in the pcp pageset is precious and we should strive to use no
> more than a cacheline for the diffs.
> 
> 

Andi has helped to explain it very clearly. Thanks very much.

For 64-bit OS:
                                     base       with this patch(even include numa_threshold)
sizeof(struct per_cpu_pageset)	      88 		96

Copy the discussion before from another email thread in case you missed it:

> Hi Mel
>   I am refreshing this patch. Would you pls be more explicit of what "that
> structure" indicates. 
>   If you mean "struct per_cpu_pageset", for 64 bits machine, this structure
> still occupies two caches line after extending s8 to s16/u16, that should
> not be a problem.

You're right, I was in error. I miscalculated badly initially. It still
fits in as expected.

> For 32 bits machine, we probably does not need to extend
> the size of vm_numa_stat_diff[] since 32 bits OS nearly not be used in large
> numa system, and s8/u8 is large enough for it, in this case, we can keep the 
> same size of "struct per_cpu_pageset".
>

I don't believe it's worth the complexity of making this
bitness-specific. 32-bit takes penalties in other places and besides,
32-bit does not necessarily mean a change in cache line size.

Fortunately, I think you should still be able to gain a bit more with
some special casing the fact it's always incrementing and always do full
spill of the counters instead of half. If so, then using u16 instead of
s16 should also reduce the update frequency. However, if you find it's
too complex and the gain is too marginal then I'll ack without it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
