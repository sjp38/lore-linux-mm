Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 02B756B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 21:21:59 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB12LvW2032256
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 1 Dec 2010 11:21:57 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 43F4C45DE59
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 11:21:57 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 22F5545DE5B
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 11:21:57 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 09F6CE08001
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 11:21:57 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C392BE38005
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 11:21:56 +0900 (JST)
Date: Wed, 1 Dec 2010 11:16:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/4] Per cgroup background reclaim.
Message-Id: <20101201111615.12ca97cd.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101201111428.ABA5.A69D9226@jp.fujitsu.com>
References: <1291099785-5433-1-git-send-email-yinghan@google.com>
	<1291099785-5433-4-git-send-email-yinghan@google.com>
	<20101201111428.ABA5.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed,  1 Dec 2010 11:18:45 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index a15bc1c..dc61f2a 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -615,6 +615,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
> >  
> >  		do {
> >  			page = list_entry(list->prev, struct page, lru);
> > +			mem_cgroup_clear_unreclaimable(page, zone);
> >  			/* must delete as __free_one_page list manipulates */
> >  			list_del(&page->lru);
> >  			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
> > @@ -632,6 +633,7 @@ static void free_one_page(struct zone *zone, struct page *page, int order,
> >  	spin_lock(&zone->lock);
> >  	zone->all_unreclaimable = 0;
> >  	zone->pages_scanned = 0;
> > +	mem_cgroup_clear_unreclaimable(page, zone);
> >  
> >  	__free_one_page(page, zone, order, migratetype);
> >  	__mod_zone_page_state(zone, NR_FREE_PAGES, 1 << order);
> 
> Please don't do that. free page is one of fast path. We don't want to add
> additonal overhead here.
> 
> So I would like to explain why we clear zone->all_unreclaimable in free 
> page path at first. Look, zone free pages are maintained by NR_FREE_PAGES
> and free_one_page modify it.
> 
> But, free_one_page() is unrelated to memory cgroup uncharge thing. If nobody
> does memcg uncharge, reclaim retrying is pointless. no? I think we have
> better place than here.
> 
I agree. Should be done in uncharge or event counter.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
