Date: Tue, 1 May 2007 02:45:15 +0100 (BST)
From: Mark Fortescue <mark@mtfhpc.demon.co.uk>
Subject: Re: vm changes from linux-2.6.14 to linux-2.6.15
In-Reply-To: <20070430.173806.112621225.davem@davemloft.net>
Message-ID: <Pine.LNX.4.61.0705010223040.3556@mtfhpc.demon.co.uk>
References: <20070430145414.88fda272.akpm@linux-foundation.org>
 <20070430.150407.07642146.davem@davemloft.net> <1177977619.24962.6.camel@localhost.localdomain>
 <20070430.173806.112621225.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: benh@kernel.crashing.org, akpm@linux-foundation.org, linuxppc-dev@ozlabs.org, wli@holomorphy.com, linux-mm@kvack.org, andrea@suse.de, sparclinux@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Mon, 30 Apr 2007, David Miller wrote:

> From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Date: Tue, 01 May 2007 10:00:19 +1000
>
>>
>>>> Interesting - thanks for working that out.  Let's keep linux-mm on cc please.
>>>
>>> You can't elide the update_mmu_cache() call on sun4c because that will
>>> miss some critical TLB setups which are performed there.
>>>
>>> The sun4c TLB has two tiers of entries:
>>>
>>> 1) segment maps, these hold ptes for a range of addresses
>>> 2) ptes, mapped into segment maps
>>>
>>> update_mmu_cache() on sun4c take care of allocating and setting
>>> up the segment maps, so if you elide the call this never happens
>>> and we fault forever.
>>
>> Maybe we can move that logic to ptep_set_access_flags()... in fact, the
>> tlb flush logic should be done there too imho.
>>
>> There would still be the update_mmu_cache() that we don't want on
>> powerpc in all cases I suppose. That can be done by having
>> ptep_set_access_flags() return a boolean indicating wether
>> update_mmu_cache() shall be called or not ...
>
> Always doing ptep_set_access_flags() and returning a boolean like
> that might be a good idea.

At present, update_mmu_cache() and lazy_mmu_prot_update() are always 
called when ptep_set_access_flags() is called so why not move them into 
ptep_set_access_flags() and change ptep_set_access_flags() to have an 
additional boolean parameter (__update) that would when set, cause 
update_mmu_cache() and lazy_mmu_prot_update() to be called.

On sun4c, an architecture specific function would be installed that 
always treats the __update parameter as set at all times.

The generic function would change to somthing along the lines:

#define ptep_set_access_flags(__vma, __address, \
                               __ptep, __entry, __dirty, __update)
do { \
    if (__update) { \
        set_pte_at((__vma)->vm_mm, (__address), __ptep, __entry); \
        flush_tlb_page(__vma, __address); \
        update_mmu_cache(__vma, __address, __entry); \
        lazy_mmu_prot_update(__entry); \
    } else if (__dirty) {
        flush_tlb_page(__vma, __address); \
    } \
} while (0)

The code in mm/memory.c and mm/hugetlb.c and the architecture specific 
versions of ptep_set_access_flags would then be changed acordingly.

Regards
 	Mark Fortescue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
