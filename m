Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A744C6B0012
	for <linux-mm@kvack.org>; Sun, 12 Jun 2011 10:45:24 -0400 (EDT)
Date: Sun, 12 Jun 2011 16:45:21 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v3 03/10] Add additional isolation mode
Message-ID: <20110612144521.GB24323@tiehlicka.suse.cz>
References: <cover.1307455422.git.minchan.kim@gmail.com>
 <b72a86ed33c693aeccac0dba3fba8c13145106ab.1307455422.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b72a86ed33c693aeccac0dba3fba8c13145106ab.1307455422.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Tue 07-06-11 23:38:16, Minchan Kim wrote:
> There are some places to isolate lru page and I believe
> users of isolate_lru_page will be growing.
> The purpose of them is each different so part of isolated pages
> should put back to LRU, again.
> 
> The problem is when we put back the page into LRU,
> we lose LRU ordering and the page is inserted at head of LRU list.
> It makes unnecessary LRU churning so that vm can evict working set pages
> rather than idle pages.

I guess that, although this is true, it doesn't fit in with this patch
very much because this patch doesn't fix this problem. It is a
preparation for for further work. I would expect this description with
the core patch that actlually handles this issue.

> 
> This patch adds new modes when we isolate page in LRU so we don't isolate pages
> if we can't handle it. It could reduce LRU churning.
> 
> This patch doesn't change old behavior. It's just used by next patches.

It doesn't because there is not user of those flags but maybe it would
be better to have those to see why it actually can reduce LRU
isolations.

> 
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> ---
>  include/linux/swap.h |    2 ++
>  mm/vmscan.c          |    6 ++++++
>  2 files changed, 8 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 48d50e6..731f5dd 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -248,6 +248,8 @@ enum ISOLATE_MODE {
>  	ISOLATE_NONE,
>  	ISOLATE_INACTIVE = 1,	/* Isolate inactive pages */
>  	ISOLATE_ACTIVE = 2,	/* Isolate active pages */
> +	ISOLATE_CLEAN = 8,      /* Isolate clean file */
> +	ISOLATE_UNMAPPED = 16,  /* Isolate unmapped file */
>  };
>  
>  /* linux/mm/vmscan.c */
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 4cbe114..26aa627 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -990,6 +990,12 @@ int __isolate_lru_page(struct page *page, enum ISOLATE_MODE mode, int file)
>  
>  	ret = -EBUSY;
>  
> +	if (mode & ISOLATE_CLEAN && (PageDirty(page) || PageWriteback(page)))
> +		return ret;
> +
> +	if (mode & ISOLATE_UNMAPPED && page_mapped(page))
> +		return ret;
> +
>  	if (likely(get_page_unless_zero(page))) {
>  		/*
>  		 * Be careful not to clear PageLRU until after we're
> -- 
> 1.7.0.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

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
