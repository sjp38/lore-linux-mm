Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B67416B0026
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 11:00:36 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id j8so2761843pfh.13
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 08:00:36 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id s8-v6si4492005plk.550.2018.03.21.08.00.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 08:00:35 -0700 (PDT)
Date: Wed, 21 Mar 2018 23:01:40 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [RFC PATCH v2 3/4] mm/rmqueue_bulk: alloc without touching
 individual page structure
Message-ID: <20180321150140.GA1838@intel.com>
References: <20180320085452.24641-1-aaron.lu@intel.com>
 <20180320085452.24641-4-aaron.lu@intel.com>
 <12a89171-27b8-af4f-450e-41e5775683c5@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <12a89171-27b8-af4f-450e-41e5775683c5@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>

Hi Vlastimil,

Thanks for taking the time to reivew the patch, I appreciate that.

On Wed, Mar 21, 2018 at 01:55:01PM +0100, Vlastimil Babka wrote:
> On 03/20/2018 09:54 AM, Aaron Lu wrote:
> > Profile on Intel Skylake server shows the most time consuming part
> > under zone->lock on allocation path is accessing those to-be-returned
> > page's "struct page" on the free_list inside zone->lock. One explanation
> > is, different CPUs are releasing pages to the head of free_list and
> > those page's 'struct page' may very well be cache cold for the allocating
> > CPU when it grabs these pages from free_list' head. The purpose here
> > is to avoid touching these pages one by one inside zone->lock.
> > 
> > One idea is, we just take the requested number of pages off free_list
> > with something like list_cut_position() and then adjust nr_free of
> > free_area accordingly inside zone->lock and other operations like
> > clearing PageBuddy flag for these pages are done outside of zone->lock.
> > 
> > list_cut_position() needs to know where to cut, that's what the new
> > 'struct cluster' meant to provide. All pages on order 0's free_list
> > belongs to a cluster so when a number of pages is needed, the cluster
> > to which head page of free_list belongs is checked and then tail page
> > of the cluster could be found. With tail page, list_cut_position() can
> > be used to drop the cluster off free_list. The 'struct cluster' also has
> > 'nr' to tell how many pages this cluster has so nr_free of free_area can
> > be adjusted inside the lock too.
> > 
> > This caused a race window though: from the moment zone->lock is dropped
> > till these pages' PageBuddy flags get cleared, these pages are not in
> > buddy but still have PageBuddy flag set.
> > 
> > This doesn't cause problems for users that access buddy pages through
> > free_list. But there are other users, like move_freepages() which is
> > used to move a pageblock pages from one migratetype to another in
> > fallback allocation path, will test PageBuddy flag of a page derived
> > from PFN. The end result could be that for pages in the race window,
> > they are moved back to free_list of another migratetype. For this
> > reason, a synchronization function zone_wait_cluster_alloc() is
> > introduced to wait till all pages are in correct state. This function
> > is meant to be called with zone->lock held, so after this function
> > returns, we do not need to worry about new pages becoming racy state.
> > 
> > Another user is compaction, where it will scan a pageblock for
> > migratable candidates. In this process, pages derived from PFN will
> > be checked for PageBuddy flag to decide if it is a merge skipped page.
> > To avoid a racy page getting merged back into buddy, the
> > zone_wait_and_disable_cluster_alloc() function is introduced to:
> > 1 disable clustered allocation by increasing zone->cluster.disable_depth;
> > 2 wait till the race window pass by calling zone_wait_cluster_alloc().
> > This function is also meant to be called with zone->lock held so after
> > it returns, all pages are in correct state and no more cluster alloc
> > will be attempted till zone_enable_cluster_alloc() is called to decrease
> > zone->cluster.disable_depth.
> 
> I'm sorry, but I feel the added complexity here is simply too large to
> justify the change. Especially if the motivation seems to be just the
> microbenchmark. It would be better if this was motivated by a real
> workload where zone lock contention was identified as the main issue,
> and we would see the improvements on the workload. We could also e.g.
> find out that the problem can be avoided at a different level.

One thing I'm aware of is there is some app that consumes a ton of
memory and when it misbehaves or crashes, it takes some 10-20 minutes to
have it exit(munmap() takes a long time to free all those consumed
memory).

THP could help a lot, but it's beyond my understanding why they didn't
use it.

> 
> Besides complexity, it may also add overhead to the non-contended case,
> i.e. the atomic operations on in_progress. This goes against recent page
> allocation optimizations by Mel Gorman etc.
> 
> Would perhaps prefetching the next page in freelist (in
> remove_from_buddy()) help here?

I'm afraid there isn't enough a window for prefetch() to actually make
a difference, but I could give it a try.

We also considered prefetching free_list before taking the lock but
that prefetch could be useless(i.e. the prefetched page can be taken by
another CPU and gone after we actually acquired the lock) and iterate
the list outside lock can be dangerous.

> > The two patches could eliminate zone->lock contention entirely but at
> > the same time, pgdat->lru_lock contention rose to 82%. Final performance
> > increased about 8.3%.
> > 
> > Suggested-by: Ying Huang <ying.huang@intel.com>
> > Signed-off-by: Aaron Lu <aaron.lu@intel.com>
> > ---
> >  Documentation/vm/struct_page_field |   5 +
> >  include/linux/mm_types.h           |   2 +
> >  include/linux/mmzone.h             |  35 +++++
> >  mm/compaction.c                    |   4 +
> >  mm/internal.h                      |  34 +++++
> >  mm/page_alloc.c                    | 288 +++++++++++++++++++++++++++++++++++--
> >  6 files changed, 360 insertions(+), 8 deletions(-)
