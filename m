Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 042186B004A
	for <linux-mm@kvack.org>; Thu,  9 Sep 2010 22:57:04 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8A2v1NI008617
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 10 Sep 2010 11:57:01 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id E040145DE53
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 11:57:00 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id BF5D945DE51
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 11:57:00 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 93362E08003
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 11:57:00 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4FE6CE08001
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 11:57:00 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] mm: page allocator: Drain per-cpu lists after direct reclaim allocation fails
In-Reply-To: <20100909150558.GB340@csn.ul.ie>
References: <alpine.DEB.2.00.1009090931360.18975@router.home> <20100909150558.GB340@csn.ul.ie>
Message-Id: <20100910115503.C95E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 10 Sep 2010 11:56:59 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> On Thu, Sep 09, 2010 at 09:32:52AM -0500, Christoph Lameter wrote:
> > On Thu, 9 Sep 2010, Mel Gorman wrote:
> > 
> > > > This will have the effect of never sending IPIs for slab allocations since
> > > > they do not do allocations for orders > PAGE_ALLOC_COSTLY_ORDER.
> > > >
> > >
> > > The question is how severe is that? There is somewhat of an expectation
> > > that the lower orders free naturally so it the IPI justified? That said,
> > > our historical behaviour would have looked like
> > >
> > > if (!page && !drained && order) {
> > > 	drain_all_pages();
> > > 	draiained = true;
> > > 	goto retry;
> > > }
> > >
> > > Play it safe for now and go with that?
> > 
> > I am fine with no IPIs for order <= COSTLY. Just be aware that this is
> > a change that may have some side effects.
> 
> I made the choice consciously. I felt that if slab or slub were depending on
> IPIs to make successful allocations in low-memory conditions that it would
> experience varying stalls on bigger machines due to increased interrupts that
> might be difficult to diagnose while not necessarily improving allocation
> success rates. I also considered that if the machine is under pressure then
> slab and slub may also be releasing pages of the same order and effectively
> recycling their pages without depending on IPIs.

+1.

In these days, average numbers of CPUs are increasing. So we need to be afraid
IPI storm than past.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
