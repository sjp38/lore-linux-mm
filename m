Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 2AC856005A4
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 20:08:28 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0518POE023269
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 5 Jan 2010 10:08:25 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5FA0445DE52
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 10:08:25 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3EB9145DE4E
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 10:08:25 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 24B801DB8042
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 10:08:25 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id C83D31DB8037
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 10:08:24 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] page allocator: fix update NR_FREE_PAGES only as necessary
In-Reply-To: <20100104095820.GA6373@csn.ul.ie>
References: <20100104144332.96A2.A69D9226@jp.fujitsu.com> <20100104095820.GA6373@csn.ul.ie>
Message-Id: <20100105100706.96C9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  5 Jan 2010 10:08:23 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, Huang Shijie <shijie8@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > index 4e4b5b3..87976ad 100644
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -1244,6 +1244,9 @@ again:
> > >         return page;
> > >  
> > >  failed:
> > > +       spin_lock(&zone->lock);
> > > +       __mod_zone_page_state(zone, NR_FREE_PAGES, 1 << order);
> > > +       spin_unlock(&zone->lock);
> > >         local_irq_restore(flags);
> > >         put_cpu();
> > >         return NULL;
> > 
> > Why can't we write following? __mod_zone_page_state() only require irq
> > disabling, it doesn't need spin lock. I think.
> > 
> 
> Adding Christoph to be sure but yes, as this is a per-cpu variable it
> should be safe to update with __mod_zone_page_state() as long as
> interrupts and preempt are disabled. If true, then this is a neater fix
> and is also needed for -stable 2.6.31 and 2.6.32.
> 
> Well spotted and thanks.

Yes, it should be sent to -stable tree. I hope this fix also solve recent mysterious
allocation failure problem ;-)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
