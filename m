Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3F3026B0003
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 02:48:45 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id g6-v6so22836398plo.0
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 23:48:45 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id c24-v6si19491096pls.211.2018.10.17.23.48.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 23:48:43 -0700 (PDT)
Date: Thu, 18 Oct 2018 14:48:39 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [RFC v4 PATCH 2/5] mm/__free_one_page: skip merge for order-0
 page unless compaction failed
Message-ID: <20181018064839.GA6468@intel.com>
References: <20181017063330.15384-1-aaron.lu@intel.com>
 <20181017063330.15384-3-aaron.lu@intel.com>
 <20181017104427.GJ5819@techsingularity.net>
 <20181017131059.GA9167@intel.com>
 <20181017135807.GL5819@techsingularity.net>
 <6d4d1a59-bb70-d4c9-bd18-8c398a09f25f@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6d4d1a59-bb70-d4c9-bd18-8c398a09f25f@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>, Tariq Toukan <tariqt@mellanox.com>, Jesper Dangaard Brouer <brouer@redhat.com>

On Wed, Oct 17, 2018 at 07:03:30PM +0200, Vlastimil Babka wrote:
> On 10/17/18 3:58 PM, Mel Gorman wrote:
> > Again, as compaction is not guaranteed to find the pageblocks, it would
> > be important to consider whether a) that matters or b) find an
> > alternative way of keeping unmerged buddies on separate lists so they
> > can be quickly discovered when a high-order allocation fails.
> 
> Agree, unmerged buddies could be on separate freelist from regular
> order-0 freelist. That list could be also preferred to allocations
> before the regular one. Then one could e.g. try "direct merging" via
> this list when compaction fails, or prefer direct merging to compaction
> for non-costly-order allocations, do direct merging when allocation
> context doesn't even allow compaction (atomic etc).

One concern regarding "direct merging" these unmerged pages via this
separate freelist(let's call it unmerged_free_list) is: adjacent
unmerged pages on the unmerged_free_list could be far away from each
other regarding their physical positions, so during the process of
merging them, the needed high order page may not be able to be formed
in a short time. Actually, the time could be unbound in a bad condition
when:
1 unmerged pages adjacent on the unmerged_free_list happen to be far
  away from each other regarding their physical positions; and
2 there are a lot of unmerged pages on unmerged_free_list.

That's the reason I hooked the merging of unmerged pages in compaction
when isolate_migratepages_block() is scanning every page of a pageblock
in PFN order.

OTOH, if there is a kernel thread trying to reduce fragmentation by
doing merges for these unmerged pages, I think it's perfect fine to let
it iterate all unmerged pages of that list and do_merge() for all of
them.

So what about this: if kcompactd is running, let it handle these
unmerged pages on the list and after that, do its usual job of
compaction. If direct compaction is running, do not handle unmerged
pages on that list but rely on isolate_migratepages_block() to do the
merging as is done in this patchset.

This of course has the effect of tying compaction with 'lazy merging'.
If it is not desirable, what about creating a new kernel thread to do
the merging of unmerged pages on the list while keeping the behaviour of
isolate_migratepages_block() in this patchset to improve compaction
success rate.

> Also I would definitely consider always merging pages freed to
> non-MOVABLE pageblocks. We really don't want to increase the
> fragmentation in those. However that means it probably won't help the
> netperf case?

Yes, that would be unfortunate for all in-kernel users of page
allocator...
