Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id D6F5F6B0003
	for <linux-mm@kvack.org>; Tue, 22 May 2018 03:08:01 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z7-v6so13036666wrg.11
        for <linux-mm@kvack.org>; Tue, 22 May 2018 00:08:01 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o61-v6si1252088edb.107.2018.05.22.00.08.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 22 May 2018 00:08:00 -0700 (PDT)
Subject: Re: [PATCH v2 2/4] mm: check for proper migrate type during isolation
References: <20180503232935.22539-1-mike.kravetz@oracle.com>
 <20180503232935.22539-3-mike.kravetz@oracle.com>
 <0a74f688-74fb-b841-4782-f9c96b1b9cfc@suse.cz>
 <f50d6814-8bc6-80cd-c0e5-b2cfa4f9e576@oracle.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a9816b88-015e-7e44-cbb8-a7ff04453870@suse.cz>
Date: Tue, 22 May 2018 09:07:56 +0200
MIME-Version: 1.0
In-Reply-To: <f50d6814-8bc6-80cd-c0e5-b2cfa4f9e576@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Cc: Reinette Chatre <reinette.chatre@intel.com>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 05/22/2018 01:10 AM, Mike Kravetz wrote:
> On 05/18/2018 03:32 AM, Vlastimil Babka wrote:
>> On 05/04/2018 01:29 AM, Mike Kravetz wrote:
>>> The routine start_isolate_page_range and alloc_contig_range have
>>> comments saying that migratetype must be either MIGRATE_MOVABLE or
>>> MIGRATE_CMA.  However, this is not enforced.
>>
>> Enforced, no. But if the pageblocks really were as such, it used to
>> shortcut has_unmovable_pages(). This was wrong and removed in
>> d7b236e10ced ("mm: drop migrate type checks from has_unmovable_pages")
>> plus 4da2ce250f98 ("mm: distinguish CMA and MOVABLE isolation in
>> has_unmovable_pages()").
>>
>>
>>   What is important is
>>> that that all pageblocks in the range are of type migratetype.
>>                                                the same
>>> This is because blocks will be set to migratetype on error.
>>
>> Strictly speaking this is true only for the CMA case. For other cases,
>> the best thing actually would be to employ the same heuristics as page
>> allocation migratetype fallbacks, and count how many pages are free and
>> how many appear to be movable, see how steal_suitable_fallback() uses
>> the last parameter of move_freepages_block().
>>
>>> Add a boolean argument enforce_migratetype to the routine
>>> start_isolate_page_range.  If set, it will check that all pageblocks
>>> in the range have the passed migratetype.  Return -EINVAL is pageblock
>>                                                             if
>>> is wrong type is found in range.
>>   of
>>>
>>> A boolean is used for enforce_migratetype as there are two primary
>>> users.  Contiguous range allocation which wants to enforce migration
>>> type checking.  Memory offline (hotplug) which is not concerned about
>>> type checking.
>>
>> This is missing some high-level result. The end change is that CMA is
>> now enforcing. So we are making it more robust when it's called on
>> non-CMA pageblocks by mistake? (BTW I still do hope we can remove
>> MIGRATE_CMA soon after Joonsoo's ZONE_MOVABLE CMA conversion. Combined
>> with my suggestion above we could hopefully get rid of the migratetype
>> parameter completely instead of enforcing it?). Is this also a
>> preparation for introducing find_alloc_contig_pages() which will be
>> enforcing? (I guess, and will find out shortly, but it should be stated
>> here)
> 
> Thank you for looking at these patches Vlastimil.
> 
> My primary motivation for this patch was the 'error recovery' in
> start_isolate_page_range.  It takes a range and attempts to set
> all pageblocks to MIGRATE_ISOLATE.  If it encounters an error after
> setting some blocks to isolate, it will 'clean up' by setting the
> migrate type of previously modified blocks to the passed migratetype.

Right.

> So, one possible side effect of an error in start_isolate_page_range
> is that the migrate type of some pageblocks could be modified.  Thinking
> about it more now, that may be OK.

It would be definitely OK if the migratetype was changed similarly as
steal_suitable_fallback() does it, as I've said above.

> It just does not seem like the
> right thing to do, especially with comments saying "migratetype must
> be either MIGRATE_MOVABLE or MIGRATE_CMA".  I'm fine with leaving the
> code as is and just cleaning up the comments if you think that may
> be better.

That's also possible, especially when the code is restructured as I've
suggested in the other reply, which should significantly reduce the
amount of error recoveries.
