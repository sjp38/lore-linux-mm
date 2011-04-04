Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D5C158D003B
	for <linux-mm@kvack.org>; Mon,  4 Apr 2011 08:05:15 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 886B13EE0C0
	for <linux-mm@kvack.org>; Mon,  4 Apr 2011 21:05:11 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C1E745DE52
	for <linux-mm@kvack.org>; Mon,  4 Apr 2011 21:05:11 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 495AE45DE4F
	for <linux-mm@kvack.org>; Mon,  4 Apr 2011 21:05:11 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3BDF41DB8040
	for <linux-mm@kvack.org>; Mon,  4 Apr 2011 21:05:11 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id F377A1DB8037
	for <linux-mm@kvack.org>; Mon,  4 Apr 2011 21:05:10 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/3] Unmapped page cache control (v5)
In-Reply-To: <20110404001936.GL6957@dastard>
References: <20110403183229.AE4C.A69D9226@jp.fujitsu.com> <20110404001936.GL6957@dastard>
Message-Id: <20110404210523.DA69.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  4 Apr 2011 21:05:09 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>

Hi Dave,

Thanks long explanation.

> > Secondly, You misparsed "avoid direct reclaim" paragraph. We don't talk
> > about "avoid direct reclaim even if system memory is no enough", We talk
> > about "avoid direct reclaim by preparing before". 
> 
> I don't think I misparsed it. I am addressing the "avoid direct
> reclaim by preparing before" principle directly. The problem with it
> is that just enalrging the free memory pool doesn't guarantee future
> allocation success when there are other concurrent allocations
> occurring. IOWs, if you don't _reserve_ the free memory for the
> critical area in advance then there is no guarantee it will be
> available when needed by the critical section.

Right.

Then, I made per-task reserve memory code at very years ago when I'm
working for embedded. So, There are some design choice here. best effort
as Christoph described or per thread or RT thread specific reservation.


> A simple example: the radix tree node preallocation code to
> guarantee inserts succeed while holding a spinlock. If just relying
> on free memory was sufficient, then GFP_ATOMIC allocations are all
> that is necessary. However, even that isn't sufficient as even the
> GFP_ATOMIC reserved pool can be exhausted by other concurrent
> GFP_ATOMIC allocations. Hence preallocation is required before
> entering the critical section to guarantee success in all cases.
> 
> And to state the obvious: doing allocation before the critical
> section will trigger reclaim if necessary so there is no need to
> have the application trigger reclaim.

Yes and No.
Preallocation is core piece, yes. But Almost all syscall call 
kmalloc() implicitly. then mlock() is no sufficient preallocation.
Almost all application except HPC can't avoid syscall use. That's 
the reason why finance people repeatedly requirest us the feature,
I think.

Thanks!


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
