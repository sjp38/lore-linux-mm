Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 563106B007B
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 21:56:18 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0C2uF4Y020328
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 12 Jan 2010 11:56:16 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B31DD45DE4F
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 11:56:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 95A5545DE4D
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 11:56:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F5211DB803A
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 11:56:15 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 35B6F1DB8040
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 11:56:12 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] mm/page_alloc : relieve zone->lock's pressure for memory free
In-Reply-To: <20100112022708.GA21621@localhost>
References: <20100112094708.d09b01ea.kamezawa.hiroyu@jp.fujitsu.com> <20100112022708.GA21621@localhost>
Message-Id: <20100112115550.B398.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 12 Jan 2010 11:56:11 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Huang Shijie <shijie8@gmail.com>, akpm@linux-foundation.org, mel@csn.ul.ie, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> On Tue, Jan 12, 2010 at 09:47:08AM +0900, KAMEZAWA Hiroyuki wrote:
> > > Thanks, Huang. 
> > > 
> > > Frankly speaking, I am not sure this ir right way.
> > > This patch is adding to fine-grained locking overhead
> > > 
> > > As you know, this functions are one of hot pathes.
> > > In addition, we didn't see the any problem, until now.
> > > It means out of synchronization in ZONE_ALL_UNRECLAIMABLE 
> > > and pages_scanned are all right?
> > > 
> > > If it is, we can move them out of zone->lock, too.
> > > If it isn't, we need one more lock, then. 
> > > 
> > I don't want to see additional spin_lock, here. 
> > 
> > About ZONE_ALL_UNRECLAIMABLE, it's not necessary to be handled in atomic way.
> > If you have concerns with other flags, please modify this with single word,
> > instead of a bit field.
> 
> I'd second it. It's not a big problem to reset ZONE_ALL_UNRECLAIMABLE
> and pages_scanned outside of zone->lru_lock.
> 
> Clear of ZONE_ALL_UNRECLAIMABLE is already atomic; if we lose one
> pages_scanned=0 due to races, there are plenty of page free events
> ahead to reset it, before pages_scanned hit the huge
> zone_reclaimable_pages() * 6.

Yes, this patch should be rejected.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
