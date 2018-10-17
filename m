Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 91E456B000E
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 07:20:45 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id v15-v6so16514261edm.13
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 04:20:45 -0700 (PDT)
Received: from outbound-smtp26.blacknight.com (outbound-smtp26.blacknight.com. [81.17.249.194])
        by mx.google.com with ESMTPS id e15-v6si443492eds.334.2018.10.17.04.20.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 Oct 2018 04:20:44 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp26.blacknight.com (Postfix) with ESMTPS id B7D11B8AE3
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 12:20:41 +0100 (IST)
Date: Wed, 17 Oct 2018 12:20:42 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC v4 PATCH 3/5] mm/rmqueue_bulk: alloc without touching
 individual page structure
Message-ID: <20181017112042.GK5819@techsingularity.net>
References: <20181017063330.15384-1-aaron.lu@intel.com>
 <20181017063330.15384-4-aaron.lu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20181017063330.15384-4-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>, Tariq Toukan <tariqt@mellanox.com>, Jesper Dangaard Brouer <brouer@redhat.com>

On Wed, Oct 17, 2018 at 02:33:28PM +0800, Aaron Lu wrote:
> Profile on Intel Skylake server shows the most time consuming part
> under zone->lock on allocation path is accessing those to-be-returned
> page's "struct page" on the free_list inside zone->lock. One explanation
> is, different CPUs are releasing pages to the head of free_list and
> those page's 'struct page' may very well be cache cold for the allocating
> CPU when it grabs these pages from free_list' head. The purpose here
> is to avoid touching these pages one by one inside zone->lock.
> 

I didn't read this one in depth because it's somewhat ortogonal to the
lazy buddy merging which I think would benefit from being finalised and
ensuring that there are no reductions in high-order allocation success
rates.  Pages being allocated on one CPU and freed on another is not that
unusual -- ping-pong workloads or things like netperf used to exhibit
this sort of pattern.

However, this part stuck out

> +static inline void zone_wait_cluster_alloc(struct zone *zone)
> +{
> +	while (atomic_read(&zone->cluster.in_progress))
> +		cpu_relax();
> +}
> +

RT has had problems with cpu_relax in the past but more importantly, as
this delay for parallel compactions and allocations of contig ranges,
we could be stuck here for very long periods of time with interrupts
disabled. It gets even worse if it's from an interrupt context such as
jumbo frame allocation or a high-order slab allocation that is atomic.
These potentially large periods of time with interrupts disabled is very
hazardous. It may be necessary to consider instead minimising the number
of struct page update when merging to PCP and then either increasing the
size of the PCP or allowing it to exceed pcp->high for short periods of
time to batch the struct page updates.

I didn't read the rest of the series as it builds upon this patch.

-- 
Mel Gorman
SUSE Labs
