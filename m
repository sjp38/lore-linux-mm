Subject: Re: [patch 1/1] vmscan: give referenced, active and unmapped pages
	a second trip around the LRU
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <200705242357.l4ONvw49006681@shell0.pdx.osdl.net>
References: <200705242357.l4ONvw49006681@shell0.pdx.osdl.net>
Content-Type: text/plain
Date: Fri, 25 May 2007 09:02:45 +0200
Message-Id: <1180076565.7348.14.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, mbligh@mbligh.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Thu, 2007-05-24 at 16:57 -0700, akpm@linux-foundation.org wrote:
> Martin spotted this.
> 
> In the original rmap conversion in 2.5.32 we broke aging of pagecache pages on
> the active list: we deactivate these pages even if they had PG_referenced set.
> 
> We should instead clear PG_referenced and give these pages another trip around
> the active list.
> 
> We have basically no way of working out whether or not this change will
> benefit or worsen anything.
> 
> Cc: Martin Bligh <mbligh@mbligh.org>
> Cc: Rik van Riel <riel@redhat.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/vmscan.c |    3 +++
>  1 files changed, 3 insertions(+)
> 
> diff -puN mm/vmscan.c~vmscan-give-referenced-active-and-unmapped-pages-a-second-trip-around-the-lru mm/vmscan.c
> --- a/mm/vmscan.c~vmscan-give-referenced-active-and-unmapped-pages-a-second-trip-around-the-lru
> +++ a/mm/vmscan.c
> @@ -836,6 +836,9 @@ force_reclaim_mapped:
>  				list_add(&page->lru, &l_active);
>  				continue;
>  			}
> +		} else if (TestClearPageReferenced(page)) {
> +			list_add(&page->lru, &l_active);
> +			continue;
>  		}
>  		list_add(&page->lru, &l_inactive);
>  	}

I myself prefer a patch like this:

---
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 53ad8ee..5addda9 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -957,16 +957,17 @@ force_reclaim_mapped:
 	spin_unlock_irq(&zone->lru_lock);
 
 	while (!list_empty(&l_hold)) {
+		int referenced;
+
 		cond_resched();
 		page = lru_to_page(&l_hold);
 		list_del(&page->lru);
-		if (page_mapped(page)) {
-			if (!reclaim_mapped ||
-			    (total_swap_pages == 0 && PageAnon(page)) ||
-			    page_referenced(page, 0)) {
-				list_add(&page->lru, &l_active);
-				continue;
-			}
+
+		referenced = page_referenced(page, 0);
+		if (referenced || (page_mapped(page) && !reclaim_mapped) ||
+				(total_swap_pages == 0 && PageAnon(page))) {
+			list_add(&page->lru, &l_active);
+			continue;
 		}
 		list_add(&page->lru, &l_inactive);
 	}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
