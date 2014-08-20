Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 854416B0037
	for <linux-mm@kvack.org>; Wed, 20 Aug 2014 19:46:16 -0400 (EDT)
Received: by mail-qg0-f52.google.com with SMTP id f51so8248074qge.11
        for <linux-mm@kvack.org>; Wed, 20 Aug 2014 16:46:16 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g106si36462102qge.32.2014.08.20.16.46.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Aug 2014 16:46:16 -0700 (PDT)
Date: Wed, 20 Aug 2014 20:46:05 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH 5/7] mm: introduce common page state for ballooned memory
Message-ID: <20140820234605.GE3457@optiplex.redhat.com>
References: <20140820150435.4194.28003.stgit@buzz>
 <20140820150458.4194.58775.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140820150458.4194.58775.stgit@buzz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, linux-kernel@vger.kernel.org

On Wed, Aug 20, 2014 at 07:04:58PM +0400, Konstantin Khlebnikov wrote:
> This patch adds page state PageBallon() and functions __Set/ClearPageBalloon.
> Like PageBuddy() PageBalloon() looks like page-flag but actually this is special
> state of page->_mapcount counter. There is no conflict because ballooned pages
> cannot be mapped and cannot be in buddy allocator.
> 
> Ballooned pages are counted in vmstat counter NR_BALLOON_PAGES, it's shown them
> in /proc/meminfo and /proc/meminfo. Also this patch it exports PageBallon into
> userspace via /proc/kpageflags as KPF_BALLOON.
> 
> All this code including mm/balloon_compaction.o is under CONFIG_MEMORY_BALLOON,
> it should be selected by ballooning driver which want use this feature.
> 

Very nice overhaul Konstantin!
Please, consider the nits I have below:


> Signed-off-by: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
> ---
>  Documentation/filesystems/proc.txt     |    2 ++
>  drivers/base/node.c                    |   16 ++++++++++------
>  drivers/virtio/Kconfig                 |    1 +
>  fs/proc/meminfo.c                      |    6 ++++++
>  fs/proc/page.c                         |    3 +++
>  include/linux/mm.h                     |   10 ++++++++++
>  include/linux/mmzone.h                 |    3 +++
>  include/uapi/linux/kernel-page-flags.h |    1 +
>  mm/Kconfig                             |    5 +++++
>  mm/Makefile                            |    3 ++-
>  mm/balloon_compaction.c                |   14 ++++++++++++++
>  mm/vmstat.c                            |    8 +++++++-
>  tools/vm/page-types.c                  |    1 +
>  13 files changed, 65 insertions(+), 8 deletions(-)
> 
> diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
> index eb8a10e..154a345 100644
> --- a/Documentation/filesystems/proc.txt
> +++ b/Documentation/filesystems/proc.txt
> @@ -796,6 +796,7 @@ VmallocTotal:   112216 kB
>  VmallocUsed:       428 kB
>  VmallocChunk:   111088 kB
>  AnonHugePages:   49152 kB
> +BalloonPages:        0 kB
>  
>      MemTotal: Total usable ram (i.e. physical ram minus a few reserved
>                bits and the kernel binary code)
> @@ -838,6 +839,7 @@ MemAvailable: An estimate of how much memory is available for starting new
>     Writeback: Memory which is actively being written back to the disk
>     AnonPages: Non-file backed pages mapped into userspace page tables
>  AnonHugePages: Non-file backed huge pages mapped into userspace page tables
> +BalloonPages: Memory which was ballooned, not included into MemTotal
>        Mapped: files which have been mmaped, such as libraries
>          Slab: in-kernel data structures cache
>  SReclaimable: Part of Slab, that might be reclaimed, such as caches
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index c6d3ae0..59e565c 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -120,6 +120,9 @@ static ssize_t node_read_meminfo(struct device *dev,
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>  		       "Node %d AnonHugePages:  %8lu kB\n"
>  #endif
> +#ifdef CONFIG_MEMORY_BALLOON
> +		       "Node %d BalloonPages:   %8lu kB\n"
> +#endif
>  			,
>  		       nid, K(node_page_state(nid, NR_FILE_DIRTY)),
>  		       nid, K(node_page_state(nid, NR_WRITEBACK)),
> @@ -136,14 +139,15 @@ static ssize_t node_read_meminfo(struct device *dev,
>  		       nid, K(node_page_state(nid, NR_SLAB_RECLAIMABLE) +
>  				node_page_state(nid, NR_SLAB_UNRECLAIMABLE)),
>  		       nid, K(node_page_state(nid, NR_SLAB_RECLAIMABLE)),
> -#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>  		       nid, K(node_page_state(nid, NR_SLAB_UNRECLAIMABLE))
> -			, nid,
> -			K(node_page_state(nid, NR_ANON_TRANSPARENT_HUGEPAGES) *
> -			HPAGE_PMD_NR));
> -#else
> -		       nid, K(node_page_state(nid, NR_SLAB_UNRECLAIMABLE)));
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +		       ,nid, K(node_page_state(nid,
> +				NR_ANON_TRANSPARENT_HUGEPAGES) * HPAGE_PMD_NR)
> +#endif
> +#ifdef CONFIG_MEMORY_BALLOON
> +		       ,nid, K(node_page_state(nid, NR_BALLOON_PAGES))
>  #endif
> +		       );
>  	n += hugetlb_report_node_meminfo(nid, buf + n);
>  	return n;
>  }
> diff --git a/drivers/virtio/Kconfig b/drivers/virtio/Kconfig
> index c6683f2..00b2286 100644
> --- a/drivers/virtio/Kconfig
> +++ b/drivers/virtio/Kconfig
> @@ -25,6 +25,7 @@ config VIRTIO_PCI
>  config VIRTIO_BALLOON
>  	tristate "Virtio balloon driver"
>  	depends on VIRTIO
> +	select MEMORY_BALLOON
>  	---help---
>  	 This driver supports increasing and decreasing the amount
>  	 of memory within a KVM guest.
> diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
> index aa1eee0..f897fbf 100644
> --- a/fs/proc/meminfo.c
> +++ b/fs/proc/meminfo.c
> @@ -138,6 +138,9 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>  		"AnonHugePages:  %8lu kB\n"
>  #endif
> +#ifdef CONFIG_MEMORY_BALLOON
> +		"BalloonPages:   %8lu kB\n"
> +#endif
>  		,
>  		K(i.totalram),
>  		K(i.freeram),
> @@ -193,6 +196,9 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
>  		,K(global_page_state(NR_ANON_TRANSPARENT_HUGEPAGES) *
>  		   HPAGE_PMD_NR)
>  #endif
> +#ifdef CONFIG_MEMORY_BALLOON
> +		,K(global_page_state(NR_BALLOON_PAGES))
> +#endif
>  		);
>  
>  	hugetlb_report_meminfo(m);
> diff --git a/fs/proc/page.c b/fs/proc/page.c
> index e647c55..1e3187d 100644
> --- a/fs/proc/page.c
> +++ b/fs/proc/page.c
> @@ -133,6 +133,9 @@ u64 stable_page_flags(struct page *page)
>  	if (PageBuddy(page))
>  		u |= 1 << KPF_BUDDY;
>  
> +	if (PageBalloon(page))
> +		u |= 1 << KPF_BALLOON;
> +
>  	u |= kpf_copy_bit(k, KPF_LOCKED,	PG_locked);
>  
>  	u |= kpf_copy_bit(k, KPF_SLAB,		PG_slab);
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 8981cc8..d2dd497 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -553,6 +553,16 @@ static inline void __ClearPageBuddy(struct page *page)
>  	atomic_set(&page->_mapcount, -1);
>  }
>  
> +#define PAGE_BALLOON_MAPCOUNT_VALUE (-256)
> +
> +static inline int PageBalloon(struct page *page)
> +{
> +	return IS_ENABLED(CONFIG_MEMORY_BALLOON) &&
> +		atomic_read(&page->_mapcount) == PAGE_BALLOON_MAPCOUNT_VALUE;
> +}
> +void __SetPageBalloon(struct page *page);
> +void __ClearPageBalloon(struct page *page);
> +

1) I think you should consider the following here:

-void __SetPageBalloon(struct page *page);
-void __ClearPageBalloon(struct page *page);
+
+static inline void __SetPageBalloon(struct page *page)
+{
+#ifdef CONFIG_MEMORY_BALLOON
+        VM_BUG_ON_PAGE(atomic_read(&page->_mapcount) != -1, page);
+        atomic_set(&page->_mapcount, PAGE_BALLOON_MAPCOUNT_VALUE);
+#endif
+}
+
+static inline void __ClearPageBalloon(struct page *page)
+{
+#ifdef CONFIG_MEMORY_BALLOON
+        VM_BUG_ON_PAGE(!PageBalloon(page), page);
+        atomic_set(&page->_mapcount, -1);
+#endif
+}




>  void put_page(struct page *page);
>  void put_pages_list(struct list_head *pages);
>  
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 318df70..d88fd01 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -157,6 +157,9 @@ enum zone_stat_item {
>  	WORKINGSET_NODERECLAIM,
>  	NR_ANON_TRANSPARENT_HUGEPAGES,
>  	NR_FREE_CMA_PAGES,
> +#ifdef CONFIG_MEMORY_BALLOON
> +	NR_BALLOON_PAGES,
> +#endif
>  	NR_VM_ZONE_STAT_ITEMS };
>  
>  /*
> diff --git a/include/uapi/linux/kernel-page-flags.h b/include/uapi/linux/kernel-page-flags.h
> index 5116a0e..2f96d23 100644
> --- a/include/uapi/linux/kernel-page-flags.h
> +++ b/include/uapi/linux/kernel-page-flags.h
> @@ -31,6 +31,7 @@
>  
>  #define KPF_KSM			21
>  #define KPF_THP			22
> +#define KPF_BALLOON		23
>  
>  
>  #endif /* _UAPILINUX_KERNEL_PAGE_FLAGS_H */
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 886db21..72e0db0 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -228,6 +228,11 @@ config ARCH_ENABLE_SPLIT_PMD_PTLOCK
>  	boolean
>  
>  #
> +# support for memory ballooning
> +config MEMORY_BALLOON
> +	boolean
> +
> +#
>  # support for memory balloon compaction
>  config BALLOON_COMPACTION
>  	bool "Allow for balloon memory compaction/migration"
> diff --git a/mm/Makefile b/mm/Makefile
> index 632ae77..2d33d7f 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -16,7 +16,7 @@ obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
>  			   readahead.o swap.o truncate.o vmscan.o shmem.o \
>  			   util.o mmzone.o vmstat.o backing-dev.o \
>  			   mm_init.o mmu_context.o percpu.o slab_common.o \
> -			   compaction.o balloon_compaction.o vmacache.o \
> +			   compaction.o vmacache.o \
>  			   interval_tree.o list_lru.o workingset.o \
>  			   iov_iter.o $(mmu-y)
>  
> @@ -64,3 +64,4 @@ obj-$(CONFIG_ZBUD)	+= zbud.o
>  obj-$(CONFIG_ZSMALLOC)	+= zsmalloc.o
>  obj-$(CONFIG_GENERIC_EARLY_IOREMAP) += early_ioremap.o
>  obj-$(CONFIG_CMA)	+= cma.o
> +obj-$(CONFIG_MEMORY_BALLOON) += balloon_compaction.o
> diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
> index 6e45a50..533c567 100644
> --- a/mm/balloon_compaction.c
> +++ b/mm/balloon_compaction.c
> @@ -10,6 +10,20 @@
>  #include <linux/export.h>
>  #include <linux/balloon_compaction.h>
>  
> +void __SetPageBalloon(struct page *page)
> +{
> +	VM_BUG_ON_PAGE(atomic_read(&page->_mapcount) != -1, page);
> +	atomic_set(&page->_mapcount, PAGE_BALLOON_MAPCOUNT_VALUE);
> +	inc_zone_page_state(page, NR_BALLOON_PAGES);
> +}
> +
> +void __ClearPageBalloon(struct page *page)
> +{
> +	VM_BUG_ON_PAGE(!PageBalloon(page), page);
> +	atomic_set(&page->_mapcount, -1);
> +	dec_zone_page_state(page, NR_BALLOON_PAGES);
> +}
> +

and if you go with (1), here:
-void __SetPageBalloon(struct page *page)
-{
-       VM_BUG_ON_PAGE(atomic_read(&page->_mapcount) != -1, page);
-       atomic_set(&page->_mapcount, PAGE_BALLOON_MAPCOUNT_VALUE);
-       inc_zone_page_state(page, NR_BALLOON_PAGES);
-}
-
-void __ClearPageBalloon(struct page *page)
-{
-       VM_BUG_ON_PAGE(!PageBalloon(page), page);
-       atomic_set(&page->_mapcount, -1);
-       dec_zone_page_state(page, NR_BALLOON_PAGES);
-}


>  /*
>   * balloon_devinfo_alloc - allocates a balloon device information descriptor.
>   * @balloon_dev_descriptor: pointer to reference the balloon device which
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index e9ab104..6e704cc 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -735,7 +735,7 @@ static void walk_zones_in_node(struct seq_file *m, pg_data_t *pgdat,
>  					TEXT_FOR_HIGHMEM(xx) xx "_movable",
>  
>  const char * const vmstat_text[] = {
> -	/* Zoned VM counters */
> +	/* enum zone_stat_item countes */
>  	"nr_free_pages",
>  	"nr_alloc_batch",
>  	"nr_inactive_anon",
> @@ -778,10 +778,16 @@ const char * const vmstat_text[] = {
>  	"workingset_nodereclaim",
>  	"nr_anon_transparent_hugepages",
>  	"nr_free_cma",
> +#ifdef CONFIG_MEMORY_BALLOON
> +	"nr_balloon_pages",
> +#endif
> +
> +	/* enum writeback_stat_item counters */
>  	"nr_dirty_threshold",
>  	"nr_dirty_background_threshold",
>  
>  #ifdef CONFIG_VM_EVENT_COUNTERS
> +	/* enum vm_event_item counters */
>  	"pgpgin",
>  	"pgpgout",
>  	"pswpin",
> diff --git a/tools/vm/page-types.c b/tools/vm/page-types.c
> index c4d6d2e..264fbc2 100644
> --- a/tools/vm/page-types.c
> +++ b/tools/vm/page-types.c
> @@ -132,6 +132,7 @@ static const char * const page_flag_names[] = {
>  	[KPF_NOPAGE]		= "n:nopage",
>  	[KPF_KSM]		= "x:ksm",
>  	[KPF_THP]		= "t:thp",
> +	[KPF_BALLOON]		= "o:balloon",
>  
>  	[KPF_RESERVED]		= "r:reserved",
>  	[KPF_MLOCKED]		= "m:mlocked",
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
