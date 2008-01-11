Date: Fri, 11 Jan 2008 16:35:24 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 05/19] split LRU lists into anon & file sets
In-Reply-To: <20080108210002.638347207@redhat.com>
References: <20080108205939.323955454@redhat.com> <20080108210002.638347207@redhat.com>
Message-Id: <20080111162320.FD6A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Hi Rik

> @@ -1128,64 +1026,65 @@ static void shrink_active_list(unsigned 
  (snip)

> +	/*
> +	 * For sorting active vs inactive pages, we'll use the 'anon'
> +	 * elements of the local list[] array and sort out the file vs
> +	 * anon pages below.
> +	 */
>  	while (!list_empty(&l_hold)) {
> +		lru = LRU_INACTIVE_ANON;
>  		cond_resched();
>  		page = lru_to_page(&l_hold);
>  		list_del(&page->lru);
> -		if (page_mapped(page)) {
> -			if (!reclaim_mapped ||
> -			    (total_swap_pages == 0 && PageAnon(page)) ||
> -			    page_referenced(page, 0, sc->mem_cgroup)) {
> -				list_add(&page->lru, &list[LRU_ACTIVE]);
> -				continue;
> -			}
> -		} else if (TestClearPageReferenced(page)) {
> -			list_add(&page->lru, &list[LRU_ACTIVE]);
> -			continue;
> -		}
> -		list_add(&page->lru, &list[LRU_INACTIVE]);
> +		if (page_referenced(page, 0, sc->mem_cgroup))
> +			lru = LRU_ACTIVE_ANON;
> +		list_add(&page->lru, &list[lru]);
>  	}

Why drop (total_swap_pages == 0 && PageAnon(page)) condition?
in embedded sysmtem, 
CONFIG_NORECLAIM is OFF (because almost embedded cpu is 32bit) and
that anon move to inactive list is meaningless because it doesn't have swap.

below code is more good, may be.
but I don't understand yet why ignore page_referenced() result at anon page ;-)


- kosaki


---
 mm/vmscan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.24-rc6-mm1-rvr/mm/vmscan.c
===================================================================
--- linux-2.6.24-rc6-mm1-rvr.orig/mm/vmscan.c   2008-01-11 13:59:12.000000000 +0900
+++ linux-2.6.24-rc6-mm1-rvr/mm/vmscan.c        2008-01-11 16:16:44.000000000 +0900
@@ -1147,7 +1147,7 @@ static void shrink_active_list(unsigned
                }

                if (page_referenced(page, 0, sc->mem_cgroup)) {
-                       if (file)
+                       if (file || (total_swap_pages == 0))
                                /* Referenced file pages stay active. */
                                lru = LRU_ACTIVE_ANON;
                        else


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
