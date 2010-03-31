Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 306DE6B01EE
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 01:30:26 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2V5UNHH012310
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 31 Mar 2010 14:30:23 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F68845DE81
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 14:30:22 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5100A45DE85
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 14:30:18 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5440CE18012
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 14:30:17 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 825401DB804D
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 14:30:13 +0900 (JST)
Date: Wed, 31 Mar 2010 14:26:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 14/14] mm,migration: Allow the migration of
 PageSwapCache pages
Message-Id: <20100331142623.62ac9175.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1269940489-5776-15-git-send-email-mel@csn.ul.ie>
References: <1269940489-5776-1-git-send-email-mel@csn.ul.ie>
	<1269940489-5776-15-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 30 Mar 2010 10:14:49 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> PageAnon pages that are unmapped may or may not have an anon_vma so
> are not currently migrated. However, a swap cache page can be migrated
> and fits this description. This patch identifies page swap caches and
> allows them to be migrated.
> 

Some comments.

> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
>  mm/migrate.c |   15 ++++++++++-----
>  mm/rmap.c    |    6 ++++--
>  2 files changed, 14 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 35aad2a..f9bf37e 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -203,6 +203,9 @@ static int migrate_page_move_mapping(struct address_space *mapping,
>  	void **pslot;
>  
>  	if (!mapping) {
> +		if (PageSwapCache(page))
> +			SetPageSwapCache(newpage);
> +

Migration of SwapCache requires radix-tree replacement, IOW, 
 mapping == NULL && PageSwapCache is BUG.

So, this never happens.


>  		/* Anonymous page without mapping */
>  		if (page_count(page) != 1)
>  			return -EAGAIN;
> @@ -607,11 +610,13 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
>  		 * the page was isolated and when we reached here while
>  		 * the RCU lock was not held
>  		 */
> -		if (!page_mapped(page))
> -			goto rcu_unlock;
> -
> -		anon_vma = page_anon_vma(page);
> -		atomic_inc(&anon_vma->external_refcount);
> +		if (!page_mapped(page)) {
> +			if (!PageSwapCache(page))
> +				goto rcu_unlock;
> +		} else {
> +			anon_vma = page_anon_vma(page);
> +			atomic_inc(&anon_vma->external_refcount);
> +		}
>  	}
>  
>  	/*
> diff --git a/mm/rmap.c b/mm/rmap.c
> index af35b75..d5ea1f2 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1394,9 +1394,11 @@ int rmap_walk(struct page *page, int (*rmap_one)(struct page *,
>  
>  	if (unlikely(PageKsm(page)))
>  		return rmap_walk_ksm(page, rmap_one, arg);
> -	else if (PageAnon(page))
> +	else if (PageAnon(page)) {
> +		if (PageSwapCache(page))
> +			return SWAP_AGAIN;
>  		return rmap_walk_anon(page, rmap_one, arg);

SwapCache has a condition as (PageSwapCache(page) && page_mapped(page) == true.

Please see do_swap_page(), PageSwapCache bit is cleared only when

do_swap_page()...
       swap_free(entry);
        if (vm_swap_full() || (vma->vm_flags & VM_LOCKED) || PageMlocked(page))
                try_to_free_swap(page);

Then, PageSwapCache is cleared only when swap is freeable even if mapped.

rmap_walk_anon() should be called and the check is not necessary.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
