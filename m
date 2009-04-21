Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C03916B0047
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 05:26:48 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3L9RBVH004523
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 21 Apr 2009 18:27:12 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 89DD445DD75
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 18:27:11 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6923F45DD74
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 18:27:11 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 54D67E08004
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 18:27:11 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 10DED1DB8012
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 18:27:11 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 3/3][rfc] vmscan: batched swap slot allocation
In-Reply-To: <20090421085231.GB2527@cmpxchg.org>
References: <20090421095857.b989ce44.kamezawa.hiroyu@jp.fujitsu.com> <20090421085231.GB2527@cmpxchg.org>
Message-Id: <20090421182427.F14D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 21 Apr 2009 18:27:08 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

> > > -		cond_resched();
> > > +		if (list_empty(&swap_pages))
> > > +			cond_resched();
> > >  
> > Why this ?
> 
> It shouldn't schedule anymore when it's allocated the first swap slot.
> Another reclaimer could e.g. sleep on the cond_resched() before the
> loop and when we schedule while having swap slots allocated, we might
> continue further allocations multiple slots ahead.

Oops, It seems regression. this cond_resched() intent to

cond_resched();
pageout();
cond_resched();
pageout();
cond_resched();
pageout();



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
