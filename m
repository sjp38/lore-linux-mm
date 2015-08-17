Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 4A6B16B0253
	for <linux-mm@kvack.org>; Sun, 16 Aug 2015 21:41:37 -0400 (EDT)
Received: by paccq16 with SMTP id cq16so53192740pac.1
        for <linux-mm@kvack.org>; Sun, 16 Aug 2015 18:41:37 -0700 (PDT)
Received: from mail-pd0-x230.google.com (mail-pd0-x230.google.com. [2607:f8b0:400e:c02::230])
        by mx.google.com with ESMTPS id d15si4364738pbu.155.2015.08.16.18.41.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Aug 2015 18:41:36 -0700 (PDT)
Received: by pdrg1 with SMTP id g1so49982345pdr.2
        for <linux-mm@kvack.org>; Sun, 16 Aug 2015 18:41:36 -0700 (PDT)
Date: Sun, 16 Aug 2015 18:40:16 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/2] mm: make compound_head() robust
In-Reply-To: <1439481286-81093-3-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.LSU.2.11.1508161751150.1299@eggly.anvils>
References: <1439481286-81093-1-git-send-email-kirill.shutemov@linux.intel.com> <1439481286-81093-3-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>

On Thu, 13 Aug 2015, Kirill A. Shutemov wrote:

> Hugh has pointed that compound_head() call can be unsafe in some
> context. There's one example:
> 
> 	CPU0					CPU1
> 
> isolate_migratepages_block()
>   page_count()
>     compound_head()
>       !!PageTail() == true
> 					put_page()
> 					  tail->first_page = NULL
>       head = tail->first_page
> 					alloc_pages(__GFP_COMP)
> 					   prep_compound_page()
> 					     tail->first_page = head
> 					     __SetPageTail(p);
>       !!PageTail() == true
>     <head == NULL dereferencing>
> 
> The race is pure theoretical. I don't it's possible to trigger it in
> practice. But who knows.
> 
> We can fix the race by chaging how encode PageTail() and compound_head()
> within struct page to be able to update them in one shot.
> 
> The patch introduces page->compound_head into union with
> page->mem_cgroup.
> 
> Set bit 0 of page->compound_head means that the page is tail. If the bit
> set, rest of the page->compound_head is pointer to head page. Otherwise,
> the field is NULL or pointer to memory cgroup.
> 
> page->mem_cgroup currenly only used for small or head pages, so there
> shouldn't be any conflicts.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> ---
>  Documentation/vm/split_page_table_lock |  4 +-
>  arch/xtensa/configs/iss_defconfig      |  1 -
>  include/linux/mm.h                     | 53 ++--------------------
>  include/linux/mm_types.h               | 15 ++++---
>  include/linux/page-flags.h             | 80 ++++++++--------------------------
>  mm/Kconfig                             | 12 -----
>  mm/debug.c                             |  7 ---
>  mm/hugetlb.c                           |  8 +---
>  mm/internal.h                          |  4 +-
>  mm/memory-failure.c                    |  7 ---
>  mm/page_alloc.c                        | 36 +++++++--------
>  mm/swap.c                              |  4 +-
>  12 files changed, 56 insertions(+), 175 deletions(-)

Mostly I like this: especially those deletions,
and removing the unloved CONFIG_PAGEFLAGS_EXTENDED.

But I do disagree with:

> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 0038ac7466fd..e0c4c0a8ec3d 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -172,13 +172,17 @@ struct page {
>  #endif
>  #endif
>  		struct kmem_cache *slab_cache;	/* SL[AU]B: Pointer to slab */
> -		struct page *first_page;	/* Compound tail pages */
>  	};
>  
> -#ifdef CONFIG_MEMCG
> -	struct mem_cgroup *mem_cgroup;
> -#endif
> +	union {
> +		/* Bit zero of the word encode PageTail() */
> +		struct mem_cgroup *mem_cgroup;	/* If bit zero is clear */
> +		unsigned long compound_head;	/* If bit zero is set */
> +	};

On 32-bit, I think the addition of that mem_cgroup pointer enlarged
struct page from 32 bytes to 36 (SLAB or SLOB) or 40 (SLUB) bytes.
I can well imagine people wanting to cut that bloat by turning off
CONFIG_MEMCG, but now you would be thwarting them.  (I can also
imagine memcg people might want to add flag bits of their own to it.)

My own preference (Andrew might disagree) would be to give up on
compound_page_dtor *compound_dtor: in all the years it's been there,
it has only been assigned two possibilities, and I think you'd do
well to hard code those in the one or two places they're needed -
moving PageHuge to be a second bit alongside your PageTail (but of
course it could only be set in the first tail page, not the head).

But as far as fixing the isolate_migratepages_block() bug you
discovered, I think your original atomic_read(&page->_count) fix
was good enough, or a page_count_raw(page) if Andrew prefers -
though I'm not so keen on dressing these things up myself, such
raw scans are exceptional and face very special problems, I like
to see exactly what's going on in them.

And even when a race between PageTail and first_page is resolved
by your READ_ONCE, it still leaves races of whether the head page
still agrees with the tail.  Safer races now because first_page is
reliably a recent first_page pointer: which might be all that's needed
to make your refcounting patches' wider use of compound_head() safe -
this patch does look like a good step for those.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
