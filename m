Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E0BEC6B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 21:18:51 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB12IlFn000386
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 1 Dec 2010 11:18:48 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A7F8C45DE55
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 11:18:47 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E9FA45DE61
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 11:18:47 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6EEF61DB8041
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 11:18:47 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A8761DB803C
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 11:18:47 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/4] Per cgroup background reclaim.
In-Reply-To: <1291099785-5433-4-git-send-email-yinghan@google.com>
References: <1291099785-5433-1-git-send-email-yinghan@google.com> <1291099785-5433-4-git-send-email-yinghan@google.com>
Message-Id: <20101201111428.ABA5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  1 Dec 2010 11:18:45 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index a15bc1c..dc61f2a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -615,6 +615,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
>  
>  		do {
>  			page = list_entry(list->prev, struct page, lru);
> +			mem_cgroup_clear_unreclaimable(page, zone);
>  			/* must delete as __free_one_page list manipulates */
>  			list_del(&page->lru);
>  			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
> @@ -632,6 +633,7 @@ static void free_one_page(struct zone *zone, struct page *page, int order,
>  	spin_lock(&zone->lock);
>  	zone->all_unreclaimable = 0;
>  	zone->pages_scanned = 0;
> +	mem_cgroup_clear_unreclaimable(page, zone);
>  
>  	__free_one_page(page, zone, order, migratetype);
>  	__mod_zone_page_state(zone, NR_FREE_PAGES, 1 << order);

Please don't do that. free page is one of fast path. We don't want to add
additonal overhead here.

So I would like to explain why we clear zone->all_unreclaimable in free 
page path at first. Look, zone free pages are maintained by NR_FREE_PAGES
and free_one_page modify it.

But, free_one_page() is unrelated to memory cgroup uncharge thing. If nobody
does memcg uncharge, reclaim retrying is pointless. no? I think we have
better place than here.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
