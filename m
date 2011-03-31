Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 201338D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 16:02:14 -0400 (EDT)
Date: Thu, 31 Mar 2011 13:01:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V3] Add the pagefault count into memcg stats
Message-Id: <20110331130159.24fbad1a.akpm@linux-foundation.org>
In-Reply-To: <1301419953-2282-1-git-send-email-yinghan@google.com>
References: <1301419953-2282-1-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Mark Brown <broonie@opensource.wolfsonmicro.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Tue, 29 Mar 2011 10:32:33 -0700
Ying Han <yinghan@google.com> wrote:

> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -24,6 +24,7 @@ struct mem_cgroup;
>  struct page_cgroup;
>  struct page;
>  struct mm_struct;
> +enum vm_event_item;
>  
>  /* Stats that can be updated by kernel. */
>  enum mem_cgroup_page_stat_item {
>
> ...
>
> @@ -354,6 +356,10 @@ static inline void mem_cgroup_split_huge_fixup(struct page *head,
>  {
>  }
>  
> +static inline
> +void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
> +{
> +}

This doesn't compile for me - parameter idx has an incomplete type.

I've seen this before and I suspect that some (later) versions of gcc
are happy with it, but older gcc's are not.  It's a recurring problem
with enums - forard-declaring them doesn't work.

What I did was to move all the vm_event_item definition into a
standalone header file and then applied the appropriate fixups.  This
was done as a preparatory patch, preceding yours.




From: Andrew Morton <akpm@linux-foundation.org>

enums are problematic because they cannot be forward-declared:

akpm2:/home/akpm> cat t.c

enum foo;

static inline void bar(enum foo f)
{
}
akpm2:/home/akpm> gcc -c t.c
t.c:4: error: parameter 1 ('f') has incomplete type

So move the enum's definition into a standalone header file which can be used
wherever its definition is needed.  

Cc: Ying Han <yinghan@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/vm_event_item.h |   64 ++++++++++++++++++++++++++++++++
 include/linux/vmstat.h        |   62 -------------------------------
 2 files changed, 65 insertions(+), 61 deletions(-)

diff -puN include/linux/vmstat.h~mm-move-enum-vm_event_item-into-a-standalone-header-file include/linux/vmstat.h
--- a/include/linux/vmstat.h~mm-move-enum-vm_event_item-into-a-standalone-header-file
+++ a/include/linux/vmstat.h
@@ -5,69 +5,9 @@
 #include <linux/percpu.h>
 #include <linux/mm.h>
 #include <linux/mmzone.h>
+#include <linux/vm_event_item.h>
 #include <asm/atomic.h>
 
-#ifdef CONFIG_ZONE_DMA
-#define DMA_ZONE(xx) xx##_DMA,
-#else
-#define DMA_ZONE(xx)
-#endif
-
-#ifdef CONFIG_ZONE_DMA32
-#define DMA32_ZONE(xx) xx##_DMA32,
-#else
-#define DMA32_ZONE(xx)
-#endif
-
-#ifdef CONFIG_HIGHMEM
-#define HIGHMEM_ZONE(xx) , xx##_HIGH
-#else
-#define HIGHMEM_ZONE(xx)
-#endif
-
-
-#define FOR_ALL_ZONES(xx) DMA_ZONE(xx) DMA32_ZONE(xx) xx##_NORMAL HIGHMEM_ZONE(xx) , xx##_MOVABLE
-
-enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
-		FOR_ALL_ZONES(PGALLOC),
-		PGFREE, PGACTIVATE, PGDEACTIVATE,
-		PGFAULT, PGMAJFAULT,
-		FOR_ALL_ZONES(PGREFILL),
-		FOR_ALL_ZONES(PGSTEAL),
-		FOR_ALL_ZONES(PGSCAN_KSWAPD),
-		FOR_ALL_ZONES(PGSCAN_DIRECT),
-#ifdef CONFIG_NUMA
-		PGSCAN_ZONE_RECLAIM_FAILED,
-#endif
-		PGINODESTEAL, SLABS_SCANNED, KSWAPD_STEAL, KSWAPD_INODESTEAL,
-		KSWAPD_LOW_WMARK_HIT_QUICKLY, KSWAPD_HIGH_WMARK_HIT_QUICKLY,
-		KSWAPD_SKIP_CONGESTION_WAIT,
-		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
-#ifdef CONFIG_COMPACTION
-		COMPACTBLOCKS, COMPACTPAGES, COMPACTPAGEFAILED,
-		COMPACTSTALL, COMPACTFAIL, COMPACTSUCCESS,
-#endif
-#ifdef CONFIG_HUGETLB_PAGE
-		HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,
-#endif
-		UNEVICTABLE_PGCULLED,	/* culled to noreclaim list */
-		UNEVICTABLE_PGSCANNED,	/* scanned for reclaimability */
-		UNEVICTABLE_PGRESCUED,	/* rescued from noreclaim list */
-		UNEVICTABLE_PGMLOCKED,
-		UNEVICTABLE_PGMUNLOCKED,
-		UNEVICTABLE_PGCLEARED,	/* on COW, page truncate */
-		UNEVICTABLE_PGSTRANDED,	/* unable to isolate on unlock */
-		UNEVICTABLE_MLOCKFREED,
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-		THP_FAULT_ALLOC,
-		THP_FAULT_FALLBACK,
-		THP_COLLAPSE_ALLOC,
-		THP_COLLAPSE_ALLOC_FAILED,
-		THP_SPLIT,
-#endif
-		NR_VM_EVENT_ITEMS
-};
-
 extern int sysctl_stat_interval;
 
 #ifdef CONFIG_VM_EVENT_COUNTERS
diff -puN /dev/null include/linux/vm_event_item.h
--- /dev/null
+++ a/include/linux/vm_event_item.h
@@ -0,0 +1,64 @@
+#ifndef VM_EVENT_ITEM_H_INCLUDED
+#define VM_EVENT_ITEM_H_INCLUDED
+
+#ifdef CONFIG_ZONE_DMA
+#define DMA_ZONE(xx) xx##_DMA,
+#else
+#define DMA_ZONE(xx)
+#endif
+
+#ifdef CONFIG_ZONE_DMA32
+#define DMA32_ZONE(xx) xx##_DMA32,
+#else
+#define DMA32_ZONE(xx)
+#endif
+
+#ifdef CONFIG_HIGHMEM
+#define HIGHMEM_ZONE(xx) , xx##_HIGH
+#else
+#define HIGHMEM_ZONE(xx)
+#endif
+
+#define FOR_ALL_ZONES(xx) DMA_ZONE(xx) DMA32_ZONE(xx) xx##_NORMAL HIGHMEM_ZONE(xx) , xx##_MOVABLE
+
+enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
+		FOR_ALL_ZONES(PGALLOC),
+		PGFREE, PGACTIVATE, PGDEACTIVATE,
+		PGFAULT, PGMAJFAULT,
+		FOR_ALL_ZONES(PGREFILL),
+		FOR_ALL_ZONES(PGSTEAL),
+		FOR_ALL_ZONES(PGSCAN_KSWAPD),
+		FOR_ALL_ZONES(PGSCAN_DIRECT),
+#ifdef CONFIG_NUMA
+		PGSCAN_ZONE_RECLAIM_FAILED,
+#endif
+		PGINODESTEAL, SLABS_SCANNED, KSWAPD_STEAL, KSWAPD_INODESTEAL,
+		KSWAPD_LOW_WMARK_HIT_QUICKLY, KSWAPD_HIGH_WMARK_HIT_QUICKLY,
+		KSWAPD_SKIP_CONGESTION_WAIT,
+		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
+#ifdef CONFIG_COMPACTION
+		COMPACTBLOCKS, COMPACTPAGES, COMPACTPAGEFAILED,
+		COMPACTSTALL, COMPACTFAIL, COMPACTSUCCESS,
+#endif
+#ifdef CONFIG_HUGETLB_PAGE
+		HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,
+#endif
+		UNEVICTABLE_PGCULLED,	/* culled to noreclaim list */
+		UNEVICTABLE_PGSCANNED,	/* scanned for reclaimability */
+		UNEVICTABLE_PGRESCUED,	/* rescued from noreclaim list */
+		UNEVICTABLE_PGMLOCKED,
+		UNEVICTABLE_PGMUNLOCKED,
+		UNEVICTABLE_PGCLEARED,	/* on COW, page truncate */
+		UNEVICTABLE_PGSTRANDED,	/* unable to isolate on unlock */
+		UNEVICTABLE_MLOCKFREED,
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+		THP_FAULT_ALLOC,
+		THP_FAULT_FALLBACK,
+		THP_COLLAPSE_ALLOC,
+		THP_COLLAPSE_ALLOC_FAILED,
+		THP_SPLIT,
+#endif
+		NR_VM_EVENT_ITEMS
+};
+
+#endif		/* VM_EVENT_ITEM_H_INCLUDED */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
