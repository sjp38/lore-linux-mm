Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id BD6176B028A
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 18:57:59 -0400 (EDT)
Received: by mail-pf0-f178.google.com with SMTP id e128so42387958pfe.3
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 15:57:59 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id 78si7299961pfp.25.2016.04.06.15.51.36
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 15:51:36 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 27/30] thp: update Documentation/vm/transhuge.txt
Date: Thu,  7 Apr 2016 01:51:17 +0300
Message-Id: <1459983080-106718-28-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1459983080-106718-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1459983080-106718-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Add info about tmpfs/shmem with huge pages.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 Documentation/vm/transhuge.txt | 130 +++++++++++++++++++++++++++++------------
 1 file changed, 93 insertions(+), 37 deletions(-)

diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
index d9cb65cf5cfd..96a49f123cac 100644
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
@@ -48,7 +48,7 @@ miss is going to run faster.
 - if some task quits and more hugepages become available (either
   immediately in the buddy or through the VM), guest physical memory
   backed by regular pages should be relocated on hugepages
-  automatically (with khugepaged)
+  automatically (with khugepaged, limited to anonymous huge pages for now)
 
 - it doesn't require memory reservation and in turn it uses hugepages
   whenever possible (the only possible reservation here is kernelcore=
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
+by reading the FileHugeMapped field in /proc/meminfo.  To identify what
+applications are mapping file  transparent huge pages, it is necessary
+to read /proc/PID/smaps and count the FileHugeMapped fields for each
+mapping.
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
-but still have PMD mapping. The addtional references go away with last
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
 
 split_huge_page uses migration entries to stabilize page->_count and
-page->_mapcount.
+page->_mapcount of anonymous pages. File pages just got unmapped.
 
 We safe against physical memory scanners too: the only legitimate way
 scanner can get reference to a page is get_page_unless_zero().
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
