Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id C01516B0005
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 02:02:55 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id d65so105716952ith.0
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 23:02:55 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id w73si5513791itw.123.2016.08.09.23.02.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Aug 2016 23:02:54 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH] fadump: Register the memory reserved by fadump
In-Reply-To: <20160805100609.GP2799@techsingularity.net>
References: <1470318165-2521-1-git-send-email-srikar@linux.vnet.ibm.com> <87mvkritii.fsf@concordia.ellerman.id.au> <20160805072838.GF11268@linux.vnet.ibm.com> <87h9azin4g.fsf@concordia.ellerman.id.au> <20160805100609.GP2799@techsingularity.net>
Date: Wed, 10 Aug 2016 16:02:47 +1000
Message-ID: <87d1lhtb3s.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, Mahesh Salgaonkar <mahesh@linux.vnet.ibm.com>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@intel.com>, Balbir Singh <bsingharora@gmail.com>

Mel Gorman <mgorman@techsingularity.net> writes:

> On Fri, Aug 05, 2016 at 07:25:03PM +1000, Michael Ellerman wrote:
>> > One way to do that would be to walk through the different memory
>> > reserved blocks and calculate the size. But Mel feels thats an
>> > overhead (from his reply to the other thread) esp for just one use
>> > case.
>> 
>> OK. I think you're referring to this:
>> 
>>   If fadump is reserving memory and alloc_large_system_hash(HASH_EARLY)
>>   does not know about then then would an arch-specific callback for
>>   arch_reserved_kernel_pages() be more appropriate?
>>   ...
>>   
>>   That approach would limit the impact to ppc64 and would be less costly than
>>   doing a memblock walk instead of using nr_kernel_pages for everyone else.
>> 
>> That sounds more robust to me than this solution.
>
> It would be the fastest with the least impact but not necessarily the
> best. Ultimately that dma_reserve/memory_reserve is used for the sizing
> calculation of the large system hashes but only the e820 map and fadump
> is taken into account. That's a bit filthy even if it happens to work out ok.

Right.

> Conceptually it would be cleaner, if expensive, to calculate the real
> memblock reserves if HASH_EARLY and ditch the dma_reserve, memory_reserve
> and nr_kernel_pages entirely.

Why is it expensive? memblock tracks the totals for all memory and
reserved memory AFAIK, so it should just be a case of subtracting one
from the other?

> Unfortuantely, aside from the calculation,
> there is a potential cost due to a smaller hash table that affects everyone,
> not just ppc64.

Yeah OK. We could make it an arch hook, or controlled by a CONFIG.

> However, if the hash table is meant to be sized on the
> number of available pages then it really should be based on that and not
> just a made-up number.

Yeah that seems to make sense.

The one complication I think is that we may have memory that's marked
reserved in memblock, but is later freed to the page allocator (eg.
initrd).

I'm not sure if that's actually a concern in practice given the relative
size of the initrd and memory on most systems. But possibly there are
other things that get reserved and then freed which could skew the hash
table size calculation.

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
