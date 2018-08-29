Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id C4F6B6B4C59
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 11:16:34 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id u22-v6so4626166qkk.10
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 08:16:34 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g130-v6sor2054692qka.111.2018.08.29.08.16.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 Aug 2018 08:16:33 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm: zero remaining unavailable struct pages
References: <20180823182513.8801-1-msys.mizuma@gmail.com>
 <20180823182513.8801-2-msys.mizuma@gmail.com>
 <7c773dec-ded0-7a1e-b3ad-6c6826851015@microsoft.com>
From: Masayoshi Mizuma <msys.mizuma@gmail.com>
Message-ID: <484388a7-1e75-0782-fdfb-20345e1bda0d@gmail.com>
Date: Wed, 29 Aug 2018 11:16:30 -0400
MIME-Version: 1.0
In-Reply-To: <7c773dec-ded0-7a1e-b3ad-6c6826851015@microsoft.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel.Tatashin@microsoft.com, linux-mm@kvack.org, n-horiguchi@ah.jp.nec.com, mhocko@kernel.org
Cc: linux-kernel@vger.kernel.org, x86@kernel.org

Hi Horiguchi-san and Pavel

Thank you for your comments!
The Pavel's additional patch looks good to me, so I will add it to this series.

However, unfortunately, the movable_node option has something wrong yet...
When I offline the memory which belongs to movable zone, I got the following
warning. I'm trying to debug it.

I try to describe the issue as following. 
If you have any comments, please let me know.

WARNING: CPU: 156 PID: 25611 at mm/page_alloc.c:7730 has_unmovable_pages+0x1bf/0x200
RIP: 0010:has_unmovable_pages+0x1bf/0x200
...
Call Trace:
 is_mem_section_removable+0xd3/0x160
 show_mem_removable+0x8e/0xb0
 dev_attr_show+0x1c/0x50
 sysfs_kf_seq_show+0xb3/0x110
 seq_read+0xee/0x480
 __vfs_read+0x36/0x190
 vfs_read+0x89/0x130
 ksys_read+0x52/0xc0
 do_syscall_64+0x5b/0x180
 entry_SYSCALL_64_after_hwframe+0x44/0xa9
RIP: 0033:0x7fe7b7823f70
...

I added a printk to catch the unmovable page.
---
@@ -7713,8 +7719,12 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
                 * is set to both of a memory hole page and a _used_ kernel
                 * page at boot.
                 */
-               if (found > count)
+               if (found > count) {
+                       pr_info("DEBUG: %s zone: %lx page: %lx pfn: %lx flags: %lx found: %ld count: %ld \n",
+                               __func__, zone, page, page_to_pfn(page), page->flags, found, count);
                        goto unmovable;
+               }
---

Then I got the following. The page (PFN: 0x1c0ff130d) flag is 
0xdfffffc0040048 (uptodate|active|swapbacked)

---
DEBUG: has_unmovable_pages zone: 0xffff8c0ffff80380 page: 0xffffea703fc4c340 pfn: 0x1c0ff130d flags: 0xdfffffc0040048 found: 1 count: 0 
---

And I got the owner from /sys/kernel/debug/page_owner.

Page allocated via order 0, mask 0x6280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO)
PFN 7532909325 type Movable Block 14712713 type Movable Flags 0xdfffffc0040048(uptodate|active|swapbacked)
 __alloc_pages_nodemask+0xfc/0x270
 alloc_pages_vma+0x7c/0x1e0
 handle_pte_fault+0x399/0xe50
 __handle_mm_fault+0x38e/0x520
 handle_mm_fault+0xdc/0x210
 __do_page_fault+0x243/0x4c0
 do_page_fault+0x31/0x130
 page_fault+0x1e/0x30

The page is allocated as anonymous page via page fault.
I'm not sure, but lru flag should be added to the page...?

Thanks,
Masa

On 08/27/2018 07:33 PM, Pasha Tatashin wrote:
> On 8/23/18 2:25 PM, Masayoshi Mizuma wrote:
>> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>>
>> There is a kernel panic that is triggered when reading /proc/kpageflags
>> on the kernel booted with kernel parameter 'memmap=nn[KMG]!ss[KMG]':
>>
>>   BUG: unable to handle kernel paging request at fffffffffffffffe
>>   PGD 9b20e067 P4D 9b20e067 PUD 9b210067 PMD 0
>>   Oops: 0000 [#1] SMP PTI
>>   CPU: 2 PID: 1728 Comm: page-types Not tainted 4.17.0-rc6-mm1-v4.17-rc6-180605-0816-00236-g2dfb086ef02c+ #160
>>   Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.11.0-2.fc28 04/01/2014
>>   RIP: 0010:stable_page_flags+0x27/0x3c0
>>   Code: 00 00 00 0f 1f 44 00 00 48 85 ff 0f 84 a0 03 00 00 41 54 55 49 89 fc 53 48 8b 57 08 48 8b 2f 48 8d 42 ff 83 e2 01 48 0f 44 c7 <48> 8b 00 f6 c4 01 0f 84 10 03 00 00 31 db 49 8b 54 24 08 4c 89 e7
>>   RSP: 0018:ffffbbd44111fde0 EFLAGS: 00010202
>>   RAX: fffffffffffffffe RBX: 00007fffffffeff9 RCX: 0000000000000000
>>   RDX: 0000000000000001 RSI: 0000000000000202 RDI: ffffed1182fff5c0
>>   RBP: ffffffffffffffff R08: 0000000000000001 R09: 0000000000000001
>>   R10: ffffbbd44111fed8 R11: 0000000000000000 R12: ffffed1182fff5c0
>>   R13: 00000000000bffd7 R14: 0000000002fff5c0 R15: ffffbbd44111ff10
>>   FS:  00007efc4335a500(0000) GS:ffff93a5bfc00000(0000) knlGS:0000000000000000
>>   CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>>   CR2: fffffffffffffffe CR3: 00000000b2a58000 CR4: 00000000001406e0
>>   Call Trace:
>>    kpageflags_read+0xc7/0x120
>>    proc_reg_read+0x3c/0x60
>>    __vfs_read+0x36/0x170
>>    vfs_read+0x89/0x130
>>    ksys_pread64+0x71/0x90
>>    do_syscall_64+0x5b/0x160
>>    entry_SYSCALL_64_after_hwframe+0x44/0xa9
>>   RIP: 0033:0x7efc42e75e23
>>   Code: 09 00 ba 9f 01 00 00 e8 ab 81 f4 ff 66 2e 0f 1f 84 00 00 00 00 00 90 83 3d 29 0a 2d 00 00 75 13 49 89 ca b8 11 00 00 00 0f 05 <48> 3d 01 f0 ff ff 73 34 c3 48 83 ec 08 e8 db d3 01 00 48 89 04 24
>>
>> According to kernel bisection, this problem became visible due to commit
>> f7f99100d8d9 which changes how struct pages are initialized.
>>
>> Memblock layout affects the pfn ranges covered by node/zone. Consider
>> that we have a VM with 2 NUMA nodes and each node has 4GB memory, and
>> the default (no memmap= given) memblock layout is like below:
>>
>>   MEMBLOCK configuration:
>>    memory size = 0x00000001fff75c00 reserved size = 0x000000000300c000
>>    memory.cnt  = 0x4
>>    memory[0x0]     [0x0000000000001000-0x000000000009efff], 0x000000000009e000 bytes on node 0 flags: 0x0
>>    memory[0x1]     [0x0000000000100000-0x00000000bffd6fff], 0x00000000bfed7000 bytes on node 0 flags: 0x0
>>    memory[0x2]     [0x0000000100000000-0x000000013fffffff], 0x0000000040000000 bytes on node 0 flags: 0x0
>>    memory[0x3]     [0x0000000140000000-0x000000023fffffff], 0x0000000100000000 bytes on node 1 flags: 0x0
>>    ...
>>
>> If you give memmap=1G!4G (so it just covers memory[0x2]),
>> the range [0x100000000-0x13fffffff] is gone:
>>
>>   MEMBLOCK configuration:
>>    memory size = 0x00000001bff75c00 reserved size = 0x000000000300c000
>>    memory.cnt  = 0x3
>>    memory[0x0]     [0x0000000000001000-0x000000000009efff], 0x000000000009e000 bytes on node 0 flags: 0x0
>>    memory[0x1]     [0x0000000000100000-0x00000000bffd6fff], 0x00000000bfed7000 bytes on node 0 flags: 0x0
>>    memory[0x2]     [0x0000000140000000-0x000000023fffffff], 0x0000000100000000 bytes on node 1 flags: 0x0
>>    ...
>>
>> This causes shrinking node 0's pfn range because it is calculated by
>> the address range of memblock.memory. So some of struct pages in the
>> gap range are left uninitialized.
>>
>> We have a function zero_resv_unavail() which does zeroing the struct
>> pages outside memblock.memory, but currently it covers only the reserved
>> unavailable range (i.e. memblock.memory && !memblock.reserved).
>> This patch extends it to cover all unavailable range, which fixes
>> the reported issue.
>>
>> Fixes: f7f99100d8d9 ("mm: stop zeroing memory during allocation in vmemmap")
>> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> Tested-by: Oscar Salvador <osalvador@suse.de>
>> Tested-by: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>
> 
> Reviewed-by: Pavel Tatashin <pavel.tatashin@microsoft.com>
> 
> Also, please review and add the following patch to this series:
> 
> From 6d23e66e979244734a06c1b636742c2568121b39 Mon Sep 17 00:00:00 2001
> From: Pavel Tatashin <pavel.tatashin@microsoft.com>
> Date: Mon, 27 Aug 2018 19:10:35 -0400
> Subject: [PATCH] mm: return zero_resv_unavail optimization
> 
> When checking for valid pfns in zero_resv_unavail(), it is not necessary to
> verify that pfns within pageblock_nr_pages ranges are valid, only the first
> one needs to be checked. This is because memory for pages are allocated in
> contiguous chunks that contain pageblock_nr_pages struct pages.
> 
> Signed-off-by: Pavel Tatashin <pavel.tatashin@microsoft.com>
> ---
>  mm/page_alloc.c | 46 ++++++++++++++++++++++++++--------------------
>  1 file changed, 26 insertions(+), 20 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 650d8f16a67e..5dfc206db40e 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -6441,6 +6441,29 @@ void __init free_area_init_node(int nid, unsigned long *zones_size,
>  }
>  
>  #if defined(CONFIG_HAVE_MEMBLOCK) && !defined(CONFIG_FLAT_NODE_MEM_MAP)
> +
> +/*
> + * Zero all valid struct pages in range [spfn, epfn), return number of struct
> + * pages zeroed
> + */
> +static u64 zero_pfn_range(unsigned long spfn, unsigned long epfn)
> +{
> +	unsigned long pfn;
> +	u64 pgcnt = 0;
> +
> +	for (pfn = spfn; pfn < epfn; pfn++) {
> +		if (!pfn_valid(ALIGN_DOWN(pfn, pageblock_nr_pages))) {
> +			pfn = ALIGN_DOWN(pfn, pageblock_nr_pages)
> +				+ pageblock_nr_pages - 1;
> +			continue;
> +		}
> +		mm_zero_struct_page(pfn_to_page(pfn));
> +		pgcnt++;
> +	}
> +
> +	return pgcnt;
> +}
> +
>  /*
>   * Only struct pages that are backed by physical memory are zeroed and
>   * initialized by going through __init_single_page(). But, there are some
> @@ -6456,7 +6479,6 @@ void __init free_area_init_node(int nid, unsigned long *zones_size,
>  void __init zero_resv_unavail(void)
>  {
>  	phys_addr_t start, end;
> -	unsigned long pfn;
>  	u64 i, pgcnt;
>  	phys_addr_t next = 0;
>  
> @@ -6466,34 +6488,18 @@ void __init zero_resv_unavail(void)
>  	pgcnt = 0;
>  	for_each_mem_range(i, &memblock.memory, NULL,
>  			NUMA_NO_NODE, MEMBLOCK_NONE, &start, &end, NULL) {
> -		if (next < start) {
> -			for (pfn = PFN_DOWN(next); pfn < PFN_UP(start); pfn++) {
> -				if (!pfn_valid(ALIGN_DOWN(pfn, pageblock_nr_pages)))
> -					continue;
> -				mm_zero_struct_page(pfn_to_page(pfn));
> -				pgcnt++;
> -			}
> -		}
> +		if (next < start)
> +			pgcnt += zero_pfn_range(PFN_DOWN(next), PFN_UP(start));
>  		next = end;
>  	}
> -	for (pfn = PFN_DOWN(next); pfn < max_pfn; pfn++) {
> -		if (!pfn_valid(ALIGN_DOWN(pfn, pageblock_nr_pages)))
> -			continue;
> -		mm_zero_struct_page(pfn_to_page(pfn));
> -		pgcnt++;
> -	}
> -
> +	pgcnt += zero_pfn_range(PFN_DOWN(next), max_pfn);
>  
>  	/*
>  	 * Struct pages that do not have backing memory. This could be because
>  	 * firmware is using some of this memory, or for some other reasons.
> -	 * Once memblock is changed so such behaviour is not allowed: i.e.
> -	 * list of "reserved" memory must be a subset of list of "memory", then
> -	 * this code can be removed.
>  	 */
>  	if (pgcnt)
>  		pr_info("Zeroed struct page in unavailable ranges: %lld pages", pgcnt);
> -
>  }
>  #endif /* CONFIG_HAVE_MEMBLOCK && !CONFIG_FLAT_NODE_MEM_MAP */
>  
> 
