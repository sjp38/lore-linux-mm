Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 758FF6B007E
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 16:30:08 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id l184so3609812lfl.3
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 13:30:08 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id nh6si13853984wjb.224.2016.06.17.13.30.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Jun 2016 13:30:07 -0700 (PDT)
Subject: Re: [RFC PATCH 2/2] xfs: map KM_MAYFAIL to __GFP_RETRY_HARD
References: <1465212736-14637-1-git-send-email-mhocko@kernel.org>
 <1465212736-14637-3-git-send-email-mhocko@kernel.org>
 <20160616002302.GK12670@dastard> <20160616080355.GB6836@dhcp22.suse.cz>
 <20160616112606.GH6836@dhcp22.suse.cz> <20160617182235.GC10485@cmpxchg.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5c0ae2d1-28fc-7ef5-b9ae-a4c8bfa833c7@suse.cz>
Date: Fri, 17 Jun 2016 22:30:06 +0200
MIME-Version: 1.0
In-Reply-To: <20160617182235.GC10485@cmpxchg.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>
Cc: Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On 17.6.2016 20:22, Johannes Weiner wrote:
> On Thu, Jun 16, 2016 at 01:26:06PM +0200, Michal Hocko wrote:
>> @@ -54,6 +54,13 @@ kmem_flags_convert(xfs_km_flags_t flags)
>>  			lflags &= ~__GFP_FS;
>>  	}
>>  
>> +	/*
>> +	 * Default page/slab allocator behavior is to retry for ever
>> +	 * for small allocations. We can override this behavior by using
>> +	 * __GFP_RETRY_HARD which will tell the allocator to retry as long
>> +	 * as it is feasible but rather fail than retry for ever for all
>> +	 * request sizes.
>> +	 */
>>  	if (flags & KM_MAYFAIL)
>>  		lflags |= __GFP_RETRY_HARD;
> 
> I think this example shows that __GFP_RETRY_HARD is not a good flag
> because it conflates two seemingly unrelated semantics; the comment
> doesn't quite make up for that.
> 
> When the flag is set,
> 
> - it allows costly orders to invoke the OOM killer and retry

No, it's not allowing the OOM killer for costly orders, only non-costly, AFAIK.
Mainly it allows more aggressive compaction (especially after my series [1]).

> - it allows !costly orders to fail
> 
> While 1. is obvious from the name, 2. is not. Even if we don't want
> full-on fine-grained naming for every reclaim methodology and retry
> behavior, those two things just shouldn't be tied together.

Well, if allocation is not allowed to fail, it's like trying "indefinitely hard"
already. Telling it it should "try hard" then doesn't make any sense without
also being able to fail.

> I don't see us failing !costly order per default anytime soon, and
> they are common, so adding a __GFP_MAYFAIL to explicitely override
> that behavior seems like a good idea to me. That would make the XFS
> callsite here perfectly obvious.
> 
> And you can still combine it with __GFP_REPEAT.

But that would mean the following meaningful combinations for non-costly orders
(assuming e.g. GFP_KERNEL which allows reclaim/compaction in the first place).

__GFP_NORETRY - that one is well understood hopefully, and implicitly mayfail

__GFP_MAYFAIL - ???
__GFP_MAYFAIL | __GFP_REPEAT - ???

Which one of the last two tries harder? How specifically? Will they differ by
(not) allowing OOM? Won't that be just extra confusing?

> For a generic allocation site like this, __GFP_MAYFAIL | __GFP_REPEAT
> does the right thing for all orders, and it's self-explanatory: try
> hard, allow falling back.
> 
> Whether we want a __GFP_REPEAT or __GFP_TRY_HARD at all is a different
> topic. In the long term, it might be better to provide best-effort per
> default and simply annotate MAYFAIL/NORETRY callsites that want to
> give up earlier. Because as I mentioned at LSFMM, it's much easier to
> identify callsites that have a convenient fallback than callsites that
> need to "try harder." Everybody thinks their allocations are oh so
> important. The former is much more specific and uses obvious criteria.

For higher-order allocations, best-effort might also mean significant system
disruption, not just latency of the allocation itself. One example is hugeltbfs
allocations (echo X > .../nr_hugepages) where the admin is willing to pay this
cost. But to do that by default and rely on everyone else passing NORETRY
wouldn't go far. So I think the TRY_HARD kind of flag makes sense.

> Either way, __GFP_MAYFAIL should be on its own.

[1] https://lwn.net/Articles/689154/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
