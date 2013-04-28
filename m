Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id B49136B0036
	for <linux-mm@kvack.org>; Sun, 28 Apr 2013 15:52:00 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 29 Apr 2013 01:17:27 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 57128125804F
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 01:23:35 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3SJpnHm67043562
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 01:21:49 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3SJptUL002223
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 05:51:55 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V7 00/10] THP support for PPC64 (Patchset 2)
Date: Mon, 29 Apr 2013 01:21:41 +0530
Message-Id: <1367178711-8232-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, dwg@au1.ibm.com, linux-mm@kvack.org
Cc: linuxppc-dev@lists.ozlabs.org

Hi,

This is the second patchset needed to support THP on ppc64. Some of the changes
included in this series are tricky in that it changes the powerpc linux page table
walk subtly. We also overload few of the pte flags for ptes at PMD leve (huge
page PTEs). This patchset require closer review before merging upstream.

I have split the patch series into two patchset, so that we can look at getting
prerequisite patches upstream in 3.10.

Some numbers:

The latency measurements code from Anton  found at
http://ozlabs.org/~anton/junkcode/latency2001.c

64K page size (With THP support)
--------------------------
[root@llmp24l02 test]# ./latency2001 8G
 8589934592    428.49 cycles    120.50 ns
[root@llmp24l02 test]# ./latency2001 -l 8G
 8589934592    471.16 cycles    132.50 ns
[root@llmp24l02 test]# echo never > /sys/kernel/mm/transparent_hugepage/enabled 
[root@llmp24l02 test]# ./latency2001 8G
 8589934592    766.52 cycles    215.56 ns
[root@llmp24l02 test]# 

4K page size (No THP support for 4K)
----------------------------
[root@llmp24l02 test]# ./latency2001 8G
 8589934592    814.88 cycles    229.16 ns
[root@llmp24l02 test]# ./latency2001 -l 8G
 8589934592    463.69 cycles    130.40 ns
[root@llmp24l02 test]# 

We are close to hugetlbfs in latency and we can achieve this with zero
config/page reservation. Most of the allocations above are fault allocated.

Another test that does 50000000 random access over 1GB area goes from
2.65 seconds to 1.07 seconds with this patchset.

split_huge_page impact:
---------------------
To look at the performance impact of large page invalidate, I tried the below
experiment. The test involved, accessing a large contiguous region of memory
location as below

    for (i = 0; i < size; i += PAGE_SIZE)
	data[i] = i;

We wanted to access the data in sequential order so that we look at the
worst case THP performance. Accesing the data in sequential order implies
we have the Page table cached and overhead of TLB miss is as minimal as
possible. We also don't touch the entire page, because that can result in
cache evict.

After we touched the full range as above, we now call mprotect on each
of that page. A mprotect will result in a hugepage split. This should
allow us to measure the impact of hugepage split.

    for (i = 0; i < size; i += PAGE_SIZE)
	 mprotect(&data[i], PAGE_SIZE, PROT_READ);

Split hugepage impact: 
---------------------
THP enabled: 2.851561705 seconds for test completion
THP disable: 3.599146098 seconds for test completion

We are 20.7% better than non THP case even when we have all the large pages split.

Detailed output:

THP enabled:
---------------------------------------
[root@llmp24l02 ~]# cat /proc/vmstat  | grep thp
thp_fault_alloc 0
thp_fault_fallback 0
thp_collapse_alloc 0
thp_collapse_alloc_failed 0
thp_split 0
thp_zero_page_alloc 0
thp_zero_page_alloc_failed 0
[root@llmp24l02 ~]# /root/thp/tools/perf/perf stat -e page-faults,dTLB-load-misses ./split-huge-page-mpro 20G                                                                      
time taken to touch all the data in ns: 2763096913 

 Performance counter stats for './split-huge-page-mpro 20G':

             1,581 page-faults                                                 
             3,159 dTLB-load-misses                                            

       2.851561705 seconds time elapsed

[root@llmp24l02 ~]# 
[root@llmp24l02 ~]# cat /proc/vmstat  | grep thp
thp_fault_alloc 1279
thp_fault_fallback 0
thp_collapse_alloc 0
thp_collapse_alloc_failed 0
thp_split 1279
thp_zero_page_alloc 0
thp_zero_page_alloc_failed 0
[root@llmp24l02 ~]# 

    77.05%  split-huge-page  [kernel.kallsyms]     [k] .clear_user_page                        
     7.10%  split-huge-page  [kernel.kallsyms]     [k] .perf_event_mmap_ctx                    
     1.51%  split-huge-page  split-huge-page-mpro  [.] 0x0000000000000a70                      
     0.96%  split-huge-page  [unknown]             [H] 0x000000000157e3bc                      
     0.81%  split-huge-page  [kernel.kallsyms]     [k] .up_write                               
     0.76%  split-huge-page  [kernel.kallsyms]     [k] .perf_event_mmap                        
     0.76%  split-huge-page  [kernel.kallsyms]     [k] .down_write                             
     0.74%  split-huge-page  [kernel.kallsyms]     [k] .lru_add_page_tail                      
     0.61%  split-huge-page  [kernel.kallsyms]     [k] .split_huge_page                        
     0.59%  split-huge-page  [kernel.kallsyms]     [k] .change_protection                      
     0.51%  split-huge-page  [kernel.kallsyms]     [k] .release_pages                          


     0.96%  split-huge-page  [unknown]             [H] 0x000000000157e3bc                      
            |          
            |--79.44%-- reloc_start
            |          |          
            |          |--86.54%-- .__pSeries_lpar_hugepage_invalidate
            |          |          .pSeries_lpar_hugepage_invalidate
            |          |          .hpte_need_hugepage_flush
            |          |          .split_huge_page
            |          |          .__split_huge_page_pmd
            |          |          .vma_adjust
            |          |          .vma_merge
            |          |          .mprotect_fixup
            |          |          .SyS_mprotect


THP disabled:
---------------
[root@llmp24l02 ~]# echo never > /sys/kernel/mm/transparent_hugepage/enabled
[root@llmp24l02 ~]# /root/thp/tools/perf/perf stat -e page-faults,dTLB-load-misses ./split-huge-page-mpro 20G
time taken to touch all the data in ns: 3513767220 

 Performance counter stats for './split-huge-page-mpro 20G':

          3,27,726 page-faults                                                 
          3,29,654 dTLB-load-misses                                            

       3.599146098 seconds time elapsed

[root@llmp24l02 ~]#

Changes from V6:
* split the patch series into two patchset.
* Address review feedback.

Changes from V5:
* Address review comments
* Added new patch to not use hugepd for explcit hugepages. Explicit hugepaes
  now use PTE format similar to transparent hugepages.
* We don't use page->_mapcount for tracking free PTE frags in a PTE page.
* rebased to a86d52667d8eda5de39393ce737794403bdce1eb
* Tested with libhugetlbfs test suite

Changes from V4:
* Fix bad page error in page_table_alloc
  BUG: Bad page state in process stream  pfn:f1a59
  page:f0000000034dc378 count:1 mapcount:0 mapping:          (null) index:0x0
  [c000000f322c77d0] [c00000000015e198] .bad_page+0xe8/0x140
  [c000000f322c7860] [c00000000015e3c4] .free_pages_prepare+0x1d4/0x1e0
  [c000000f322c7910] [c000000000160450] .free_hot_cold_page+0x50/0x230
  [c000000f322c79c0] [c00000000003ad18] .page_table_alloc+0x168/0x1c0

Changes from V3:
* PowerNV boot fixes

Change from V2:
* Change patch "powerpc: Reduce PTE table memory wastage" to use much simpler approach
  for PTE page sharing.
* Changes to handle huge pages in KVM code.
* Address other review comments

Changes from V1
* Address review comments
* More patch split
* Add batch hpte invalidate for hugepages.

Changes from RFC V2:
* Address review comments
* More code cleanup and patch split

Changes from RFC V1:
* HugeTLB fs now works
* Compile issues fixed
* rebased to v3.8
* Patch series reorded so that ppc64 cleanups and MM THP changes are moved
  early in the series. This should help in picking those patches early.

Thanks,
-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
