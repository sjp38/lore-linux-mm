Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4AED28E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 10:00:26 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id q62so4024254pgq.9
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 07:00:26 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k38si6182618pgi.235.2019.01.16.07.00.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 07:00:25 -0800 (PST)
Subject: Re: [PATCH 11/25] mm, compaction: Use free lists to quickly locate a
 migration source
References: <20190104125011.16071-1-mgorman@techsingularity.net>
 <20190104125011.16071-12-mgorman@techsingularity.net>
 <f1e0e977-d901-776d-9a6a-799735ebd3bf@suse.cz>
 <20190116143308.GE27437@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d232eb5a-065f-742f-35e3-b06cfdfbeb69@suse.cz>
Date: Wed, 16 Jan 2019 16:00:22 +0100
MIME-Version: 1.0
In-Reply-To: <20190116143308.GE27437@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux-MM <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On 1/16/19 3:33 PM, Mel Gorman wrote:
>>> +				break;
>>> +			}
>>> +
>>> +			/*
>>> +			 * If low PFNs are being found and discarded then
>>> +			 * limit the scan as fast searching is finding
>>> +			 * poor candidates.
>>> +			 */
>>
>> I wonder about the "low PFNs are being found and discarded" part. Maybe
>> I'm missing it, but I don't see them being discarded above, this seems
>> to be the first check against cc->migrate_pfn. With the min() part in
>> update_fast_start_pfn(), does it mean we can actually go back and rescan
>> (or skip thanks to skip bits, anyway) again pageblocks that we already
>> scanned?
>>
> 
> Extremely poor phrasing. My mind was thinking in terms of discarding
> unsuitable candidates as they were below the migration scanner and it
> did not translate properly.
> 
> Based on your feedback, how does the following untested diff look?

IMHO better. Meanwhile I noticed that the next patch removes the
set_pageblock_skip() so maybe it's needless churn to introduce the
fast_find_block, but I'll check more closely.

The new comment about pfns below cc->migrate_pfn is better but I still
wonder if it would be better to really skip over those candidates (they
are still called unsuitable) and not go backwards with cc->migrate_pfn.
But if you think the pageblock skip bits and halving of limit minimizes
pointless rescan sufficiently, then fine.
