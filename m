Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 7E1446B0005
	for <linux-mm@kvack.org>; Sat, 26 Jan 2013 21:48:49 -0500 (EST)
Received: by mail-da0-f52.google.com with SMTP id f10so735586dak.39
        for <linux-mm@kvack.org>; Sat, 26 Jan 2013 18:48:48 -0800 (PST)
Message-ID: <1359254927.4159.11.camel@kernel>
Subject: Re: [PATCH 5/11] ksm: get_ksm_page locked
From: Simon Jeons <simon.jeons@gmail.com>
Date: Sat, 26 Jan 2013 20:48:47 -0600
In-Reply-To: <alpine.LNX.2.00.1301251759470.29196@eggly.anvils>
References: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils>
	 <alpine.LNX.2.00.1301251759470.29196@eggly.anvils>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 2013-01-25 at 18:00 -0800, Hugh Dickins wrote:
> In some places where get_ksm_page() is used, we need the page to be locked.
> 
> When KSM migration is fully enabled, we shall want that to make sure that
> the page just acquired cannot be migrated beneath us (raised page count is
> only effective when there is serialization to make sure migration notices).
> Whereas when navigating through the stable tree, we certainly do not want
> to lock each node (raised page count is enough to guarantee the memcmps,
> even if page is migrated to another node).
> 
> Since we're about to add another use case, add the locked argument to
> get_ksm_page() now.
> 
> Hmm, what's that rcu_read_lock() about?  Complete misunderstanding, I
> really got the wrong end of the stick on that!  There's a configuration
> in which page_cache_get_speculative() can do something cheaper than
> get_page_unless_zero(), relying on its caller's rcu_read_lock() to have
> disabled preemption for it.  There's no need for rcu_read_lock() around
> get_page_unless_zero() (and mapping checks) here.  Cut out that
> silliness before making this any harder to understand.

BTW, what's the meaning of ksm page forked? 

> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
>  mm/ksm.c |   23 +++++++++++++----------
>  1 file changed, 13 insertions(+), 10 deletions(-)
> 
> --- mmotm.orig/mm/ksm.c	2013-01-25 14:36:53.244205966 -0800
> +++ mmotm/mm/ksm.c	2013-01-25 14:36:58.856206099 -0800
> @@ -514,15 +514,14 @@ static void remove_node_from_stable_tree
>   * but this is different - made simpler by ksm_thread_mutex being held, but
>   * interesting for assuming that no other use of the struct page could ever
>   * put our expected_mapping into page->mapping (or a field of the union which
> - * coincides with page->mapping).  The RCU calls are not for KSM at all, but
> - * to keep the page_count protocol described with page_cache_get_speculative.
> + * coincides with page->mapping).
>   *
>   * Note: it is possible that get_ksm_page() will return NULL one moment,
>   * then page the next, if the page is in between page_freeze_refs() and
>   * page_unfreeze_refs(): this shouldn't be a problem anywhere, the page
>   * is on its way to being freed; but it is an anomaly to bear in mind.
>   */
> -static struct page *get_ksm_page(struct stable_node *stable_node)
> +static struct page *get_ksm_page(struct stable_node *stable_node, bool locked)
>  {
>  	struct page *page;
>  	void *expected_mapping;
> @@ -530,7 +529,6 @@ static struct page *get_ksm_page(struct
>  	page = pfn_to_page(stable_node->kpfn);
>  	expected_mapping = (void *)stable_node +
>  				(PAGE_MAPPING_ANON | PAGE_MAPPING_KSM);
> -	rcu_read_lock();
>  	if (page->mapping != expected_mapping)
>  		goto stale;
>  	if (!get_page_unless_zero(page))
> @@ -539,10 +537,16 @@ static struct page *get_ksm_page(struct
>  		put_page(page);
>  		goto stale;
>  	}
> -	rcu_read_unlock();
> +	if (locked) {
> +		lock_page(page);
> +		if (page->mapping != expected_mapping) {
> +			unlock_page(page);
> +			put_page(page);
> +			goto stale;
> +		}
> +	}
>  	return page;
>  stale:
> -	rcu_read_unlock();
>  	remove_node_from_stable_tree(stable_node);
>  	return NULL;
>  }
> @@ -558,11 +562,10 @@ static void remove_rmap_item_from_tree(s
>  		struct page *page;
>  
>  		stable_node = rmap_item->head;
> -		page = get_ksm_page(stable_node);
> +		page = get_ksm_page(stable_node, true);
>  		if (!page)
>  			goto out;
>  
> -		lock_page(page);
>  		hlist_del(&rmap_item->hlist);
>  		unlock_page(page);
>  		put_page(page);
> @@ -1042,7 +1045,7 @@ static struct page *stable_tree_search(s
>  
>  		cond_resched();
>  		stable_node = rb_entry(node, struct stable_node, node);
> -		tree_page = get_ksm_page(stable_node);
> +		tree_page = get_ksm_page(stable_node, false);
>  		if (!tree_page)
>  			return NULL;
>  
> @@ -1086,7 +1089,7 @@ static struct stable_node *stable_tree_i
>  
>  		cond_resched();
>  		stable_node = rb_entry(*new, struct stable_node, node);
> -		tree_page = get_ksm_page(stable_node);
> +		tree_page = get_ksm_page(stable_node, false);
>  		if (!tree_page)
>  			return NULL;
>  
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
