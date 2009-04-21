Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 530476B0047
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 05:39:17 -0400 (EDT)
Date: Tue, 21 Apr 2009 11:38:30 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 3/3][rfc] vmscan: batched swap slot allocation
Message-ID: <20090421093830.GA3639@cmpxchg.org>
References: <20090421095857.b989ce44.kamezawa.hiroyu@jp.fujitsu.com> <20090421085231.GB2527@cmpxchg.org> <20090421182427.F14D.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090421182427.F14D.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 21, 2009 at 06:27:08PM +0900, KOSAKI Motohiro wrote:
> > > > -		cond_resched();
> > > > +		if (list_empty(&swap_pages))
> > > > +			cond_resched();
> > > >  
> > > Why this ?
> > 
> > It shouldn't schedule anymore when it's allocated the first swap slot.
> > Another reclaimer could e.g. sleep on the cond_resched() before the
> > loop and when we schedule while having swap slots allocated, we might
> > continue further allocations multiple slots ahead.
> 
> Oops, It seems regression. this cond_resched() intent to
> 
> cond_resched();
> pageout();
> cond_resched();
> pageout();
> cond_resched();
> pageout();

It still does that.  While it collects swap pages (swap_pages list is
non-empty), it doesn't page out.  And if it restarts for unmap and
page-out, the swap_pages list is empty and cond_resched() is called.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
