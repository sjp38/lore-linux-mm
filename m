Date: Mon, 1 Dec 2008 12:24:38 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] vmscan: evict streaming IO first
Message-Id: <20081201122438.16828a87.akpm@linux-foundation.org>
In-Reply-To: <20081117190642.3aabd3ff@bree.surriel.com>
References: <20081115181748.3410.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20081115210039.537f59f5.akpm@linux-foundation.org>
	<alpine.LFD.2.00.0811161013270.3468@nehalem.linux-foundation.org>
	<49208E9A.5080801@redhat.com>
	<20081116204720.1b8cbe18.akpm@linux-foundation.org>
	<20081117153012.51ece88f.kamezawa.hiroyu@jp.fujitsu.com>
	<2f11576a0811162239w58555c6dq8a61ec184b22bd52@mail.gmail.com>
	<20081117155417.5cc63907.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LFD.2.00.0811170802010.3468@nehalem.linux-foundation.org>
	<20081117190642.3aabd3ff@bree.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: torvalds@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, gene.heskett@gmail.com
List-ID: <linux-mm.kvack.org>

On Mon, 17 Nov 2008 19:06:42 -0500
Rik van Riel <riel@redhat.com> wrote:

> Count the insertion of new pages in the statistics used to drive the
> pageout scanning code.  This should help the kernel quickly evict
> streaming file IO.
> 
> We count on the fact that new file pages start on the inactive file
> LRU and new anonymous pages start on the active anon list.  This
> means streaming file IO will increment the recent scanned file
> statistic, while leaving the recent rotated file statistic alone,
> driving pageout scanning to the file LRUs.
> 
> Pageout activity does its own list manipulation.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>
> ---
>  mm/swap.c |    7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> On Mon, 17 Nov 2008 08:22:13 -0800 (PST)
> Linus Torvalds <torvalds@linux-foundation.org> wrote:
> 
> > .. or how about just considering the act of adding a new page to the LRU 
> > to be a "scan" event? IOW, "scanning" is not necessarily just an act of 
> > the VM looking for pages to free, but would be a more general "activity" 
> > meter.
> 
> Linus, this should implement your idea.  
> 
> Gene, does this patch resolve the problem for you?

Has Gene had a chance to confirm this yet?

> Index: linux-2.6.28-rc5/mm/swap.c
> ===================================================================
> --- linux-2.6.28-rc5.orig/mm/swap.c	2008-11-16 17:47:13.000000000 -0500
> +++ linux-2.6.28-rc5/mm/swap.c	2008-11-17 18:58:32.000000000 -0500
> @@ -445,6 +445,7 @@ void ____pagevec_lru_add(struct pagevec 
>  	for (i = 0; i < pagevec_count(pvec); i++) {
>  		struct page *page = pvec->pages[i];
>  		struct zone *pagezone = page_zone(page);
> +		int file;
>  
>  		if (pagezone != zone) {
>  			if (zone)
> @@ -456,8 +457,12 @@ void ____pagevec_lru_add(struct pagevec 
>  		VM_BUG_ON(PageUnevictable(page));
>  		VM_BUG_ON(PageLRU(page));
>  		SetPageLRU(page);
> -		if (is_active_lru(lru))
> +		file = is_file_lru(lru);
> +		zone->recent_scanned[file]++;
> +		if (is_active_lru(lru)) {
>  			SetPageActive(page);
> +			zone->recent_rotated[file]++;
> +		}
>  		add_page_to_lru_list(zone, page, lru);
>  	}
>  	if (zone)

Were you not able to reproduce the problem?  It looks like it'd be a
pretty simple test case to set up?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
