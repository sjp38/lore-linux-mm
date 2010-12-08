Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 68CF26B0087
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 02:21:44 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB87LbnJ006580
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 8 Dec 2010 16:21:37 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D44D445DE84
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 16:21:06 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B88E945DE9B
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 16:21:06 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A2537E38004
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 16:21:06 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A206E08003
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 16:21:06 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] Add kswapd descriptor.
In-Reply-To: <AANLkTimzL_CwLruzPspgmOk4OJU8M7dXycUyHmhW2s9O@mail.gmail.com>
References: <20101207123308.GD5422@csn.ul.ie> <AANLkTimzL_CwLruzPspgmOk4OJU8M7dXycUyHmhW2s9O@mail.gmail.com>
Message-Id: <20101208161622.1745.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  8 Dec 2010 16:21:05 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Tue, Dec 7, 2010 at 4:33 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> > On Mon, Nov 29, 2010 at 10:49:42PM -0800, Ying Han wrote:
> >> There is a kswapd kernel thread for each memory node. We add a different kswapd
> >> for each cgroup.
> >
> > What is considered a normal number of cgroups in production? 10, 50, 10000?
> Normally it is less than 100. I assume there is a cap of number of
> cgroups can be created
> per system.
> 
> If it's a really large number and all the cgroups kswapds wake at the same time,
> > the zone LRU lock will be very heavily contended.
> 
> Thanks for reviewing the patch~
> 
> Agree. The zone->lru_lock is another thing we are looking at.
> Eventually, we need to break the lock to
> per-zone per-memcg lru.

This may make following bad scenario. That's the reason why now we are using zone->lru_lock.

1) start memcg reclaim
2) found the lru tail page has pte access bit
3) memcg reclaim decided that the page move to active list of memcg-lru.
    Also, pte access bit was cleaned. But, the page still remain inactive list of global-lru.
4) Sadly, global reclaim discard the page quickly because it has been lost accessed bit by memcg.


But, if we have to modify both memcg and global LRU, we can't avoid zone->lru_lock anyway.
Then, we don't use memcg special lock.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
