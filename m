Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 804436B0253
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 00:15:13 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id i64so11806136ith.2
        for <linux-mm@kvack.org>; Thu, 11 Aug 2016 21:15:13 -0700 (PDT)
Received: from comal.ext.ti.com (comal.ext.ti.com. [198.47.26.152])
        by mx.google.com with ESMTPS id o4si3038771otb.127.2016.08.11.21.15.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 11 Aug 2016 21:15:12 -0700 (PDT)
Subject: Re: kmemleak: Cannot insert 0xff7f1000 into the object search tree
 (overlaps existing)
References: <7f50c137-5c6a-0882-3704-ae9bb7552c30@ti.com>
 <20160811155423.GC18366@e104818-lin.cambridge.arm.com>
 <920709c7-2d5b-ea67-5f1c-4197ef30e3b2@ti.com>
 <20160811170812.GF18366@e104818-lin.cambridge.arm.com>
From: Vignesh R <vigneshr@ti.com>
Message-ID: <e3495507-abf9-8df6-057d-32016bd4f221@ti.com>
Date: Fri, 12 Aug 2016 09:45:05 +0530
MIME-Version: 1.0
In-Reply-To: <20160811170812.GF18366@e104818-lin.cambridge.arm.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, "Strashko, Grygorii" <grygorii.strashko@ti.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>

Hi Catalin,

Thanks for the response!

On Thursday 11 August 2016 10:38 PM, Catalin Marinas wrote:
> On Thu, Aug 11, 2016 at 07:48:12PM +0300, Grygorii Strashko wrote:
>> On 08/11/2016 06:54 PM, Catalin Marinas wrote:
>>> On Thu, Aug 11, 2016 at 05:20:51PM +0530, Vignesh R wrote:
>>>> I see the below message from kmemleak when booting linux-next on AM335x
>>>> GP EVM and DRA7 EVM
>>>
>>> Can you also reproduce it with 4.8-rc1?

Yes, I can reproduce this on 4.8.0-rc1-g4b9eaf33d83d

[...]
> 
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 483197ef613f..7d3361d53ac2 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -723,7 +723,8 @@ int __init_memblock memblock_free(phys_addr_t base, phys_addr_t size)
>  		     (unsigned long long)base + size - 1,
>  		     (void *)_RET_IP_);
>  
> -	kmemleak_free_part(__va(base), size);
> +	if (base < __pa(high_memory))
> +		kmemleak_free_part(__va(base), size);
>  	return memblock_remove_range(&memblock.reserved, base, size);
>  }
>  
> @@ -1152,7 +1153,8 @@ static phys_addr_t __init memblock_alloc_range_nid(phys_addr_t size,
>  		 * The min_count is set to 0 so that memblock allocations are
>  		 * never reported as leaks.
>  		 */
> -		kmemleak_alloc(__va(found), size, 0, 0);
> +		if (found < __pa(high_memory))
> +			kmemleak_alloc(__va(found), size, 0, 0);
>  		return found;
>  	}
>  	return 0;
> @@ -1399,7 +1401,8 @@ void __init __memblock_free_early(phys_addr_t base, phys_addr_t size)
>  	memblock_dbg("%s: [%#016llx-%#016llx] %pF\n",
>  		     __func__, (u64)base, (u64)base + size - 1,
>  		     (void *)_RET_IP_);
> -	kmemleak_free_part(__va(base), size);
> +	if (base < __pa(high_memory))
> +		kmemleak_free_part(__va(base), size);
>  	memblock_remove_range(&memblock.reserved, base, size);
>  }
>  
> @@ -1419,7 +1422,8 @@ void __init __memblock_free_late(phys_addr_t base, phys_addr_t size)
>  	memblock_dbg("%s: [%#016llx-%#016llx] %pF\n",
>  		     __func__, (u64)base, (u64)base + size - 1,
>  		     (void *)_RET_IP_);
> -	kmemleak_free_part(__va(base), size);
> +	if (base < __pa(high_memory))
> +		kmemleak_free_part(__va(base), size);
>  	cursor = PFN_UP(base);
>  	end = PFN_DOWN(base + size);
>  
> 

With above change on 4.8-rc1, I see a different warning from kmemleak:

[    0.002918] kmemleak: Trying to color unknown object at 0xfe800000 as
Black
[    0.002943] CPU: 0 PID: 0 Comm: swapper/0 Not tainted
4.8.0-rc1-00121-g4b9eaf33d83d-dirty #59
[    0.002955] Hardware name: Generic AM33XX (Flattened Device Tree)
[    0.003000] [<c01100fc>] (unwind_backtrace) from [<c010c264>]
(show_stack+0x10/0x14)
[    0.003027] [<c010c264>] (show_stack) from [<c049040c>]
(dump_stack+0xac/0xe0)
[    0.003052] [<c049040c>] (dump_stack) from [<c02971c0>]
(paint_ptr+0x78/0x9c)
[    0.003074] [<c02971c0>] (paint_ptr) from [<c0b25e20>]
(kmemleak_init+0x1cc/0x284)
[    0.003104] [<c0b25e20>] (kmemleak_init) from [<c0b00bc0>]
(start_kernel+0x2d8/0x3b4)
[    0.003122] [<c0b00bc0>] (start_kernel) from [<8000807c>] (0x8000807c)
[    0.003133] kmemleak: Early log backtrace:
[    0.003146]    [<c0b3c9cc>] dma_contiguous_reserve+0x80/0x94
[    0.003170]    [<c0b06810>] arm_memblock_init+0x130/0x184
[    0.003191]    [<c0b04210>] setup_arch+0x58c/0xc00
[    0.003208]    [<c0b00940>] start_kernel+0x58/0x3b4
[    0.003224]    [<8000807c>] 0x8000807c
[    0.003239]    [<ffffffff>] 0xffffffff

Full boot log: http://pastebin.ubuntu.com/23048180/

-- 
Thanks
Vignesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
