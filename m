Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 297D36B0253
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 07:17:47 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id j3so2330978pfh.16
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 04:17:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 65si1182346pgj.472.2017.11.29.04.17.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 29 Nov 2017 04:17:46 -0800 (PST)
Date: Wed, 29 Nov 2017 13:17:40 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: NUMA stats code cleanup and enhancement
Message-ID: <20171129121740.f6drkbktc43l5ib6@dhcp22.suse.cz>
References: <1511848824-18709-1-git-send-email-kemi.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1511848824-18709-1-git-send-email-kemi.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kemi Wang <kemi.wang@intel.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Rientjes <rientjes@google.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Aubrey Li <aubrey.li@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Tue 28-11-17 14:00:23, Kemi Wang wrote:
> The existed implementation of NUMA counters is per logical CPU along with
> zone->vm_numa_stat[] separated by zone, plus a global numa counter array
> vm_numa_stat[]. However, unlike the other vmstat counters, numa stats don't
> effect system's decision and are only read from /proc and /sys, it is a
> slow path operation and likely tolerate higher overhead. Additionally,
> usually nodes only have a single zone, except for node 0. And there isn't
> really any use where you need these hits counts separated by zone.
> 
> Therefore, we can migrate the implementation of numa stats from per-zone to
> per-node, and get rid of these global numa counters. It's good enough to
> keep everything in a per cpu ptr of type u64, and sum them up when need, as
> suggested by Andi Kleen. That's helpful for code cleanup and enhancement
> (e.g. save more than 130+ lines code).

I agree. Having these stats per zone is a bit of overcomplication. The
only consumer is /proc/zoneinfo and I would argue this doesn't justify
the additional complexity. Who does really need to know per zone broken
out numbers?

Anyway, I haven't checked your implementation too deeply but why don't
you simply define static percpu array for each numa node?
[...]
> +extern u64 __percpu *vm_numa_stat;
[...]
> +#ifdef CONFIG_NUMA
> +	size = sizeof(u64) * num_possible_nodes() * NR_VM_NUMA_STAT_ITEMS;
> +	align = __alignof__(u64[num_possible_nodes() * NR_VM_NUMA_STAT_ITEMS]);
> +	vm_numa_stat = (u64 __percpu *)__alloc_percpu(size, align);
> +#endif
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
