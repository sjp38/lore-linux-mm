Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id D6BF96B0036
	for <linux-mm@kvack.org>; Fri,  5 Sep 2014 10:47:44 -0400 (EDT)
Received: by mail-lb0-f182.google.com with SMTP id u10so13655344lbd.13
        for <linux-mm@kvack.org>; Fri, 05 Sep 2014 07:47:41 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id ab3si3381200lbc.52.2014.09.05.07.47.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 05 Sep 2014 07:47:39 -0700 (PDT)
Date: Fri, 5 Sep 2014 10:47:23 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: regression caused by cgroups optimization in 3.17-rc2
Message-ID: <20140905144723.GB13392@cmpxchg.org>
References: <54061505.8020500@sr71.net>
 <5406262F.4050705@intel.com>
 <54062F32.5070504@sr71.net>
 <20140904142721.GB14548@dhcp22.suse.cz>
 <5408CB2E.3080101@sr71.net>
 <20140905092537.GC26243@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140905092537.GC26243@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Dave Hansen <dave@sr71.net>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Tejun Heo <tj@kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Sep 05, 2014 at 11:25:37AM +0200, Michal Hocko wrote:
> @@ -900,10 +900,10 @@ void lru_add_drain_all(void)
>   * grabbed the page via the LRU.  If it did, give up: shrink_inactive_list()
>   * will free it.
>   */
> -void release_pages(struct page **pages, int nr, bool cold)
> +static void release_lru_pages(struct page **pages, int nr,
> +			      struct list_head *pages_to_free)
>  {
>  	int i;
> -	LIST_HEAD(pages_to_free);
>  	struct zone *zone = NULL;
>  	struct lruvec *lruvec;
>  	unsigned long uninitialized_var(flags);
> @@ -943,11 +943,26 @@ void release_pages(struct page **pages, int nr, bool cold)
>  		/* Clear Active bit in case of parallel mark_page_accessed */
>  		__ClearPageActive(page);
>  
> -		list_add(&page->lru, &pages_to_free);
> +		list_add(&page->lru, pages_to_free);
>  	}
>  	if (zone)
>  		spin_unlock_irqrestore(&zone->lru_lock, flags);
> +}
> +/*
> + * Batched page_cache_release(). Frees and uncharges all given pages
> + * for which the reference count drops to 0.
> + */
> +void release_pages(struct page **pages, int nr, bool cold)
> +{
> +	LIST_HEAD(pages_to_free);
>  
> +	while (nr) {
> +		int batch = min(nr, PAGEVEC_SIZE);
> +
> +		release_lru_pages(pages, batch, &pages_to_free);
> +		pages += batch;
> +		nr -= batch;
> +	}

We might be able to process a lot more pages in one go if nobody else
needs the lock or the CPU.  Can't we just cycle the lock or reschedule
if necessary?

diff --git a/mm/swap.c b/mm/swap.c
index 6b2dc3897cd5..ee0cf21dd521 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -944,6 +944,15 @@ void release_pages(struct page **pages, int nr, bool cold)
 		__ClearPageActive(page);
 
 		list_add(&page->lru, &pages_to_free);
+
+		if (should_resched() ||
+		    (zone && spin_needbreak(&zone->lru_lock))) {
+			if (zone) {
+				spin_unlock_irqrestore(&zone->lru_lock, flags);
+				zone = NULL;
+			}
+			cond_resched();
+		}
 	}
 	if (zone)
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 3e0ec83d000c..c487ca4682a4 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -262,19 +262,12 @@ void free_page_and_swap_cache(struct page *page)
  */
 void free_pages_and_swap_cache(struct page **pages, int nr)
 {
-	struct page **pagep = pages;
+	int i;
 
 	lru_add_drain();
-	while (nr) {
-		int todo = min(nr, PAGEVEC_SIZE);
-		int i;
-
-		for (i = 0; i < todo; i++)
-			free_swap_cache(pagep[i]);
-		release_pages(pagep, todo, false);
-		pagep += todo;
-		nr -= todo;
-	}
+	for (i = 0; i < nr; i++)
+		free_swap_cache(pages[i]);
+	release_pages(pages, nr, false);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
