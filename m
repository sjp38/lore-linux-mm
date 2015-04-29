Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 643E76B0032
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 00:35:55 -0400 (EDT)
Received: by pabtp1 with SMTP id tp1so16406733pab.2
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 21:35:55 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id pm11si37712550pdb.55.2015.04.28.21.35.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Apr 2015 21:35:54 -0700 (PDT)
Received: by pabsx10 with SMTP id sx10so16345819pab.3
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 21:35:53 -0700 (PDT)
Date: Wed, 29 Apr 2015 13:35:36 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 3/3] proc: add kpageidle file
Message-ID: <20150429043536.GB11486@blaptop>
References: <cover.1430217477.git.vdavydov@parallels.com>
 <4c24a6bf2c9711dd4dbb72a43a16eba6867527b7.1430217477.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4c24a6bf2c9711dd4dbb72a43a16eba6867527b7.1430217477.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Apr 28, 2015 at 03:24:42PM +0300, Vladimir Davydov wrote:
> Knowing the portion of memory that is not used by a certain application
> or memory cgroup (idle memory) can be useful for partitioning the system
> efficiently, e.g. by setting memory cgroup limits appropriately.
> Currently, the only means to estimate the amount of idle memory provided
> by the kernel is /proc/PID/{clear_refs,smaps}: the user can clear the
> access bit for all pages mapped to a particular process by writing 1 to
> clear_refs, wait for some time, and then count smaps:Referenced.
> However, this method has two serious shortcomings:
> 
>  - it does not count unmapped file pages
>  - it affects the reclaimer logic
> 
> To overcome these drawbacks, this patch introduces two new page flags,
> Idle and Young, and a new proc file, /proc/kpageidle. A page's Idle flag
> can only be set from userspace by writing 1 to /proc/kpageidle at the
> offset corresponding to the page, and it is cleared whenever the page is
> accessed either through page tables (it is cleared in page_referenced()
> in this case) or using the read(2) system call (mark_page_accessed()).
> Thus by setting the Idle flag for pages of a particular workload, which
> can be found e.g. by reading /proc/PID/pagemap, waiting for some time to
> let the workload access its working set, and then reading the kpageidle
> file, one can estimate the amount of pages that are not used by the
> workload.
> 
> The Young page flag is used to avoid interference with the memory
> reclaimer. A page's Young flag is set whenever the Access bit of a page
> table entry pointing to the page is cleared by writing to kpageidle. If
> page_referenced() is called on a Young page, it will add 1 to its return
> value, therefore concealing the fact that the Access bit was cleared.
> 
> Note, since there is no room for extra page flags on 32 bit, this
> feature uses extended page flags when compiled on 32 bit.

Thanks for considering 32bit.

Anyway, I believe it's good feature but not sure it's worth to consume
2bit of page flag but have no idea with saving page flags.

> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> ---
>  Documentation/vm/pagemap.txt |   10 ++-
>  fs/proc/page.c               |  154 ++++++++++++++++++++++++++++++++++++++++++
>  fs/proc/task_mmu.c           |    4 +-
>  include/linux/mm.h           |   88 ++++++++++++++++++++++++
>  include/linux/page-flags.h   |    9 +++
>  include/linux/page_ext.h     |    4 ++
>  mm/Kconfig                   |   12 ++++
>  mm/debug.c                   |    4 ++
>  mm/page_ext.c                |    3 +
>  mm/rmap.c                    |    7 ++
>  mm/swap.c                    |    2 +
>  11 files changed, 295 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/vm/pagemap.txt b/Documentation/vm/pagemap.txt
> index a9b7afc8fbc6..ac6fd32a9296 100644
> --- a/Documentation/vm/pagemap.txt
> +++ b/Documentation/vm/pagemap.txt
> @@ -5,7 +5,7 @@ pagemap is a new (as of 2.6.25) set of interfaces in the kernel that allow
>  userspace programs to examine the page tables and related information by
>  reading files in /proc.
>  
> -There are four components to pagemap:
> +There are five components to pagemap:
>  
>   * /proc/pid/pagemap.  This file lets a userspace process find out which
>     physical frame each virtual page is mapped to.  It contains one 64-bit
> @@ -69,6 +69,14 @@ There are four components to pagemap:
>     memory cgroup each page is charged to, indexed by PFN. Only available when
>     CONFIG_MEMCG is set.
>  
> + * /proc/kpageidle.  For each page this file contains a 64-bit number, which
> +   equals 1 if the page is idle or 0 otherwise, indexed by PFN. A page is

As I replied to the cover letter, we need justification consume 64bit per page.

> +   considered idle if it has not been accessed since it was marked idle. To
> +   mark a page idle one should write 1 to this file at the offset corresponding
> +   to the page. Only user memory pages can be marked idle, for other page types
> +   input is silently ignored. Writing to this file beyond max PFN results in
> +   the ENXIO error. Only available when CONFIG_IDLE_PAGE_TRACKING is set.
> +
>  Short descriptions to the page flags:
>  
>   0. LOCKED
> diff --git a/fs/proc/page.c b/fs/proc/page.c
> index 70d23245dd43..cfc55ba7fee6 100644
> --- a/fs/proc/page.c
> +++ b/fs/proc/page.c
> @@ -275,6 +275,156 @@ static const struct file_operations proc_kpagecgroup_operations = {
>  };
>  #endif /* CONFIG_MEMCG */
>  
> +#ifdef CONFIG_IDLE_PAGE_TRACKING
> +static struct page *kpageidle_get_page(unsigned long pfn)
> +{
> +	struct page *page;
> +
> +	if (!pfn_valid(pfn))
> +		return NULL;
> +	page = pfn_to_page(pfn);
> +	/*
> +	 * We are only interested in user memory pages, i.e. pages that are
> +	 * allocated and on an LRU list.
> +	 */
> +	if (!page || page_count(page) == 0 || !PageLRU(page))

Why do you check (page_count == 0) even if we check it with get_page_unless_zero
below?

> +		return NULL;
> +	if (!get_page_unless_zero(page))
> +		return NULL;
> +	if (unlikely(!PageLRU(page))) {

What lock protect the check PageLRU?
If it is racing ClearPageLRU, what happens?

> +		put_page(page);
> +		return NULL;
> +	}
> +	return page;
> +}
> +
> +static void kpageidle_clear_refs(struct page *page)
> +{
> +	unsigned long dummy;
> +
> +	if (page_referenced(page, 0, NULL, &dummy))
> +		/*
> +		 * This page was referenced. To avoid interference with the
> +		 * reclaimer, mark it young so that the next call will also

                                                        next what call?

It just works with mapped page so kpageidle_clear_pte_refs as function name
is more clear.

One more, kpageidle_clear_refs removes PG_idle via page_referenced which
is important feature for the function. Please document it so we could
understand why we need double check for PG_idle after calling
kpageidle_clear_refs for pte access bit.

> +		 * return > 0 (see page_referenced_one)
> +		 */
> +		set_page_young(page);
> +}
> +
> +static ssize_t kpageidle_read(struct file *file, char __user *buf,
> +			      size_t count, loff_t *ppos)
> +{
> +	u64 __user *out = (u64 __user *)buf;
> +	struct page *page;
> +	unsigned long src = *ppos;
> +	unsigned long pfn;
> +	ssize_t ret = 0;
> +	u64 val;
> +
> +	pfn = src / KPMSIZE;
> +	count = min_t(unsigned long, count, (max_pfn * KPMSIZE) - src);
> +	if (src & KPMMASK || count & KPMMASK)
> +		return -EINVAL;
> +
> +	while (count > 0) {
> +		val = 0;
> +		page = kpageidle_get_page(pfn);
> +		if (page) {
> +			if (page_is_idle(page)) {
> +				/*
> +				 * The page might have been referenced via a
> +				 * pte, in which case it is not idle. Clear
> +				 * refs and recheck.
> +				 */
> +				kpageidle_clear_refs(page);
> +				if (page_is_idle(page))
> +					val = 1;
> +			}
> +			put_page(page);
> +		}
> +
> +		if (put_user(val, out)) {
> +			ret = -EFAULT;
> +			break;
> +		}
> +
> +		pfn++;
> +		out++;
> +		count -= KPMSIZE;
> +	}
> +
> +	*ppos += (char __user *)out - buf;
> +	if (!ret)
> +		ret = (char __user *)out - buf;
> +	return ret;
> +}
> +
> +static ssize_t kpageidle_write(struct file *file, const char __user *buf,
> +			       size_t count, loff_t *ppos)
> +{
> +	const u64 __user *in = (u64 __user *)buf;
> +	struct page *page;
> +	unsigned long src = *ppos;
> +	unsigned long pfn;
> +	ssize_t ret = 0;
> +	u64 val;
> +
> +	pfn = src / KPMSIZE;
> +	if (src & KPMMASK || count & KPMMASK)
> +		return -EINVAL;
> +
> +	while (count > 0) {
> +		if (pfn >= max_pfn) {
> +			if ((char __user *)in == buf)
> +				ret = -ENXIO;
> +			break;
> +		}
> +
> +		if (get_user(val, in)) {
> +			ret = -EFAULT;
> +			break;
> +		}
> +
> +		if (val == 1) {
> +			page = kpageidle_get_page(pfn);
> +			if (page) {
> +				kpageidle_clear_refs(page);
> +				set_page_idle(page);
> +				put_page(page);
> +			}
> +		} else if (val) {
> +			ret = -EINVAL;
> +			break;
> +		}
> +
> +		pfn++;
> +		in++;
> +		count -= KPMSIZE;
> +	}
> +
> +	*ppos += (char __user *)in - buf;
> +	if (!ret)
> +		ret = (char __user *)in - buf;
> +	return ret;
> +}
> +
> +static const struct file_operations proc_kpageidle_operations = {
> +	.llseek = mem_lseek,
> +	.read = kpageidle_read,
> +	.write = kpageidle_write,
> +};
> +
> +#ifndef CONFIG_64BIT
> +static bool need_page_idle(void)
> +{
> +	return true;
> +}
> +struct page_ext_operations page_idle_ops = {
> +	.need = need_page_idle,
> +};
> +#endif
> +#endif /* CONFIG_IDLE_PAGE_TRACKING */
> +
>  static int __init proc_page_init(void)
>  {
>  	proc_create("kpagecount", S_IRUSR, NULL, &proc_kpagecount_operations);
> @@ -282,6 +432,10 @@ static int __init proc_page_init(void)
>  #ifdef CONFIG_MEMCG
>  	proc_create("kpagecgroup", S_IRUSR, NULL, &proc_kpagecgroup_operations);
>  #endif
> +#ifdef CONFIG_IDLE_PAGE_TRACKING
> +	proc_create("kpageidle", S_IRUSR | S_IWUSR, NULL,
> +		    &proc_kpageidle_operations);
> +#endif
>  	return 0;
>  }
>  fs_initcall(proc_page_init);
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 6dee68d013ff..ab04846f7dd5 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -458,7 +458,7 @@ static void smaps_account(struct mem_size_stats *mss, struct page *page,
>  
>  	mss->resident += size;
>  	/* Accumulate the size in pages that have been accessed. */
> -	if (young || PageReferenced(page))
> +	if (young || page_is_young(page) || PageReferenced(page))
>  		mss->referenced += size;
>  	mapcount = page_mapcount(page);
>  	if (mapcount >= 2) {
> @@ -808,6 +808,7 @@ static int clear_refs_pte_range(pmd_t *pmd, unsigned long addr,
>  
>  		/* Clear accessed and referenced bits. */
>  		pmdp_test_and_clear_young(vma, addr, pmd);
> +		clear_page_young(page);
>  		ClearPageReferenced(page);
>  out:
>  		spin_unlock(ptl);
> @@ -835,6 +836,7 @@ out:
>  
>  		/* Clear accessed and referenced bits. */
>  		ptep_test_and_clear_young(vma, addr, pte);
> +		clear_page_young(page);
>  		ClearPageReferenced(page);
>  	}
>  	pte_unmap_unlock(pte - 1, ptl);
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 0755b9fd03a7..794d29aa2317 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2200,5 +2200,93 @@ void __init setup_nr_node_ids(void);
>  static inline void setup_nr_node_ids(void) {}
>  #endif
>  
> +#ifdef CONFIG_IDLE_PAGE_TRACKING
> +#ifdef CONFIG_64BIT
> +static inline bool page_is_young(struct page *page)
> +{
> +	return PageYoung(page);
> +}
> +
> +static inline void set_page_young(struct page *page)
> +{
> +	SetPageYoung(page);
> +}
> +
> +static inline void clear_page_young(struct page *page)
> +{
> +	ClearPageYoung(page);
> +}
> +
> +static inline bool page_is_idle(struct page *page)
> +{
> +	return PageIdle(page);
> +}
> +
> +static inline void set_page_idle(struct page *page)
> +{
> +	SetPageIdle(page);
> +}
> +
> +static inline void clear_page_idle(struct page *page)
> +{
> +	ClearPageIdle(page);
> +}
> +#else /* !CONFIG_64BIT */
> +/*
> + * If there is not enough space to store Idle and Young bits in page flags, use
> + * page ext flags instead.
> + */
> +extern struct page_ext_operations page_idle_ops;
> +
> +static inline bool page_is_young(struct page *page)
> +{
> +	return test_bit(PAGE_EXT_YOUNG, &lookup_page_ext(page)->flags);
> +}
> +
> +static inline void set_page_young(struct page *page)
> +{
> +	set_bit(PAGE_EXT_YOUNG, &lookup_page_ext(page)->flags);
> +}
> +
> +static inline void clear_page_young(struct page *page)
> +{
> +	clear_bit(PAGE_EXT_YOUNG, &lookup_page_ext(page)->flags);
> +}
> +
> +static inline bool page_is_idle(struct page *page)
> +{
> +	return test_bit(PAGE_EXT_IDLE, &lookup_page_ext(page)->flags);
> +}
> +
> +static inline void set_page_idle(struct page *page)
> +{
> +	set_bit(PAGE_EXT_IDLE, &lookup_page_ext(page)->flags);
> +}
> +
> +static inline void clear_page_idle(struct page *page)
> +{
> +	clear_bit(PAGE_EXT_IDLE, &lookup_page_ext(page)->flags);
> +}
> +#endif /* CONFIG_64BIT */
> +#else /* !CONFIG_IDLE_PAGE_TRACKING */
> +static inline bool page_is_young(struct page *page)
> +{
> +	return false;
> +}
> +
> +static inline void clear_page_young(struct page *page)
> +{
> +}
> +
> +static inline bool page_is_idle(struct page *page)
> +{
> +	return false;
> +}
> +
> +static inline void clear_page_idle(struct page *page)
> +{
> +}
> +#endif /* CONFIG_IDLE_PAGE_TRACKING */
> +
>  #endif /* __KERNEL__ */
>  #endif /* _LINUX_MM_H */
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index f34e040b34e9..5e7c4f50a644 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -109,6 +109,10 @@ enum pageflags {
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>  	PG_compound_lock,
>  #endif
> +#if defined(CONFIG_IDLE_PAGE_TRACKING) && defined(CONFIG_64BIT)
> +	PG_young,
> +	PG_idle,
> +#endif
>  	__NR_PAGEFLAGS,
>  
>  	/* Filesystems */
> @@ -289,6 +293,11 @@ PAGEFLAG_FALSE(HWPoison)
>  #define __PG_HWPOISON 0
>  #endif
>  
> +#if defined(CONFIG_IDLE_PAGE_TRACKING) && defined(CONFIG_64BIT)
> +PAGEFLAG(Young, young)
> +PAGEFLAG(Idle, idle)
> +#endif
> +
>  /*
>   * On an anonymous page mapped into a user virtual memory area,
>   * page->mapping points to its anon_vma, not to a struct address_space;
> diff --git a/include/linux/page_ext.h b/include/linux/page_ext.h
> index c42981cd99aa..17f118a82854 100644
> --- a/include/linux/page_ext.h
> +++ b/include/linux/page_ext.h
> @@ -26,6 +26,10 @@ enum page_ext_flags {
>  	PAGE_EXT_DEBUG_POISON,		/* Page is poisoned */
>  	PAGE_EXT_DEBUG_GUARD,
>  	PAGE_EXT_OWNER,
> +#if defined(CONFIG_IDLE_PAGE_TRACKING) && !defined(CONFIG_64BIT)
> +	PAGE_EXT_YOUNG,
> +	PAGE_EXT_IDLE,
> +#endif
>  };
>  
>  /*
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 390214da4546..3600eace4774 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -635,3 +635,15 @@ config MAX_STACK_SIZE_MB
>  	  changed to a smaller value in which case that is used.
>  
>  	  A sane initial value is 80 MB.
> +
> +config IDLE_PAGE_TRACKING
> +	bool "Enable idle page tracking"
> +	select PROC_PAGE_MONITOR
> +	select PAGE_EXTENSION if !64BIT
> +	help
> +	  This feature allows to estimate the amount of user pages that have
> +	  not been touched during a given period of time. This information can
> +	  be useful to tune memory cgroup limits and/or for job placement
> +	  within a compute cluster.
> +
> +	  See Documentation/vm/pagemap.txt for more details.
> diff --git a/mm/debug.c b/mm/debug.c
> index 3eb3ac2fcee7..bb66f9ccec03 100644
> --- a/mm/debug.c
> +++ b/mm/debug.c
> @@ -48,6 +48,10 @@ static const struct trace_print_flags pageflag_names[] = {
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>  	{1UL << PG_compound_lock,	"compound_lock"	},
>  #endif
> +#if defined(CONFIG_IDLE_PAGE_TRACKING) && defined(CONFIG_64BIT)
> +	{1UL << PG_young,		"young"		},
> +	{1UL << PG_idle,		"idle"		},
> +#endif
>  };
>  
>  static void dump_flags(unsigned long flags,
> diff --git a/mm/page_ext.c b/mm/page_ext.c
> index d86fd2f5353f..e4b3af054bf2 100644
> --- a/mm/page_ext.c
> +++ b/mm/page_ext.c
> @@ -59,6 +59,9 @@ static struct page_ext_operations *page_ext_ops[] = {
>  #ifdef CONFIG_PAGE_OWNER
>  	&page_owner_ops,
>  #endif
> +#if defined(CONFIG_IDLE_PAGE_TRACKING) && !defined(CONFIG_64BIT)
> +	&page_idle_ops,
> +#endif
>  };
>  
>  static unsigned long total_usage;
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 24dd3f9fee27..12e73b758d9e 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -784,6 +784,13 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
>  	if (referenced) {
>  		pra->referenced++;
>  		pra->vm_flags |= vma->vm_flags;
> +		if (page_is_idle(page))
> +			clear_page_idle(page);
> +	}
> +
> +	if (page_is_young(page)) {
> +		clear_page_young(page);
> +		pra->referenced++;

If a page was page_is_young and referenced recenlty,
pra->referenced is increased doubly and it changes current
behavior for file-backed page promotion. Look at page_check_references.

>  	}
>  
>  	pra->mapcount--;
> diff --git a/mm/swap.c b/mm/swap.c
> index a7251a8ed532..6bf6f293a9ea 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -623,6 +623,8 @@ void mark_page_accessed(struct page *page)
>  	} else if (!PageReferenced(page)) {
>  		SetPageReferenced(page);
>  	}
> +	if (page_is_idle(page))
> +		clear_page_idle(page);
>  }
>  EXPORT_SYMBOL(mark_page_accessed);
>  
> -- 
> 1.7.10.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
