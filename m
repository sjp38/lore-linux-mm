Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id A4B4E6B13F0
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 22:46:12 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id D3CD73EE0B5
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 12:46:10 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id BA75245DE56
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 12:46:10 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 983C245DE54
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 12:46:10 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8AD121DB804E
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 12:46:10 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3607C1DB8044
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 12:46:10 +0900 (JST)
Date: Fri, 10 Feb 2012 12:44:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [LSF/MM TOPIC] [ATTEND] memcg: soft limit reclaim (continue)
 and others
Message-Id: <20120210124446.55e882ad.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <CALWz4iwHq6rX72gv4XMVAviqtFT8mjW2OgCBtjU6AVX94YsnGg@mail.gmail.com>
References: <CALWz4iypV=k-7gVcFx=OsHJsWcUzQsfEoYbQ4+ySQoTob_PWcQ@mail.gmail.com>
	<20120201135442.0491d882.kamezawa.hiroyu@jp.fujitsu.com>
	<CALWz4iwHq6rX72gv4XMVAviqtFT8mjW2OgCBtjU6AVX94YsnGg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On Wed, 1 Feb 2012 16:00:44 -0800
Ying Han <yinghan@google.com> wrote:

> On Tue, Jan 31, 2012 at 8:54 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Tue, 31 Jan 2012 11:59:40 -0800
> > Ying Han <yinghan@google.com> wrote:
> >
> >> some topics that I would like to discuss this year:
> >>
> >> 1) we talked about soft limit redesign during last LSF, and there are
> >> quite a lot of efforts and changes being pushed after that. I would
> >> like to take this time to sync-up our efforts and also discuss some of
> >> the remaining issues.
> >>
> >> Discussion from last year :
> >> http://www.spinics.net/lists/linux-mm/msg17102.html and lots of
> >> changes have been made since then.
> >>
> >
> > Yes, it seems re-sync is required.
> >
> >> 2) memory.stat, this is the main stat file for all memcg statistics.
> >> are we planning to keep stuff it for something like per-memcg
> >> vmscan_stat, vmstat or not.
> >>
> >
> > Could you calrify ? Do you want to have another stat file like memory.vmstat ?
> 
> I was planning to add per-memcg vmstat file at one point, but there
> were discussions of just extending memory.stat. I don't mind to have
> very long memory.stat file since my screen is now vertical anyway.
> Just want to sync-up our final decision for later patches.
> 
> >
> >
> >> 3) root cgroup now becomes quite interesting, especially after we
> >> bring back the exclusive lru to root. To be more specific, root cgroup
> >> now is like a sink which contains pages allocated on its own, and also
> >> pages being re-parented. Those pages won't be reclaimed until there is
> >> a global pressure, and we want to see anything we can do better.
> >>
> >
> > I'm sorry I can't get your point.
> >
> > Do you think it's better to shrink root mem cgroup LRU even if there are
> > no memory pressure ?
> 
> The benefit will be reduced memory reclaim latency.
> 
> That is something I am thinking now. Now what we do in removing a
> cgroup is re-parent all the pages, and root become a sink with all the
> left-over pages. There is no external memory pressure to push those
> pages out unless global reclaim, and the machine size will look
> smaller and smaller on admin perspective.
> 
> I am thinking to use some existing reclaim mechanism to apply pressure
> on those pages inside the kernel.
> 

I considered your re-parent problem a bit...my suggestion is..

How about using cleancache other than re-parent ?

Assume a memcg X contains 100M Bytes of file caches.

# rmdir X 
  => puts all file caches to cleancache, by reclaiming all pages.
     Here, memcg's charge will disappear. and clean cache will have 100MB cache.

If a file cache will be accessed again, it will be re-charged to proper cgroup.
If a file cache won't be accessed soon, it will be dropped from the system.

Furthermore, we may be able to add control knobs
  - re-parent all file caches     (current implemenation)
  - drop all file caches at rmdir
  - drop all file caches to cleancache.

Size of clean cache may be a problem even if it's configurable..

I don't have good idea for ANON pages but I think there are no big problem with
re-parenting them..

Thanks,
-Kame











--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
