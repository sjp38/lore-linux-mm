Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 201E66B0038
	for <linux-mm@kvack.org>; Tue,  6 Sep 2016 11:35:52 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id t65so329010141yba.0
        for <linux-mm@kvack.org>; Tue, 06 Sep 2016 08:35:52 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0058.hostedemail.com. [216.40.44.58])
        by mx.google.com with ESMTPS id b140si6891502ioe.35.2016.09.06.08.35.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Sep 2016 08:35:49 -0700 (PDT)
Date: Tue, 6 Sep 2016 11:35:42 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [RFC 2/4] Add non-swap page flag to mark a page will not swap
Message-ID: <20160906113542.08690455@gandalf.local.home>
In-Reply-To: <1471854309-30414-3-git-send-email-zhuhui@xiaomi.com>
References: <1471854309-30414-1-git-send-email-zhuhui@xiaomi.com>
	<1471854309-30414-3-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hui Zhu <zhuhui@xiaomi.com>
Cc: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, hughd@google.com, mingo@redhat.com, peterz@infradead.org, acme@kernel.org, alexander.shishkin@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, redkoi@virtuozzo.com, luto@kernel.org, kirill.shutemov@linux.intel.com, geliangtang@163.com, baiyaowei@cmss.chinamobile.com, dan.j.williams@intel.com, vdavydov@virtuozzo.com, aarcange@redhat.com, dvlasenk@redhat.com, jmarchan@redhat.com, koct9i@gmail.com, yang.shi@linaro.org, dave.hansen@linux.intel.com, vkuznets@redhat.com, vitalywool@gmail.com, ross.zwisler@linux.intel.com, tglx@linutronix.de, kwapulinski.piotr@gmail.com, axboe@fb.com, mchristi@redhat.com, joe@perches.com, namit@vmware.com, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, teawater@gmail.com

On Mon, 22 Aug 2016 16:25:07 +0800
Hui Zhu <zhuhui@xiaomi.com> wrote:

>
> --- a/include/linux/mm_inline.h
> +++ b/include/linux/mm_inline.h
> @@ -46,15 +46,31 @@ static __always_inline void update_lru_size(struct lruvec *lruvec,
>  static __always_inline void add_page_to_lru_list(struct page *page,
>  				struct lruvec *lruvec, enum lru_list lru)
>  {
> -	update_lru_size(lruvec, lru, page_zonenum(page), hpage_nr_pages(page));
> +	int nr_pages = hpage_nr_pages(page);
> +	enum zone_type zid = page_zonenum(page);
> +#ifdef CONFIG_NON_SWAP
> +	if (PageNonSwap(page)) {

Can't we just have PageNonSwap() return false when CONFIG_NON_SWAP is
not defined, and lose the ugly #ifdef? It will make this much cleaner.

> +		lru = LRU_UNEVICTABLE;
> +		update_lru_size(lruvec, NR_NON_SWAP, zid, nr_pages);
> +	}
> +#endif
> +	update_lru_size(lruvec, lru, zid, nr_pages);
>  	list_add(&page->lru, &lruvec->lists[lru]);
>  }
>  
>  static __always_inline void del_page_from_lru_list(struct page *page,
>  				struct lruvec *lruvec, enum lru_list lru)
>  {
> +	int nr_pages = hpage_nr_pages(page);
> +	enum zone_type zid = page_zonenum(page);
> +#ifdef CONFIG_NON_SWAP
> +	if (PageNonSwap(page)) {
> +		lru = LRU_UNEVICTABLE;
> +		update_lru_size(lruvec, NR_NON_SWAP, zid, -nr_pages);
> +	}
> +#endif
>  	list_del(&page->lru);
> -	update_lru_size(lruvec, lru, page_zonenum(page), -hpage_nr_pages(page));
> +	update_lru_size(lruvec, lru, zid, -nr_pages);
>  }
>  
>  /**
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index d572b78..da08d20 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -138,6 +138,9 @@ enum zone_stat_item {
>  	NUMA_OTHER,		/* allocation from other node */
>  #endif
>  	NR_FREE_CMA_PAGES,
> +#ifdef CONFIG_NON_SWAP
> +	NR_NON_SWAP,
> +#endif

Is it bad to have NR_NON_SWAP defined as an enum if CONFIG_NON_SWAP is
not defined?

>  	NR_VM_ZONE_STAT_ITEMS };
>  
>  enum node_stat_item {
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index 74e4dda..0cd80db9 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -105,6 +105,9 @@ enum pageflags {
>  	PG_young,
>  	PG_idle,
>  #endif
> +#ifdef CONFIG_NON_SWAP
> +	PG_non_swap,
> +#endif

Here too.

>  	__NR_PAGEFLAGS,
>  
>  	/* Filesystems */
> @@ -303,6 +306,11 @@ PAGEFLAG(Reclaim, reclaim, PF_NO_TAIL)
>  PAGEFLAG(Readahead, reclaim, PF_NO_COMPOUND)
>  	TESTCLEARFLAG(Readahead, reclaim, PF_NO_COMPOUND)
>  
> +#ifdef CONFIG_NON_SWAP
> +PAGEFLAG(NonSwap, non_swap, PF_NO_TAIL)
> +	TESTSCFLAG(NonSwap, non_swap, PF_NO_TAIL)
> +#endif
> +
>  #ifdef CONFIG_HIGHMEM
>  /*
>   * Must use a macro here due to header dependency issues. page_zone() is not
> diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
> index 5a81ab4..1c0ccc9 100644
> --- a/include/trace/events/mmflags.h
> +++ b/include/trace/events/mmflags.h
> @@ -79,6 +79,12 @@
>  #define IF_HAVE_PG_IDLE(flag,string)
>  #endif
>  
> +#ifdef CONFIG_NON_SWAP
> +#define IF_HAVE_PG_NON_SWAP(flag,string) ,{1UL << flag, string}
> +#else
> +#define IF_HAVE_PG_NON_SWAP(flag,string)
> +#endif
> +
>  #define __def_pageflag_names						\
>  	{1UL << PG_locked,		"locked"	},		\
>  	{1UL << PG_error,		"error"		},		\
> @@ -104,7 +110,8 @@ IF_HAVE_PG_MLOCK(PG_mlocked,		"mlocked"	)		\
>  IF_HAVE_PG_UNCACHED(PG_uncached,	"uncached"	)		\
>  IF_HAVE_PG_HWPOISON(PG_hwpoison,	"hwpoison"	)		\
>  IF_HAVE_PG_IDLE(PG_young,		"young"		)		\
> -IF_HAVE_PG_IDLE(PG_idle,		"idle"		)
> +IF_HAVE_PG_IDLE(PG_idle,		"idle"		)		\
> +IF_HAVE_PG_NON_SWAP(PG_non_swap,	"non_swap"	)
>  
>  #define show_page_flags(flags)						\
>  	(flags) ? __print_flags(flags, "|",				\
> diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
> index b7a525a..a7e4153 100644
> --- a/kernel/events/uprobes.c
> +++ b/kernel/events/uprobes.c
> @@ -160,6 +160,10 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
>  	const unsigned long mmun_start = addr;
>  	const unsigned long mmun_end   = addr + PAGE_SIZE;
>  	struct mem_cgroup *memcg;
> +	pte_t pte;
> +#ifdef CONFIG_NON_SWAP
> +	bool non_swap;
> +#endif
>  
>  	err = mem_cgroup_try_charge(kpage, vma->vm_mm, GFP_KERNEL, &memcg,
>  			false);
> @@ -176,6 +180,11 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
>  		goto unlock;
>  
>  	get_page(kpage);
> +#ifdef CONFIG_NON_SWAP
> +	non_swap = TestClearPageNonSwap(page);

Can't we have TestClearPageNonSwap() return false when CONFIG_NON_SWAP
is not defined, and lose the ugly #ifdefs here in the code?

> +	if (non_swap)
> +		SetPageNonSwap(kpage);

Make SetPageNonSwap() a nop (or warning) if CONFIG_NON_SWAP is not
defined.

> +#endif
>  	page_add_new_anon_rmap(kpage, vma, addr, false);
>  	mem_cgroup_commit_charge(kpage, memcg, false, false);
>  	lru_cache_add_active_or_unevictable(kpage, vma);
> @@ -187,7 +196,12 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
>  
>  	flush_cache_page(vma, addr, pte_pfn(*ptep));
>  	ptep_clear_flush_notify(vma, addr, ptep);
> -	set_pte_at_notify(mm, addr, ptep, mk_pte(kpage, vma->vm_page_prot));
> +	pte = mk_pte(kpage, vma->vm_page_prot);
> +#ifdef CONFIG_NON_SWAP
> +	if (non_swap)
> +		pte = pte_wrprotect(pte);
> +#endif

Again, I hate the added #ifdef in code, when we can have stub functions
make non_swap false.

A lot of the #ifdef's can be nuked with proper stub functions, which
makes maintaining and reviewing the code much easier.

-- Steve

> +	set_pte_at_notify(mm, addr, ptep, pte);
>  
>  	page_remove_rmap(page, false);
>  	if (!page_mapped(page))
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 57ecdb3..d8d4b41 100644
> --- a/mm/Kconfig

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
