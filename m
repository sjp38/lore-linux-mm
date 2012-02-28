Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 74F286B004A
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 19:28:50 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id E9D093EE0B6
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:28:48 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CC05D45DE5B
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:28:48 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A476645DE54
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:28:48 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 95DBB1DB8043
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:28:48 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E1FC1DB803B
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:28:48 +0900 (JST)
Date: Tue, 28 Feb 2012 09:27:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3 06/21] mm: lruvec linking functions
Message-Id: <20120228092724.22e135e7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120223135204.12988.75350.stgit@zurg>
References: <20120223133728.12988.5432.stgit@zurg>
	<20120223135204.12988.75350.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>

On Thu, 23 Feb 2012 17:52:04 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> This patch adds links from page to its lruvec and from lruvec to its zone and node.
> If CONFIG_CGROUP_MEM_RES_CTLR=n they just page_zone() and container_of().
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

small comments in below.

> ---
>  include/linux/mm.h     |   37 +++++++++++++++++++++++++++++++++++++
>  include/linux/mmzone.h |   12 ++++++++----
>  mm/internal.h          |    1 +
>  mm/memcontrol.c        |   27 ++++++++++++++++++++++++---
>  mm/page_alloc.c        |   17 ++++++++++++++---
>  5 files changed, 84 insertions(+), 10 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index ee3ebc1..c6dc4ab 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -728,6 +728,43 @@ static inline void set_page_links(struct page *page, enum zone_type zone,
>  #endif
>  }
>  
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +
> +/* Multiple lruvecs in zone */
> +
> +extern struct lruvec *page_lruvec(struct page *page);
> +
> +static inline struct zone *lruvec_zone(struct lruvec *lruvec)
> +{
> +	return lruvec->zone;
> +}
> +
> +static inline struct pglist_data *lruvec_node(struct lruvec *lruvec)
> +{
> +	return lruvec->node;
> +}
> +
> +#else /* CONFIG_CGROUP_MEM_RES_CTLR */
> +
> +/* Single lruvec in zone */
> +
> +static inline struct lruvec *page_lruvec(struct page *page)
> +{
> +	return &page_zone(page)->lruvec;
> +}
> +
> +static inline struct zone *lruvec_zone(struct lruvec *lruvec)
> +{
> +	return container_of(lruvec, struct zone, lruvec);
> +}
> +
> +static inline struct pglist_data *lruvec_node(struct lruvec *lruvec)
> +{
> +	return lruvec_zone(lruvec)->zone_pgdat;
> +}
> +
> +#endif /* CONFIG_CGROUP_MEM_RES_CTLR */
> +
>  /*
>   * Some inline functions in vmstat.h depend on page_zone()
>   */
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index ddd0fd2..be8873a 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -159,10 +159,6 @@ static inline int is_unevictable_lru(enum lru_list lru)
>  	return (lru == LRU_UNEVICTABLE);
>  }
>  
> -struct lruvec {
> -	struct list_head pages_lru[NR_LRU_LISTS];
> -};
> -
>  /* Mask used at gathering information at once (see memcontrol.c) */
>  #define LRU_ALL_FILE (BIT(LRU_INACTIVE_FILE) | BIT(LRU_ACTIVE_FILE))
>  #define LRU_ALL_ANON (BIT(LRU_INACTIVE_ANON) | BIT(LRU_ACTIVE_ANON))
> @@ -300,6 +296,14 @@ struct zone_reclaim_stat {
>  	unsigned long		recent_scanned[2];
>  };
>  
> +struct lruvec {
> +	struct list_head	pages_lru[NR_LRU_LISTS];
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +	struct zone		*zone;
> +	struct pglist_data	*node;
> +#endif

I don't think this #ifdef is very good ....this adds other #ifdefs in other headers.
How bad if we remove this #ifdef and use ->zone, ->pgdat in lruvec_zone, lruvec_page
always ?

There may be concerns to fit lruvec at el into cache-line...but this set will add
a (big) hash here later..

I'm sorry if you're asked to add this #ifdef in v1 or v2.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
