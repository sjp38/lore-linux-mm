Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id EC7D76B0033
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 20:58:51 -0400 (EDT)
Message-ID: <521D4B0D.3050209@huawei.com>
Date: Wed, 28 Aug 2013 08:57:49 +0800
From: leizhen <thunder.leizhen@huawei.com>
MIME-Version: 1.0
Subject: Re: [BUG] ARM64: Create 4K page size mmu memory map at init time
 will trigger exception.
References: <BFAC7FA8F7636E45AB9ECBAC17346F3434557683@SZXEML508-MBS.china.huawei.com> <20130822161614.GE1352@arm.com> <20130823171605.GH10971@arm.com> <521C9DB3.60305@huawei.com> <20130827144823.GD27164@darko.cambridge.arm.com>
In-Reply-To: <20130827144823.GD27164@darko.cambridge.arm.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Russell King <linux@arm.linux.org.uk>, "Liujiang (Gerry)" <jiang.liu@huawei.com>, Will Deacon <Will.Deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Huxinwei <huxinwei@huawei.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Lizefan <lizefan@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On 2013/8/27 22:48, Catalin Marinas wrote:
> On Tue, Aug 27, 2013 at 01:38:11PM +0100, leizhen wrote:
>> On 2013/8/24 1:16, Catalin Marinas wrote:
>>> On Thu, Aug 22, 2013 at 05:16:14PM +0100, Catalin Marinas wrote:
>>>> On Thu, Aug 22, 2013 at 04:35:29AM +0100, Leizhen (ThunderTown, Euler) wrote:
>>>>> This problem is on ARM64. When CONFIG_ARM64_64K_PAGES is not opened, the memory
>>>>> map size can be 2M(section) and 4K(PAGE). First, OS will create map for pgd
>>>>> (level 1 table) and level 2 table which in swapper_pg_dir. Then, OS register
>>>>> mem block into memblock.memory according to memory node in fdt, like memory@0,
>>>>> and create map in setup_arch-->paging_init. If all mem block start address and
>>>>> size is integral multiple of 2M, there is no problem, because we will create 2M
>>>>> section size map whose entries locate in level 2 table. But if it is not
>>>>> integral multiple of 2M, we should create level 3 table, which granule is 4K.
>>>>> Now, current implementtion is call early_alloc-->memblock_alloc to alloc memory
>>>>> for level 3 table. This function will find a 4K free memory which locate in
>>>>> memblock.memory tail(high address), but paging_init is create map from low
>>>>> address to high address, so new alloced memory is not mapped, write page talbe
>>>>> entry to it will trigger exception.
>>>>
>>>> I see how this can happen. There is a memblock_set_current_limit to
>>>> PGDIR_SIZE (1GB, we have a pre-allocated pmd) and in my tests I had at
>>>> least 1GB of RAM which got mapped first and didn't have this problem.
>>>> I'll come up with a patch tomorrow.
>>>
>>> Could you please try this patch?
> ...
>> I test this patch on my board, it's passed. But I think there still
>> some little problem. First, we align start address and truncate last,
>> which will cause some memory wasted.
> 
> It truncates the start of the first block, which should really be
> 2MB-aligned (as per Documentation/arm64/booting.txt).
> 
>> Second, if we update current_limit after each memblock mapped, the
>> page alloced by early_alloc will be more dispersedly. So I fix this
>> bug like below:
> 
> I thought about this but was worried if some platform has a small
> initial block followed by huge blocks. I'm happy to simply limit the
> early memblock allocations to the first block and assume that it is
> large enough for other page table allocations.
> 
> Also note that this is (intermediate) physical space. Locality would
> probably help on some hardware implementations that do TLB caching of
> the stage 2 (IPA->PA) translations.
> 
>> If page size is 4K, a 4K size level 2 tables can map 1G, so 512G need
>> 512 * 4K. And max level 3 tables number is (memblock num) * 2(if both
>> head part and tail part not multiple of 2M), 2M = 256 * 2 * 4K. We
>> first alloc 2M memory, map it, then free it, and mark current_limit at
>> this boundary.
> 
> What I don't really like is that it makes assumptions about how the
> memblock allocator works. If one wants to take out every page every x MB
> you end up allocating more for level 3 tables, so the 2MB assumption no
> longer works (and I've seen this in the past to work around a hardware
> bug).
> 
> So I would rather assume that the first block is large enough and limit
> the initial allocation to this block. If anyone complains we can revisit
> it later.
> 
> So on top of my original patch:
> 
> diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
> index 49a0bc2..f557ebb 100644
> --- a/arch/arm64/mm/mmu.c
> +++ b/arch/arm64/mm/mmu.c
> @@ -335,11 +335,6 @@ static void __init map_mem(void)
>  #endif
>  
>                 create_mapping(start, __phys_to_virt(start), end - start);
> -
> -               /*
> -                * Mapping created, extend the current memblock limit.
> -                */
> -               memblock_set_current_limit(end);
>         }
>  
>         /* Limit no longer required. */
> 
> 
> .
> 


OK.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
