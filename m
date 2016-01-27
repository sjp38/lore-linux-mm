Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id B884B6B0253
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 09:39:55 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id n128so5740788pfn.3
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 06:39:55 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id z87si8612528pfa.67.2016.01.27.06.39.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jan 2016 06:39:55 -0800 (PST)
Date: Wed, 27 Jan 2016 17:39:38 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 4/5] mm: workingset: eviction buckets for bigmem/lowbit
 machines
Message-ID: <20160127143938.GD9623@esperanza>
References: <1453842006-29265-1-git-send-email-hannes@cmpxchg.org>
 <1453842006-29265-5-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1453842006-29265-5-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Jan 26, 2016 at 04:00:05PM -0500, Johannes Weiner wrote:
> For per-cgroup thrash detection, we need to store the memcg ID inside
> the radix tree cookie as well. However, on 32 bit that doesn't leave
> enough bits for the eviction timestamp to cover the necessary range of
> recently evicted pages. The radix tree entry would look like this:
> 
> [ RADIX_TREE_EXCEPTIONAL(2) | ZONEID(2) | MEMCGID(16) | EVICTION(12) ]
> 
> 12 bits means 4096 pages, means 16M worth of recently evicted pages.
> But refaults are actionable up to distances covering half of memory.
> To not miss refaults, we have to stretch out the range at the cost of
> how precisely we can tell when a page was evicted. This way we can
> shave off lower bits from the eviction timestamp until the necessary
> range is covered. E.g. grouping evictions into 1M buckets (256 pages)
> will stretch the longest representable refault distance to 4G.
> 
> This patch implements eviction buckets that are automatically sized
> according to the available bits and the necessary refault range, in
> preparation for per-cgroup thrash detection.
> 
> The maximum actionable distance is currently half of memory, but to
> support memory hotplug of up to 200% of boot-time memory, we size the
> buckets to cover double the distance. Beyond that, thrashing won't be
> detectable anymore.
> 
> During boot, the kernel will print out the exact parameters, like so:
> 
> [    0.113929] workingset: timestamp_bits=12 max_order=18 bucket_order=6
> 
> In this example, there are 12 radix entry bits available for the
> eviction timestamp, to cover a maximum distance of 2^18 pages (this is
> a 1G machine). Consequently, evictions must be grouped into buckets of
> 2^6 pages, or 256K.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>

One nit below.

> +/*
> + * Eviction timestamps need to be able to cover the full range of
> + * actionable refaults. However, bits are tight in the radix tree
> + * entry, and after storing the identifier for the lruvec there might
> + * not be enough left to represent every single actionable refault. In
> + * that case, we have to sacrifice granularity for distance, and group
> + * evictions into coarser buckets by shaving off lower timestamp bits.
> + */
> +static unsigned int bucket_order;

__read_mostly?

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
