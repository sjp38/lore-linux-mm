Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 073438D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 20:19:26 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 17BD43EE0B6
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 09:19:24 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F188145DE4F
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 09:19:23 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id DAE5A45DE4D
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 09:19:23 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CC5F21DB8037
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 09:19:23 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A5151DB802F
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 09:19:23 +0900 (JST)
Date: Tue, 29 Mar 2011 09:12:54 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC 0/3] Implementation of cgroup isolation
Message-Id: <20110329091254.20c7cfcb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTi=CPMxOg3juDiD-_hnBsXKdZ+at+i9c1YYM=vv1@mail.gmail.com>
References: <20110328093957.089007035@suse.cz>
	<AANLkTi=CPMxOg3juDiD-_hnBsXKdZ+at+i9c1YYM=vv1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Suleiman Souhlal <suleiman@google.com>

On Mon, 28 Mar 2011 11:01:18 -0700
Ying Han <yinghan@google.com> wrote:

> On Mon, Mar 28, 2011 at 2:39 AM, Michal Hocko <mhocko@suse.cz> wrote:
> > Hi all,
> >
> > Memory cgroups can be currently used to throttle memory usage of a group of
> > processes. It, however, cannot be used for an isolation of processes from
> > the rest of the system because all the pages that belong to the group are
> > also placed on the global LRU lists and so they are eligible for the global
> > memory reclaim.
> >
> > This patchset aims at providing an opt-in memory cgroup isolation. This
> > means that a cgroup can be configured to be isolated from the rest of the
> > system by means of cgroup virtual filesystem (/dev/memctl/group/memory.isolated).
> 
> Thank you Hugh pointing me to the thread. We are working on similar
> problem in memcg currently
> 
> Here is the problem we see:
> 1. In memcg, a page is both on per-memcg-per-zone lru and global-lru.
> 2. Global memory reclaim will throw page away regardless of cgroup.
> 3. The zone->lru_lock is shared between per-memcg-per-zone lru and global-lru.
> 
> And we know:
> 1. We shouldn't do global reclaim since it breaks memory isolation.
> 2. There is no need for a page to be on both LRU list, especially
> after having per-memcg background reclaim.
> 
> So our approach is to take off page from global lru after it is
> charged to a memcg. Only pages allocated at root cgroup remains in
> global LRU, and each memcg reclaims pages on its isolated LRU.
> 

Why you don't use cpuset and virtual nodes ? It's what you want.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
