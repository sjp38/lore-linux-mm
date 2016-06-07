Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f197.google.com (mail-ob0-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7CE1C6B026B
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 07:01:31 -0400 (EDT)
Received: by mail-ob0-f197.google.com with SMTP id wj2so1665257obc.1
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 04:01:31 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id 2si20256592pfz.229.2016.06.07.04.01.07
        for <linux-mm@kvack.org>;
        Tue, 07 Jun 2016 04:01:07 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv9-rebased 32/32] thp: update Documentation/{vm/transhuge,filesystems/proc}.txt
Date: Tue,  7 Jun 2016 14:00:46 +0300
Message-Id: <1465297246-98985-33-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1465297246-98985-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1465222029-45942-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1465297246-98985-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Add info about tmpfs/shmem with huge pages.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 Documentation/filesystems/proc.txt |   9 +++
 Documentation/vm/transhuge.txt     | 128 ++++++++++++++++++++++++++-----------
 2 files changed, 101 insertions(+), 36 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index e8d00759bfa5..50fcf48f4d58 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -436,6 +436,7 @@ Private_Dirty:         0 kB
 Referenced:          892 kB
 Anonymous:             0 kB
 AnonHugePages:         0 kB
+ShmemPmdMapped:        0 kB
 Shared_Hugetlb:        0 kB
 Private_Hugetlb:       0 kB
 Swap:                  0 kB
@@ -464,6 +465,8 @@ accessed.
 a mapping associated with a file may contain anonymous pages: when MAP_PRIVATE
 and a page is modified, the file page is replaced by a private anonymous copy.
 "AnonHugePages" shows the ammount of memory backed by transparent hugepage.
+"ShmemPmdMapped" shows the ammount of shared (shmem/tmpfs) memory backed by
+huge pages.
 "Shared_Hugetlb" and "Private_Hugetlb" show the ammounts of memory backed by
 hugetlbfs page which is *not* counted in "RSS" or "PSS" field for historical
 reasons. And these are not included in {Shared,Private}_{Clean,Dirty} field.
@@ -868,6 +871,9 @@ VmallocTotal:   112216 kB
 VmallocUsed:       428 kB
 VmallocChunk:   111088 kB
 AnonHugePages:   49152 kB
+ShmemHugePages:      0 kB
+ShmemPmdMapped:      0 kB
+
 
     MemTotal: Total usable ram (i.e. physical ram minus a few reserved
               bits and the kernel binary code)
@@ -912,6 +918,9 @@ MemAvailable: An estimate of how much memory is available for starting new
 AnonHugePages: Non-file backed huge pages mapped into userspace page tables
       Mapped: files which have been mmaped, such as libraries
        Shmem: Total memory used by shared memory (shmem) and tmpfs
+ShmemHugePages: Memory used by shared memory (shmem) and tmpfs allocated
+              with huge pages
+ShmemPmdMapped: Shared memory mapped into userspace with huge pages
         Slab: in-kernel data structures cache
 SReclaimable: Part of Slab, that might be reclaimed, such as caches
   SUnreclaim: Part of Slab, that cannot be reclaimed on memory pressure
diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
index 7c871d6beb63..2ec6adb5a4ce 100644
--- a/Documentation/vm/transhuge.txt
+++ b/Documentation/vm/transhuge.txt
@@ -9,8 +9,8 @@ using huge pages for the backing of virtual memory with huge pages
 that supports the automatic promotion and demotion of page sizes and
 without the shortcomings of hugetlbfs.
 
-Currently it only works for anonymous memory mappings but in the
-future it can expand over the pagecache layer starting with tmpfs.
+Currently it only works for anonymous memory mappings and tmpfs/shmem.
+But in the future it can expand to other filesystems.
 
 The reason applications are running faster is because of two
 factors. The first factor is almost completely irrelevant and it's not
@@ -57,10 +57,6 @@ miss is going to run faster.
   feature that applies to all dynamic high order allocations in the
   kernel)
 
-- this initial support only offers the feature in the anonymous memory
-  regions but it'd be ideal to move it to tmpfs and the pagecache
-  later
-
 Transparent Hugepage Support maximizes the usefulness of free memory
 if compared to the reservation approach of hugetlbfs by allowing all
 unused memory to be used as cache or other movable (or even unmovable
@@ -94,21 +90,21 @@ madvise(MADV_HUGEPAGE) on their critical mmapped regions.
 
 == sysfs ==
 
-Transparent Hugepage Support can be entirely disabled (mostly for
-debugging purposes) or only enabled inside MADV_HUGEPAGE regions (to
-avoid the risk of consuming more memory resources) or enabled system
-wide. This can be achieved with one of:
+Transparent Hugepage Support for anonymous memory can be entirely disabled
+(mostly for debugging purposes) or only enabled inside MADV_HUGEPAGE
+regions (to avoid the risk of consuming more memory resources) or enabled
+system wide. This can be achieved with one of:
 
 echo always >/sys/kernel/mm/transparent_hugepage/enabled
 echo madvise >/sys/kernel/mm/transparent_hugepage/enabled
 echo never >/sys/kernel/mm/transparent_hugepage/enabled
 
 It's also possible to limit defrag efforts in the VM to generate
-hugepages in case they're not immediately free to madvise regions or
-to never try to defrag memory and simply fallback to regular pages
-unless hugepages are immediately available. Clearly if we spend CPU
-time to defrag memory, we would expect to gain even more by the fact
-we use hugepages later instead of regular pages. This isn't always
+anonymous hugepages in case they're not immediately free to madvise
+regions or to never try to defrag memory and simply fallback to regular
+pages unless hugepages are immediately available. Clearly if we spend CPU
+time to defrag memory, we would expect to gain even more by the fact we
+use hugepages later instead of regular pages. This isn't always
 guaranteed, but it may be more likely in case the allocation is for a
 MADV_HUGEPAGE region.
 
@@ -133,9 +129,9 @@ that are have used madvise(MADV_HUGEPAGE). This is the default behaviour.
 
 "never" should be self-explanatory.
 
-By default kernel tries to use huge zero page on read page fault.
-It's possible to disable huge zero page by writing 0 or enable it
-back by writing 1:
+By default kernel tries to use huge zero page on read page fault to
+anonymous mapping. It's possible to disable huge zero page by writing 0
+or enable it back by writing 1:
 
 echo 0 >/sys/kernel/mm/transparent_hugepage/use_zero_page
 echo 1 >/sys/kernel/mm/transparent_hugepage/use_zero_page
@@ -204,21 +200,67 @@ Support by passing the parameter "transparent_hugepage=always" or
 "transparent_hugepage=madvise" or "transparent_hugepage=never"
 (without "") to the kernel command line.
 
+== Hugepages in tmpfs/shmem ==
+
+You can control hugepage allocation policy in tmpfs with mount option
+"huge=". It can have following values:
+
+  - "always":
+    Attempt to allocate huge pages every time we need a new page;
+
+  - "never":
+    Do not allocate huge pages;
+
+  - "within_size":
+    Only allocate huge page if it will be fully within i_size.
+    Also respect fadvise()/madvise() hints;
+
+  - "advise:
+    Only allocate huge pages if requested with fadvise()/madvise();
+
+The default policy is "never".
+
+"mount -o remount,huge= /mountpoint" works fine after mount: remounting
+huge=never will not attempt to break up huge pages at all, just stop more
+from being allocated.
+
+There's also sysfs knob to control hugepage allocation policy for internal
+shmem mount: /sys/kernel/mm/transparent_hugepage/shmem_enabled. The mount
+is used for SysV SHM, memfds, shared anonymous mmaps (of /dev/zero or
+MAP_ANONYMOUS), GPU drivers' DRM objects, Ashmem.
+
+In addition to policies listed above, shmem_enabled allows two further
+values:
+
+  - "deny":
+    For use in emergencies, to force the huge option off from
+    all mounts;
+  - "force":
+    Force the huge option on for all - very useful for testing;
+
 == Need of application restart ==
 
-The transparent_hugepage/enabled values only affect future
-behavior. So to make them effective you need to restart any
-application that could have been using hugepages. This also applies to
-the regions registered in khugepaged.
+The transparent_hugepage/enabled values and tmpfs mount option only affect
+future behavior. So to make them effective you need to restart any
+application that could have been using hugepages. This also applies to the
+regions registered in khugepaged.
 
 == Monitoring usage ==
 
-The number of transparent huge pages currently used by the system is
-available by reading the AnonHugePages field in /proc/meminfo. To
-identify what applications are using transparent huge pages, it is
-necessary to read /proc/PID/smaps and count the AnonHugePages fields
-for each mapping. Note that reading the smaps file is expensive and
-reading it frequently will incur overhead.
+The number of anonymous transparent huge pages currently used by the
+system is available by reading the AnonHugePages field in /proc/meminfo.
+To identify what applications are using anonymous transparent huge pages,
+it is necessary to read /proc/PID/smaps and count the AnonHugePages fields
+for each mapping.
+
+The number of file transparent huge pages mapped to userspace is available
+by reading ShmemPmdMapped and ShmemHugePages fields in /proc/meminfo.
+To identify what applications are mapping file  transparent huge pages, it
+is necessary to read /proc/PID/smaps and count the FileHugeMapped fields
+for each mapping.
+
+Note that reading the smaps file is expensive and reading it
+frequently will incur overhead.
 
 There are a number of counters in /proc/vmstat that may be used to
 monitor how successfully the system is providing huge pages for use.
@@ -238,6 +280,12 @@ thp_collapse_alloc_failed is incremented if khugepaged found a range
 	of pages that should be collapsed into one huge page but failed
 	the allocation.
 
+thp_file_alloc is incremented every time a file huge page is successfully
+i	allocated.
+
+thp_file_mapped is incremented every time a file huge page is mapped into
+	user address space.
+
 thp_split_page is incremented every time a huge page is split into base
 	pages. This can happen for a variety of reasons but a common
 	reason is that a huge page is old and is being reclaimed.
@@ -403,19 +451,27 @@ pages:
     on relevant sub-page of the compound page.
 
   - map/unmap of the whole compound page accounted in compound_mapcount
-    (stored in first tail page).
+    (stored in first tail page). For file huge pages, we also increment
+    ->_mapcount of all sub-pages in order to have race-free detection of
+    last unmap of subpages.
 
-PageDoubleMap() indicates that ->_mapcount in all subpages is offset up by one.
-This additional reference is required to get race-free detection of unmap of
-subpages when we have them mapped with both PMDs and PTEs.
+PageDoubleMap() indicates that the page is *possibly* mapped with PTEs.
+
+For anonymous pages PageDoubleMap() also indicates ->_mapcount in all
+subpages is offset up by one. This additional reference is required to
+get race-free detection of unmap of subpages when we have them mapped with
+both PMDs and PTEs.
 
 This is optimization required to lower overhead of per-subpage mapcount
 tracking. The alternative is alter ->_mapcount in all subpages on each
 map/unmap of the whole compound page.
 
-We set PG_double_map when a PMD of the page got split for the first time,
-but still have PMD mapping. The additional references go away with last
-compound_mapcount.
+For anonymous pages, we set PG_double_map when a PMD of the page got split
+for the first time, but still have PMD mapping. The additional references
+go away with last compound_mapcount.
+
+File pages get PG_double_map set on first map of the page with PTE and
+goes away when the page gets evicted from page cache.
 
 split_huge_page internally has to distribute the refcounts in the head
 page to the tail pages before clearing all PG_head/tail bits from the page
@@ -427,7 +483,7 @@ sum of mapcount of all sub-pages plus one (split_huge_page caller must
 have reference for head page).
 
 split_huge_page uses migration entries to stabilize page->_refcount and
-page->_mapcount.
+page->_mapcount of anonymous pages. File pages just got unmapped.
 
 We safe against physical memory scanners too: the only legitimate way
 scanner can get reference to a page is get_page_unless_zero().
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
