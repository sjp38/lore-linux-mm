Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 01A946B003D
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 20:38:48 -0500 (EST)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1C1ck6h012924
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 12 Feb 2009 10:38:46 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id DCE0345DE4E
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 10:38:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id AE6D245DE51
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 10:38:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 998A31DB803A
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 10:38:45 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 416431DB803E
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 10:38:45 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] mm: update_page_reclaim_stat() is called form page fault path
In-Reply-To: <20090211151801.d9e8c84b.akpm@linux-foundation.org>
References: <20090211213340.C3CD.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20090211151801.d9e8c84b.akpm@linux-foundation.org>
Message-Id: <20090212103801.C8E1.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 12 Feb 2009 10:38:44 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, npiggin@suse.de, hugh@veritas.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

> > +void update_page_reclaim_stat(struct page *page)
> > +{
> > +	struct zone *zone = page_zone(page);
> > +
> > +	spin_lock_irq(&zone->lru_lock);
> > +	/* if the page isn't reclaimable, it doesn't update reclaim stat */
> > +	if (PageLRU(page) && !PageUnevictable(page)) {
> > +		update_page_reclaim_stat_locked(zone, page,
> > +					 !!page_is_file_cache(page), 1);
> > +	}
> > +	spin_unlock_irq(&zone->lru_lock);
> > +}
> 
> And we just added a spin_lock_irq() and a bunch of other stuff to it.
> 
> Can we improve this?
> 
> Can we just omit it, even?
> 
> Can we update those stats locklessly and accomodate the resulting
> inaccuracy over at the codesites where these statistics are actually
> used?

fair enough.
thanks good suggestion.

I'm working it on.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
