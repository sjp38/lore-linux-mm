Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0647A6B0005
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 02:58:02 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id d65so108463054ith.0
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 23:58:02 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id u17si5702387itc.119.2016.08.09.23.58.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Aug 2016 23:58:01 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH] fadump: Register the memory reserved by fadump
In-Reply-To: <20160810064056.GB24800@linux.vnet.ibm.com>
References: <1470318165-2521-1-git-send-email-srikar@linux.vnet.ibm.com> <87mvkritii.fsf@concordia.ellerman.id.au> <20160805072838.GF11268@linux.vnet.ibm.com> <87h9azin4g.fsf@concordia.ellerman.id.au> <20160805100609.GP2799@techsingularity.net> <87d1lhtb3s.fsf@concordia.ellerman.id.au> <20160810064056.GB24800@linux.vnet.ibm.com>
Date: Wed, 10 Aug 2016 16:57:57 +1000
Message-ID: <877fbpt8ju.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, Mahesh Salgaonkar <mahesh@linux.vnet.ibm.com>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@intel.com>, Balbir Singh <bsingharora@gmail.com>

Srikar Dronamraju <srikar@linux.vnet.ibm.com> writes:

>> 
>> > Conceptually it would be cleaner, if expensive, to calculate the real
>> > memblock reserves if HASH_EARLY and ditch the dma_reserve, memory_reserve
>> > and nr_kernel_pages entirely.
>> 
>> Why is it expensive? memblock tracks the totals for all memory and
>> reserved memory AFAIK, so it should just be a case of subtracting one
>> from the other?
>
> Are you suggesting that we use something like
> memblock_phys_mem_size() but one which returns
> memblock.reserved.total_size ? Maybe a new function like
> memblock_reserved_mem_size()?

Yeah, something like that. I'm not sure if it actually needs a function,
AFAIK you can just look at the structure directly.

>> > Unfortuantely, aside from the calculation,
>> > there is a potential cost due to a smaller hash table that affects everyone,
>> > not just ppc64.
>> 
>> Yeah OK. We could make it an arch hook, or controlled by a CONFIG.
>
> If its based on memblock.reserved.total_size, then should it be arch
> specific?

Yes I think so. Otherwise you have to test it on every architecture :)

>> > However, if the hash table is meant to be sized on the
>> > number of available pages then it really should be based on that and not
>> > just a made-up number.
>> 
>> Yeah that seems to make sense.
>> 
>> The one complication I think is that we may have memory that's marked
>> reserved in memblock, but is later freed to the page allocator (eg.
>> initrd).
>
> Yes, this is a possibility, for example lets say we want fadump to
> continue to run instead of rebooting to a new kernel as it does today.

But that's a bad idea and no one should ever do it.

For starters all your caches will be undersized, and anything that is
allocated per-node early in boot will not be allocated on the nodes
which were reserved, so the system's performance will potentially differ
from a normal boot in weird and unpredictable ways.

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
