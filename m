Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4E8BE6B0087
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 19:46:01 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB80jvUR005036
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 8 Dec 2010 09:45:57 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8A13E45DE5E
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 09:45:57 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6FD5245DE69
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 09:45:57 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 604271DB8037
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 09:45:57 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 23803E18002
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 09:45:57 +0900 (JST)
Date: Wed, 8 Dec 2010 09:39:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] Add kswapd descriptor.
Message-Id: <20101208093948.1b3b64c5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTimzL_CwLruzPspgmOk4OJU8M7dXycUyHmhW2s9O@mail.gmail.com>
References: <1291099785-5433-1-git-send-email-yinghan@google.com>
	<1291099785-5433-2-git-send-email-yinghan@google.com>
	<20101207123308.GD5422@csn.ul.ie>
	<AANLkTimzL_CwLruzPspgmOk4OJU8M7dXycUyHmhW2s9O@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 7 Dec 2010 09:28:01 -0800
Ying Han <yinghan@google.com> wrote:

> On Tue, Dec 7, 2010 at 4:33 AM, Mel Gorman <mel@csn.ul.ie> wrote:

> Potentially there will
> > also be a very large number of new IO sources. I confess I haven't read the
> > thread yet so maybe this has already been thought of but it might make sense
> > to have a 1:N relationship between kswapd and memcgroups and cycle between
> > containers. The difficulty will be a latency between when kswapd wakes up
> > and when a particular container is scanned. The closer the ratio is to 1:1,
> > the less the latency will be but the higher the contenion on the LRU lock
> > and IO will be.
> 
> No, we weren't talked about the mapping anywhere in the thread. Having
> many kswapd threads
> at the same time isn't a problem as long as no locking contention (
> ext, 1k kswapd threads on
> 1k fake numa node system). So breaking the zone->lru_lock should work.
> 

That's me who make zone->lru_lock be shared. And per-memcg lock will makes
the maintainance of memcg very bad. That will add many races.
Or we need to make memcg's LRU not synchronized with zone's LRU, IOW, we need
to have completely independent LRU.

I'd like to limit the number of kswapd-for-memcg if zone->lru lock contention
is problematic. memcg _can_ work without background reclaim.

How about adding per-node kswapd-for-memcg it will reclaim pages by a memcg's
request ? as

	memcg_wake_kswapd(struct mem_cgroup *mem) 
	{
		do {
			nid = select_victim_node(mem);
			/* ask kswapd to reclaim memcg's memory */
			ret = memcg_kswapd_queue_work(nid, mem); /* may return -EBUSY if very busy*/
		} while()
	}

This will make lock contention minimum. Anyway, using too much cpu for this
unnecessary_but_good_for_performance_function is bad. Throttoling is required.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
