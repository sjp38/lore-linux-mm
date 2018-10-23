Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3A3DB6B0006
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 22:19:35 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id e6-v6so30845954pge.5
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 19:19:35 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id y40-v6si16958273pla.389.2018.10.22.19.19.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Oct 2018 19:19:34 -0700 (PDT)
Date: Tue, 23 Oct 2018 10:19:30 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [RFC v4 PATCH 3/5] mm/rmqueue_bulk: alloc without touching
 individual page structure
Message-ID: <20181023021930.GA20069@intel.com>
References: <20181017063330.15384-1-aaron.lu@intel.com>
 <20181017063330.15384-4-aaron.lu@intel.com>
 <b343cf1a-ea15-b70e-ff5a-e08d3dc5354d@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b343cf1a-ea15-b70e-ff5a-e08d3dc5354d@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>, Tariq Toukan <tariqt@mellanox.com>, Jesper Dangaard Brouer <brouer@redhat.com>

On Mon, Oct 22, 2018 at 11:37:53AM +0200, Vlastimil Babka wrote:
> On 10/17/18 8:33 AM, Aaron Lu wrote:
> > Profile on Intel Skylake server shows the most time consuming part
> > under zone->lock on allocation path is accessing those to-be-returned
> > page's "struct page" on the free_list inside zone->lock. One explanation
> > is, different CPUs are releasing pages to the head of free_list and
> > those page's 'struct page' may very well be cache cold for the allocating
> > CPU when it grabs these pages from free_list' head. The purpose here
> > is to avoid touching these pages one by one inside zone->lock.
> 
> What about making the pages cache-hot first, without zone->lock, by
> traversing via page->lru. It would need some safety checks obviously
> (maybe based on page_to_pfn + pfn_valid, or something) to make sure we
> only read from real struct pages in case there's some update racing. The
> worst case would be not populating enough due to race, and thus not
> gaining the performance when doing the actual rmqueueing under lock.

Yes, there are the 2 potential problems you have pointed out:
1 we may be prefetching something that isn't a page due to page->lru can
  be reused as different things under different scenerios;
2 we may not be able to prefetch much due to other CPU is doing
  allocation inside the lock, it's possible we end up with prefetching
  pages that are on another CPU's pcp list.

Considering the above 2 problems, I feel prefetching outside lock a
little risky and troublesome.

Allocation path is the hard part of improving page allocator
performance - in free path, we can prefetch them safely outside the lock
and we can even pre-merge them outside the lock to reduce the pressure of
the zone lock; but in allocation path, there is pretty nothing we can do
before acquiring the lock, except taking the risk to prefetch them
without taking the lock as you mentioned here.

We can come back to this if 'address space range' lock doesn't work out.
