Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 7D55F6B007E
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 05:27:50 -0400 (EDT)
Received: by mail-wm0-f46.google.com with SMTP id 127so51127105wmu.1
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 02:27:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b1si15529629wmi.61.2016.03.29.02.27.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 Mar 2016 02:27:49 -0700 (PDT)
Subject: Re: [PATCH v2 2/2] mm: rename _count, field of the struct page, to
 _refcount
References: <1459146601-11448-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1459146601-11448-2-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56FA4A93.6090502@suse.cz>
Date: Tue, 29 Mar 2016 11:27:47 +0200
MIME-Version: 1.0
In-Reply-To: <1459146601-11448-2-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Johannes Berg <johannes@sipsolutions.net>, "David S. Miller" <davem@davemloft.net>, Sunil Goutham <sgoutham@cavium.com>, Chris Metcalf <cmetcalf@mellanox.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 03/28/2016 08:30 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Many developer already know that field for reference count of
> the struct page is _count and atomic type. They would try to handle it
> directly and this could break the purpose of page reference count
> tracepoint. To prevent direct _count modification, this patch rename it
> to _refcount and add warning message on the code. After that, developer
> who need to handle reference count will find that field should not be
> accessed directly.
> 
> v2: change more _count usages to _refcount

There's also
Documentation/vm/transhuge.txt talking about ->_count
include/linux/mm.h:      * requires to already have an elevated page->_count.
include/linux/mm_types.h:                        * Keep _count separate from slub cmpxchg_double data.
include/linux/mm_types.h:                        * slab_lock but _count is not.
include/linux/pagemap.h: * If the page is free (_count == 0), then _count is untouched, and 0
include/linux/pagemap.h: * is returned. Otherwise, _count is incremented by 1 and 1 is returned.
include/linux/pagemap.h: * this allows allocators to use a synchronize_rcu() to stabilize _count.
include/linux/pagemap.h: * Remove-side that cares about stability of _count (eg. reclaim) has the
mm/huge_memory.c:        * tail_page->_count is zero and not changing from under us. But
mm/huge_memory.c:       /* Prevent deferred_split_scan() touching ->_count */
mm/internal.h: * Turn a non-refcounted page (->_count == 0) into refcounted with
mm/page_alloc.c:                bad_reason = "nonzero _count";
mm/page_alloc.c:                bad_reason = "nonzero _count";
mm/page_alloc.c:                 * because their page->_count is zero at all time.
mm/slub.c:       * as page->_count.  If we assign to ->counters directly
mm/slub.c:       * we run the risk of losing updates to page->_count, so
mm/vmscan.c:     * load is not satisfied before that of page->_count.
mm/vmscan.c: * The downside is that we have to touch page->_count against each page.

I've arrived at the following command to find this:
git grep "[^a-zA-Z0-9_]_count[^_]"

Not that many false positives in the output :)

> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>   arch/tile/mm/init.c      |  2 +-
>   include/linux/mm_types.h |  8 ++++++--
>   include/linux/page_ref.h | 26 +++++++++++++-------------
>   kernel/kexec_core.c      |  2 +-
>   4 files changed, 21 insertions(+), 17 deletions(-)
> 
> diff --git a/arch/tile/mm/init.c b/arch/tile/mm/init.c
> index a0582b7..adce254 100644
> --- a/arch/tile/mm/init.c
> +++ b/arch/tile/mm/init.c
> @@ -679,7 +679,7 @@ static void __init init_free_pfn_range(unsigned long start, unsigned long end)
>   			 * Hacky direct set to avoid unnecessary
>   			 * lock take/release for EVERY page here.
>   			 */
> -			p->_count.counter = 0;
> +			p->_refcount.counter = 0;
>   			p->_mapcount.counter = -1;
>   		}
>   		init_page_count(page);
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 944b2b3..9e8eb5a 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -97,7 +97,11 @@ struct page {
>   					};
>   					int units;	/* SLOB */
>   				};
> -				atomic_t _count;		/* Usage count, see below. */
> +				/*
> +				 * Usage count, *USE WRAPPER FUNCTION*
> +				 * when manual accounting. See page_ref.h
> +				 */
> +				atomic_t _refcount;
>   			};
>   			unsigned int active;	/* SLAB */
>   		};
> @@ -248,7 +252,7 @@ struct page_frag_cache {
>   	__u32 offset;
>   #endif
>   	/* we maintain a pagecount bias, so that we dont dirty cache line
> -	 * containing page->_count every time we allocate a fragment.
> +	 * containing page->_refcount every time we allocate a fragment.
>   	 */
>   	unsigned int		pagecnt_bias;
>   	bool pfmemalloc;
> diff --git a/include/linux/page_ref.h b/include/linux/page_ref.h
> index e596d5d9..8b5e0a9 100644
> --- a/include/linux/page_ref.h
> +++ b/include/linux/page_ref.h
> @@ -63,17 +63,17 @@ static inline void __page_ref_unfreeze(struct page *page, int v)
>   
>   static inline int page_ref_count(struct page *page)
>   {
> -	return atomic_read(&page->_count);
> +	return atomic_read(&page->_refcount);
>   }
>   
>   static inline int page_count(struct page *page)
>   {
> -	return atomic_read(&compound_head(page)->_count);
> +	return atomic_read(&compound_head(page)->_refcount);
>   }
>   
>   static inline void set_page_count(struct page *page, int v)
>   {
> -	atomic_set(&page->_count, v);
> +	atomic_set(&page->_refcount, v);
>   	if (page_ref_tracepoint_active(__tracepoint_page_ref_set))
>   		__page_ref_set(page, v);
>   }
> @@ -89,35 +89,35 @@ static inline void init_page_count(struct page *page)
>   
>   static inline void page_ref_add(struct page *page, int nr)
>   {
> -	atomic_add(nr, &page->_count);
> +	atomic_add(nr, &page->_refcount);
>   	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod))
>   		__page_ref_mod(page, nr);
>   }
>   
>   static inline void page_ref_sub(struct page *page, int nr)
>   {
> -	atomic_sub(nr, &page->_count);
> +	atomic_sub(nr, &page->_refcount);
>   	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod))
>   		__page_ref_mod(page, -nr);
>   }
>   
>   static inline void page_ref_inc(struct page *page)
>   {
> -	atomic_inc(&page->_count);
> +	atomic_inc(&page->_refcount);
>   	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod))
>   		__page_ref_mod(page, 1);
>   }
>   
>   static inline void page_ref_dec(struct page *page)
>   {
> -	atomic_dec(&page->_count);
> +	atomic_dec(&page->_refcount);
>   	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod))
>   		__page_ref_mod(page, -1);
>   }
>   
>   static inline int page_ref_sub_and_test(struct page *page, int nr)
>   {
> -	int ret = atomic_sub_and_test(nr, &page->_count);
> +	int ret = atomic_sub_and_test(nr, &page->_refcount);
>   
>   	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod_and_test))
>   		__page_ref_mod_and_test(page, -nr, ret);
> @@ -126,7 +126,7 @@ static inline int page_ref_sub_and_test(struct page *page, int nr)
>   
>   static inline int page_ref_dec_and_test(struct page *page)
>   {
> -	int ret = atomic_dec_and_test(&page->_count);
> +	int ret = atomic_dec_and_test(&page->_refcount);
>   
>   	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod_and_test))
>   		__page_ref_mod_and_test(page, -1, ret);
> @@ -135,7 +135,7 @@ static inline int page_ref_dec_and_test(struct page *page)
>   
>   static inline int page_ref_dec_return(struct page *page)
>   {
> -	int ret = atomic_dec_return(&page->_count);
> +	int ret = atomic_dec_return(&page->_refcount);
>   
>   	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod_and_return))
>   		__page_ref_mod_and_return(page, -1, ret);
> @@ -144,7 +144,7 @@ static inline int page_ref_dec_return(struct page *page)
>   
>   static inline int page_ref_add_unless(struct page *page, int nr, int u)
>   {
> -	int ret = atomic_add_unless(&page->_count, nr, u);
> +	int ret = atomic_add_unless(&page->_refcount, nr, u);
>   
>   	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod_unless))
>   		__page_ref_mod_unless(page, nr, ret);
> @@ -153,7 +153,7 @@ static inline int page_ref_add_unless(struct page *page, int nr, int u)
>   
>   static inline int page_ref_freeze(struct page *page, int count)
>   {
> -	int ret = likely(atomic_cmpxchg(&page->_count, count, 0) == count);
> +	int ret = likely(atomic_cmpxchg(&page->_refcount, count, 0) == count);
>   
>   	if (page_ref_tracepoint_active(__tracepoint_page_ref_freeze))
>   		__page_ref_freeze(page, count, ret);
> @@ -165,7 +165,7 @@ static inline void page_ref_unfreeze(struct page *page, int count)
>   	VM_BUG_ON_PAGE(page_count(page) != 0, page);
>   	VM_BUG_ON(count == 0);
>   
> -	atomic_set(&page->_count, count);
> +	atomic_set(&page->_refcount, count);
>   	if (page_ref_tracepoint_active(__tracepoint_page_ref_unfreeze))
>   		__page_ref_unfreeze(page, count);
>   }
> diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
> index f826e11..e0e95b0 100644
> --- a/kernel/kexec_core.c
> +++ b/kernel/kexec_core.c
> @@ -1410,7 +1410,7 @@ static int __init crash_save_vmcoreinfo_init(void)
>   	VMCOREINFO_STRUCT_SIZE(list_head);
>   	VMCOREINFO_SIZE(nodemask_t);
>   	VMCOREINFO_OFFSET(page, flags);
> -	VMCOREINFO_OFFSET(page, _count);
> +	VMCOREINFO_OFFSET(page, _refcount);
>   	VMCOREINFO_OFFSET(page, mapping);
>   	VMCOREINFO_OFFSET(page, lru);
>   	VMCOREINFO_OFFSET(page, _mapcount);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
