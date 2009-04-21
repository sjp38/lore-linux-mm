Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E83646B0047
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 05:40:43 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3L9fKTa011984
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 21 Apr 2009 18:41:20 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C5A245DD7B
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 18:41:20 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id ECCEA45DD7D
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 18:41:19 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C4EDAE08006
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 18:41:19 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 342CEE08001
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 18:41:19 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 3/3][rfc] vmscan: batched swap slot allocation
In-Reply-To: <20090421093830.GA3639@cmpxchg.org>
References: <20090421182427.F14D.A69D9226@jp.fujitsu.com> <20090421093830.GA3639@cmpxchg.org>
Message-Id: <20090421184106.F150.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 21 Apr 2009 18:41:18 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

> On Tue, Apr 21, 2009 at 06:27:08PM +0900, KOSAKI Motohiro wrote:
> > > > > -		cond_resched();
> > > > > +		if (list_empty(&swap_pages))
> > > > > +			cond_resched();
> > > > >  
> > > > Why this ?
> > > 
> > > It shouldn't schedule anymore when it's allocated the first swap slot.
> > > Another reclaimer could e.g. sleep on the cond_resched() before the
> > > loop and when we schedule while having swap slots allocated, we might
> > > continue further allocations multiple slots ahead.
> > 
> > Oops, It seems regression. this cond_resched() intent to
> > 
> > cond_resched();
> > pageout();
> > cond_resched();
> > pageout();
> > cond_resched();
> > pageout();
> 
> It still does that.  While it collects swap pages (swap_pages list is
> non-empty), it doesn't page out.  And if it restarts for unmap and
> page-out, the swap_pages list is empty and cond_resched() is called.

Ah, ok.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
