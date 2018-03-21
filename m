Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3604F6B0277
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:25:01 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id e185so2739480wmg.5
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 12:25:01 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d4si4622951edd.431.2018.03.21.12.24.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 12:24:58 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2LJIZDW047120
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:24:57 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2guuubveff-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:24:57 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 21 Mar 2018 19:24:54 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 25/32] docs/vm: transhuge.txt: convert to ReST format
Date: Wed, 21 Mar 2018 21:22:41 +0200
In-Reply-To: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1521660168-14372-26-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/vm/transhuge.txt | 286 ++++++++++++++++++++++++-----------------
 1 file changed, 166 insertions(+), 120 deletions(-)

diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
index 4dde03b..569d182 100644
--- a/Documentation/vm/transhuge.txt
+++ b/Documentation/vm/transhuge.txt
@@ -1,6 +1,11 @@
-= Transparent Hugepage Support =
+.. _transhuge:
 
-== Objective ==
+============================
+Transparent Hugepage Support
+============================
+
+Objective
+=========
 
 Performance critical computing applications dealing with large memory
 working sets are already running on top of libhugetlbfs and in turn
@@ -33,7 +38,8 @@ are using hugepages but a significant speedup already happens if only
 one of the two is using hugepages just because of the fact the TLB
 miss is going to run faster.
 
-== Design ==
+Design
+======
 
 - "graceful fallback": mm components which don't have transparent hugepage
   knowledge fall back to breaking huge pmd mapping into table of ptes and,
@@ -88,16 +94,17 @@ Applications that gets a lot of benefit from hugepages and that don't
 risk to lose memory by using hugepages, should use
 madvise(MADV_HUGEPAGE) on their critical mmapped regions.
 
-== sysfs ==
+sysfs
+=====
 
 Transparent Hugepage Support for anonymous memory can be entirely disabled
 (mostly for debugging purposes) or only enabled inside MADV_HUGEPAGE
 regions (to avoid the risk of consuming more memory resources) or enabled
-system wide. This can be achieved with one of:
+system wide. This can be achieved with one of::
 
-echo always >/sys/kernel/mm/transparent_hugepage/enabled
-echo madvise >/sys/kernel/mm/transparent_hugepage/enabled
-echo never >/sys/kernel/mm/transparent_hugepage/enabled
+	echo always >/sys/kernel/mm/transparent_hugepage/enabled
+	echo madvise >/sys/kernel/mm/transparent_hugepage/enabled
+	echo never >/sys/kernel/mm/transparent_hugepage/enabled
 
 It's also possible to limit defrag efforts in the VM to generate
 anonymous hugepages in case they're not immediately free to madvise
@@ -108,44 +115,53 @@ use hugepages later instead of regular pages. This isn't always
 guaranteed, but it may be more likely in case the allocation is for a
 MADV_HUGEPAGE region.
 
-echo always >/sys/kernel/mm/transparent_hugepage/defrag
-echo defer >/sys/kernel/mm/transparent_hugepage/defrag
-echo defer+madvise >/sys/kernel/mm/transparent_hugepage/defrag
-echo madvise >/sys/kernel/mm/transparent_hugepage/defrag
-echo never >/sys/kernel/mm/transparent_hugepage/defrag
-
-"always" means that an application requesting THP will stall on allocation
-failure and directly reclaim pages and compact memory in an effort to
-allocate a THP immediately. This may be desirable for virtual machines
-that benefit heavily from THP use and are willing to delay the VM start
-to utilise them.
-
-"defer" means that an application will wake kswapd in the background
-to reclaim pages and wake kcompactd to compact memory so that THP is
-available in the near future. It's the responsibility of khugepaged
-to then install the THP pages later.
-
-"defer+madvise" will enter direct reclaim and compaction like "always", but
-only for regions that have used madvise(MADV_HUGEPAGE); all other regions
-will wake kswapd in the background to reclaim pages and wake kcompactd to
-compact memory so that THP is available in the near future.
-
-"madvise" will enter direct reclaim like "always" but only for regions
-that are have used madvise(MADV_HUGEPAGE). This is the default behaviour.
-
-"never" should be self-explanatory.
+::
+
+	echo always >/sys/kernel/mm/transparent_hugepage/defrag
+	echo defer >/sys/kernel/mm/transparent_hugepage/defrag
+	echo defer+madvise >/sys/kernel/mm/transparent_hugepage/defrag
+	echo madvise >/sys/kernel/mm/transparent_hugepage/defrag
+	echo never >/sys/kernel/mm/transparent_hugepage/defrag
+
+always
+	means that an application requesting THP will stall on
+	allocation failure and directly reclaim pages and compact
+	memory in an effort to allocate a THP immediately. This may be
+	desirable for virtual machines that benefit heavily from THP
+	use and are willing to delay the VM start to utilise them.
+
+defer
+	means that an application will wake kswapd in the background
+	to reclaim pages and wake kcompactd to compact memory so that
+	THP is available in the near future. It's the responsibility
+	of khugepaged to then install the THP pages later.
+
+defer+madvise
+	will enter direct reclaim and compaction like ``always``, but
+	only for regions that have used madvise(MADV_HUGEPAGE); all
+	other regions will wake kswapd in the background to reclaim
+	pages and wake kcompactd to compact memory so that THP is
+	available in the near future.
+
+madvise
+	will enter direct reclaim like ``always`` but only for regions
+	that are have used madvise(MADV_HUGEPAGE). This is the default
+	behaviour.
+
+never
+	should be self-explanatory.
 
 By default kernel tries to use huge zero page on read page fault to
 anonymous mapping. It's possible to disable huge zero page by writing 0
-or enable it back by writing 1:
+or enable it back by writing 1::
 
-echo 0 >/sys/kernel/mm/transparent_hugepage/use_zero_page
-echo 1 >/sys/kernel/mm/transparent_hugepage/use_zero_page
+	echo 0 >/sys/kernel/mm/transparent_hugepage/use_zero_page
+	echo 1 >/sys/kernel/mm/transparent_hugepage/use_zero_page
 
 Some userspace (such as a test program, or an optimized memory allocation
-library) may want to know the size (in bytes) of a transparent hugepage:
+library) may want to know the size (in bytes) of a transparent hugepage::
 
-cat /sys/kernel/mm/transparent_hugepage/hpage_pmd_size
+	cat /sys/kernel/mm/transparent_hugepage/hpage_pmd_size
 
 khugepaged will be automatically started when
 transparent_hugepage/enabled is set to "always" or "madvise, and it'll
@@ -155,84 +171,86 @@ khugepaged runs usually at low frequency so while one may not want to
 invoke defrag algorithms synchronously during the page faults, it
 should be worth invoking defrag at least in khugepaged. However it's
 also possible to disable defrag in khugepaged by writing 0 or enable
-defrag in khugepaged by writing 1:
+defrag in khugepaged by writing 1::
 
-echo 0 >/sys/kernel/mm/transparent_hugepage/khugepaged/defrag
-echo 1 >/sys/kernel/mm/transparent_hugepage/khugepaged/defrag
+	echo 0 >/sys/kernel/mm/transparent_hugepage/khugepaged/defrag
+	echo 1 >/sys/kernel/mm/transparent_hugepage/khugepaged/defrag
 
 You can also control how many pages khugepaged should scan at each
-pass:
+pass::
 
-/sys/kernel/mm/transparent_hugepage/khugepaged/pages_to_scan
+	/sys/kernel/mm/transparent_hugepage/khugepaged/pages_to_scan
 
 and how many milliseconds to wait in khugepaged between each pass (you
-can set this to 0 to run khugepaged at 100% utilization of one core):
+can set this to 0 to run khugepaged at 100% utilization of one core)::
 
-/sys/kernel/mm/transparent_hugepage/khugepaged/scan_sleep_millisecs
+	/sys/kernel/mm/transparent_hugepage/khugepaged/scan_sleep_millisecs
 
 and how many milliseconds to wait in khugepaged if there's an hugepage
-allocation failure to throttle the next allocation attempt.
+allocation failure to throttle the next allocation attempt::
 
-/sys/kernel/mm/transparent_hugepage/khugepaged/alloc_sleep_millisecs
+	/sys/kernel/mm/transparent_hugepage/khugepaged/alloc_sleep_millisecs
 
-The khugepaged progress can be seen in the number of pages collapsed:
+The khugepaged progress can be seen in the number of pages collapsed::
 
-/sys/kernel/mm/transparent_hugepage/khugepaged/pages_collapsed
+	/sys/kernel/mm/transparent_hugepage/khugepaged/pages_collapsed
 
-for each pass:
+for each pass::
 
-/sys/kernel/mm/transparent_hugepage/khugepaged/full_scans
+	/sys/kernel/mm/transparent_hugepage/khugepaged/full_scans
 
-max_ptes_none specifies how many extra small pages (that are
+``max_ptes_none`` specifies how many extra small pages (that are
 not already mapped) can be allocated when collapsing a group
-of small pages into one large page.
+of small pages into one large page::
 
-/sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_none
+	/sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_none
 
 A higher value leads to use additional memory for programs.
 A lower value leads to gain less thp performance. Value of
 max_ptes_none can waste cpu time very little, you can
 ignore it.
 
-max_ptes_swap specifies how many pages can be brought in from
-swap when collapsing a group of pages into a transparent huge page.
+``max_ptes_swap`` specifies how many pages can be brought in from
+swap when collapsing a group of pages into a transparent huge page::
 
-/sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_swap
+	/sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_swap
 
 A higher value can cause excessive swap IO and waste
 memory. A lower value can prevent THPs from being
 collapsed, resulting fewer pages being collapsed into
 THPs, and lower memory access performance.
 
-== Boot parameter ==
+Boot parameter
+==============
 
 You can change the sysfs boot time defaults of Transparent Hugepage
-Support by passing the parameter "transparent_hugepage=always" or
-"transparent_hugepage=madvise" or "transparent_hugepage=never"
-(without "") to the kernel command line.
+Support by passing the parameter ``transparent_hugepage=always`` or
+``transparent_hugepage=madvise`` or ``transparent_hugepage=never``
+to the kernel command line.
 
-== Hugepages in tmpfs/shmem ==
+Hugepages in tmpfs/shmem
+========================
 
 You can control hugepage allocation policy in tmpfs with mount option
-"huge=". It can have following values:
+``huge=``. It can have following values:
 
-  - "always":
+always
     Attempt to allocate huge pages every time we need a new page;
 
-  - "never":
+never
     Do not allocate huge pages;
 
-  - "within_size":
+within_size
     Only allocate huge page if it will be fully within i_size.
     Also respect fadvise()/madvise() hints;
 
-  - "advise:
+advise
     Only allocate huge pages if requested with fadvise()/madvise();
 
-The default policy is "never".
+The default policy is ``never``.
 
-"mount -o remount,huge= /mountpoint" works fine after mount: remounting
-huge=never will not attempt to break up huge pages at all, just stop more
+``mount -o remount,huge= /mountpoint`` works fine after mount: remounting
+``huge=never`` will not attempt to break up huge pages at all, just stop more
 from being allocated.
 
 There's also sysfs knob to control hugepage allocation policy for internal
@@ -243,110 +261,130 @@ MAP_ANONYMOUS), GPU drivers' DRM objects, Ashmem.
 In addition to policies listed above, shmem_enabled allows two further
 values:
 
-  - "deny":
+deny
     For use in emergencies, to force the huge option off from
     all mounts;
-  - "force":
+force
     Force the huge option on for all - very useful for testing;
 
-== Need of application restart ==
+Need of application restart
+===========================
 
 The transparent_hugepage/enabled values and tmpfs mount option only affect
 future behavior. So to make them effective you need to restart any
 application that could have been using hugepages. This also applies to the
 regions registered in khugepaged.
 
-== Monitoring usage ==
+Monitoring usage
+================
 
 The number of anonymous transparent huge pages currently used by the
-system is available by reading the AnonHugePages field in /proc/meminfo.
+system is available by reading the AnonHugePages field in ``/proc/meminfo``.
 To identify what applications are using anonymous transparent huge pages,
-it is necessary to read /proc/PID/smaps and count the AnonHugePages fields
+it is necessary to read ``/proc/PID/smaps`` and count the AnonHugePages fields
 for each mapping.
 
 The number of file transparent huge pages mapped to userspace is available
-by reading ShmemPmdMapped and ShmemHugePages fields in /proc/meminfo.
+by reading ShmemPmdMapped and ShmemHugePages fields in ``/proc/meminfo``.
 To identify what applications are mapping file transparent huge pages, it
-is necessary to read /proc/PID/smaps and count the FileHugeMapped fields
+is necessary to read ``/proc/PID/smaps`` and count the FileHugeMapped fields
 for each mapping.
 
 Note that reading the smaps file is expensive and reading it
 frequently will incur overhead.
 
-There are a number of counters in /proc/vmstat that may be used to
+There are a number of counters in ``/proc/vmstat`` that may be used to
 monitor how successfully the system is providing huge pages for use.
 
-thp_fault_alloc is incremented every time a huge page is successfully
+thp_fault_alloc
+	is incremented every time a huge page is successfully
 	allocated to handle a page fault. This applies to both the
 	first time a page is faulted and for COW faults.
 
-thp_collapse_alloc is incremented by khugepaged when it has found
+thp_collapse_alloc
+	is incremented by khugepaged when it has found
 	a range of pages to collapse into one huge page and has
 	successfully allocated a new huge page to store the data.
 
-thp_fault_fallback is incremented if a page fault fails to allocate
+thp_fault_fallback
+	is incremented if a page fault fails to allocate
 	a huge page and instead falls back to using small pages.
 
-thp_collapse_alloc_failed is incremented if khugepaged found a range
+thp_collapse_alloc_failed
+	is incremented if khugepaged found a range
 	of pages that should be collapsed into one huge page but failed
 	the allocation.
 
-thp_file_alloc is incremented every time a file huge page is successfully
+thp_file_alloc
+	is incremented every time a file huge page is successfully
 	allocated.
 
-thp_file_mapped is incremented every time a file huge page is mapped into
+thp_file_mapped
+	is incremented every time a file huge page is mapped into
 	user address space.
 
-thp_split_page is incremented every time a huge page is split into base
+thp_split_page
+	is incremented every time a huge page is split into base
 	pages. This can happen for a variety of reasons but a common
 	reason is that a huge page is old and is being reclaimed.
 	This action implies splitting all PMD the page mapped with.
 
-thp_split_page_failed is incremented if kernel fails to split huge
+thp_split_page_failed
+	is incremented if kernel fails to split huge
 	page. This can happen if the page was pinned by somebody.
 
-thp_deferred_split_page is incremented when a huge page is put onto split
+thp_deferred_split_page
+	is incremented when a huge page is put onto split
 	queue. This happens when a huge page is partially unmapped and
 	splitting it would free up some memory. Pages on split queue are
 	going to be split under memory pressure.
 
-thp_split_pmd is incremented every time a PMD split into table of PTEs.
+thp_split_pmd
+	is incremented every time a PMD split into table of PTEs.
 	This can happen, for instance, when application calls mprotect() or
 	munmap() on part of huge page. It doesn't split huge page, only
 	page table entry.
 
-thp_zero_page_alloc is incremented every time a huge zero page is
+thp_zero_page_alloc
+	is incremented every time a huge zero page is
 	successfully allocated. It includes allocations which where
 	dropped due race with other allocation. Note, it doesn't count
 	every map of the huge zero page, only its allocation.
 
-thp_zero_page_alloc_failed is incremented if kernel fails to allocate
+thp_zero_page_alloc_failed
+	is incremented if kernel fails to allocate
 	huge zero page and falls back to using small pages.
 
 As the system ages, allocating huge pages may be expensive as the
 system uses memory compaction to copy data around memory to free a
-huge page for use. There are some counters in /proc/vmstat to help
+huge page for use. There are some counters in ``/proc/vmstat`` to help
 monitor this overhead.
 
-compact_stall is incremented every time a process stalls to run
+compact_stall
+	is incremented every time a process stalls to run
 	memory compaction so that a huge page is free for use.
 
-compact_success is incremented if the system compacted memory and
+compact_success
+	is incremented if the system compacted memory and
 	freed a huge page for use.
 
-compact_fail is incremented if the system tries to compact memory
+compact_fail
+	is incremented if the system tries to compact memory
 	but failed.
 
-compact_pages_moved is incremented each time a page is moved. If
+compact_pages_moved
+	is incremented each time a page is moved. If
 	this value is increasing rapidly, it implies that the system
 	is copying a lot of data to satisfy the huge page allocation.
 	It is possible that the cost of copying exceeds any savings
 	from reduced TLB misses.
 
-compact_pagemigrate_failed is incremented when the underlying mechanism
+compact_pagemigrate_failed
+	is incremented when the underlying mechanism
 	for moving a page failed.
 
-compact_blocks_moved is incremented each time memory compaction examines
+compact_blocks_moved
+	is incremented each time memory compaction examines
 	a huge page aligned range of pages.
 
 It is possible to establish how long the stalls were using the function
@@ -354,7 +392,8 @@ tracer to record how long was spent in __alloc_pages_nodemask and
 using the mm_page_alloc tracepoint to identify which allocations were
 for huge pages.
 
-== get_user_pages and follow_page ==
+get_user_pages and follow_page
+==============================
 
 get_user_pages and follow_page if run on a hugepage, will return the
 head or tail pages as usual (exactly as they would do on
@@ -367,10 +406,11 @@ for the head page and not the tail page), it should be updated to jump
 to check head page instead. Taking reference on any head/tail page would
 prevent page from being split by anyone.
 
-NOTE: these aren't new constraints to the GUP API, and they match the
-same constrains that applies to hugetlbfs too, so any driver capable
-of handling GUP on hugetlbfs will also work fine on transparent
-hugepage backed mappings.
+.. note::
+   these aren't new constraints to the GUP API, and they match the
+   same constrains that applies to hugetlbfs too, so any driver capable
+   of handling GUP on hugetlbfs will also work fine on transparent
+   hugepage backed mappings.
 
 In case you can't handle compound pages if they're returned by
 follow_page, the FOLL_SPLIT bit can be specified as parameter to
@@ -383,13 +423,15 @@ hugepages being returned (as it's not only checking the pfn of the
 page and pinning it during the copy but it pretends to migrate the
 memory in regular page sizes and with regular pte/pmd mappings).
 
-== Optimizing the applications ==
+Optimizing the applications
+===========================
 
 To be guaranteed that the kernel will map a 2M page immediately in any
 memory region, the mmap region has to be hugepage naturally
 aligned. posix_memalign() can provide that guarantee.
 
-== Hugetlbfs ==
+Hugetlbfs
+=========
 
 You can use hugetlbfs on a kernel that has transparent hugepage
 support enabled just fine as always. No difference can be noted in
@@ -397,7 +439,8 @@ hugetlbfs other than there will be less overall fragmentation. All
 usual features belonging to hugetlbfs are preserved and
 unaffected. libhugetlbfs will also work fine as usual.
 
-== Graceful fallback ==
+Graceful fallback
+=================
 
 Code walking pagetables but unaware about huge pmds can simply call
 split_huge_pmd(vma, pmd, addr) where the pmd is the one returned by
@@ -415,20 +458,21 @@ it tries to swapout the hugepage for example. split_huge_page() can fail
 if the page is pinned and you must handle this correctly.
 
 Example to make mremap.c transparent hugepage aware with a one liner
-change:
+change::
 
-diff --git a/mm/mremap.c b/mm/mremap.c
---- a/mm/mremap.c
-+++ b/mm/mremap.c
-@@ -41,6 +41,7 @@ static pmd_t *get_old_pmd(struct mm_stru
-		return NULL;
+	diff --git a/mm/mremap.c b/mm/mremap.c
+	--- a/mm/mremap.c
+	+++ b/mm/mremap.c
+	@@ -41,6 +41,7 @@ static pmd_t *get_old_pmd(struct mm_stru
+			return NULL;
 
-	pmd = pmd_offset(pud, addr);
-+	split_huge_pmd(vma, pmd, addr);
-	if (pmd_none_or_clear_bad(pmd))
-		return NULL;
+		pmd = pmd_offset(pud, addr);
+	+	split_huge_pmd(vma, pmd, addr);
+		if (pmd_none_or_clear_bad(pmd))
+			return NULL;
 
-== Locking in hugepage aware code ==
+Locking in hugepage aware code
+==============================
 
 We want as much code as possible hugepage aware, as calling
 split_huge_page() or split_huge_pmd() has a cost.
@@ -448,7 +492,8 @@ should just drop the page table lock and fallback to the old code as
 before. Otherwise you can proceed to process the huge pmd and the
 hugepage natively. Once finished you can drop the page table lock.
 
-== Refcounts and transparent huge pages ==
+Refcounts and transparent huge pages
+====================================
 
 Refcounting on THP is mostly consistent with refcounting on other compound
 pages:
@@ -510,7 +555,8 @@ clear where reference should go after split: it will stay on head page.
 Note that split_huge_pmd() doesn't have any limitation on refcounting:
 pmd can be split at any point and never fails.
 
-== Partial unmap and deferred_split_huge_page() ==
+Partial unmap and deferred_split_huge_page()
+============================================
 
 Unmapping part of THP (with munmap() or other way) is not going to free
 memory immediately. Instead, we detect that a subpage of THP is not in use
-- 
2.7.4
