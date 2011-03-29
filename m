Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id CFA4A8D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 20:54:30 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 6C8AF3EE0B5
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 09:54:27 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9014045DE5C
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 09:54:26 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5114245DE3E
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 09:54:26 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 01EF0E08004
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 09:54:26 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 91903E08002
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 09:54:24 +0900 (JST)
Date: Tue, 29 Mar 2011 09:47:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC 0/3] Implementation of cgroup isolation
Message-Id: <20110329094756.49af153d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTin4J5kiysPdQD2aTC52U4-dy04C1g@mail.gmail.com>
References: <20110328093957.089007035@suse.cz>
	<AANLkTi=CPMxOg3juDiD-_hnBsXKdZ+at+i9c1YYM=vv1@mail.gmail.com>
	<20110329091254.20c7cfcb.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTin4J5kiysPdQD2aTC52U4-dy04C1g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Suleiman Souhlal <suleiman@google.com>

On Mon, 28 Mar 2011 17:37:02 -0700
Ying Han <yinghan@google.com> wrote:

> On Mon, Mar 28, 2011 at 5:12 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Mon, 28 Mar 2011 11:01:18 -0700
> > Ying Han <yinghan@google.com> wrote:
> >
> >> On Mon, Mar 28, 2011 at 2:39 AM, Michal Hocko <mhocko@suse.cz> wrote:
> >> > Hi all,
> >> >
> >> > Memory cgroups can be currently used to throttle memory usage of a group of
> >> > processes. It, however, cannot be used for an isolation of processes from
> >> > the rest of the system because all the pages that belong to the group are
> >> > also placed on the global LRU lists and so they are eligible for the global
> >> > memory reclaim.
> >> >
> >> > This patchset aims at providing an opt-in memory cgroup isolation. This
> >> > means that a cgroup can be configured to be isolated from the rest of the
> >> > system by means of cgroup virtual filesystem (/dev/memctl/group/memory.isolated).
> >>
> >> Thank you Hugh pointing me to the thread. We are working on similar
> >> problem in memcg currently
> >>
> >> Here is the problem we see:
> >> 1. In memcg, a page is both on per-memcg-per-zone lru and global-lru.
> >> 2. Global memory reclaim will throw page away regardless of cgroup.
> >> 3. The zone->lru_lock is shared between per-memcg-per-zone lru and global-lru.
> >>
> >> And we know:
> >> 1. We shouldn't do global reclaim since it breaks memory isolation.
> >> 2. There is no need for a page to be on both LRU list, especially
> >> after having per-memcg background reclaim.
> >>
> >> So our approach is to take off page from global lru after it is
> >> charged to a memcg. Only pages allocated at root cgroup remains in
> >> global LRU, and each memcg reclaims pages on its isolated LRU.
> >>
> >
> > Why you don't use cpuset and virtual nodes ? It's what you want.
> 
> We've been running cpuset + fakenuma nodes configuration in google to
> provide memory isolation. The configuration of having the virtual box
> is complex which user needs to know great details of the which node to
> assign to which cgroup. That is one of the motivations for us moving
> towards to memory controller which simply do memory accounting no
> matter where pages are allocated.
> 

I think current fake-numa is not useful because it works only at boot time.

> By saying that, memcg simplified the memory accounting per-cgroup but
> the memory isolation is broken. This is one of examples where pages
> are shared between global LRU and per-memcg LRU. It is easy to get
> cgroup-A's page evicted by adding memory pressure to cgroup-B.
> 
If you overcommit....Right ?


> The approach we are thinking to make the page->lru exclusive solve the
> problem. and also we should be able to break the zone->lru_lock
> sharing.
> 
Is zone->lru_lock is a problem even with the help of pagevecs ?

If LRU management guys acks you to isolate LRUs and to make kswapd etc..
more complex, okay, we'll go that way. This will _change_ the whole
memcg design and concepts Maybe memcg should have some kind of balloon driver to
work happy with isolated lru.

But my current standing position is "never bad effects global reclaim".
So, I'm not very happy with the solution.

If we go that way, I guess we'll think we should have pseudo nodes/zones, which
was proposed in early days of resource controls.(not cgroup).

Thanks,
-Kame








--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
