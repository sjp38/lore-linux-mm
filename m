Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4D7856B0390
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 13:04:53 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id 46so6967836qtu.18
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 10:04:53 -0700 (PDT)
Received: from mail-qt0-f177.google.com (mail-qt0-f177.google.com. [209.85.216.177])
        by mx.google.com with ESMTPS id k82si6674978qkl.183.2017.03.29.10.04.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Mar 2017 10:04:51 -0700 (PDT)
Received: by mail-qt0-f177.google.com with SMTP id i34so18247144qtc.0
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 10:04:51 -0700 (PDT)
Subject: Re: [PATCH] mm: enable page poisoning early at boot
References: <1490358246-11001-1-git-send-email-vinmenon@codeaurora.org>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <d9e8b184-b2a9-1174-4a6b-17ae1d2d6444@redhat.com>
Date: Wed, 29 Mar 2017 10:04:47 -0700
MIME-Version: 1.0
In-Reply-To: <1490358246-11001-1-git-send-email-vinmenon@codeaurora.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>, iamjoonsoo.kim@lge.com, mhocko@suse.com, akpm@linux-foundation.org
Cc: shashim@codeaurora.org, linux-mm@kvack.org

On 03/24/2017 05:24 AM, Vinayak Menon wrote:
> On SPARSEMEM systems page poisoning is enabled after buddy is up, because
> of the dependency on page extension init. This causes the pages released
> by free_all_bootmem not to be poisoned. This either delays or misses
> the identification of some issues because the pages have to undergo another
> cycle of alloc-free-alloc for any corruption to be detected.
> Enable page poisoning early by getting rid of the PAGE_EXT_DEBUG_POISON
> flag. Since all the free pages will now be poisoned, the flag need not be
> verified before checking the poison during an alloc.
> 
> Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
> ---
> 
> An RFC was sent earlier (http://www.spinics.net/lists/linux-mm/msg123142.html)
> Not sure if there exists a code path that can free pages to buddy skipping
> kernel_poison_pages, making the flag PAGE_EXT_DEBUG_POISON a necessity. But
> the tests have not shown any issues. As per Laura's suggestion, the patch was
> tested with HIBERNATION enabled and no issues were seen.
> 

I gave this a spin on some of my machines and it appears to be working
okay. I wish we had a bit more context about why it was necessary to track
the poison in the page itself.

This change means that we shouldn't need the "select PAGE_EXTENSION"
anymore so that can be dropped. If you do that, you can add

Acked-by: Laura Abbott <labbott@redhat.com>

>  include/linux/mm.h |  1 -
>  mm/page_alloc.c    | 13 +++------
>  mm/page_ext.c      |  3 ---
>  mm/page_poison.c   | 77 +++++++++---------------------------------------------
>  4 files changed, 15 insertions(+), 79 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 0d65dd7..b881966 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2473,7 +2473,6 @@ extern long copy_huge_page_from_user(struct page *dst_page,
>  #endif /* CONFIG_TRANSPARENT_HUGEPAGE || CONFIG_HUGETLBFS */
>  
>  extern struct page_ext_operations debug_guardpage_ops;
> -extern struct page_ext_operations page_poisoning_ops;
>  
>  #ifdef CONFIG_DEBUG_PAGEALLOC
>  extern unsigned int _debug_guardpage_minorder;
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index fc5db1b..860b36f 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1694,10 +1694,10 @@ static inline int check_new_page(struct page *page)
>  	return 1;
>  }
>  
> -static inline bool free_pages_prezeroed(bool poisoned)
> +static inline bool free_pages_prezeroed(void)
>  {
>  	return IS_ENABLED(CONFIG_PAGE_POISONING_ZERO) &&
> -		page_poisoning_enabled() && poisoned;
> +		page_poisoning_enabled();
>  }
>  
>  #ifdef CONFIG_DEBUG_VM
> @@ -1751,17 +1751,10 @@ static void prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags
>  							unsigned int alloc_flags)
>  {
>  	int i;
> -	bool poisoned = true;
> -
> -	for (i = 0; i < (1 << order); i++) {
> -		struct page *p = page + i;
> -		if (poisoned)
> -			poisoned &= page_is_poisoned(p);
> -	}
>  
>  	post_alloc_hook(page, order, gfp_flags);
>  
> -	if (!free_pages_prezeroed(poisoned) && (gfp_flags & __GFP_ZERO))
> +	if (!free_pages_prezeroed() && (gfp_flags & __GFP_ZERO))
>  		for (i = 0; i < (1 << order); i++)
>  			clear_highpage(page + i);
>  
> diff --git a/mm/page_ext.c b/mm/page_ext.c
> index 121dcff..fc3e7ff 100644
> --- a/mm/page_ext.c
> +++ b/mm/page_ext.c
> @@ -59,9 +59,6 @@
>  
>  static struct page_ext_operations *page_ext_ops[] = {
>  	&debug_guardpage_ops,
> -#ifdef CONFIG_PAGE_POISONING
> -	&page_poisoning_ops,
> -#endif
>  #ifdef CONFIG_PAGE_OWNER
>  	&page_owner_ops,
>  #endif
> diff --git a/mm/page_poison.c b/mm/page_poison.c
> index 2e647c6..be19e98 100644
> --- a/mm/page_poison.c
> +++ b/mm/page_poison.c
> @@ -6,7 +6,6 @@
>  #include <linux/poison.h>
>  #include <linux/ratelimit.h>
>  
> -static bool __page_poisoning_enabled __read_mostly;
>  static bool want_page_poisoning __read_mostly;
>  
>  static int early_page_poison_param(char *buf)
> @@ -19,74 +18,21 @@ static int early_page_poison_param(char *buf)
>  
>  bool page_poisoning_enabled(void)
>  {
> -	return __page_poisoning_enabled;
> -}
> -
> -static bool need_page_poisoning(void)
> -{
> -	return want_page_poisoning;
> -}
> -
> -static void init_page_poisoning(void)
> -{
>  	/*
> -	 * page poisoning is debug page alloc for some arches. If either
> -	 * of those options are enabled, enable poisoning
> +	 * Assumes that debug_pagealloc_enabled is set before
> +	 * free_all_bootmem.
> +	 * Page poisoning is debug page alloc for some arches. If
> +	 * either of those options are enabled, enable poisoning.
>  	 */
> -	if (!IS_ENABLED(CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC)) {
> -		if (!want_page_poisoning && !debug_pagealloc_enabled())
> -			return;
> -	} else {
> -		if (!want_page_poisoning)
> -			return;
> -	}
> -
> -	__page_poisoning_enabled = true;
> -}
> -
> -struct page_ext_operations page_poisoning_ops = {
> -	.need = need_page_poisoning,
> -	.init = init_page_poisoning,
> -};
> -
> -static inline void set_page_poison(struct page *page)
> -{
> -	struct page_ext *page_ext;
> -
> -	page_ext = lookup_page_ext(page);
> -	if (unlikely(!page_ext))
> -		return;
> -
> -	__set_bit(PAGE_EXT_DEBUG_POISON, &page_ext->flags);
> -}
> -
> -static inline void clear_page_poison(struct page *page)
> -{
> -	struct page_ext *page_ext;
> -
> -	page_ext = lookup_page_ext(page);
> -	if (unlikely(!page_ext))
> -		return;
> -
> -	__clear_bit(PAGE_EXT_DEBUG_POISON, &page_ext->flags);
> -}
> -
> -bool page_is_poisoned(struct page *page)
> -{
> -	struct page_ext *page_ext;
> -
> -	page_ext = lookup_page_ext(page);
> -	if (unlikely(!page_ext))
> -		return false;
> -
> -	return test_bit(PAGE_EXT_DEBUG_POISON, &page_ext->flags);
> +	return (want_page_poisoning ||
> +		(!IS_ENABLED(CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC) &&
> +		debug_pagealloc_enabled()));
>  }
>  
>  static void poison_page(struct page *page)
>  {
>  	void *addr = kmap_atomic(page);
>  
> -	set_page_poison(page);
>  	memset(addr, PAGE_POISON, PAGE_SIZE);
>  	kunmap_atomic(addr);
>  }
> @@ -140,12 +86,13 @@ static void unpoison_page(struct page *page)
>  {
>  	void *addr;
>  
> -	if (!page_is_poisoned(page))
> -		return;
> -
>  	addr = kmap_atomic(page);
> +	/*
> +	 * Page poisoning when enabled poisons each and every page
> +	 * that is freed to buddy. Thus no extra check is done to
> +	 * see if a page was posioned.
> +	 */
>  	check_poison_mem(addr, PAGE_SIZE);
> -	clear_page_poison(page);
>  	kunmap_atomic(addr);
>  }
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
