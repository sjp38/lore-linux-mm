Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E39586B00A5
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 21:16:47 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9J1Gj7N009984
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 19 Oct 2010 10:16:45 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2236045DE54
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 10:16:45 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5D97B45DE52
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 10:16:44 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 00D8D1DB804A
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 10:16:44 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A48BE38002
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 10:16:43 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: zone state overhead
In-Reply-To: <20101018103941.GX30667@csn.ul.ie>
References: <20101014120804.8B8F.A69D9226@jp.fujitsu.com> <20101018103941.GX30667@csn.ul.ie>
Message-Id: <20101019100658.A1B3.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 19 Oct 2010 10:16:42 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cl@linux.com" <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> > In this case, wakeup_kswapd() don't wake kswapd because
> > 
> > ---------------------------------------------------------------------------------
> > void wakeup_kswapd(struct zone *zone, int order)
> > {
> >         pg_data_t *pgdat;
> > 
> >         if (!populated_zone(zone))
> >                 return;
> > 
> >         pgdat = zone->zone_pgdat;
> >         if (zone_watermark_ok(zone, order, low_wmark_pages(zone), 0, 0))
> >                 return;                          // HERE
> > ---------------------------------------------------------------------------------
> > 
> > So, if we take your approach, we need to know exact free pages in this.
> 
> Good point!
> 
> > But, zone_page_state_snapshot() is slow. that's dilemma.
> > 
> 
> Very true. I'm prototyping a version of the patch that keeps
> zone_page_state_snapshot but only uses is in wakeup_kswapd and
> sleeping_prematurely.

Ok, this might works. but note, if we are running IO intensive workload, wakeup_kswapd()
is called very frequently. because it is called even though allocation is succeed. we need to
request Shaohua run and mesure his problem workload. and can you please cc me
when you post next version? I hope to review it too.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
