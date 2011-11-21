Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 23E146B0069
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 06:51:37 -0500 (EST)
Date: Mon, 21 Nov 2011 11:51:31 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 3/8] mm: check if we isolated a compound page during
 lumpy scan
Message-ID: <20111121115131.GC19415@suse.de>
References: <1321635524-8586-1-git-send-email-mgorman@suse.de>
 <1321732460-14155-4-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1321732460-14155-4-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, linux-kernel@vger.kernel.org

On Sat, Nov 19, 2011 at 08:54:15PM +0100, Andrea Arcangeli wrote:
> Properly take into account if we isolated a compound page during the
> lumpy scan in reclaim and break the loop if we've isolated enough.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
>  1 files changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a1893c0..3421746 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1183,13 +1183,16 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  				break;
>  
>  			if (__isolate_lru_page(cursor_page, mode, file) == 0) {
> +				unsigned int isolated_pages;
>  				list_move(&cursor_page->lru, dst);
>  				mem_cgroup_del_lru(cursor_page);
> -				nr_taken += hpage_nr_pages(page);

nr_taken was already being updated correctly.

> -				nr_lumpy_taken++;
> +				isolated_pages = hpage_nr_pages(page);
> +				nr_taken += isolated_pages;
> +				nr_lumpy_taken += isolated_pages;

nr_lumpy_taken was not, and this patch corrects it.

>  				if (PageDirty(cursor_page))
> -					nr_lumpy_dirty++;
> +					nr_lumpy_dirty += isolated_pages;

nr_lumpy_dirty was not, and this patch corrects it.

However, the nr_lumpy_* variables here are not of critical importance
as they only are used by a trace point. Fixing them is nice but
functionally changes nothing.

>  				scan++;
> +				pfn += isolated_pages-1;

This is more important. With the current code the next page encountered
after a THP page is isolated will be a tail page, not on the LRU
and will cause the loop to break as __isolate_lru_page will return
EINVAL. With this change, the next PFN encountered will really be
the next PFN of interest.

That said, the impact of this change is low. For THP allocations,
pfn += isolated_pages-1 will bring pfn past end_pfn so with or without
the page, we break the loop after isolating a THP. For lower-order
allocations, pfn+= isolated_pages-1 will also bring pfn past end_pfn.
This patch does help the case where the allocation is for a page larger
than a THP but that is very rare.

Hence, while I think the patch is correct, the changelog is misleading
as it does not have a large impact on breaking the loop if we've
isolated enough. To really break if we've isolated enough, you'd also
need 

scan += isolated_pages-1

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
