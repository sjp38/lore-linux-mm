Date: Thu, 28 Feb 2008 15:41:52 -0800
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [patch 14/21] scan noreclaim list for reclaimable pages
Message-Id: <20080228154152.9648b7b8.randy.dunlap@oracle.com>
In-Reply-To: <20080228192929.203173998@redhat.com>
References: <20080228192908.126720629@redhat.com>
	<20080228192929.203173998@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Thu, 28 Feb 2008 14:29:22 -0500 Rik van Riel wrote:

> V2 -> V3:
> + rebase to 23-mm1 atop RvR's split LRU series
> 
> New in V2
> 
> This patch adds a function to scan individual or all zones' noreclaim
> lists and move any pages that have become reclaimable onto the respective
> zone's inactive list, where shrink_inactive_list() will deal with them.
> 
> This replaces the function to splice the entire noreclaim list onto the
> active list for rescan by shrink_active_list().  That method had problems
> with vmstat accounting and complicated '[__]isolate_lru_pages()'.  Now,
> __isolate_lru_page() will never isolate a non-reclaimable page.  The
> only time it should see one is when scanning nearby pages for lumpy
> reclaim.
> 
>   TODO:  This approach may still need some refinement.
>          E.g., put back to active list?
> 
> DEBUGGING ONLY: NOT FOR UPSTREAM MERGE
> 
> Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
> Signed-off-by:  Rik van Riel <riel@redhat.com>


Hi,

I haven't looked at all 21 patches, but please use kernel-doc
notation as it's defined.  See Documentation/kernel-doc-nano-HOWTO.txt
for details, or ask.

> Index: linux-2.6.25-rc2-mm1/mm/vmscan.c
> ===================================================================
> --- linux-2.6.25-rc2-mm1.orig/mm/vmscan.c	2008-02-28 11:05:04.000000000 -0500
> +++ linux-2.6.25-rc2-mm1/mm/vmscan.c	2008-02-28 12:48:01.000000000 -0500
> @@ -2295,4 +2296,144 @@ int page_reclaimable(struct page *page, 
>  
>  	return 1;
>  }
> +
> +/**
> + * scan_zone_noreclaim_pages(@zone)
> + * @zone - zone to scan

E.g.:

 * scan_zone_reclaim_pages - some short description here
 * @zone: zone to scan


> + *
> + * Scan @zone's noreclaim LRU lists to check for pages that have become
> + * reclaimable.  Move those that have to @zone's inactive list where they
> + * become candidates for reclaim, unless shrink_inactive_zone() decides
> + * to reactivate them.  Pages that are still non-reclaimable are rotated
> + * back onto @zone's noreclaim list.
> + */
> +#define SCAN_NORECLAIM_BATCH_SIZE 16UL	/* arbitrary lock hold batch size */

and don't insert macros between the kernel-doc section and the
function definition, please.


> +void scan_zone_noreclaim_pages(struct zone *zone)
> +{
...
> +}

---
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
