Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id F1D0F6B0275
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 11:13:35 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id fu14so156483694pad.0
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 08:13:35 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id kd15si1911449pad.225.2016.09.22.08.13.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 22 Sep 2016 08:13:35 -0700 (PDT)
Subject: Re: [PATCH 1/1] lib/ioremap.c: avoid endless loop under ioremapping
 page unaligned ranges
References: <57E20A69.5010206@zoho.com>
 <20160922124735.GB11204@dhcp22.suse.cz>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <35661a34-c3e0-0ec2-b58f-ee59bef4e4d4@zoho.com>
Date: Thu, 22 Sep 2016 23:13:17 +0800
MIME-Version: 1.0
In-Reply-To: <20160922124735.GB11204@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: zijun_hu@htc.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tj@kernel.org, mingo@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net

On 2016/9/22 20:47, Michal Hocko wrote:
> On Wed 21-09-16 12:19:53, zijun_hu wrote:
>> From: zijun_hu <zijun_hu@htc.com>
>>
>> endless loop maybe happen if either of parameter addr and end is not
>> page aligned for kernel API function ioremap_page_range()
> 
> Does this happen in practise or this you found it by reading the code?
> 
i found it by reading the code, this is a kernel API function and there
are no enough hint for parameter requirements, so any parameters
combination maybe be used by user, moreover, it seems appropriate for
many bad parameter combination, for example, provided  PMD_SIZE=2M and
PAGE_SIZE=4K, 0x00 is used for aligned very well address
a user maybe want to map virtual range[0x1ff800, 0x200800) to physical address
0x300800, it will cause endless loop
>> in order to fix this issue and alert improper range parameters to user
>> WARN_ON() checkup and rounding down range lower boundary are performed
>> firstly, loop end condition within ioremap_pte_range() is optimized due
>> to lack of relevant macro pte_addr_end()
>>
>> Signed-off-by: zijun_hu <zijun_hu@htc.com>
>> ---
>>  lib/ioremap.c | 4 +++-
>>  1 file changed, 3 insertions(+), 1 deletion(-)
>>
>> diff --git a/lib/ioremap.c b/lib/ioremap.c
>> index 86c8911..911bdca 100644
>> --- a/lib/ioremap.c
>> +++ b/lib/ioremap.c
>> @@ -64,7 +64,7 @@ static int ioremap_pte_range(pmd_t *pmd, unsigned long addr,
>>  		BUG_ON(!pte_none(*pte));
>>  		set_pte_at(&init_mm, addr, pte, pfn_pte(pfn, prot));
>>  		pfn++;
>> -	} while (pte++, addr += PAGE_SIZE, addr != end);
>> +	} while (pte++, addr += PAGE_SIZE, addr < end && addr >= PAGE_SIZE);
>>  	return 0;
>>  }
> 
> Ble, this just overcomplicate things. Can we just make sure that the
> proper alignment is done in ioremap_page_range which is the only caller
> of this (and add VM_BUG_ON in ioremap_pud_range to make sure no new
> caller will forget about that).
> 
  this complicate express is used to avoid addr overflow, consider map
  virtual rang [0xffe00800, 0xfffff800) for 32bit machine
  actually, my previous approach is just like that you pointed mailed at 20/09
  as below, besides, i apply my previous approach for mm/vmalloc.c and 
  npiggin@gmail.com have "For API functions perhaps it's reasonable" comments
  i don't tell which is better

 diff --git a/lib/ioremap.c b/lib/ioremap.c 
 --- a/lib/ioremap.c 
 +++ b/lib/ioremap.c 
 @@ -64,7 +64,7 @@ static int ioremap_pte_range(pmd_t *pmd, unsigned long addr, 
         BUG_ON(!pte_none(*pte)); 
         set_pte_at(&init_mm, addr, pte, pfn_pte(pfn, prot)); 
         pfn++; 
 -    } while (pte++, addr += PAGE_SIZE, addr != end); 
 +    } while (pte++, addr += PAGE_SIZE, addr < end); 
     return 0; 
 } 
 
 @@ -129,6 +129,7 @@ int ioremap_page_range(unsigned long addr, 
     int err; 
 
     BUG_ON(addr >= end); 
 +   BUG_ON(!PAGE_ALIGNED(addr) || !PAGE_ALIGNED(end));
 
     start = addr; 
     phys_addr -= addr; 
 
>>  
>> @@ -129,7 +129,9 @@ int ioremap_page_range(unsigned long addr,
>>  	int err;
>>  
>>  	BUG_ON(addr >= end);
>> +	WARN_ON(!PAGE_ALIGNED(addr) || !PAGE_ALIGNED(end));
> 
> maybe WARN_ON_ONCE would be sufficient to prevent from swamping logs if
> something just happens to do this too often in some pathological path.
> 
if WARN_ON_ONCE is used, the later bad ranges for many other purposes can't
be alerted, and ioremap_page_range() can map large enough ranges so not too many
calls happens for a purpose
>>  
>> +	addr = round_down(addr, PAGE_SIZE);
> 
> 	end = round_up(end, PAGE_SIZE);
> 
> wouldn't work?
> 
no, it don't work for many special case
for example, provided  PMD_SIZE=2M
mapping [0x1f8800, 0x208800) virtual range will be split to two ranges
[0x1f8800, 0x200000) and [0x200000,0x208800) and map them separately
the first range will cause dead loop
>>  	start = addr;
>>  	phys_addr -= addr;
>>  	pgd = pgd_offset_k(addr);
>> -- 
>> 1.9.1
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
