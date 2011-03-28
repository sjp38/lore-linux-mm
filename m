Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D32368D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 14:01:26 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id p2SI1Oa5032647
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 11:01:24 -0700
Received: from gwj16 (gwj16.prod.google.com [10.200.10.16])
	by wpaz24.hot.corp.google.com with ESMTP id p2SI1IQc004303
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 11:01:23 -0700
Received: by gwj16 with SMTP id 16so1522483gwj.37
        for <linux-mm@kvack.org>; Mon, 28 Mar 2011 11:01:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110328093957.089007035@suse.cz>
References: <20110328093957.089007035@suse.cz>
Date: Mon, 28 Mar 2011 11:01:18 -0700
Message-ID: <AANLkTi=CPMxOg3juDiD-_hnBsXKdZ+at+i9c1YYM=vv1@mail.gmail.com>
Subject: Re: [RFC 0/3] Implementation of cgroup isolation
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Suleiman Souhlal <suleiman@google.com>

On Mon, Mar 28, 2011 at 2:39 AM, Michal Hocko <mhocko@suse.cz> wrote:
> Hi all,
>
> Memory cgroups can be currently used to throttle memory usage of a group =
of
> processes. It, however, cannot be used for an isolation of processes from
> the rest of the system because all the pages that belong to the group are
> also placed on the global LRU lists and so they are eligible for the glob=
al
> memory reclaim.
>
> This patchset aims at providing an opt-in memory cgroup isolation. This
> means that a cgroup can be configured to be isolated from the rest of the
> system by means of cgroup virtual filesystem (/dev/memctl/group/memory.is=
olated).

Thank you Hugh pointing me to the thread. We are working on similar
problem in memcg currently

Here is the problem we see:
1. In memcg, a page is both on per-memcg-per-zone lru and global-lru.
2. Global memory reclaim will throw page away regardless of cgroup.
3. The zone->lru_lock is shared between per-memcg-per-zone lru and global-l=
ru.

And we know:
1. We shouldn't do global reclaim since it breaks memory isolation.
2. There is no need for a page to be on both LRU list, especially
after having per-memcg background reclaim.

So our approach is to take off page from global lru after it is
charged to a memcg. Only pages allocated at root cgroup remains in
global LRU, and each memcg reclaims pages on its isolated LRU.

By doing this, we can further solve the lock contention mentioned in
3) to have per-memcg-per-zone lock. I can post the patch later if that
helps better understanding.

Thanks

--Ying

>
> Isolated mem cgroup can be particularly helpful in deployments where we h=
ave
> a primary service which needs to have a certain guarantees for memory
> resources (e.g. a database server) and we want to shield it off the
> rest of the system (e.g. a burst memory activity in another group). This =
is
> currently possible only with mlocking memory that is essential for the
> application(s) or a rather hacky configuration where the primary app is i=
n
> the root mem cgroup while all the other system activity happens in other
> groups.
>
> mlocking is not an ideal solution all the time because sometimes the work=
ing
> set is very large and it depends on the workload (e.g. number of incoming
> requests) so it can end up not fitting in into memory (leading to a OOM
> killer). If we use mem. cgroup isolation instead we are keeping memory re=
sident
> and if the working set goes wild we can still do per-cgroup reclaim so th=
e
> service is less prone to be OOM killed.
>
> The patch series is split into 3 patches. First one adds a new flag into
> mem_cgroup structure which controls whether the group is isolated (false =
by
> default) and a cgroup fs interface to set it.
> The second patch implements interaction with the global LRU. The current
> semantic is that we are putting a page into a global LRU only if mem cgro=
up
> LRU functions say they do not want the page for themselves.
> The last patch prevents from soft reclaim if the group is isolated.
>
> I have tested the patches with the simple memory consumer (allocating
> private and shared anon memory and SYSV SHM).
>
> One instance (call it big consumer) running in the group and paging in th=
e
> memory (>90% of cgroup limit) and sleeping for the rest of its life. Then=
 I
> had a pool of consumers running in the same cgroup which page in smaller
> amount of memory and paging them in the loop to simulate in group memory
> pressure (call them sharks).
> The sum of consumed memory is more than memory.limit_in_bytes so some
> portion of the memory is swapped out.
> There is one consumer running in the root cgroup running in parallel whic=
h
> makes a pressure on the memory (to trigger background reclaim).
>
> Rss+cache of the group drops down significantly (~66% of the limit) if th=
e
> group is not isolated. On the other hand if we isolate the group we are
> still saturating the group (~97% of the limit). I can show more
> comprehensive results if somebody is interested.
>
> Thanks for comments.
>
> ---
> =A0include/linux/memcontrol.h | =A0 24 ++++++++------
> =A0include/linux/mm_inline.h =A0| =A0 10 ++++-
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 76 ++++++++++++++++++++++=
++++++++++++++---------
> =A0mm/swap.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 12 ++++---
> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 43 +++++++++++++++---=
-------
> =A05 files changed, 118 insertions(+), 47 deletions(-)
>
> --
> Michal Hocko
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
