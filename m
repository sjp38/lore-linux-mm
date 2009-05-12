Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 74C0C6B005A
	for <linux-mm@kvack.org>; Mon, 11 May 2009 22:57:38 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4C2wUJq016446
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 12 May 2009 11:58:30 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 368EC45DE55
	for <linux-mm@kvack.org>; Tue, 12 May 2009 11:58:30 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 08C0345DE51
	for <linux-mm@kvack.org>; Tue, 12 May 2009 11:58:30 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DF394E18001
	for <linux-mm@kvack.org>; Tue, 12 May 2009 11:58:29 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 90DD91DB8038
	for <linux-mm@kvack.org>; Tue, 12 May 2009 11:58:29 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH -mm] vmscan: merge duplicate code in shrink_active_list()
In-Reply-To: <20090512025319.GD7518@localhost>
References: <20090508125859.210a2a25.akpm@linux-foundation.org> <20090512025319.GD7518@localhost>
Message-Id: <20090512115811.D613.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 12 May 2009 11:58:28 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "peterz@infradead.org" <peterz@infradead.org>, "riel@redhat.com" <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "cl@linux-foundation.org" <cl@linux-foundation.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

> +void move_active_pages_to_lru(enum lru_list lru, struct list_head *list)

it can be static?

> +{
> +	unsigned long pgmoved = 0;
> +
> +	while (!list_empty(&list)) {
> +		page = lru_to_page(&list);
> +		prefetchw_prev_lru_page(page, &list, flags);
> +
> +		VM_BUG_ON(PageLRU(page));
> +		SetPageLRU(page);
> +
> +		VM_BUG_ON(!PageActive(page));
> +		if (lru < LRU_ACTIVE)
> +			ClearPageActive(page);
> +
> +		list_move(&page->lru, &zone->lru[lru].list);
> +		mem_cgroup_add_lru_list(page, lru);
> +		pgmoved++;
> +		if (!pagevec_add(&pvec, page)) {
> +			spin_unlock_irq(&zone->lru_lock);
> +			if (buffer_heads_over_limit)
> +				pagevec_strip(&pvec);
> +			__pagevec_release(&pvec);
> +			spin_lock_irq(&zone->lru_lock);
> +		}
> +	}
> +	__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
> +	if (lru < LRU_ACTIVE)
> +		__count_vm_events(PGDEACTIVATE, pgmoved);
> +}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
