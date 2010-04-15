Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E18F26B01F5
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 02:35:18 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3F6ZG2q032188
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 15 Apr 2010 15:35:16 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0659A45DE4F
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 15:35:16 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D7BFA45DE55
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 15:35:15 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BB3B81DB8041
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 15:35:15 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B866E08003
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 15:35:15 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
In-Reply-To: <20100415062055.GQ2493@dastard>
References: <20100415130212.D16E.A69D9226@jp.fujitsu.com> <20100415062055.GQ2493@dastard>
Message-Id: <20100415152816.D18C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 15 Apr 2010 15:35:14 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> On Thu, Apr 15, 2010 at 01:09:01PM +0900, KOSAKI Motohiro wrote:
> > Hi
> > 
> > > How about this? For now, we stop direct reclaim from doing writeback
> > > only on order zero allocations, but allow it for higher order
> > > allocations. That will prevent the majority of situations where
> > > direct reclaim blows the stack and interferes with background
> > > writeout, but won't cause lumpy reclaim to change behaviour.
> > > This reduces the scope of impact and hence testing and validation
> > > the needs to be done.
> > 
> > Tend to agree. but I would proposed slightly different algorithm for
> > avoind incorrect oom.
> > 
> > for high order allocation
> > 	allow to use lumpy reclaim and pageout() for both kswapd and direct reclaim
> 
> SO same as current.

Yes. as same as you propsed.

> 
> > for low order allocation
> > 	- kswapd:          always delegate io to flusher thread
> > 	- direct reclaim:  delegate io to flusher thread only if vm pressure is low
> 
> IMO, this really doesn't fix either of the problems - the bad IO
> patterns nor the stack usage. All it will take is a bit more memory
> pressure to trigger stack and IO problems, and the user reporting the
> problems is generating an awful lot of memory pressure...

This patch doesn't care stack usage. because
  - again, I think all stack eater shold be diet.
  - under allowing lumpy reclaim world, only deny low order reclaim
    doesn't solve anything.

Please don't forget priority=0 recliam failure incvoke OOM-killer.
I don't imagine anyone want it.

And, Which IO workload trigger <6 priority vmscan?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
