Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 8256C6B002D
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 08:07:54 -0500 (EST)
Date: Tue, 15 Nov 2011 13:07:48 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: Do not stall in synchronous compaction for THP
 allocations
Message-ID: <20111115130748.GE27150@suse.de>
References: <20111110100616.GD3083@suse.de>
 <20111110142202.GE3083@suse.de>
 <CAEwNFnCRCxrru5rBk7FpypqeL8nD=SY5W3-TaA7Ap5o4CgDSbg@mail.gmail.com>
 <20111110161331.GG3083@suse.de>
 <20111110151211.523fa185.akpm@linux-foundation.org>
 <20111111100156.GI3083@suse.de>
 <20111114160345.01e94987.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20111114160345.01e94987.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Nov 14, 2011 at 04:03:45PM -0800, Andrew Morton wrote:
> > <SNIP>
> > A 1000-hour compute job will have its pages collapsed into hugepages by
> > khugepaged so they might not have the huge pages at the very beginning
> > but they get them. With khugepaged in place, there should be no need for
> > an additional tuneable.
> 
> OK...
> 

David Rientjes did point out that it is preferred in certain
cases that khugepaged be disabled on jobs that are CPU bound, high
priority and do not want interference. If this really is the case,
it should not be the default behaviour and added as a new option to
/sys/kernel/mm/transparent_hugepage/defrag in a separate patch.

> > > Do we have the accounting in place for us to be able to determine how
> > > many huge page allocation attempts failed due to this change?
> > > 
> > 
> > thp_fault_fallback is the big one. It is incremented if we fail to
> > 	allocate a hugepage during fault in either
> > 	do_huge_pmd_anonymous_page or do_huge_pmd_wp_page_fallback
> > 
> > thp_collapse_alloc_failed is also very interesting. It is incremented
> > 	if khugepaged tried to collapse pages into a hugepage and
> > 	failed the allocation
> > 
> > The user has the  option of monitoring their compute jobs hugepage
> > usage by reading /proc/PID/smaps and looking at the AnonHugePages
> > count for the large mappings of interest.
> 
> Fair enough.  One slight problem though:
> 
> akpm:/usr/src/25> grep -r thp_collapse_alloc_failed Documentation 
> akpm:/usr/src/25> 
> 

mel@machina:~/git-public/linux-2.6/Documentation > git grep vmstat
trace/postprocess/trace-vmscan-postprocess.pl:                  # To closer match vmstat scanning statistics, only count isolate_both
mel@machina:~/git-public/linux-2.6/Documentation >

Given such an abundance and wealth of information on vmstat, how
about this?

==== CUT HERE ====
mm: Document the meminfo and vmstat fields of relevance to transparent hugepages

This patch updates Documentation/vm/transhuge.txt and
Documentation/filesystems/proc.txt with some information on monitoring
transparent huge page usage and the associated overhead.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 Documentation/filesystems/proc.txt |    2 +
 Documentation/vm/transhuge.txt     |   62 ++++++++++++++++++++++++++++++++++++
 2 files changed, 64 insertions(+), 0 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 0ec91f0..fb6ca6d 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -710,6 +710,7 @@ Committed_AS:   100056 kB
 VmallocTotal:   112216 kB
 VmallocUsed:       428 kB
 VmallocChunk:   111088 kB
+AnonHugePages:   49152 kB
 
     MemTotal: Total usable ram (i.e. physical ram minus a few reserved
               bits and the kernel binary code)
@@ -743,6 +744,7 @@ VmallocChunk:   111088 kB
        Dirty: Memory which is waiting to get written back to the disk
    Writeback: Memory which is actively being written back to the disk
    AnonPages: Non-file backed pages mapped into userspace page tables
+AnonHugePages: Non-file backed huge pages mapped into userspace page tables
       Mapped: files which have been mmaped, such as libraries
         Slab: in-kernel data structures cache
 SReclaimable: Part of Slab, that might be reclaimed, such as caches
diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
index 29bdf62..f734bb2 100644
--- a/Documentation/vm/transhuge.txt
+++ b/Documentation/vm/transhuge.txt
@@ -166,6 +166,68 @@ behavior. So to make them effective you need to restart any
 application that could have been using hugepages. This also applies to
 the regions registered in khugepaged.
 
+== Monitoring usage ==
+
+The number of transparent huge pages currently used by the system is
+available by reading the AnonHugePages field in /proc/meminfo. To
+identify what applications are using transparent huge pages, it is
+necessary to read /proc/PID/smaps and count the AnonHugePages fields
+for each mapping. Note that reading the smaps file is expensive and
+reading it frequently will incur overhead.
+
+There are a number of counters in /proc/vmstat that may be used to
+monitor how successfully the system is providing huge pages for use.
+
+thp_fault_alloc is incremented every time a huge page is successfully
+	allocated to handle a page fault. This applies to both the
+	first time a page is faulted and for COW faults.
+
+thp_collapse_alloc is incremented by khugepaged when it has found
+	a range of pages to collapse into one huge page and has
+	successfully allocated a new huge page to store the data.
+
+thp_fault_fallback is incremented if a page fault fails to allocate
+	a huge page and instead falls back to using small pages.
+
+thp_collapse_alloc_failed is incremented if khugepaged found a range
+	of pages that should be collapsed into one huge page but failed
+	the allocation.
+
+thp_split is incremented every time a huge page is split into base
+	pages. This can happen for a variety of reasons but a common
+	reason is that a huge page is old and is being reclaimed.
+
+As the system ages, allocating huge pages may be expensive as the
+system uses memory compaction to copy data around memory to free a
+huge page for use. There are some counters in /proc/vmstat to help
+monitor this overhead.
+
+compact_stall is incremented every time a process stalls to run
+	memory compaction so that a huge page is free for use.
+
+compact_success is incremented if the system compacted memory and
+	freed a huge page for use.
+
+compact_fail is incremented if the system tries to compact memory
+	but failed.
+
+compact_pages_moved is incremented each time a page is moved. If
+	this value is increasing rapidly, it implies that the system
+	is copying a lot of data to satisfy the huge page allocation.
+	It is possible that the cost of copying exceeds any savings
+	from reduced TLB misses.
+
+compact_pagemigrate_failed is incremented when the underlying mechanism
+	for moving a page failed.
+
+compact_blocks_moved is incremented each time memory compaction examines
+	a huge page aligned range of pages.
+
+It is possible to establish how long the stalls were using the function
+tracer to record how long was spent in __alloc_pages_nodemask and
+using the mm_page_alloc tracepoint to identify which allocations were
+for huge pages.
+
 == get_user_pages and follow_page ==
 
 get_user_pages and follow_page if run on a hugepage, will return the

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
