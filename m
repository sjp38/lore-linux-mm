Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3F7F76B0253
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 06:04:54 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ag5so34313296pad.2
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 03:04:54 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id fk10si8205484pab.272.2016.08.12.03.04.52
        for <linux-mm@kvack.org>;
        Fri, 12 Aug 2016 03:04:53 -0700 (PDT)
Date: Fri, 12 Aug 2016 11:04:48 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: kmemleak: Cannot insert 0xff7f1000 into the object search tree
 (overlaps existing)
Message-ID: <20160812100447.GD12939@e104818-lin.cambridge.arm.com>
References: <7f50c137-5c6a-0882-3704-ae9bb7552c30@ti.com>
 <20160811155423.GC18366@e104818-lin.cambridge.arm.com>
 <920709c7-2d5b-ea67-5f1c-4197ef30e3b2@ti.com>
 <20160811170812.GF18366@e104818-lin.cambridge.arm.com>
 <e3495507-abf9-8df6-057d-32016bd4f221@ti.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e3495507-abf9-8df6-057d-32016bd4f221@ti.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vignesh R <vigneshr@ti.com>
Cc: "Strashko, Grygorii" <grygorii.strashko@ti.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>

On Fri, Aug 12, 2016 at 09:45:05AM +0530, Vignesh R wrote:
> On Thursday 11 August 2016 10:38 PM, Catalin Marinas wrote:
> > diff --git a/mm/memblock.c b/mm/memblock.c
> > index 483197ef613f..7d3361d53ac2 100644
> > --- a/mm/memblock.c
> > +++ b/mm/memblock.c
> > @@ -723,7 +723,8 @@ int __init_memblock memblock_free(phys_addr_t base, phys_addr_t size)
> >  		     (unsigned long long)base + size - 1,
> >  		     (void *)_RET_IP_);
> >  
> > -	kmemleak_free_part(__va(base), size);
> > +	if (base < __pa(high_memory))
> > +		kmemleak_free_part(__va(base), size);
> >  	return memblock_remove_range(&memblock.reserved, base, size);
> >  }
> >  
> > @@ -1152,7 +1153,8 @@ static phys_addr_t __init memblock_alloc_range_nid(phys_addr_t size,
> >  		 * The min_count is set to 0 so that memblock allocations are
> >  		 * never reported as leaks.
> >  		 */
> > -		kmemleak_alloc(__va(found), size, 0, 0);
> > +		if (found < __pa(high_memory))
> > +			kmemleak_alloc(__va(found), size, 0, 0);
> >  		return found;
> >  	}
> >  	return 0;
> > @@ -1399,7 +1401,8 @@ void __init __memblock_free_early(phys_addr_t base, phys_addr_t size)
> >  	memblock_dbg("%s: [%#016llx-%#016llx] %pF\n",
> >  		     __func__, (u64)base, (u64)base + size - 1,
> >  		     (void *)_RET_IP_);
> > -	kmemleak_free_part(__va(base), size);
> > +	if (base < __pa(high_memory))
> > +		kmemleak_free_part(__va(base), size);
> >  	memblock_remove_range(&memblock.reserved, base, size);
> >  }
> >  
> > @@ -1419,7 +1422,8 @@ void __init __memblock_free_late(phys_addr_t base, phys_addr_t size)
> >  	memblock_dbg("%s: [%#016llx-%#016llx] %pF\n",
> >  		     __func__, (u64)base, (u64)base + size - 1,
> >  		     (void *)_RET_IP_);
> > -	kmemleak_free_part(__va(base), size);
> > +	if (base < __pa(high_memory))
> > +		kmemleak_free_part(__va(base), size);
> >  	cursor = PFN_UP(base);
> >  	end = PFN_DOWN(base + size);
> 
> With above change on 4.8-rc1, I see a different warning from kmemleak:
> 
> [    0.002918] kmemleak: Trying to color unknown object at 0xfe800000 as
> Black
> [    0.002943] CPU: 0 PID: 0 Comm: swapper/0 Not tainted
> 4.8.0-rc1-00121-g4b9eaf33d83d-dirty #59
> [    0.002955] Hardware name: Generic AM33XX (Flattened Device Tree)
> [    0.003000] [<c01100fc>] (unwind_backtrace) from [<c010c264>] (show_stack+0x10/0x14)
> [    0.003027] [<c010c264>] (show_stack) from [<c049040c>] (dump_stack+0xac/0xe0)
> [    0.003052] [<c049040c>] (dump_stack) from [<c02971c0>] (paint_ptr+0x78/0x9c)
> [    0.003074] [<c02971c0>] (paint_ptr) from [<c0b25e20>] (kmemleak_init+0x1cc/0x284)
> [    0.003104] [<c0b25e20>] (kmemleak_init) from [<c0b00bc0>] (start_kernel+0x2d8/0x3b4)
> [    0.003122] [<c0b00bc0>] (start_kernel) from [<8000807c>] (0x8000807c)
> [    0.003133] kmemleak: Early log backtrace:
> [    0.003146]    [<c0b3c9cc>] dma_contiguous_reserve+0x80/0x94
> [    0.003170]    [<c0b06810>] arm_memblock_init+0x130/0x184
> [    0.003191]    [<c0b04210>] setup_arch+0x58c/0xc00
> [    0.003208]    [<c0b00940>] start_kernel+0x58/0x3b4
> [    0.003224]    [<8000807c>] 0x8000807c
> [    0.003239]    [<ffffffff>] 0xffffffff

That's because I missed the CMA kmemleak call:

diff --git a/mm/cma.c b/mm/cma.c
index bd0e1412475e..7c0ef3037415 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -336,7 +336,8 @@ int __init cma_declare_contiguous(phys_addr_t base,
 		 * kmemleak scans/reads tracked objects for pointers to other
 		 * objects but this address isn't mapped and accessible
 		 */
-		kmemleak_ignore(phys_to_virt(addr));
+		if (addr < __pa(high_memory))
+			kmemleak_ignore(phys_to_virt(addr));
 		base = addr;
 	}
 

Anyway, a better workaround is to add kmemleak_*_phys() static inline
functions and do the __pa(high_memory) check in there:

-----------------8<---------------------------
