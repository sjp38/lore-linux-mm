Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E1D026B000C
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 10:11:21 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c5so1021767pfn.17
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 07:11:21 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id t28si1386211pfk.187.2018.03.20.07.11.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Mar 2018 07:11:20 -0700 (PDT)
Date: Tue, 20 Mar 2018 22:11:01 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [RFC PATCH v2 2/4] mm/__free_one_page: skip merge for order-0
 page unless compaction failed
Message-ID: <20180320141101.GB2033@intel.com>
References: <20180320085452.24641-1-aaron.lu@intel.com>
 <20180320085452.24641-3-aaron.lu@intel.com>
 <7b1988e9-7d50-d55e-7590-20426fb257af@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7b1988e9-7d50-d55e-7590-20426fb257af@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>

On Tue, Mar 20, 2018 at 12:45:50PM +0100, Vlastimil Babka wrote:
> On 03/20/2018 09:54 AM, Aaron Lu wrote:
> > Running will-it-scale/page_fault1 process mode workload on a 2 sockets
> > Intel Skylake server showed severe lock contention of zone->lock, as
> > high as about 80%(42% on allocation path and 35% on free path) CPU
> > cycles are burnt spinning. With perf, the most time consuming part inside
> > that lock on free path is cache missing on page structures, mostly on
> > the to-be-freed page's buddy due to merging.
> 
> But why, with all the prefetching in place?

The prefetch is just for its order 0 buddy, if merge happens, then its
order 1 buddy will also be checked and on and on, so the cache misses
are much more in merge mode.

> 
> > One way to avoid this overhead is not do any merging at all for order-0
> > pages. With this approach, the lock contention for zone->lock on free
> > path dropped to 1.1% but allocation side still has as high as 42% lock
> > contention. In the meantime, the dropped lock contention on free side
> > doesn't translate to performance increase, instead, it's consumed by
> > increased lock contention of the per node lru_lock(rose from 5% to 37%)
> > and the final performance slightly dropped about 1%.
> > 
> > Though performance dropped a little, it almost eliminated zone lock
> > contention on free path and it is the foundation for the next patch
> > that eliminates zone lock contention for allocation path.
> 
> Not thrilled about such disruptive change in the name of a
> microbenchmark :/ Shouldn't normally the pcplists hide the overhead?

Sadly, with the default pcp count, it didn't avoid the lock contention.
We can of course increase pcp->count to a large enough value to avoid
entering buddy and thus avoid zone->lock contention, but that would
require admin to manually change the value on a per-machine per-workload
basis I believe.

> If not, wouldn't it make more sense to turn zone->lock into a range lock?

Not familiar with range lock, will need to take a look at it, thanks for
the pointer.

> 
> > A new document file called "struct_page_filed" is added to explain
> > the newly reused field in "struct page".
> 
> Sounds rather ad-hoc for a single field, I'd rather document it via
> comments.

Dave would like to have a document to explain all those "struct page"
fields that are repurposed under different scenarios and this is the
very start of the document :-)

I probably should have explained the intent of the document more.

Thanks for taking a look at this.

> > Suggested-by: Dave Hansen <dave.hansen@intel.com>
> > Signed-off-by: Aaron Lu <aaron.lu@intel.com>
> > ---
> >  Documentation/vm/struct_page_field |  5 +++
> >  include/linux/mm_types.h           |  1 +
> >  mm/compaction.c                    | 13 +++++-
> >  mm/internal.h                      | 27 ++++++++++++
> >  mm/page_alloc.c                    | 89 +++++++++++++++++++++++++++++++++-----
> >  5 files changed, 122 insertions(+), 13 deletions(-)
> >  create mode 100644 Documentation/vm/struct_page_field
> > 
