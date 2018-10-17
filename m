Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0ED5C6B026A
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 10:23:33 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id v138-v6so19928032pgb.7
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 07:23:33 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id b28-v6si18121588pff.192.2018.10.17.07.23.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 07:23:31 -0700 (PDT)
Date: Wed, 17 Oct 2018 22:23:27 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [RFC v4 PATCH 3/5] mm/rmqueue_bulk: alloc without touching
 individual page structure
Message-ID: <20181017142327.GB9167@intel.com>
References: <20181017063330.15384-1-aaron.lu@intel.com>
 <20181017063330.15384-4-aaron.lu@intel.com>
 <20181017112042.GK5819@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181017112042.GK5819@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>, Tariq Toukan <tariqt@mellanox.com>, Jesper Dangaard Brouer <brouer@redhat.com>

On Wed, Oct 17, 2018 at 12:20:42PM +0100, Mel Gorman wrote:
> On Wed, Oct 17, 2018 at 02:33:28PM +0800, Aaron Lu wrote:
> > Profile on Intel Skylake server shows the most time consuming part
> > under zone->lock on allocation path is accessing those to-be-returned
> > page's "struct page" on the free_list inside zone->lock. One explanation
> > is, different CPUs are releasing pages to the head of free_list and
> > those page's 'struct page' may very well be cache cold for the allocating
> > CPU when it grabs these pages from free_list' head. The purpose here
> > is to avoid touching these pages one by one inside zone->lock.
> > 
> 
> I didn't read this one in depth because it's somewhat ortogonal to the
> lazy buddy merging which I think would benefit from being finalised and
> ensuring that there are no reductions in high-order allocation success
> rates.  Pages being allocated on one CPU and freed on another is not that
> unusual -- ping-pong workloads or things like netperf used to exhibit
> this sort of pattern.
> 
> However, this part stuck out
> 
> > +static inline void zone_wait_cluster_alloc(struct zone *zone)
> > +{
> > +	while (atomic_read(&zone->cluster.in_progress))
> > +		cpu_relax();
> > +}
> > +
> 
> RT has had problems with cpu_relax in the past but more importantly, as
> this delay for parallel compactions and allocations of contig ranges,
> we could be stuck here for very long periods of time with interrupts

The longest possible time is one CPU accessing pcp->batch number cold
cachelines. Reason:
When zone_wait_cluster_alloc() is called, we already held zone lock so
no more allocations are possible. Waiting in_progress to become zero
means waiting any CPU that increased in_progress to finish processing
their allocated pages. Since they will at most allocate pcp->batch pages
and worse case are all these page structres are cache cold, so the
longest wait time is one CPU accessing pcp->batch number cold cache lines.

I have no idea if this time is too long though.

> disabled. It gets even worse if it's from an interrupt context such as
> jumbo frame allocation or a high-order slab allocation that is atomic.

My understanding is atomic allocation won't trigger compaction, no?

> These potentially large periods of time with interrupts disabled is very
> hazardous.

I see and agree, thanks for pointing this out.
Hopefully, the above mentioned worst case time won't be regarded as
unbound or too long.

> It may be necessary to consider instead minimising the number
> of struct page update when merging to PCP and then either increasing the
> size of the PCP or allowing it to exceed pcp->high for short periods of
> time to batch the struct page updates.

I don't quite follow this part. It doesn't seem possible we can exceed
pcp->high in allocation path, or are you talking about free path?

And thanks a lot for the review!
