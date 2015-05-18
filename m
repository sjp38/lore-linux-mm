Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id C038D6B00AE
	for <linux-mm@kvack.org>; Mon, 18 May 2015 08:57:29 -0400 (EDT)
Received: by wicnf17 with SMTP id nf17so68575087wic.1
        for <linux-mm@kvack.org>; Mon, 18 May 2015 05:57:29 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ge8si12547512wib.104.2015.05.18.05.57.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 18 May 2015 05:57:28 -0700 (PDT)
Message-ID: <5559E1B6.6020501@suse.cz>
Date: Mon, 18 May 2015 14:57:26 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCHv5 16/28] mm, thp: remove compound_lock
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com> <1429823043-157133-17-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1429823043-157133-17-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/23/2015 11:03 PM, Kirill A. Shutemov wrote:
> We are going to use migration entries to stabilize page counts. It means
> we don't need compound_lock() for that.

git grep says you didn't clean up enough :)

mm/memcontrol.c: * zone->lru_lock, 'splitting on pmd' and compound_lock.
mm/memcontrol.c: * compound_lock(), so we don't have to take care of races.
mm/memcontrol.c: * - compound_lock is held when nr_pages > 1

> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>

When that's amended,

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>   include/linux/mm.h         | 35 -----------------------------------
>   include/linux/page-flags.h | 12 +-----------
>   mm/debug.c                 |  3 ---
>   3 files changed, 1 insertion(+), 49 deletions(-)
>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index dd1b5f2b1966..dad667d99304 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -393,41 +393,6 @@ static inline int is_vmalloc_or_module_addr(const void *x)
>
>   extern void kvfree(const void *addr);
>
> -static inline void compound_lock(struct page *page)
> -{
> -#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> -	VM_BUG_ON_PAGE(PageSlab(page), page);
> -	bit_spin_lock(PG_compound_lock, &page->flags);
> -#endif
> -}
> -
> -static inline void compound_unlock(struct page *page)
> -{
> -#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> -	VM_BUG_ON_PAGE(PageSlab(page), page);
> -	bit_spin_unlock(PG_compound_lock, &page->flags);
> -#endif
> -}
> -
> -static inline unsigned long compound_lock_irqsave(struct page *page)
> -{
> -	unsigned long uninitialized_var(flags);
> -#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> -	local_irq_save(flags);
> -	compound_lock(page);
> -#endif
> -	return flags;
> -}
> -
> -static inline void compound_unlock_irqrestore(struct page *page,
> -					      unsigned long flags)
> -{
> -#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> -	compound_unlock(page);
> -	local_irq_restore(flags);
> -#endif
> -}
> -
>   /*
>    * The atomic page->_mapcount, starts from -1: so that transitions
>    * both from it and to it can be tracked, using atomic_inc_and_test
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index 91b7f9b2b774..74b7cece1dfa 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -106,9 +106,6 @@ enum pageflags {
>   #ifdef CONFIG_MEMORY_FAILURE
>   	PG_hwpoison,		/* hardware poisoned page. Don't touch */
>   #endif
> -#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> -	PG_compound_lock,
> -#endif
>   	__NR_PAGEFLAGS,
>
>   	/* Filesystems */
> @@ -683,12 +680,6 @@ static inline void ClearPageSlabPfmemalloc(struct page *page)
>   #define __PG_MLOCKED		0
>   #endif
>
> -#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> -#define __PG_COMPOUND_LOCK		(1 << PG_compound_lock)
> -#else
> -#define __PG_COMPOUND_LOCK		0
> -#endif
> -
>   /*
>    * Flags checked when a page is freed.  Pages being freed should not have
>    * these flags set.  It they are, there is a problem.
> @@ -698,8 +689,7 @@ static inline void ClearPageSlabPfmemalloc(struct page *page)
>   	 1 << PG_private | 1 << PG_private_2 | \
>   	 1 << PG_writeback | 1 << PG_reserved | \
>   	 1 << PG_slab	 | 1 << PG_swapcache | 1 << PG_active | \
> -	 1 << PG_unevictable | __PG_MLOCKED | __PG_HWPOISON | \
> -	 __PG_COMPOUND_LOCK)
> +	 1 << PG_unevictable | __PG_MLOCKED | __PG_HWPOISON )
>
>   /*
>    * Flags checked when a page is prepped for return by the page allocator.
> diff --git a/mm/debug.c b/mm/debug.c
> index 3eb3ac2fcee7..9dfcd77e7354 100644
> --- a/mm/debug.c
> +++ b/mm/debug.c
> @@ -45,9 +45,6 @@ static const struct trace_print_flags pageflag_names[] = {
>   #ifdef CONFIG_MEMORY_FAILURE
>   	{1UL << PG_hwpoison,		"hwpoison"	},
>   #endif
> -#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> -	{1UL << PG_compound_lock,	"compound_lock"	},
> -#endif
>   };
>
>   static void dump_flags(unsigned long flags,
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
