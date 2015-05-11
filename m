Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0E1A56B0038
	for <linux-mm@kvack.org>; Mon, 11 May 2015 05:39:38 -0400 (EDT)
Received: by wgin8 with SMTP id n8so122513015wgi.0
        for <linux-mm@kvack.org>; Mon, 11 May 2015 02:39:37 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id q20si11234990wiv.60.2015.05.11.02.39.35
        for <linux-mm@kvack.org>;
        Mon, 11 May 2015 02:39:36 -0700 (PDT)
Date: Mon, 11 May 2015 12:36:52 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC] rmap: fix "race" between do_wp_page and shrink_active_list
Message-ID: <20150511093652.GA11257@node.dhcp.inet.fi>
References: <1431330677-24476-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1431330677-24476-1-git-send-email-vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@linux.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, May 11, 2015 at 10:51:17AM +0300, Vladimir Davydov wrote:
> Hi,
> 
> I've been arguing with Minchan for a while about whether store-tearing
> is possible while setting page->mapping in __page_set_anon_rmap and
> friends, see
> 
>   http://thread.gmane.org/gmane.linux.kernel.mm/131949/focus=132132
> 
> This patch is intended to draw attention to this discussion. It fixes a
> race that could happen if store-tearing were possible. The race is as
> follows.
> 
> In do_wp_page() we can call page_move_anon_rmap(), which sets
> page->mapping as follows:
> 
>         anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
>         page->mapping = (struct address_space *) anon_vma;
> 
> The page in question may be on an LRU list, because nowhere in
> do_wp_page() we remove it from the list, neither do we take any LRU
> related locks. Although the page is locked, shrink_active_list() can
> still call page_referenced() on it concurrently, because the latter does
> not require an anonymous page to be locked.
> 
> If store tearing described in the thread were possible, we could face
> the following race resulting in kernel panic:
> 
>   CPU0                          CPU1
>   ----                          ----
>   do_wp_page                    shrink_active_list
>    lock_page                     page_referenced
>                                   PageAnon->yes, so skip trylock_page
>    page_move_anon_rmap
>     page->mapping = anon_vma
>                                   rmap_walk
>                                    PageAnon->no
>                                    rmap_walk_file
>                                     BUG
>     page->mapping += PAGE_MAPPING_ANON
> 
> This patch fixes this race by explicitly forbidding the compiler to
> split page->mapping store in __page_set_anon_rmap() and friends and load
> in PageAnon() with the aid of WRITE/READ_ONCE.
> 
> Personally, I don't believe that this can ever happen on any sane
> compiler, because such an "optimization" would only result in two stores
> vs one (note, anon_vma is not a constant), but since I can be mistaken I
> would like to hear from synchronization experts what they think about
> it.
> 
> Thanks,
> Vladimir
> ---
>  include/linux/page-flags.h |    3 ++-
>  mm/rmap.c                  |    6 +++---
>  2 files changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index 5e7c4f50a644..a529e0a35fe9 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -320,7 +320,8 @@ PAGEFLAG(Idle, idle)
>  
>  static inline int PageAnon(struct page *page)
>  {
> -	return ((unsigned long)page->mapping & PAGE_MAPPING_ANON) != 0;
> +	return ((unsigned long)READ_ONCE(page->mapping) &
> +		PAGE_MAPPING_ANON) != 0;

Why do we need this? Write side should be enough to get this
deterministic.

>  }
>  
>  #ifdef CONFIG_KSM
> diff --git a/mm/rmap.c b/mm/rmap.c
> index eca7416f55d7..aa60c63704e6 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -958,7 +958,7 @@ void page_move_anon_rmap(struct page *page,
>  	VM_BUG_ON_PAGE(page->index != linear_page_index(vma, address), page);
>  
>  	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
> -	page->mapping = (struct address_space *) anon_vma;
> +	WRITE_ONCE(page->mapping, (struct address_space *) anon_vma);
>  }
>  
>  /**
> @@ -987,7 +987,7 @@ static void __page_set_anon_rmap(struct page *page,
>  		anon_vma = anon_vma->root;
>  
>  	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
> -	page->mapping = (struct address_space *) anon_vma;
> +	WRITE_ONCE(page->mapping, (struct address_space *) anon_vma);
>  	page->index = linear_page_index(vma, address);

No need: we don't hit this code if page is already PageAnon().

>  }
>  
> @@ -1579,7 +1579,7 @@ static void __hugepage_set_anon_rmap(struct page *page,
>  		anon_vma = anon_vma->root;
>  
>  	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
> -	page->mapping = (struct address_space *) anon_vma;
> +	WRITE_ONCE(page->mapping, (struct address_space *) anon_vma);

Ditto.

>  	page->index = linear_page_index(vma, address);
>  }
>  
> -- 
> 1.7.10.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
