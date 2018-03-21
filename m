Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C6F5A6B0007
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 03:55:20 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c5so2262186pfn.17
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 00:55:20 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s11si2449452pgn.207.2018.03.21.00.55.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Mar 2018 00:55:19 -0700 (PDT)
Subject: Re: [RFC PATCH v2 2/4] mm/__free_one_page: skip merge for order-0
 page unless compaction failed
References: <20180320085452.24641-1-aaron.lu@intel.com>
 <20180320085452.24641-3-aaron.lu@intel.com>
 <7b1988e9-7d50-d55e-7590-20426fb257af@suse.cz>
 <20180320141101.GB2033@intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5b1f7ef5-0dca-c35f-aba9-3b55f81740b2@suse.cz>
Date: Wed, 21 Mar 2018 08:53:27 +0100
MIME-Version: 1.0
In-Reply-To: <20180320141101.GB2033@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>

On 03/20/2018 03:11 PM, Aaron Lu wrote:
> On Tue, Mar 20, 2018 at 12:45:50PM +0100, Vlastimil Babka wrote:
>> But why, with all the prefetching in place?
> 
> The prefetch is just for its order 0 buddy, if merge happens, then its
> order 1 buddy will also be checked and on and on, so the cache misses
> are much more in merge mode.

I see.

>> Not thrilled about such disruptive change in the name of a
>> microbenchmark :/ Shouldn't normally the pcplists hide the overhead?
> 
> Sadly, with the default pcp count, it didn't avoid the lock contention.
> We can of course increase pcp->count to a large enough value to avoid
> entering buddy and thus avoid zone->lock contention, but that would
> require admin to manually change the value on a per-machine per-workload
> basis I believe.

Well, anyone who really cares about performance has to invest some time
to tuning anyway, I believe?

>> If not, wouldn't it make more sense to turn zone->lock into a range lock?
> 
> Not familiar with range lock, will need to take a look at it, thanks for
> the pointer.

The suggestion was rather quick and not well thought-out. Range lock
itself is insufficient - for merging/splitting buddies it's ok for
working with struct pages because the candidate buddies are within a
MAX_ORDER range. But the freelists contain pages from the whole zone.

>>
>>> A new document file called "struct_page_filed" is added to explain
>>> the newly reused field in "struct page".
>>
>> Sounds rather ad-hoc for a single field, I'd rather document it via
>> comments.
> 
> Dave would like to have a document to explain all those "struct page"
> fields that are repurposed under different scenarios and this is the
> very start of the document :-)

Oh, I see.

> I probably should have explained the intent of the document more.
> 
> Thanks for taking a look at this.
> 
>>> Suggested-by: Dave Hansen <dave.hansen@intel.com>
>>> Signed-off-by: Aaron Lu <aaron.lu@intel.com>
>>> ---
>>>  Documentation/vm/struct_page_field |  5 +++
>>>  include/linux/mm_types.h           |  1 +
>>>  mm/compaction.c                    | 13 +++++-
>>>  mm/internal.h                      | 27 ++++++++++++
>>>  mm/page_alloc.c                    | 89 +++++++++++++++++++++++++++++++++-----
>>>  5 files changed, 122 insertions(+), 13 deletions(-)
>>>  create mode 100644 Documentation/vm/struct_page_field
>>>
