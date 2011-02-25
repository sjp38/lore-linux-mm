Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 45B608D0039
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 20:34:29 -0500 (EST)
Date: Fri, 25 Feb 2011 02:34:13 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 8/8] Add VM counters for transparent hugepages
Message-ID: <20110225013413.GI23252@random.random>
References: <1298425922-23630-1-git-send-email-andi@firstfloor.org>
 <1298425922-23630-9-git-send-email-andi@firstfloor.org>
 <20110225005155.GH23252@random.random>
 <20110225011205.GK5818@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110225011205.GK5818@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>

On Fri, Feb 25, 2011 at 02:12:05AM +0100, Andi Kleen wrote:
> On Fri, Feb 25, 2011 at 01:51:55AM +0100, Andrea Arcangeli wrote:
> > On Tue, Feb 22, 2011 at 05:52:02PM -0800, Andi Kleen wrote:
> > > +	"thp_direct_alloc",
> > > +	"thp_daemon_alloc",
> > > +	"thp_direct_fallback",
> > > +	"thp_daemon_alloc_failed",
> > 
> > I've been wondering if we should do s/daemon/khugepaged/ or
> 
> Fine by me.
> 
> > s/daemon/collapse/.
> > 
> > And s/direct/fault/.
> 
> Fine for me too.

So this would be it. (incremental with previous patch I sent that
adjusts the location of THP_SPLIT)

===
Subject: thp: make vmstat more accurate

From: Andrea Arcangeli <aarcange@redhat.com>

s/direct/fault/g s/daemon/collapse/g

It's better to account even if memcg fails if the allocation succeeded so
it gives a bit more accurate ratios on the effectiveness of the VM in
creating hugepages. This adds coverage to the not NUMA case and it actually
uses THP_COLLAPSE_ALLOC. The thp_collapse_alloc is closely related to the
/sys/kernel/mm/transparent_hugepage/khugepaged/pages_collapsed but just like
for memcg this also accounts when the strict _allocation_ succeed but the
collapse can't go through after releasing the mmap_sem for a little
(pages_collapsed only accounts when the collapse really went through in
addition to the strict THP allocation).

Output under heavy swap load with khugepaged scan_sleep_millisecs=0
(and new kswapd compaction logic) follows.

$ vmstat 1
procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 5 10 3390416 147772   2108   8476    0 42196     0 42196 6908  610  0  1 88 11
 1 12 3493968 153624   2104   8968    0 103552     0 103552 2664  901  0  6 41 52
 1 13 3598636 158336   2104   8404    0 104668     0 104668  778  431  0  5 60 34
 1 12 3377120 130148   2104   7576  184 42120   184 42120  998  399  0  5 38 57
 0 11 2419352 149360   2104   8844  232 19936   232 19936 9028  718  3  4 83 11
 0 13 2488964 139476   2104   8036    0 76184     0 76184 3340 1133  0  1 89 11
$ grep thp /proc/vmstat 
thp_fault_alloc 44725
thp_fault_fallback 364
thp_collapse_alloc 59
thp_collapse_alloc_failed 3
thp_split 14223

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/vmstat.h |    8 ++++----
 mm/huge_memory.c       |   27 +++++++++++++++++++--------
 mm/vmstat.c            |    8 ++++----
 3 files changed, 27 insertions(+), 16 deletions(-)

--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -59,10 +59,10 @@ enum vm_event_item { PGPGIN, PGPGOUT, PS
 		UNEVICTABLE_PGSTRANDED,	/* unable to isolate on unlock */
 		UNEVICTABLE_MLOCKFREED,
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	        THP_DIRECT_ALLOC,
-		THP_DAEMON_ALLOC,
-		THP_DIRECT_FALLBACK,
-		THP_DAEMON_ALLOC_FAILED,
+	        THP_FAULT_ALLOC,
+		THP_FAULT_FALLBACK,
+		THP_COLLAPSE_ALLOC,
+		THP_COLLAPSE_ALLOC_FAILED,
 		THP_SPLIT,
 #endif
 		NR_VM_EVENT_ITEMS
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -681,14 +681,14 @@ int do_huge_pmd_anonymous_page(struct mm
 		page = alloc_hugepage_vma(transparent_hugepage_defrag(vma),
 					  vma, haddr, numa_node_id(), 0);
 		if (unlikely(!page)) {
-			count_vm_event(THP_DIRECT_FALLBACK);
+			count_vm_event(THP_FAULT_FALLBACK);
 			goto out;
 		}
+		count_vm_event(THP_FAULT_ALLOC);
 		if (unlikely(mem_cgroup_newpage_charge(page, mm, GFP_KERNEL))) {
 			put_page(page);
 			goto out;
 		}
-		count_vm_event(THP_DIRECT_ALLOC);
 		return __do_huge_pmd_anonymous_page(mm, vma, haddr, pmd, page);
 	}
 out:
@@ -911,12 +911,13 @@ int do_huge_pmd_wp_page(struct mm_struct
 		new_page = NULL;
 
 	if (unlikely(!new_page)) {
-		count_vm_event(THP_DIRECT_FALLBACK);
+		count_vm_event(THP_FAULT_FALLBACK);
 		ret = do_huge_pmd_wp_page_fallback(mm, vma, address,
 						   pmd, orig_pmd, page, haddr);
 		put_page(page);
 		goto out;
 	}
+	count_vm_event(THP_FAULT_ALLOC);
 
 	if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))) {
 		put_page(new_page);
@@ -924,7 +925,7 @@ int do_huge_pmd_wp_page(struct mm_struct
 		ret |= VM_FAULT_OOM;
 		goto out;
 	}
-	count_vm_event(THP_DIRECT_ALLOC);
+
 	copy_user_huge_page(new_page, page, haddr, vma, HPAGE_PMD_NR);
 	__SetPageUptodate(new_page);
 
@@ -1784,10 +1785,11 @@ static void collapse_huge_page(struct mm
 				      node, __GFP_OTHER_NODE);
 	if (unlikely(!new_page)) {
 		up_read(&mm->mmap_sem);
-		count_vm_event(THP_DAEMON_ALLOC_FAILED);
+		count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
 		*hpage = ERR_PTR(-ENOMEM);
 		return;
 	}
+	count_vm_event(THP_COLLAPSE_ALLOC);
 #endif
 	if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))) {
 		up_read(&mm->mmap_sem);
@@ -2152,8 +2154,11 @@ static void khugepaged_do_scan(struct pa
 #ifndef CONFIG_NUMA
 		if (!*hpage) {
 			*hpage = alloc_hugepage(khugepaged_defrag());
-			if (unlikely(!*hpage))
+			if (unlikely(!*hpage)) {
+				count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
 				break;
+			}
+			count_vm_event(THP_COLLAPSE_ALLOC);
 		}
 #else
 		if (IS_ERR(*hpage))
@@ -2193,8 +2198,11 @@ static struct page *khugepaged_alloc_hug
 
 	do {
 		hpage = alloc_hugepage(khugepaged_defrag());
-		if (!hpage)
+		if (!hpage) {
+			count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
 			khugepaged_alloc_sleep();
+		} else
+			count_vm_event(THP_COLLAPSE_ALLOC);
 	} while (unlikely(!hpage) &&
 		 likely(khugepaged_enabled()));
 	return hpage;
@@ -2211,8 +2219,11 @@ static void khugepaged_loop(void)
 	while (likely(khugepaged_enabled())) {
 #ifndef CONFIG_NUMA
 		hpage = khugepaged_alloc_hugepage();
-		if (unlikely(!hpage))
+		if (unlikely(!hpage)) {
+			count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
 			break;
+		}
+		count_vm_event(THP_COLLAPSE_ALLOC);
 #else
 		if (IS_ERR(hpage)) {
 			khugepaged_alloc_sleep();
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -948,10 +948,10 @@ static const char * const vmstat_text[] 
 #endif
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	"thp_direct_alloc",
-	"thp_daemon_alloc",
-	"thp_direct_fallback",
-	"thp_daemon_alloc_failed",
+	"thp_fault_alloc",
+	"thp_fault_fallback",
+	"thp_collapse_alloc",
+	"thp_collapse_alloc_failure",
 	"thp_split",
 #endif
 };

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
