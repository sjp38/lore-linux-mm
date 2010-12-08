Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E78826B0087
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 20:33:58 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB81Xu4n004146
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 8 Dec 2010 10:33:56 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7FC1045DE80
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 10:33:56 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6789F45DE7C
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 10:33:56 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 57E211DB8038
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 10:33:56 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 163981DB803B
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 10:33:56 +0900 (JST)
Date: Wed, 8 Dec 2010 10:28:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] Add kswapd descriptor.
Message-Id: <20101208102812.5b93c1bc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTin+p5WnLjMkr8Qntkt4fR1+fdY=t6hkvV6G8Mok@mail.gmail.com>
References: <1291099785-5433-1-git-send-email-yinghan@google.com>
	<1291099785-5433-2-git-send-email-yinghan@google.com>
	<20101207123308.GD5422@csn.ul.ie>
	<AANLkTimzL_CwLruzPspgmOk4OJU8M7dXycUyHmhW2s9O@mail.gmail.com>
	<20101208093948.1b3b64c5.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTin+p5WnLjMkr8Qntkt4fR1+fdY=t6hkvV6G8Mok@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 7 Dec 2010 17:24:12 -0800
Ying Han <yinghan@google.com> wrote:

> On Tue, Dec 7, 2010 at 4:39 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Tue, 7 Dec 2010 09:28:01 -0800
> > Ying Han <yinghan@google.com> wrote:
> >
> >> On Tue, Dec 7, 2010 at 4:33 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> >
> >> Potentially there will
> >> > also be a very large number of new IO sources. I confess I haven't read the
> >> > thread yet so maybe this has already been thought of but it might make sense
> >> > to have a 1:N relationship between kswapd and memcgroups and cycle between
> >> > containers. The difficulty will be a latency between when kswapd wakes up
> >> > and when a particular container is scanned. The closer the ratio is to 1:1,
> >> > the less the latency will be but the higher the contenion on the LRU lock
> >> > and IO will be.
> >>
> >> No, we weren't talked about the mapping anywhere in the thread. Having
> >> many kswapd threads
> >> at the same time isn't a problem as long as no locking contention (
> >> ext, 1k kswapd threads on
> >> 1k fake numa node system). So breaking the zone->lru_lock should work.
> >>
> >
> > That's me who make zone->lru_lock be shared. And per-memcg lock will makes
> > the maintainance of memcg very bad. That will add many races.
> > Or we need to make memcg's LRU not synchronized with zone's LRU, IOW, we need
> > to have completely independent LRU.
> >
> > I'd like to limit the number of kswapd-for-memcg if zone->lru lock contention
> > is problematic. memcg _can_ work without background reclaim.
> 
> >
> > How about adding per-node kswapd-for-memcg it will reclaim pages by a memcg's
> > request ? as
> >
> > A  A  A  A memcg_wake_kswapd(struct mem_cgroup *mem)
> > A  A  A  A {
> > A  A  A  A  A  A  A  A do {
> > A  A  A  A  A  A  A  A  A  A  A  A nid = select_victim_node(mem);
> > A  A  A  A  A  A  A  A  A  A  A  A /* ask kswapd to reclaim memcg's memory */
> > A  A  A  A  A  A  A  A  A  A  A  A ret = memcg_kswapd_queue_work(nid, mem); /* may return -EBUSY if very busy*/
> > A  A  A  A  A  A  A  A } while()
> > A  A  A  A }
> >
> > This will make lock contention minimum. Anyway, using too much cpu for this
> > unnecessary_but_good_for_performance_function is bad. Throttoling is required.
> 
> I don't see the problem of one-kswapd-per-cgroup here since there will
> be no performance cost if they are not running.
> 
Yes. But we've got a report from user who uses 2000+ cgroups on his host, one year ago.
(in libcgroup mailing list.)

So, running 2000+ deadly thread will be bad. It's cost.
In theory, the number of memcg can be 65534.

> I haven't measured the lock contention and cputime for each kswapd
> running. Theoretically it would be a problem
> if thousands of cgroups are configured on the the host and all of them
> are under memory pressure.
> 
I think that's a configuration mistake. 

> We can either optimize the locking or make each kswapd smarter (hold
> the lock less time). My current plan is to have the
> one-kswapd-per-cgroup on the V2 patch w/ select_victim_node, and the
> optimization for this comes as following patchset.
> 

My point above is holding remove node's lock, touching remote node's page
increases memory reclaim cost very much. Then, I like per-node approach.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
