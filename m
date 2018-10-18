Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5AE5E6B000D
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 09:22:03 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id t28-v6so15732934pfk.21
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 06:22:03 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id e13-v6si21793687pfb.174.2018.10.18.06.22.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Oct 2018 06:22:02 -0700 (PDT)
Date: Thu, 18 Oct 2018 21:21:28 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [RFC v4 PATCH 3/5] mm/rmqueue_bulk: alloc without touching
 individual page structure
Message-ID: <20181018132128.GA17006@intel.com>
References: <20181017063330.15384-1-aaron.lu@intel.com>
 <20181017063330.15384-4-aaron.lu@intel.com>
 <20181017112042.GK5819@techsingularity.net>
 <20181017142327.GB9167@intel.com>
 <20181018112055.GN5819@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181018112055.GN5819@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>, Tariq Toukan <tariqt@mellanox.com>, Jesper Dangaard Brouer <brouer@redhat.com>

On Thu, Oct 18, 2018 at 12:20:55PM +0100, Mel Gorman wrote:
> On Wed, Oct 17, 2018 at 10:23:27PM +0800, Aaron Lu wrote:
> > > RT has had problems with cpu_relax in the past but more importantly, as
> > > this delay for parallel compactions and allocations of contig ranges,
> > > we could be stuck here for very long periods of time with interrupts
> > 
> > The longest possible time is one CPU accessing pcp->batch number cold
> > cachelines. Reason:
> > When zone_wait_cluster_alloc() is called, we already held zone lock so
> > no more allocations are possible. Waiting in_progress to become zero
> > means waiting any CPU that increased in_progress to finish processing
> > their allocated pages. Since they will at most allocate pcp->batch pages
> > and worse case are all these page structres are cache cold, so the
> > longest wait time is one CPU accessing pcp->batch number cold cache lines.
> > 
> > I have no idea if this time is too long though.
> > 
> 
> But compact_zone calls zone_wait_and_disable_cluster_alloc so how is the
> disabled time there bound by pcp->batch?

My mistake, I misunderstood spin_lock_irqsave() and thought lock would
need be acquired before irq is disabled...

So yeah, your concern of possible excessive long irq disabled time here
is true.
