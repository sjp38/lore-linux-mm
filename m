Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id E8B046B0008
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 13:06:17 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id b7-v6so20706268pgt.10
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 10:06:17 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f24-v6si16853728pgv.390.2018.10.17.10.06.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 10:06:16 -0700 (PDT)
Subject: Re: [RFC v4 PATCH 2/5] mm/__free_one_page: skip merge for order-0
 page unless compaction failed
References: <20181017063330.15384-1-aaron.lu@intel.com>
 <20181017063330.15384-3-aaron.lu@intel.com>
 <20181017104427.GJ5819@techsingularity.net> <20181017131059.GA9167@intel.com>
 <20181017135807.GL5819@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <6d4d1a59-bb70-d4c9-bd18-8c398a09f25f@suse.cz>
Date: Wed, 17 Oct 2018 19:03:30 +0200
MIME-Version: 1.0
In-Reply-To: <20181017135807.GL5819@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Aaron Lu <aaron.lu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>, Tariq Toukan <tariqt@mellanox.com>, Jesper Dangaard Brouer <brouer@redhat.com>

On 10/17/18 3:58 PM, Mel Gorman wrote:
> Again, as compaction is not guaranteed to find the pageblocks, it would
> be important to consider whether a) that matters or b) find an
> alternative way of keeping unmerged buddies on separate lists so they
> can be quickly discovered when a high-order allocation fails.

Agree, unmerged buddies could be on separate freelist from regular
order-0 freelist. That list could be also preferred to allocations
before the regular one. Then one could e.g. try "direct merging" via
this list when compaction fails, or prefer direct merging to compaction
for non-costly-order allocations, do direct merging when allocation
context doesn't even allow compaction (atomic etc).

Also I would definitely consider always merging pages freed to
non-MOVABLE pageblocks. We really don't want to increase the
fragmentation in those. However that means it probably won't help the
netperf case?

Vlastimil
