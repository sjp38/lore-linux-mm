Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 909746B00A5
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 21:34:17 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9J1YExZ018362
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 19 Oct 2010 10:34:15 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C3F7C45DE51
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 10:34:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 962FA45DE4E
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 10:34:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 806C91DB803C
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 10:34:14 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3ACD41DB803B
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 10:34:14 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [experimental][PATCH] mm,vmstat: per cpu stat flush too when per cpu page cache flushed
In-Reply-To: <20101018110829.GZ30667@csn.ul.ie>
References: <20101014114541.8B89.A69D9226@jp.fujitsu.com> <20101018110829.GZ30667@csn.ul.ie>
Message-Id: <20101019102428.A1BF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 19 Oct 2010 10:34:13 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cl@linux.com" <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> > Initial variable ZVC commit (df9ecaba3f1) says 
> > 
> > >     [PATCH] ZVC: Scale thresholds depending on the size of the system
> > > 
> > >     The ZVC counter update threshold is currently set to a fixed value of 32.
> > >     This patch sets up the threshold depending on the number of processors and
> > >     the sizes of the zones in the system.
> > > 
> > >     With the current threshold of 32, I was able to observe slight contention
> > >     when more than 130-140 processors concurrently updated the counters.  The
> > >     contention vanished when I either increased the threshold to 64 or used
> > >     Andrew's idea of overstepping the interval (see ZVC overstep patch).
> > > 
> > >     However, we saw contention again at 220-230 processors.  So we need higher
> > >     values for larger systems.
> > 
> > So, I'm worry about your patch reintroduce old cache contention issue that Christoph
> > observed when run 128-256cpus system.  May I ask how do you think this issue?
> 
> It only reintroduces the overhead while kswapd is awake and the system is in danger
> of accidentally allocating all of its pages. Yes, it's slower but it's
> less risky.

When we have rich storage and running IO intensive workload, kswapd are almost 
always awake ;)
However, yes, your approach is less risky.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
