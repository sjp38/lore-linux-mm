Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 98A466B01E3
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 00:32:55 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3F4Wq0s007337
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 15 Apr 2010 13:32:53 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6AD2145DE53
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 13:32:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 39D8F45DE4D
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 13:32:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0BE001DB8044
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 13:32:52 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 85C871DB8042
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 13:32:51 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: 32GB SSD on USB1.1 P3/700 == ___HELL___ (2.6.34-rc3)
In-Reply-To: <20100415041931.GA14215@localhost>
References: <20100415122928.D168.A69D9226@jp.fujitsu.com> <20100415041931.GA14215@localhost>
Message-Id: <20100415132312.D180.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 15 Apr 2010 13:32:50 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andreas Mohr <andi@lisas.de>, Jens Axboe <axboe@kernel.dk>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> On Thu, Apr 15, 2010 at 11:31:52AM +0800, KOSAKI Motohiro wrote:
> > > > Many applications (this one and below) are stuck in
> > > > wait_on_page_writeback(). I guess this is why "heavy write to
> > > > irrelevant partition stalls the whole system".  They are stuck on page
> > > > allocation. Your 512MB system memory is a bit tight, so reclaim
> > > > pressure is a bit high, which triggers the wait-on-writeback logic.
> > > 
> > > I wonder if this hacking patch may help.
> > > 
> > > When creating 300MB dirty file with dd, it is creating continuous
> > > region of hard-to-reclaim pages in the LRU list. priority can easily
> > > go low when irrelevant applications' direct reclaim run into these
> > > regions..
> > 
> > Sorry I'm confused not. can you please tell us more detail explanation?
> > Why did lumpy reclaim cause OOM? lumpy reclaim might cause
> > direct reclaim slow down. but IIUC it's not cause OOM because OOM is
> > only occur when priority-0 reclaim failure.
> 
> No I'm not talking OOM. Nor lumpy reclaim.
> 
> I mean the direct reclaim can get stuck for long time, when we do
> wait_on_page_writeback() on lumpy_reclaim=1.
> 
> > IO get stcking also prevent priority reach to 0.
> 
> Sure. But we can wait for IO a bit later -- after scanning 1/64 LRU
> (the below patch) instead of the current 1/1024.
> 
> In Andreas' case, 512MB/1024 = 512KB, this is way too low comparing to
> the 22MB writeback pages. There can easily be a continuous range of
> 512KB dirty/writeback pages in the LRU, which will trigger the wait
> logic.

In my feeling from your explanation, we need auto adjustment mechanism
instead change default value for special machine. no?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
