Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 47F196B7F8A
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 13:47:29 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id 20-v6so17768866ois.21
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 10:47:29 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id x19-v6si5428565oix.68.2018.09.07.10.47.27
        for <linux-mm@kvack.org>;
        Fri, 07 Sep 2018 10:47:27 -0700 (PDT)
Subject: Re: [PATCH] arm64: mm: always enable CONFIG_HOLES_IN_ZONE
References: <20180830150532.22745-1-james.morse@arm.com>
 <20180903194731.GE14951@dhcp22.suse.cz>
From: James Morse <james.morse@arm.com>
Message-ID: <1310a17b-214a-b840-d87b-42b799b623d2@arm.com>
Date: Fri, 7 Sep 2018 18:47:24 +0100
MIME-Version: 1.0
In-Reply-To: <20180903194731.GE14951@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Pavel Tatashin <Pavel.Tatashin@microsoft.com>, Mikulas Patocka <mpatocka@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>

Hi Michal,

On 03/09/18 20:47, Michal Hocko wrote:
> On Thu 30-08-18 16:05:32, James Morse wrote:
>> Commit 6d526ee26ccd ("arm64: mm: enable CONFIG_HOLES_IN_ZONE for NUMA")
>> only enabled HOLES_IN_ZONE for NUMA systems because the NUMA code was
>> choking on the missing zone for nomap pages. This problem doesn't just
>> apply to NUMA systems.
>>
>> If the architecture doesn't set HAVE_ARCH_PFN_VALID, pfn_valid() will
>> return true if the pfn is part of a valid sparsemem section.
>>
>> When working with multiple pages, the mm code uses pfn_valid_within()
>> to test each page it uses within the sparsemem section is valid. On
>> most systems memory comes in MAX_ORDER_NR_PAGES chunks which all
>> have valid/initialised struct pages. In this case pfn_valid_within()
>> is optimised out.
>>
>> Systems where this isn't true (e.g. due to nomap) should set
>> HOLES_IN_ZONE and provide HAVE_ARCH_PFN_VALID so that mm tests each
>> page as it works with it.
>>
>> Currently non-NUMA arm64 systems can't enable HOLES_IN_ZONE, leading to
>> VM_BUG_ON()

[...]

>> Remove the NUMA dependency.
>>
>> Reported-by: Mikulas Patocka <mpatocka@redhat.com>
>> Link: https://www.spinics.net/lists/arm-kernel/msg671851.html
>> Fixes: 6d526ee26ccd ("arm64: mm: enable CONFIG_HOLES_IN_ZONE for NUMA")
>> CC: Ard Biesheuvel <ard.biesheuvel@linaro.org>
>> Signed-off-by: James Morse <james.morse@arm.com>
> 
> OK. I guess you are also going to post a patch to drop
> ARCH_HAS_HOLES_MEMORYMODEL, right?

Yes:
https://marc.info/?l=linux-arm-kernel&m=153572884121769&w=2

After all this I'm suspicious about arm64's support for FLATMEM given we always
set HAVE_ARCH_PFN_VALID.


> Anyway
> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!


> I wish we could simplify the pfn validation code a bit. I find
> pfn_valid_within quite confusing and I would bet it is not used
> consistently.

> This will require a non trivial audit. I am wondering
> whether we really need to make the code more complicated rather than
> simply establish a contract that we always have a pageblock worth of
> struct pages always available. Even when there is no physical memory
> backing it. Such a page can be reserved and never used by the page
> allocator. pfn walkers should back off for reserved pages already.

Is PG_Reserved really where this stops?
Going through the mail archive it looks like whenever this crops up on arm64 the
issues are with nomap pages needing a 'correct' node or zone,  where-as we would
prefer it if linux knew nothing about them.


Thanks,

James


pages needing a node came up here:
https://www.spinics.net/lists/arm-kernel/msg535191.html

and flags such as PG_Reserved on nomap pages made Ard slightly uneasy here:
https://lkml.org/lkml/2016/12/5/388
