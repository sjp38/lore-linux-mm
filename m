Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 6A44C6B0072
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 02:00:12 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id kx1so1309706pab.0
        for <linux-mm@kvack.org>; Wed, 03 Apr 2013 23:00:11 -0700 (PDT)
Message-ID: <515D16E4.8020207@gmail.com>
Date: Thu, 04 Apr 2013 14:00:04 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH -V5 00/25] THP support for PPC64
References: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Hi Aneesh,
On 04/04/2013 01:57 PM, Aneesh Kumar K.V wrote:
> Hi,
>
> This patchset adds transparent hugepage support for PPC64.
>
> TODO:
> * hash preload support in update_mmu_cache_pmd (we don't do that for hugetlb)
>
> Some numbers:
>
> The latency measurements code from Anton  found at
> http://ozlabs.org/~anton/junkcode/latency2001.c

Is there test case against x86?

>
> THP disabled 64K page size
> ------------------------
> [root@llmp24l02 ~]# ./latency2001 8G
>   8589934592    731.73 cycles    205.77 ns
> [root@llmp24l02 ~]# ./latency2001 8G
>   8589934592    743.39 cycles    209.05 ns
> [root@llmp24l02 ~]#
>
> THP disabled large page via hugetlbfs
> -------------------------------------
> [root@llmp24l02 ~]# ./latency2001  -l 8G
>   8589934592    416.09 cycles    117.01 ns
> [root@llmp24l02 ~]# ./latency2001  -l 8G
>   8589934592    415.74 cycles    116.91 ns
>
> THP enabled 64K page size.
> ----------------
> [root@llmp24l02 ~]# ./latency2001 8G
>   8589934592    405.07 cycles    113.91 ns
> [root@llmp24l02 ~]# ./latency2001 8G
>   8589934592    411.82 cycles    115.81 ns
> [root@llmp24l02 ~]#
>
> We are close to hugetlbfs in latency and we can achieve this with zero
> config/page reservation. Most of the allocations above are fault allocated.
>
> Another test that does 50000000 random access over 1GB area goes from
> 2.65 seconds to 1.07 seconds with this patchset.
>
> split_huge_page impact:
> ---------------------
> To look at the performance impact of large page invalidate, I tried the below
> experiment. The test involved, accessing a large contiguous region of memory
> location as below
>
>      for (i = 0; i < size; i += PAGE_SIZE)
> 	data[i] = i;
>
> We wanted to access the data in sequential order so that we look at the
> worst case THP performance. Accesing the data in sequential order implies
> we have the Page table cached and overhead of TLB miss is as minimal as
> possible. We also don't touch the entire page, because that can result in
> cache evict.
>
> After we touched the full range as above, we now call mprotect on each
> of that page. A mprotect will result in a hugepage split. This should
> allow us to measure the impact of hugepage split.
>
>      for (i = 0; i < size; i += PAGE_SIZE)
> 	 mprotect(&data[i], PAGE_SIZE, PROT_READ);
>
> Split hugepage impact:
> ---------------------
> THP enabled: 2.851561705 seconds for test completion
> THP disable: 3.599146098 seconds for test completion
>
> We are 20.7% better than non THP case even when we have all the large pages split.
>
> Detailed output:
>
> THP enabled:
> ---------------------------------------
> [root@llmp24l02 ~]# cat /proc/vmstat  | grep thp
> thp_fault_alloc 0
> thp_fault_fallback 0
> thp_collapse_alloc 0
> thp_collapse_alloc_failed 0
> thp_split 0
> thp_zero_page_alloc 0
> thp_zero_page_alloc_failed 0
> [root@llmp24l02 ~]# /root/thp/tools/perf/perf stat -e page-faults,dTLB-load-misses ./split-huge-page-mpro 20G
> time taken to touch all the data in ns: 2763096913
>
>   Performance counter stats for './split-huge-page-mpro 20G':
>
>               1,581 page-faults
>               3,159 dTLB-load-misses
>
>         2.851561705 seconds time elapsed
>
> [root@llmp24l02 ~]#
> [root@llmp24l02 ~]# cat /proc/vmstat  | grep thp
> thp_fault_alloc 1279
> thp_fault_fallback 0
> thp_collapse_alloc 0
> thp_collapse_alloc_failed 0
> thp_split 1279
> thp_zero_page_alloc 0
> thp_zero_page_alloc_failed 0
> [root@llmp24l02 ~]#
>
>      77.05%  split-huge-page  [kernel.kallsyms]     [k] .clear_user_page
>       7.10%  split-huge-page  [kernel.kallsyms]     [k] .perf_event_mmap_ctx
>       1.51%  split-huge-page  split-huge-page-mpro  [.] 0x0000000000000a70
>       0.96%  split-huge-page  [unknown]             [H] 0x000000000157e3bc
>       0.81%  split-huge-page  [kernel.kallsyms]     [k] .up_write
>       0.76%  split-huge-page  [kernel.kallsyms]     [k] .perf_event_mmap
>       0.76%  split-huge-page  [kernel.kallsyms]     [k] .down_write
>       0.74%  split-huge-page  [kernel.kallsyms]     [k] .lru_add_page_tail
>       0.61%  split-huge-page  [kernel.kallsyms]     [k] .split_huge_page
>       0.59%  split-huge-page  [kernel.kallsyms]     [k] .change_protection
>       0.51%  split-huge-page  [kernel.kallsyms]     [k] .release_pages
>
>
>       0.96%  split-huge-page  [unknown]             [H] 0x000000000157e3bc
>              |
>              |--79.44%-- reloc_start
>              |          |
>              |          |--86.54%-- .__pSeries_lpar_hugepage_invalidate
>              |          |          .pSeries_lpar_hugepage_invalidate
>              |          |          .hpte_need_hugepage_flush
>              |          |          .split_huge_page
>              |          |          .__split_huge_page_pmd
>              |          |          .vma_adjust
>              |          |          .vma_merge
>              |          |          .mprotect_fixup
>              |          |          .SyS_mprotect
>
>
> THP disabled:
> ---------------
> [root@llmp24l02 ~]# echo never > /sys/kernel/mm/transparent_hugepage/enabled
> [root@llmp24l02 ~]# /root/thp/tools/perf/perf stat -e page-faults,dTLB-load-misses ./split-huge-page-mpro 20G
> time taken to touch all the data in ns: 3513767220
>
>   Performance counter stats for './split-huge-page-mpro 20G':
>
>            3,27,726 page-faults
>            3,29,654 dTLB-load-misses
>
>         3.599146098 seconds time elapsed
>
> [root@llmp24l02 ~]#
>
> Changes from V4:
> * Fix bad page error in page_table_alloc
>    BUG: Bad page state in process stream  pfn:f1a59
>    page:f0000000034dc378 count:1 mapcount:0 mapping:          (null) index:0x0
>    [c000000f322c77d0] [c00000000015e198] .bad_page+0xe8/0x140
>    [c000000f322c7860] [c00000000015e3c4] .free_pages_prepare+0x1d4/0x1e0
>    [c000000f322c7910] [c000000000160450] .free_hot_cold_page+0x50/0x230
>    [c000000f322c79c0] [c00000000003ad18] .page_table_alloc+0x168/0x1c0
>
> Changes from V3:
> * PowerNV boot fixes
>
> Change from V2:
> * Change patch "powerpc: Reduce PTE table memory wastage" to use much simpler approach
>    for PTE page sharing.
> * Changes to handle huge pages in KVM code.
> * Address other review comments
>
> Changes from V1
> * Address review comments
> * More patch split
> * Add batch hpte invalidate for hugepages.
>
> Changes from RFC V2:
> * Address review comments
> * More code cleanup and patch split
>
> Changes from RFC V1:
> * HugeTLB fs now works
> * Compile issues fixed
> * rebased to v3.8
> * Patch series reorded so that ppc64 cleanups and MM THP changes are moved
>    early in the series. This should help in picking those patches early.
>
> Thanks,
> -aneesh
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
