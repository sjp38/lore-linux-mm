Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 158F68D0040
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 17:56:07 -0400 (EDT)
Date: Wed, 30 Mar 2011 14:45:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 8/8] Add VM counters for transparent hugepages
Message-Id: <20110330144507.2c0ecf73.akpm@linux-foundation.org>
In-Reply-To: <20110308114159.7EAD.A69D9226@jp.fujitsu.com>
References: <20110307172609.8A01.A69D9226@jp.fujitsu.com>
	<20110307163513.GC13384@alboin.amr.corp.intel.com>
	<20110308114159.7EAD.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andi Kleen <ak@linux.intel.com>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue,  8 Mar 2011 11:43:23 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > > Don't we need to make per zone stastics? I'm afraid small dma zone 
> > > makes much thp-splitting and screw up this stastics.
> > 
> > Does it? I haven't seen that so far.
> > 
> > If it happens a lot it would be better to disable THP for the 16MB DMA
> > zone at least. Or did you mean the 4GB zone?
> 
> I assumered 4GB. And cpusets/mempolicy binding might makes similar 
> issue. It can make only one zone high pressure.
> 
> But, hmmm...
> Do you mean you don't hit any issue then? I don't think do don't tested
> NUMA machine. So, it has  no practical problem I can agree this.
> 

I didn't actually merge this patch because I assumed you guys were
still arguing over it.  But I now see you weren't.

Do we still want it?  Are we sure we don't want the per-zone numbers?


From: Andi Kleen <ak@linux.intel.com>

I found it difficult to make sense of transparent huge pages without
having any counters for its actions.  Add some counters to vmstat for
allocation of transparent hugepages and fallback to smaller pages.

Optional patch, but useful for development and understanding the system.

Contains improvements from Andrea Arcangeli and Johannes Weiner

[akpm@linux-foundation.org: coding-style fixes]
[hannes@cmpxchg.org: fix vmstat_text[] entries]
Signed-off-by: Andi Kleen <ak@linux.intel.com>
Acked-by: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/vmstat.h |    7 +++++++
 mm/huge_memory.c       |   25 +++++++++++++++++++++----
 mm/vmstat.c            |    9 +++++++++
 3 files changed, 37 insertions(+), 4 deletions(-)

diff -puN include/linux/vmstat.h~mm-add-vm-counters-for-transparent-hugepages include/linux/vmstat.h
--- a/include/linux/vmstat.h~mm-add-vm-counters-for-transparent-hugepages
+++ a/include/linux/vmstat.h
@@ -58,6 +58,13 @@ enum vm_event_item { PGPGIN, PGPGOUT, PS
 		UNEVICTABLE_PGCLEARED,	/* on COW, page truncate */
 		UNEVICTABLE_PGSTRANDED,	/* unable to isolate on unlock */
 		UNEVICTABLE_MLOCKFREED,
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+		THP_FAULT_ALLOC,
+		THP_FAULT_FALLBACK,
+		THP_COLLAPSE_ALLOC,
+		THP_COLLAPSE_ALLOC_FAILED,
+		THP_SPLIT,
+#endif
 		NR_VM_EVENT_ITEMS
 };
 
diff -puN mm/huge_memory.c~mm-add-vm-counters-for-transparent-hugepages mm/huge_memory.c
--- a/mm/huge_memory.c~mm-add-vm-counters-for-transparent-hugepages
+++ a/mm/huge_memory.c
@@ -680,8 +680,11 @@ int do_huge_pmd_anonymous_page(struct mm
 			return VM_FAULT_OOM;
 		page = alloc_hugepage_vma(transparent_hugepage_defrag(vma),
 					  vma, haddr, numa_node_id(), 0);
-		if (unlikely(!page))
+		if (unlikely(!page)) {
+			count_vm_event(THP_FAULT_FALLBACK);
 			goto out;
+		}
+		count_vm_event(THP_FAULT_ALLOC);
 		if (unlikely(mem_cgroup_newpage_charge(page, mm, GFP_KERNEL))) {
 			put_page(page);
 			goto out;
@@ -909,11 +912,13 @@ int do_huge_pmd_wp_page(struct mm_struct
 		new_page = NULL;
 
 	if (unlikely(!new_page)) {
+		count_vm_event(THP_FAULT_FALLBACK);
 		ret = do_huge_pmd_wp_page_fallback(mm, vma, address,
 						   pmd, orig_pmd, page, haddr);
 		put_page(page);
 		goto out;
 	}
+	count_vm_event(THP_FAULT_ALLOC);
 
 	if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))) {
 		put_page(new_page);
@@ -1390,6 +1395,7 @@ int split_huge_page(struct page *page)
 
 	BUG_ON(!PageSwapBacked(page));
 	__split_huge_page(page, anon_vma);
+	count_vm_event(THP_SPLIT);
 
 	BUG_ON(PageCompound(page));
 out_unlock:
@@ -1784,9 +1790,11 @@ static void collapse_huge_page(struct mm
 				      node, __GFP_OTHER_NODE);
 	if (unlikely(!new_page)) {
 		up_read(&mm->mmap_sem);
+		count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
 		*hpage = ERR_PTR(-ENOMEM);
 		return;
 	}
+	count_vm_event(THP_COLLAPSE_ALLOC);
 	if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))) {
 		up_read(&mm->mmap_sem);
 		put_page(new_page);
@@ -2151,8 +2159,11 @@ static void khugepaged_do_scan(struct pa
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
@@ -2192,8 +2203,11 @@ static struct page *khugepaged_alloc_hug
 
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
@@ -2210,8 +2224,11 @@ static void khugepaged_loop(void)
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
diff -puN mm/vmstat.c~mm-add-vm-counters-for-transparent-hugepages mm/vmstat.c
--- a/mm/vmstat.c~mm-add-vm-counters-for-transparent-hugepages
+++ a/mm/vmstat.c
@@ -951,7 +951,16 @@ static const char * const vmstat_text[] 
 	"unevictable_pgs_cleared",
 	"unevictable_pgs_stranded",
 	"unevictable_pgs_mlockfreed",
+
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	"thp_fault_alloc",
+	"thp_fault_fallback",
+	"thp_collapse_alloc",
+	"thp_collapse_alloc_failed",
+	"thp_split",
 #endif
+
+#endif /* CONFIG_VM_EVENTS_COUNTERS */
 };
 
 static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
