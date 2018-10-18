Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2B13E6B0006
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 07:20:59 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i16-v6so18235189ede.11
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 04:20:59 -0700 (PDT)
Received: from outbound-smtp16.blacknight.com (outbound-smtp16.blacknight.com. [46.22.139.233])
        by mx.google.com with ESMTPS id t18-v6si12652475ejg.200.2018.10.18.04.20.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Oct 2018 04:20:57 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp16.blacknight.com (Postfix) with ESMTPS id 83B201C2017
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 12:20:57 +0100 (IST)
Date: Thu, 18 Oct 2018 12:20:55 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC v4 PATCH 3/5] mm/rmqueue_bulk: alloc without touching
 individual page structure
Message-ID: <20181018112055.GN5819@techsingularity.net>
References: <20181017063330.15384-1-aaron.lu@intel.com>
 <20181017063330.15384-4-aaron.lu@intel.com>
 <20181017112042.GK5819@techsingularity.net>
 <20181017142327.GB9167@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20181017142327.GB9167@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>, Tariq Toukan <tariqt@mellanox.com>, Jesper Dangaard Brouer <brouer@redhat.com>

On Wed, Oct 17, 2018 at 10:23:27PM +0800, Aaron Lu wrote:
> > RT has had problems with cpu_relax in the past but more importantly, as
> > this delay for parallel compactions and allocations of contig ranges,
> > we could be stuck here for very long periods of time with interrupts
> 
> The longest possible time is one CPU accessing pcp->batch number cold
> cachelines. Reason:
> When zone_wait_cluster_alloc() is called, we already held zone lock so
> no more allocations are possible. Waiting in_progress to become zero
> means waiting any CPU that increased in_progress to finish processing
> their allocated pages. Since they will at most allocate pcp->batch pages
> and worse case are all these page structres are cache cold, so the
> longest wait time is one CPU accessing pcp->batch number cold cache lines.
> 
> I have no idea if this time is too long though.
> 

But compact_zone calls zone_wait_and_disable_cluster_alloc so how is the
disabled time there bound by pcp->batch?

> > disabled. It gets even worse if it's from an interrupt context such as
> > jumbo frame allocation or a high-order slab allocation that is atomic.
> 
> My understanding is atomic allocation won't trigger compaction, no?
> 

No, they can't. I didn't check properly but be wary of any possibility
whereby interrupts can get delayed in zone_wait_cluster_alloc. I didn't
go back and check if it can -- partially because I'm more focused on the
lazy buddy aspect at the moment.

> > It may be necessary to consider instead minimising the number
> > of struct page update when merging to PCP and then either increasing the
> > size of the PCP or allowing it to exceed pcp->high for short periods of
> > time to batch the struct page updates.
> 
> I don't quite follow this part. It doesn't seem possible we can exceed
> pcp->high in allocation path, or are you talking about free path?
> 

I'm talking about the free path.

> And thanks a lot for the review!

My pleasure, hope it helps.

-- 
Mel Gorman
SUSE Labs
