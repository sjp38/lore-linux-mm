Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3F6656B0282
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 04:45:54 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id w84so10406560wmg.1
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 01:45:54 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id b2si6493666wji.269.2016.09.23.01.45.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Sep 2016 01:45:53 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id 133so1600509wmq.2
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 01:45:52 -0700 (PDT)
Date: Fri, 23 Sep 2016 10:45:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/1] lib/ioremap.c: avoid endless loop under ioremapping
 page unaligned ranges
Message-ID: <20160923084551.GG4478@dhcp22.suse.cz>
References: <57E20A69.5010206@zoho.com>
 <20160922124735.GB11204@dhcp22.suse.cz>
 <35661a34-c3e0-0ec2-b58f-ee59bef4e4d4@zoho.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <35661a34-c3e0-0ec2-b58f-ee59bef4e4d4@zoho.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zijun_hu <zijun_hu@zoho.com>
Cc: zijun_hu@htc.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tj@kernel.org, mingo@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net

On Thu 22-09-16 23:13:17, zijun_hu wrote:
> On 2016/9/22 20:47, Michal Hocko wrote:
> > On Wed 21-09-16 12:19:53, zijun_hu wrote:
> >> From: zijun_hu <zijun_hu@htc.com>
> >>
> >> endless loop maybe happen if either of parameter addr and end is not
> >> page aligned for kernel API function ioremap_page_range()
> > 
> > Does this happen in practise or this you found it by reading the code?
> > 
> i found it by reading the code, this is a kernel API function and there
> are no enough hint for parameter requirements, so any parameters
> combination maybe be used by user, moreover, it seems appropriate for
> many bad parameter combination, for example, provided  PMD_SIZE=2M and
> PAGE_SIZE=4K, 0x00 is used for aligned very well address
> a user maybe want to map virtual range[0x1ff800, 0x200800) to physical address
> 0x300800, it will cause endless loop

Well, we are relying on the kernel to do the sane thing otherwise we
would be screwed anyway. If this can be triggered by a userspace then it
would be a different story. Just look at how we are doing mmap, we
sanitize the page alignment at the high level and the lower level
functions just assume sane values.

> >> in order to fix this issue and alert improper range parameters to user
> >> WARN_ON() checkup and rounding down range lower boundary are performed
> >> firstly, loop end condition within ioremap_pte_range() is optimized due
> >> to lack of relevant macro pte_addr_end()
> >>
> >> Signed-off-by: zijun_hu <zijun_hu@htc.com>
> >> ---
> >>  lib/ioremap.c | 4 +++-
> >>  1 file changed, 3 insertions(+), 1 deletion(-)
> >>
> >> diff --git a/lib/ioremap.c b/lib/ioremap.c
> >> index 86c8911..911bdca 100644
> >> --- a/lib/ioremap.c
> >> +++ b/lib/ioremap.c
> >> @@ -64,7 +64,7 @@ static int ioremap_pte_range(pmd_t *pmd, unsigned long addr,
> >>  		BUG_ON(!pte_none(*pte));
> >>  		set_pte_at(&init_mm, addr, pte, pfn_pte(pfn, prot));
> >>  		pfn++;
> >> -	} while (pte++, addr += PAGE_SIZE, addr != end);
> >> +	} while (pte++, addr += PAGE_SIZE, addr < end && addr >= PAGE_SIZE);
> >>  	return 0;
> >>  }
> > 
> > Ble, this just overcomplicate things. Can we just make sure that the
> > proper alignment is done in ioremap_page_range which is the only caller
> > of this (and add VM_BUG_ON in ioremap_pud_range to make sure no new
> > caller will forget about that).
> > 
>   this complicate express is used to avoid addr overflow, consider map
>   virtual rang [0xffe00800, 0xfffff800) for 32bit machine
>   actually, my previous approach is just like that you pointed mailed at 20/09
>   as below, besides, i apply my previous approach for mm/vmalloc.c and 
>   npiggin@gmail.com have "For API functions perhaps it's reasonable" comments
>   i don't tell which is better
> 
>  diff --git a/lib/ioremap.c b/lib/ioremap.c 
>  --- a/lib/ioremap.c 
>  +++ b/lib/ioremap.c 
>  @@ -64,7 +64,7 @@ static int ioremap_pte_range(pmd_t *pmd, unsigned long addr, 
>          BUG_ON(!pte_none(*pte)); 
>          set_pte_at(&init_mm, addr, pte, pfn_pte(pfn, prot)); 
>          pfn++; 
>  -    } while (pte++, addr += PAGE_SIZE, addr != end); 
>  +    } while (pte++, addr += PAGE_SIZE, addr < end); 
>      return 0; 
>  } 

yes this looks good to me

>  
>  @@ -129,6 +129,7 @@ int ioremap_page_range(unsigned long addr, 
>      int err; 
>  
>      BUG_ON(addr >= end); 
>  +   BUG_ON(!PAGE_ALIGNED(addr) || !PAGE_ALIGNED(end));

Well, BUG_ON is rather harsh for something that would be trivially
fixable.

>  
>      start = addr; 
>      phys_addr -= addr; 
>  
> >>  
> >> @@ -129,7 +129,9 @@ int ioremap_page_range(unsigned long addr,
> >>  	int err;
> >>  
> >>  	BUG_ON(addr >= end);
> >> +	WARN_ON(!PAGE_ALIGNED(addr) || !PAGE_ALIGNED(end));
> > 
> > maybe WARN_ON_ONCE would be sufficient to prevent from swamping logs if
> > something just happens to do this too often in some pathological path.
> > 
> if WARN_ON_ONCE is used, the later bad ranges for many other purposes can't
> be alerted, and ioremap_page_range() can map large enough ranges so not too many
> calls happens for a purpose
> >>  
> >> +	addr = round_down(addr, PAGE_SIZE);
> > 
> > 	end = round_up(end, PAGE_SIZE);
> > 
> > wouldn't work?
> > 
> no, it don't work for many special case
> for example, provided  PMD_SIZE=2M
> mapping [0x1f8800, 0x208800) virtual range will be split to two ranges
> [0x1f8800, 0x200000) and [0x200000,0x208800) and map them separately
> the first range will cause dead loop

I am not sure I see your point. How can we deadlock if _both_ addresses
get aligned to the page boundary and how does PMD_SIZE make any
difference.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
