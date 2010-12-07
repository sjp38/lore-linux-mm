Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id AD8856B0088
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 03:06:47 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB786iPr028463
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 7 Dec 2010 17:06:45 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id CAFD145DEBC
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 17:06:44 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B0DF645DEB8
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 17:06:44 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C0F7E08002
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 17:06:44 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 61759E08004
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 17:06:44 +0900 (JST)
Date: Tue, 7 Dec 2010 17:00:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] Add kswapd descriptor.
Message-Id: <20101207170049.20d5d32a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101207065929.GJ3158@balbir.in.ibm.com>
References: <1291099785-5433-1-git-send-email-yinghan@google.com>
	<1291099785-5433-2-git-send-email-yinghan@google.com>
	<20101130160838.4c66febf.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTikXzSx3Sjqb1NYZB-EJ76N-UbmiwTo=eOtSOnaP@mail.gmail.com>
	<20101130172710.38de418b.kamezawa.hiroyu@jp.fujitsu.com>
	<20101130175443.f01f4d09.kamezawa.hiroyu@jp.fujitsu.com>
	<20101207061503.GH3158@balbir.in.ibm.com>
	<20101207152423.1ba94270.kamezawa.hiroyu@jp.fujitsu.com>
	<20101207065929.GJ3158@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Minchan Kim <minchan.kim@gmail.com>, Ying Han <yinghan@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 7 Dec 2010 12:29:29 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-12-07 15:24:23]:
> > An argument to balance_pgdat_for_memcg() or a start point of zonelist[].
> > i.e.
> > 	zone_list = NODE_DATA(victim)->zonelist[0 or 1]
> > 
> > 	for_each_zone_zonelist(z, zone_list)....
> > 
> > But, this is just an example, we just need to determine where we reclaim
> > page from before start walking.
> >
> 
> OK, I understand. BTW, I am not against integration with kswapd for
> watermark based reclaim, the advantage I see is that as we balance
> zone/node watermarks, we also balance per memcg watermark. The cost
> would be proportional to the size of memcg's that have allocated from
> that zone/node. kswapd is not fast path and already optimized in terms
> of when to wake up, so it makes sense to reuse all of that. 
> 

But we cannot use balance_pgdat() as it is because we don't need almost
all checks in it and I don't want to add hooks into it because it's
updated frequently. And, I doubt how cleanly we can do merging.

As Ying Han did, adding balance_pgdat_for_memcg() is a clean way for now.
kswapd wakeup, sleep routine may be able to be reused.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
