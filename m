Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id A49C56B00A1
	for <linux-mm@kvack.org>; Wed, 12 Mar 2014 09:38:42 -0400 (EDT)
Received: by mail-we0-f182.google.com with SMTP id p61so11340247wes.13
        for <linux-mm@kvack.org>; Wed, 12 Mar 2014 06:38:42 -0700 (PDT)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id db4si23845407wjb.69.2014.03.12.06.38.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 12 Mar 2014 06:38:40 -0700 (PDT)
Date: Wed, 12 Mar 2014 13:38:06 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCHv4 2/2] arm: Get rid of meminfo
Message-ID: <20140312133806.GH21483@n2100.arm.linux.org.uk>
References: <1392761733-32628-1-git-send-email-lauraa@codeaurora.org> <1392761733-32628-3-git-send-email-lauraa@codeaurora.org> <20140312085401.GB21483@n2100.arm.linux.org.uk> <53205CA1.1090502@ti.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53205CA1.1090502@ti.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Grygorii Strashko <grygorii.strashko@ti.com>
Cc: Laura Abbott <lauraa@codeaurora.org>, David Brown <davidb@codeaurora.org>, Daniel Walker <dwalker@fifo99.com>, Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>, Eric Miao <eric.y.miao@gmail.com>, Haojian Zhuang <haojian.zhuang@gmail.com>, Ben Dooks <ben-linux@fluff.org>, Kukjin Kim <kgene.kim@samsung.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, Leif Lindholm <leif.lindholm@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Rob Herring <robherring2@gmail.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Nicolas Pitre <nicolas.pitre@linaro.org>, Santosh Shilimkar <santosh.shilimkar@ti.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Courtney Cavin <courtney.cavin@sonymobile.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Grant Likely <grant.likely@secretlab.ca>

On Wed, Mar 12, 2014 at 03:09:53PM +0200, Grygorii Strashko wrote:
> Hi Russell,
>
> On 03/12/2014 10:54 AM, Russell King - ARM Linux wrote:
>> On Tue, Feb 18, 2014 at 02:15:33PM -0800, Laura Abbott wrote:
>>> memblock is now fully integrated into the kernel and is the prefered
>>> method for tracking memory. Rather than reinvent the wheel with
>>> meminfo, migrate to using memblock directly instead of meminfo as
>>> an intermediate.
>>>
>>> Acked-by: Jason Cooper <jason@lakedaemon.net>
>>> Acked-by: Catalin Marinas <catalin.marinas@arm.com>
>>> Acked-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
>>> Acked-by: Kukjin Kim <kgene.kim@samsung.com>
>>> Tested-by: Marek Szyprowski <m.szyprowski@samsung.com>
>>> Tested-by: Leif Lindholm <leif.lindholm@linaro.org>
>>> Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
>>
>> Laura,
>>
>> This patch causes a bunch of platforms to no longer boot - imx6solo with
>> 1GB of RAM boots, imx6q with 2GB of RAM doesn't.  Versatile Express doesn't.
>>
>> The early printk messages don't reveal anything too interesting:
>>
>> Booting Linux on physical CPU 0x0
>> Linux version 3.14.0-rc6+ (rmk@rmk-PC.arm.linux.org.uk) (gcc version 4.6.4 (GCC) ) #630 SMP Wed Mar 12 01:13:36 GMT 2014
>> CPU: ARMv7 Processor [412fc09a] revision 10 (ARMv7), cr=10c53c7d
>> CPU: PIPT / VIPT nonaliasing data cache, VIPT aliasing instruction cache
>> Machine model: SolidRun Cubox-i Dual/Quad
>> cma: CMA: reserved 64 MiB at 8c000000
>> Memory policy: Data cache writealloc
>> <hang>
>>
>> vs.
>>
>> Booting Linux on physical CPU 0x0
>> Linux version 3.14.0-rc6+ (rmk@rmk-PC.arm.linux.org.uk) (gcc version 4.6.4 (GCC) ) #631 SMP Wed Mar 12 01:15:37 GMT 2014
>> CPU: ARMv7 Processor [412fc09a] revision 10 (ARMv7), cr=10c53c7d
>> CPU: PIPT / VIPT nonaliasing data cache, VIPT aliasing instruction cache
>> Machine model: SolidRun Cubox-i Dual/Quad
>> cma: CMA: reserved 64 MiB at 3b800000
>> Memory policy: Data cache writealloc
>> On node 0 totalpages: 524288
>> free_area_init_node: node 0, pgdat c09d0240, node_mem_map ea7d8000
>>    Normal zone: 1520 pages used for memmap
>>    Normal zone: 0 pages reserved
>>    Normal zone: 194560 pages, LIFO batch:31
>>    HighMem zone: 2576 pages used for memmap
>>    HighMem zone: 329728 pages, LIFO batch:31
>> ...
>>
>> The only obvious difference is the address of that CMA reservation,
>> CMA shouldn't make a difference here - but I suspect that other
>> allocations which need to be in lowmem probably aren't.
>>
>
> Could it be possible to enable memblock debug by adding "memblock=debug"  
> in cmdline?

Here's with Laura's patch:

Uncompressing Linux... done, booting the kernel.
Booting Linux on physical CPU 0x0
Linux version 3.14.0-rc6+ (rmk@rmk-PC.arm.linux.org.uk) (gcc version 4.6.4 (GCC) ) #633 SMP Wed Mar 12 12:56:15 GMT 2014
CPU: ARMv7 Processor [412fc09a] revision 10 (ARMv7), cr=10c53c7d
CPU: PIPT / VIPT nonaliasing data cache, VIPT aliasing instruction cache
Machine model: SolidRun Cubox-i Dual/Quad
memblock_reserve: [0x00000010008240-0x0000001112c1f7] flags 0x0 arm_memblock_init+0x28/0x1a8
memblock_reserve: [0x00000020000040-0x000000201caa57] flags 0x0 arm_memblock_init+0x108/0x1a8
memblock_reserve: [0x00000010004000-0x00000010007fff] flags 0x0 arm_mm_memblock_reserve+0x1c/0x24
memblock_reserve: [0x00000018000000-0x0000001800b07f] flags 0x0 arm_dt_memblock_reserve+0x2c/0x70
memblock_reserve: [0x00000018000000-0x0000001800afff] flags 0x0 arm_dt_memblock_reserve+0x68/0x70
memblock_reserve: [0x00000020000040-0x000000201caa57] flags 0x0 arm_dt_memblock_reserve+0x68/0x70
memblock_reserve: [0x0000008c000000-0x0000008fffffff] flags 0x0 memblock_alloc_base_nid+0x40/0x54
cma: CMA: reserved 64 MiB at 8c000000
MEMBLOCK configuration:
 memory size = 0x80000000 reserved size = 0x52fda50
 memory.cnt  = 0x1
 memory[0x0]   [0x00000010000000-0x0000008fffffff], 0x80000000 bytes flags: 0x06
 reserved.cnt  = 0x5
 reserved[0x0] [0x00000010004000-0x00000010007fff], 0x4000 bytes flags: 0x0
 reserved[0x1] [0x00000010008240-0x0000001112c1f7], 0x1123fb8 bytes flags: 0x0
 reserved[0x2] [0x00000018000000-0x0000001800b07f], 0xb080 bytes flags: 0x0
 reserved[0x3] [0x00000020000040-0x000000201caa57], 0x1caa18 bytes flags: 0x0
 reserved[0x4] [0x0000008c000000-0x0000008fffffff], 0x4000000 bytes flags: 0x0
Memory policy: Data cache writealloc
memblock_reserve: [0x0000008bffffd8-0x0000008bffffff] flags 0x0 memblock_alloc_base_nid+0x40/0x54

Here's without:

Booting Linux on physical CPU 0x0
Linux version 3.14.0-rc6+ (rmk@rmk-PC.arm.linux.org.uk) (gcc version 4.6.4 (GCC) ) #635 SMP Wed Mar 12 13:22:15 GMT 2014
CPU: ARMv7 Processor [412fc09a] revision 10 (ARMv7), cr=10c53c7d
CPU: PIPT / VIPT nonaliasing data cache, VIPT aliasing instruction cache
Machine model: SolidRun Cubox-i Dual/Quad
memblock_reserve: [0x00000010008240-0x0000001112c277] flags 0x0 arm_memblock_init+0x54/0x1d4
memblock_reserve: [0x00000020000040-0x000000201caa57] flags 0x0 arm_memblock_init+0x134/0x1d4
memblock_reserve: [0x00000010004000-0x00000010007fff] flags 0x0 arm_mm_memblock_reserve+0x1c/0x24
memblock_reserve: [0x00000018000000-0x0000001800b07f] flags 0x0 arm_dt_memblock_reserve+0x2c/0x70
memblock_reserve: [0x00000018000000-0x0000001800afff] flags 0x0 arm_dt_memblock_reserve+0x68/0x70
memblock_reserve: [0x00000020000040-0x000000201caa57] flags 0x0 arm_dt_memblock_reserve+0x68/0x70
memblock_reserve: [0x0000003b800000-0x0000003f7fffff] flags 0x0 memblock_alloc_base_nid+0x40/0x54
cma: CMA: reserved 64 MiB at 3b800000
MEMBLOCK configuration:
 memory size = 0x80000000 reserved size = 0x52fdad0
 memory.cnt  = 0x1
 memory[0x0]     [0x00000010000000-0x0000008fffffff], 0x80000000 bytes flags: 0x0
 reserved.cnt  = 0x5
 reserved[0x0]   [0x00000010004000-0x00000010007fff], 0x4000 bytes flags: 0x0
 reserved[0x1]   [0x00000010008240-0x0000001112c277], 0x1124038 bytes flags: 0x0
 reserved[0x2]   [0x00000018000000-0x0000001800b07f], 0xb080 bytes flags: 0x0
 reserved[0x3]   [0x00000020000040-0x000000201caa57], 0x1caa18 bytes flags: 0x0
 reserved[0x4]   [0x0000003b800000-0x0000003f7fffff], 0x4000000 bytes flags: 0x0
Memory policy: Data cache writealloc
memblock_reserve: [0x0000003b7fffd8-0x0000003b7fffff] flags 0x0 memblock_alloc_base_nid+0x40/0x54
memblock_reserve: [0x0000003b7fe000-0x0000003b7fefff] flags 0x0 memblock_alloc_base_nid+0x40/0x54
memblock_reserve: [0x0000003b7fd000-0x0000003b7fdfff] flags 0x0 memblock_alloc_base_nid+0x40/0x54
memblock_reserve: [0x0000003b7fc000-0x0000003b7fcfff] flags 0x0 memblock_alloc_base_nid+0x40/0x54
...

So it looks like allocations which must come from lowmem aren't being
limited to lowmem.

Try booting a machine with 2G of RAM with page offset set to 3GB and
highmem enabled - it will fail as per the above.

In fact, if we look at sanity_check_meminfo() post that patch, it's
clearly wrong:

        for_each_memblock(memory, reg) {
                phys_addr_t block_start = reg->base;
                phys_addr_t block_end = reg->base + reg->size;
                phys_addr_t size_limit = reg->size;

                if (reg->base >= vmalloc_limit)
                        highmem = 1;
                else
                        size_limit = vmalloc_limit - reg->base;
...
                if (!highmem) {
                        if (block_end > arm_lowmem_limit)
                                arm_lowmem_limit = block_end;
...
                }
        }

        high_memory = __va(arm_lowmem_limit - 1) + 1;

What this appears to assume is that each block of memory in memblock is
either totally in lowmem, or totally in highmem.  This is not the case
most of the time - blocks are most often split in two.

Apart from that, there's other problems:

        for_each_memblock (memory, reg) {
                unsigned int pfn1, pfn2;
                struct page *page, *end;

                pfn1 = memblock_region_memory_base_pfn(reg);
                pfn2 = memblock_region_memory_end_pfn(reg);

                page = pfn_to_page(pfn1);
                end  = pfn_to_page(pfn2 - 1) + 1;

                do {
			... dereference page ...
                        page++;
                } while (page < end);
        }

Since memblock coalesces memory ranges together, when sparsemem is
enabled, page...end may not be a continuous range of struct page
entries: they can be in different sparsemem banks.  That's precisely
why I never meminfo, because this split information is lost as soon
as you push over to memblock - two meminfo banks which are contiguous
are combined into one block by memblock and are not kept separate.

I made this point on 15th January, and that point remains valid and
unaddressed.

-- 
FTTC broadband for 0.8mile line: now at 9.7Mbps down 460kbps up... slowly
improving, and getting towards what was expected from it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
