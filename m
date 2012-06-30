Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 689F36B007D
	for <linux-mm@kvack.org>; Sat, 30 Jun 2012 01:24:10 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so2390262qcs.14
        for <linux-mm@kvack.org>; Fri, 29 Jun 2012 22:24:09 -0700 (PDT)
Date: Sat, 30 Jun 2012 01:24:05 -0400
From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Subject: Re: [PATCH 36/40] autonuma: page_autonuma
Message-ID: <20120630052404.GH3975@localhost.localdomain>
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
 <1340888180-15355-37-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340888180-15355-37-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Thu, Jun 28, 2012 at 02:56:16PM +0200, Andrea Arcangeli wrote:
> Move the AutoNUMA per page information from the "struct page" to a
> separate page_autonuma data structure allocated in the memsection
> (with sparsemem) or in the pgdat (with flatmem).
> 
> This is done to avoid growing the size of the "struct page" and the
> page_autonuma data is only allocated if the kernel has been booted on
> real NUMA hardware (or if noautonuma is passed as parameter to the
> kernel).
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  include/linux/autonuma.h       |   18 +++-
>  include/linux/autonuma_flags.h |    6 +
>  include/linux/autonuma_types.h |   55 ++++++++++
>  include/linux/mm_types.h       |   26 -----
>  include/linux/mmzone.h         |   14 +++-
>  include/linux/page_autonuma.h  |   53 +++++++++
>  init/main.c                    |    2 +
>  mm/Makefile                    |    2 +-
>  mm/autonuma.c                  |   98 ++++++++++-------
>  mm/huge_memory.c               |   26 +++--
>  mm/page_alloc.c                |   21 +---
>  mm/page_autonuma.c             |  234 ++++++++++++++++++++++++++++++++++++++++
>  mm/sparse.c                    |  126 ++++++++++++++++++++-
>  13 files changed, 577 insertions(+), 104 deletions(-)
>  create mode 100644 include/linux/page_autonuma.h
>  create mode 100644 mm/page_autonuma.c
> 
> diff --git a/include/linux/autonuma.h b/include/linux/autonuma.h
> index 85ca5eb..67af86a 100644
> --- a/include/linux/autonuma.h
> +++ b/include/linux/autonuma.h
> @@ -7,15 +7,26 @@
>  
>  extern void autonuma_enter(struct mm_struct *mm);
>  extern void autonuma_exit(struct mm_struct *mm);
> -extern void __autonuma_migrate_page_remove(struct page *page);
> +extern void __autonuma_migrate_page_remove(struct page *,
> +					   struct page_autonuma *);
>  extern void autonuma_migrate_split_huge_page(struct page *page,
>  					     struct page *page_tail);
>  extern void autonuma_setup_new_exec(struct task_struct *p);
> +extern struct page_autonuma *lookup_page_autonuma(struct page *page);
>  
>  static inline void autonuma_migrate_page_remove(struct page *page)
>  {
> -	if (ACCESS_ONCE(page->autonuma_migrate_nid) >= 0)
> -		__autonuma_migrate_page_remove(page);
> +	struct page_autonuma *page_autonuma = lookup_page_autonuma(page);
> +	if (ACCESS_ONCE(page_autonuma->autonuma_migrate_nid) >= 0)
> +		__autonuma_migrate_page_remove(page, page_autonuma);
> +}
> +
> +static inline void autonuma_free_page(struct page *page)
> +{
> +	if (!autonuma_impossible()) {

I think you are better using a different name.

Perhaps 'if (autonuma_on())'

> +		autonuma_migrate_page_remove(page);
> +		lookup_page_autonuma(page)->autonuma_last_nid = -1;
> +	}
>  }
>  
>  #define autonuma_printk(format, args...) \
> @@ -29,6 +40,7 @@ static inline void autonuma_migrate_page_remove(struct page *page) {}
>  static inline void autonuma_migrate_split_huge_page(struct page *page,
>  						    struct page *page_tail) {}
>  static inline void autonuma_setup_new_exec(struct task_struct *p) {}
> +static inline void autonuma_free_page(struct page *page) {}
>  
>  #endif /* CONFIG_AUTONUMA */
>  
> diff --git a/include/linux/autonuma_flags.h b/include/linux/autonuma_flags.h
> index 5e29a75..035d993 100644
> --- a/include/linux/autonuma_flags.h
> +++ b/include/linux/autonuma_flags.h
> @@ -15,6 +15,12 @@ enum autonuma_flag {
>  
>  extern unsigned long autonuma_flags;
>  
> +static inline bool autonuma_impossible(void)
> +{
> +	return num_possible_nodes() <= 1 ||
> +		test_bit(AUTONUMA_IMPOSSIBLE_FLAG, &autonuma_flags);
> +}
> +
>  static inline bool autonuma_enabled(void)
>  {
>  	return !!test_bit(AUTONUMA_FLAG, &autonuma_flags);
> diff --git a/include/linux/autonuma_types.h b/include/linux/autonuma_types.h
> index 9e697e3..1e860f6 100644
> --- a/include/linux/autonuma_types.h
> +++ b/include/linux/autonuma_types.h
> @@ -39,6 +39,61 @@ struct task_autonuma {
>  	unsigned long task_numa_fault[0];
>  };
>  
> +/*
> + * Per page (or per-pageblock) structure dynamically allocated only if
> + * autonuma is not impossible.

not impossible? So possible?

> + */
> +struct page_autonuma {
> +	/*
> +	 * To modify autonuma_last_nid lockless the architecture,
> +	 * needs SMP atomic granularity < sizeof(long), not all archs
> +	 * have that, notably some ancient alpha (but none of those
> +	 * should run in NUMA systems). Archs without that requires
> +	 * autonuma_last_nid to be a long.
> +	 */
> +#if BITS_PER_LONG > 32
> +	/*
> +	 * autonuma_migrate_nid is -1 if the page_autonuma structure
> +	 * is not linked into any
> +	 * pgdat->autonuma_migrate_head. Otherwise it means the
> +	 * page_autonuma structure is linked into the
> +	 * &NODE_DATA(autonuma_migrate_nid)->autonuma_migrate_head[page_nid].
> +	 * page_nid is the nid that the page (referenced by the
> +	 * page_autonuma structure) belongs to.
> +	 */
> +	int autonuma_migrate_nid;
> +	/*
> +	 * autonuma_last_nid records which is the NUMA nid that tried
> +	 * to access this page at the last NUMA hinting page fault.
> +	 * If it changed, AutoNUMA will not try to migrate the page to
> +	 * the nid where the thread is running on and to the contrary,
> +	 * it will make different threads trashing on the same pages,
> +	 * converge on the same NUMA node (if possible).
> +	 */
> +	int autonuma_last_nid;
> +#else
> +#if MAX_NUMNODES >= 32768
> +#error "too many nodes"
> +#endif
> +	short autonuma_migrate_nid;
> +	short autonuma_last_nid;
> +#endif
> +	/*
> +	 * This is the list node that links the page (referenced by
> +	 * the page_autonuma structure) in the
> +	 * &NODE_DATA(dst_nid)->autonuma_migrate_head[page_nid] lru.
> +	 */
> +	struct list_head autonuma_migrate_node;
> +
> +	/*
> +	 * To find the page starting from the autonuma_migrate_node we
> +	 * need a backlink.
> +	 *
> +	 * FIXME: drop it;
> +	 */
> +	struct page *page;
> +};
> +
>  extern int alloc_task_autonuma(struct task_struct *tsk,
>  			       struct task_struct *orig,
>  			       int node);
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index d1248cf..f0c6379 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -136,32 +136,6 @@ struct page {
>  		struct page *first_page;	/* Compound tail pages */
>  	};
>  
> -#ifdef CONFIG_AUTONUMA
> -	/*
> -	 * FIXME: move to pgdat section along with the memcg and allocate
> -	 * at runtime only in presence of a numa system.
> -	 */
> -	/*
> -	 * To modify autonuma_last_nid lockless the architecture,
> -	 * needs SMP atomic granularity < sizeof(long), not all archs
> -	 * have that, notably some ancient alpha (but none of those
> -	 * should run in NUMA systems). Archs without that requires
> -	 * autonuma_last_nid to be a long.
> -	 */
> -#if BITS_PER_LONG > 32
> -	int autonuma_migrate_nid;
> -	int autonuma_last_nid;
> -#else
> -#if MAX_NUMNODES >= 32768
> -#error "too many nodes"
> -#endif
> -	/* FIXME: remember to check the updates are atomic */
> -	short autonuma_migrate_nid;
> -	short autonuma_last_nid;
> -#endif
> -	struct list_head autonuma_migrate_node;
> -#endif
> -
>  	/*
>  	 * On machines where all RAM is mapped into kernel address space,
>  	 * we can simply calculate the virtual address. On machines with
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index d53b26a..e66da74 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -698,10 +698,13 @@ typedef struct pglist_data {
>  	int kswapd_max_order;
>  	enum zone_type classzone_idx;
>  #ifdef CONFIG_AUTONUMA
> -	spinlock_t autonuma_lock;
> +#if !defined(CONFIG_SPARSEMEM)
> +	struct page_autonuma *node_page_autonuma;
> +#endif
>  	struct list_head autonuma_migrate_head[MAX_NUMNODES];
>  	unsigned long autonuma_nr_migrate_pages;
>  	wait_queue_head_t autonuma_knuma_migrated_wait;
> +	spinlock_t autonuma_lock;
>  #endif
>  } pg_data_t;
>  
> @@ -1064,6 +1067,15 @@ struct mem_section {
>  	 * section. (see memcontrol.h/page_cgroup.h about this.)
>  	 */
>  	struct page_cgroup *page_cgroup;
> +#endif
> +#ifdef CONFIG_AUTONUMA
> +	/*
> +	 * If !SPARSEMEM, pgdat doesn't have page_autonuma pointer. We use
> +	 * section.
> +	 */
> +	struct page_autonuma *section_page_autonuma;
> +#endif
> +#if defined(CONFIG_CGROUP_MEM_RES_CTLR) ^ defined(CONFIG_AUTONUMA)
>  	unsigned long pad;
>  #endif
>  };
> diff --git a/include/linux/page_autonuma.h b/include/linux/page_autonuma.h
> new file mode 100644
> index 0000000..d748aa2
> --- /dev/null
> +++ b/include/linux/page_autonuma.h
> @@ -0,0 +1,53 @@
> +#ifndef _LINUX_PAGE_AUTONUMA_H
> +#define _LINUX_PAGE_AUTONUMA_H
> +
> +#if defined(CONFIG_AUTONUMA) && !defined(CONFIG_SPARSEMEM)
> +extern void __init page_autonuma_init_flatmem(void);
> +#else
> +static inline void __init page_autonuma_init_flatmem(void) {}
> +#endif
> +
> +#ifdef CONFIG_AUTONUMA
> +
> +#include <linux/autonuma_flags.h>
> +
> +extern void __meminit page_autonuma_map_init(struct page *page,
> +					     struct page_autonuma *page_autonuma,
> +					     int nr_pages);
> +
> +#ifdef CONFIG_SPARSEMEM
> +#define PAGE_AUTONUMA_SIZE (sizeof(struct page_autonuma))
> +#define SECTION_PAGE_AUTONUMA_SIZE (PAGE_AUTONUMA_SIZE *	\
> +				    PAGES_PER_SECTION)
> +#endif
> +
> +extern void __meminit pgdat_autonuma_init(struct pglist_data *);
> +
> +#else /* CONFIG_AUTONUMA */
> +
> +#ifdef CONFIG_SPARSEMEM
> +struct page_autonuma;
> +#define PAGE_AUTONUMA_SIZE 0
> +#define SECTION_PAGE_AUTONUMA_SIZE 0
> +
> +#define autonuma_impossible() true
> +
> +#endif
> +
> +static inline void pgdat_autonuma_init(struct pglist_data *pgdat) {}
> +
> +#endif /* CONFIG_AUTONUMA */
> +
> +#ifdef CONFIG_SPARSEMEM
> +extern struct page_autonuma * __meminit __kmalloc_section_page_autonuma(int nid,
> +									unsigned long nr_pages);
> +extern void __kfree_section_page_autonuma(struct page_autonuma *page_autonuma,
> +					  unsigned long nr_pages);
> +extern void __init sparse_early_page_autonuma_alloc_node(struct page_autonuma **page_autonuma_map,
> +							 unsigned long pnum_begin,
> +							 unsigned long pnum_end,
> +							 unsigned long map_count,
> +							 int nodeid);
> +#endif
> +
> +#endif /* _LINUX_PAGE_AUTONUMA_H */
> diff --git a/init/main.c b/init/main.c
> index b5cc0a7..070a377 100644
> --- a/init/main.c
> +++ b/init/main.c
> @@ -68,6 +68,7 @@
>  #include <linux/shmem_fs.h>
>  #include <linux/slab.h>
>  #include <linux/perf_event.h>
> +#include <linux/page_autonuma.h>
>  
>  #include <asm/io.h>
>  #include <asm/bugs.h>
> @@ -455,6 +456,7 @@ static void __init mm_init(void)
>  	 * bigger than MAX_ORDER unless SPARSEMEM.
>  	 */
>  	page_cgroup_init_flatmem();
> +	page_autonuma_init_flatmem();
>  	mem_init();
>  	kmem_cache_init();
>  	percpu_init_late();
> diff --git a/mm/Makefile b/mm/Makefile
> index 15900fd..a4d8354 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -33,7 +33,7 @@ obj-$(CONFIG_FRONTSWAP)	+= frontswap.o
>  obj-$(CONFIG_HAS_DMA)	+= dmapool.o
>  obj-$(CONFIG_HUGETLBFS)	+= hugetlb.o
>  obj-$(CONFIG_NUMA) 	+= mempolicy.o
> -obj-$(CONFIG_AUTONUMA) 	+= autonuma.o
> +obj-$(CONFIG_AUTONUMA) 	+= autonuma.o page_autonuma.o
>  obj-$(CONFIG_SPARSEMEM)	+= sparse.o
>  obj-$(CONFIG_SPARSEMEM_VMEMMAP) += sparse-vmemmap.o
>  obj-$(CONFIG_SLOB) += slob.o
> diff --git a/mm/autonuma.c b/mm/autonuma.c
> index f44272b..ec4d492 100644
> --- a/mm/autonuma.c
> +++ b/mm/autonuma.c
> @@ -51,12 +51,6 @@ static struct knumad_scan {
>  	.mm_head = LIST_HEAD_INIT(knumad_scan.mm_head),
>  };
>  
> -static inline bool autonuma_impossible(void)
> -{
> -	return num_possible_nodes() <= 1 ||
> -		test_bit(AUTONUMA_IMPOSSIBLE_FLAG, &autonuma_flags);
> -}
> -
>  static inline void autonuma_migrate_lock(int nid)
>  {
>  	spin_lock(&NODE_DATA(nid)->autonuma_lock);
> @@ -82,54 +76,63 @@ void autonuma_migrate_split_huge_page(struct page *page,
>  				      struct page *page_tail)
>  {
>  	int nid, last_nid;
> +	struct page_autonuma *page_autonuma, *page_tail_autonuma;
>  
> -	nid = page->autonuma_migrate_nid;
> +	if (autonuma_impossible())

Is it just better to call it 'autonuma_off()' ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
