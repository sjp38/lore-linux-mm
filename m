Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6F0639000BD
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 09:43:29 -0400 (EDT)
Date: Wed, 21 Sep 2011 15:43:23 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 09/11] mm: collect LRU list heads into struct lruvec
Message-ID: <20110921134323.GE8501@tiehlicka.suse.cz>
References: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
 <1315825048-3437-10-git-send-email-jweiner@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1315825048-3437-10-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 12-09-11 12:57:26, Johannes Weiner wrote:
> Having a unified structure with a LRU list set for both global zones
> and per-memcg zones allows to keep that code simple which deals with
> LRU lists and does not care about the container itself.
> 
> Once the per-memcg LRU lists directly link struct pages, the isolation
> function and all other list manipulations are shared between the memcg
> case and the global LRU case.
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>

Thanks for splitting this off the other patch. Much easier to review now.

Reviewed-by: Michal Hocko <mhocko@suse.cz>

Small nit bellow
> ---
>  include/linux/mm_inline.h |    2 +-
>  include/linux/mmzone.h    |   10 ++++++----
>  mm/memcontrol.c           |   19 ++++++++-----------
>  mm/page_alloc.c           |    2 +-
>  mm/swap.c                 |   11 +++++------
>  mm/vmscan.c               |   12 ++++++------
>  6 files changed, 27 insertions(+), 29 deletions(-)
> 
[...]
> diff --git a/mm/swap.c b/mm/swap.c
> index 3a442f1..66e8292 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
[...]
> @@ -639,7 +639,6 @@ void lru_add_page_tail(struct zone* zone,
>  	int active;
>  	enum lru_list lru;
>  	const int file = 0;
> -	struct list_head *head;
>  
>  	VM_BUG_ON(!PageHead(page));
>  	VM_BUG_ON(PageCompound(page_tail));
> @@ -659,10 +658,10 @@ void lru_add_page_tail(struct zone* zone,
>  		}
>  		update_page_reclaim_stat(zone, page_tail, file, active);
>  		if (likely(PageLRU(page)))
> -			head = page->lru.prev;
> +			__add_page_to_lru_list(zone, page_tail, lru,
> +					       page->lru.prev);

{ } around multiline __add_page_to_lru_list?

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
