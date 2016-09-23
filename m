Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id CF26F6B027E
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 08:29:35 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id n24so219248985pfb.0
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 05:29:35 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id v4si7729805paa.285.2016.09.23.05.29.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 23 Sep 2016 05:29:35 -0700 (PDT)
Subject: Re: [PATCH 1/1] lib/ioremap.c: avoid endless loop under ioremapping
 page unaligned ranges
References: <57E20A69.5010206@zoho.com>
 <20160922124735.GB11204@dhcp22.suse.cz>
 <35661a34-c3e0-0ec2-b58f-ee59bef4e4d4@zoho.com>
 <20160923084551.GG4478@dhcp22.suse.cz>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <f9e708e1-121e-367e-1141-5470e5baffe5@zoho.com>
Date: Fri, 23 Sep 2016 20:29:20 +0800
MIME-Version: 1.0
In-Reply-To: <20160923084551.GG4478@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: zijun_hu@htc.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tj@kernel.org, mingo@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net

On 2016/9/23 16:45, Michal Hocko wrote:
> On Thu 22-09-16 23:13:17, zijun_hu wrote:
>> On 2016/9/22 20:47, Michal Hocko wrote:
>>> On Wed 21-09-16 12:19:53, zijun_hu wrote:
>>>> From: zijun_hu <zijun_hu@htc.com>
>>>>
>>>> endless loop maybe happen if either of parameter addr and end is not
>>>> page aligned for kernel API function ioremap_page_range()
>>>
>>> Does this happen in practise or this you found it by reading the code?
>>>
>> i found it by reading the code, this is a kernel API function and there
>> are no enough hint for parameter requirements, so any parameters
>> combination maybe be used by user, moreover, it seems appropriate for
>> many bad parameter combination, for example, provided  PMD_SIZE=2M and
>> PAGE_SIZE=4K, 0x00 is used for aligned very well address
>> a user maybe want to map virtual range[0x1ff800, 0x200800) to physical address
>> 0x300800, it will cause endless loop
> 
> Well, we are relying on the kernel to do the sane thing otherwise we
> would be screwed anyway. If this can be triggered by a userspace then it
> would be a different story. Just look at how we are doing mmap, we
> sanitize the page alignment at the high level and the lower level
> functions just assume sane values.
> 
ioremap_page_range() is exported by EXPORT_SYMBOL_GPL() as a kernel interface
so perhaps it is called by not only any kernel module authors but also other
kernel parts

if the bad range is used by a careless kernel user really, it seems a better
choice to alert the warning message or panic the kernel than hanging the system
due to endless loop, it can help them locate problem usefully

so additional sane check BUG_ON(!PAGE_ALIGNED(addr) || !PAGE_ALIGNED(end))
is appended to existing check BUG_ON(addr >= end)

>>>> in order to fix this issue and alert improper range parameters to user
>>>> WARN_ON() checkup and rounding down range lower boundary are performed
>>>> firstly, loop end condition within ioremap_pte_range() is optimized due
>>>> to lack of relevant macro pte_addr_end()
>>>>
>>>> Signed-off-by: zijun_hu <zijun_hu@htc.com>
>>>> ---
>>>>  lib/ioremap.c | 4 +++-
>>>>  1 file changed, 3 insertions(+), 1 deletion(-)
>>>>
>>>> diff --git a/lib/ioremap.c b/lib/ioremap.c
>>>> index 86c8911..911bdca 100644
>>>> --- a/lib/ioremap.c
>>>> +++ b/lib/ioremap.c
>>>> @@ -64,7 +64,7 @@ static int ioremap_pte_range(pmd_t *pmd, unsigned long addr,
>>>>  		BUG_ON(!pte_none(*pte));
>>>>  		set_pte_at(&init_mm, addr, pte, pfn_pte(pfn, prot));
>>>>  		pfn++;
>>>> -	} while (pte++, addr += PAGE_SIZE, addr != end);
>>>> +	} while (pte++, addr += PAGE_SIZE, addr < end && addr >= PAGE_SIZE);
>>>>  	return 0;
>>>>  }
>>>
>>> Ble, this just overcomplicate things. Can we just make sure that the
>>> proper alignment is done in ioremap_page_range which is the only caller
>>> of this (and add VM_BUG_ON in ioremap_pud_range to make sure no new
>>> caller will forget about that).
>>>
>>   this complicate express is used to avoid addr overflow, consider map
>>   virtual rang [0xffe00800, 0xfffff800) for 32bit machine
>>   actually, my previous approach is just like that you pointed mailed at 20/09
>>   as below, besides, i apply my previous approach for mm/vmalloc.c and 
>>   npiggin@gmail.com have "For API functions perhaps it's reasonable" comments
>>   i don't tell which is better
>>
>>  diff --git a/lib/ioremap.c b/lib/ioremap.c 
>>  --- a/lib/ioremap.c 
>>  +++ b/lib/ioremap.c 
>>  @@ -64,7 +64,7 @@ static int ioremap_pte_range(pmd_t *pmd, unsigned long addr, 
>>          BUG_ON(!pte_none(*pte)); 
>>          set_pte_at(&init_mm, addr, pte, pfn_pte(pfn, prot)); 
>>          pfn++; 
>>  -    } while (pte++, addr += PAGE_SIZE, addr != end); 
>>  +    } while (pte++, addr += PAGE_SIZE, addr < end); 
>>      return 0; 
>>  } 
> 
> yes this looks good to me
> 
>>  
>>  @@ -129,6 +129,7 @@ int ioremap_page_range(unsigned long addr, 
>>      int err; 
>>  
>>      BUG_ON(addr >= end); 
>>  +   BUG_ON(!PAGE_ALIGNED(addr) || !PAGE_ALIGNED(end));
> 
> Well, BUG_ON is rather harsh for something that would be trivially
> fixable.
> 
i append the additional BUG_ON() by resembling exiting BUG_ON(addr >= end);
>>  
>>      start = addr; 
>>      phys_addr -= addr; 
>>  
>>>>  
>>>> @@ -129,7 +129,9 @@ int ioremap_page_range(unsigned long addr,
>>>>  	int err;
>>>>  
>>>>  	BUG_ON(addr >= end);
>>>> +	WARN_ON(!PAGE_ALIGNED(addr) || !PAGE_ALIGNED(end));
>>>
>>> maybe WARN_ON_ONCE would be sufficient to prevent from swamping logs if
>>> something just happens to do this too often in some pathological path.
>>>
>> if WARN_ON_ONCE is used, the later bad ranges for many other purposes can't
>> be alerted, and ioremap_page_range() can map large enough ranges so not too many
>> calls happens for a purpose
>>>>  
>>>> +	addr = round_down(addr, PAGE_SIZE);
>>>
>>> 	end = round_up(end, PAGE_SIZE);
>>>
>>> wouldn't work?
>>>
>> no, it don't work for many special case
>> for example, provided  PMD_SIZE=2M
>> mapping [0x1f8800, 0x208800) virtual range will be split to two ranges
>> [0x1f8800, 0x200000) and [0x200000,0x208800) and map them separately
>> the first range will cause dead loop
> 
> I am not sure I see your point. How can we deadlock if _both_ addresses
> get aligned to the page boundary and how does PMD_SIZE make any
> difference.
> 
i will take a example to illustrate my considerations
provided PUD_SIZE == 1G, PMD_SIZE == 2M, PAGE_SIZE == 4K
it is used by arm64 normally

we want to map virtual range [0xffffffff_ffc08800, 0xffffffff_fffff800) by
ioremap_page_range(),ioremap_pmd_range() is called to map the range
finally, ioremap_pmd_range() will call
ioremap_pte_range(pmd, 0xffffffff_ffc08800, 0xffffffff_fffe0000) and
ioremap_pte_range(pmd, 0xffffffff_fffe0000, 0xffffffff fffff800) separately

let's loop end condition(pte++, addr += PAGE_SIZE, addr != end) within
ioremap_pte_range() for the two ioremap_pte_range() calls separately

for ioremap_pte_range(pmd, 0xffffffff_ffc08800, 0xffffffff_fffe0000)
addr != end don't end the while loop due to parameter addr = 0xffffffff_ffc08800
is not page aligned, even any number of PAGE_SIZE is added to addr, addr can't 
equal to page aligned parameter end 0xffffffff_fffe0000

so we change the "addr != end" to "addr < end"

for ioremap_pte_range(pmd, 0xffffffff_fffe0000, 0xffffffff fffff800)
let us consider the state after the final page with the range is mapped via 
a number of while loops, at that moment, addr == 0xffffffff_fffff000, 
end == 0xffffffff_fffff800, let us see the fixed loop end condition
(pte++, addr += PAGE_SIZE, addr < end), addr overflow to 0 after PAGE_SIZE is added
, it cause the condition is true and loop continues, it should be terminated the loop

so we correct the "addr < end" to "addr < end && addr >= PAGE_SIZE"

in summary, there are two approaches for fixing this issue
i don't tell which is better




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
