Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A82416B0279
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 14:18:31 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id q27so85469849pfi.8
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 11:18:31 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id g20si352538plj.524.2017.06.02.11.18.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Jun 2017 11:18:30 -0700 (PDT)
Subject: Re: [PATCH] mm: vmalloc: make vmalloc_to_page() deal with PMD/PUD
 mappings
References: <20170602112720.28948-1-ard.biesheuvel@linaro.org>
 <e98368d8-b1bc-5804-2115-370ec7109e9b@intel.com>
 <CAKv+Gu964bDsV52gZ7QCJf26kXVaWgmuwXZSm0qWxa-34Eqttw@mail.gmail.com>
 <747b71d8-86a7-3b96-cf90-60d6c2ce0171@intel.com>
 <CAKv+Gu_0cQDyRP0urZEF6OAn7cOEVH3WXL2UpDgg6wKUrWcRYA@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <97a535d8-f9d5-57b2-4b9c-23a0e6df7cc8@intel.com>
Date: Fri, 2 Jun 2017 11:18:28 -0700
MIME-Version: 1.0
In-Reply-To: <CAKv+Gu_0cQDyRP0urZEF6OAn7cOEVH3WXL2UpDgg6wKUrWcRYA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Steve Capper <steve.capper@linaro.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Ingo Molnar <mingo@kernel.org>, Laura Abbott <labbott@fedoraproject.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Zhong Jiang <zhongjiang@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Tanxiaojun <tanxiaojun@huawei.com>, "Shutemov, Kirill" <kirill.shutemov@intel.com>

On 06/02/2017 09:21 AM, Ard Biesheuvel wrote:
>> First of all, this math isn't guaranteed to work.  We don't guarantee
>> virtual contiguity for all mem_map[]s.  I think you need to go to a pfn
>> or paddr first, add the pud offset, then convert to a 'struct page'.
> 
> OK, so you are saying the slice of the struct page array covering the
> range could be discontiguous even though the physical range it
> describes is contiguous? (which is guaranteed due to the nature of a
> PMD mapping IIUC) In that case,

Yes.

>> But, what *is* the right thing to return here?  Do the users here want
>> the head page or the tail page?
> 
> Hmm, I see what you mean. The vread() code that I am trying to fix
> simply kmaps the returned page, copies from it and unmaps it, so it is
> after the tail page. But I guess code that is aware of compound pages
> is after the head page instead.

Yeah, and some operations happen on tail pages while others get
redirected to the head page.

>> BTW, _are_ your huge vmalloc pages compound?
> 
> Not in the case that I am trying to solve, no. They are simply VM_MAP
> mappings of sequences of pages that are occupied by the kernel itself,
> and not allocated by the page allocator.

Huh, so what are they?  Are they system RAM that was bootmem allocated
or something?

>>>>> +#else
>>>>> +     VIRTUAL_BUG_ON(1);
>>>>> +#endif
>>>>> +     return page;
>>>>> +}
>>>> So if somebody manages to call this function on a huge page table entry,
>>>> but doesn't have hugetlbfs configured on, we kill the machine?
>>> Yes. But only if you have CONFIG_DEBUG_VIRTUAL defined, in which case
>>> it seems appropriate to signal a failure rather than proceed with
>>> dereferencing the huge PMD entry as if it were a table entry.
>>
>> Why kill the machine rather than just warning and returning NULL?
> 
> I know this is generally a bad thing, but in this case, when a debug
> option has been enabled exactly for this purpose, I think it is not
> inappropriate to BUG() when encountering such a mapping. But I am
> happy to relax it to a WARN() and return NULL instead, but in that
> case, it should be unconditional imo and not based on
> CONFIG_DEBUG_VIRTUAL or the likes.

Sounds sane to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
