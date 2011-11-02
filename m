Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D175B6B0069
	for <linux-mm@kvack.org>; Wed,  2 Nov 2011 14:04:40 -0400 (EDT)
Message-ID: <4EB1862E.8070401@jp.fujitsu.com>
Date: Wed, 02 Nov 2011 11:04:30 -0700
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [rfc 2/3] mm: vmscan: treat inactive cycling as neutral
References: <20110808110658.31053.55013.stgit@localhost6> <CAOJsxLF909NRC2r6RL+hm1ARve+3mA6UM_CY9epJaauyqJTG8w@mail.gmail.com> <4E3FD403.6000400@parallels.com> <20111102163056.GG19965@redhat.com> <20111102163213.GI19965@redhat.com>
In-Reply-To: <20111102163213.GI19965@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jweiner@redhat.com
Cc: khlebnikov@parallels.com, penberg@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, fengguang.wu@intel.com, kamezawa.hiroyu@jp.fujitsu.com, hannes@cmpxchg.org, riel@redhat.com, mel@csn.ul.ie, minchan.kim@gmail.com, gene.heskett@gmail.com

(11/2/2011 9:32 AM), Johannes Weiner wrote:
> Each page that is scanned but put back to the inactive list is counted
> as a successful reclaim, which tips the balance between file and anon
> lists more towards the cycling list.
> 
> This does - in my opinion - not make too much sense, but at the same
> time it was not much of a problem, as the conditions that lead to an
> inactive list cycle were mostly temporary - locked page, concurrent
> page table changes, backing device congested - or at least limited to
> a single reclaimer that was not allowed to unmap or meddle with IO.
> More important than being moderately rare, those conditions should
> apply to both anon and mapped file pages equally and balance out in
> the end.
> 
> Recently, we started cycling file pages in particular on the inactive
> list much more aggressively, for used-once detection of mapped pages,
> and when avoiding writeback from direct reclaim.
> 
> Those rotated pages do not exactly speak for the reclaimability of the
> list they sit on and we risk putting immense pressure on file list for
> no good reason.
> 
> Instead, count each page not reclaimed and put back to any list,
> active or inactive, as rotated, so they are neutral with respect to
> the scan/rotate ratio of the list class, as they should be.
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>
> ---
>  mm/vmscan.c |    9 ++++-----
>  1 files changed, 4 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 39d3da3..6da66a7 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1360,7 +1360,9 @@ putback_lru_pages(struct zone *zone, struct scan_control *sc,
>  	 */
>  	spin_lock(&zone->lru_lock);
>  	while (!list_empty(page_list)) {
> +		int file;
>  		int lru;
> +
>  		page = lru_to_page(page_list);
>  		VM_BUG_ON(PageLRU(page));
>  		list_del(&page->lru);
> @@ -1373,11 +1375,8 @@ putback_lru_pages(struct zone *zone, struct scan_control *sc,
>  		SetPageLRU(page);
>  		lru = page_lru(page);
>  		add_page_to_lru_list(zone, page, lru);
> -		if (is_active_lru(lru)) {
> -			int file = is_file_lru(lru);
> -			int numpages = hpage_nr_pages(page);
> -			reclaim_stat->recent_rotated[file] += numpages;
> -		}
> +		file = is_file_lru(lru);
> +		reclaim_stat->recent_rotated[file] += hpage_nr_pages(page);
>  		if (!pagevec_add(&pvec, page)) {
>  			spin_unlock_irq(&zone->lru_lock);
>  			__pagevec_release(&pvec);

When avoiding writeback from direct reclaim case, I think we shouldn't increase
recent_rotated because VM decided "the page should be eviceted, but also it
should be delayed". i'm not sure it's minor factor or not.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
