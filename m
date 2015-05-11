Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id 389B86B0038
	for <linux-mm@kvack.org>; Mon, 11 May 2015 10:29:43 -0400 (EDT)
Received: by qcbgy10 with SMTP id gy10so69619168qcb.3
        for <linux-mm@kvack.org>; Mon, 11 May 2015 07:29:43 -0700 (PDT)
Received: from e39.co.us.ibm.com (e39.co.us.ibm.com. [32.97.110.160])
        by mx.google.com with ESMTPS id r22si13113377qkh.86.2015.05.11.07.29.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Mon, 11 May 2015 07:29:42 -0700 (PDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 11 May 2015 08:29:41 -0600
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 148213E4003B
	for <linux-mm@kvack.org>; Mon, 11 May 2015 08:29:37 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by b03cxnp08027.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t4BETaTc37290040
	for <linux-mm@kvack.org>; Mon, 11 May 2015 07:29:36 -0700
Received: from d03av05.boulder.ibm.com (localhost [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t4BETZpb032025
	for <linux-mm@kvack.org>; Mon, 11 May 2015 08:29:36 -0600
Date: Mon, 11 May 2015 07:24:02 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC] rmap: fix "race" between do_wp_page and shrink_active_list
Message-ID: <20150511142402.GJ6776@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1431330677-24476-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1431330677-24476-1-git-send-email-vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@linux.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

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

An example "insane" compiler might notice that the value set cannot be
safely observed without multiple CPUs accessing that variable at the
same time.  A paper entitled "No Sane Compiler Would Optimize Atomics"
has some examples:

	http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2015/n4455.html

If this paper doesn't scare you, then you didn't read it carefully enough.
And yes, I did give the author a very hard time about the need to suppress
some of these optimizations in order to correctly compile old code, and
will continue to do so.  However, a READ_ONCE() would be a most excellent
and very cheap way to future-proof this code, and is highly recommended.

							Thanx, Paul

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
>  }
> 
> @@ -1579,7 +1579,7 @@ static void __hugepage_set_anon_rmap(struct page *page,
>  		anon_vma = anon_vma->root;
> 
>  	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
> -	page->mapping = (struct address_space *) anon_vma;
> +	WRITE_ONCE(page->mapping, (struct address_space *) anon_vma);
>  	page->index = linear_page_index(vma, address);
>  }
> 
> -- 
> 1.7.10.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
