Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 12AF46B0062
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 15:14:29 -0500 (EST)
Received: by iacb35 with SMTP id b35so1795738iac.14
        for <linux-mm@kvack.org>; Thu, 05 Jan 2012 12:14:28 -0800 (PST)
Date: Thu, 5 Jan 2012 12:14:25 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 3/5] memcg: lru_size instead of MEM_CGROUP_ZSTAT
In-Reply-To: <20120105153344.8c6682fb.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.LSU.2.00.1201051139140.2009@eggly.anvils>
References: <alpine.LSU.2.00.1112312322200.18500@eggly.anvils> <alpine.LSU.2.00.1112312329240.18500@eggly.anvils> <20120105153344.8c6682fb.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org

On Thu, 5 Jan 2012, KAMEZAWA Hiroyuki wrote:
> On Sat, 31 Dec 2011 23:30:38 -0800 (PST)
> Hugh Dickins <hughd@google.com> wrote:
> 
> > I never understood why we need a MEM_CGROUP_ZSTAT(mz, idx) macro
> > to obscure the LRU counts.  For easier searching?  So call it
> > lru_size rather than bare count (lru_length sounds better, but
> > would be wrong, since each huge page raises lru_size hugely).
> > 
> > Signed-off-by: Hugh Dickins <hughd@google.com>
> 
> 
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Thanks (to you and the other guys) for all the acks.

> 
> BTW, can this counter be moved to lruvec finally ?

Well.  It could be, but I haven't moved it (even in coming patches),
and it's not yet quite clear to me whether that's right or not.

Because there's a struct lruvec in struct zone, which we use when
!CONFIG_CGROUP_MEM_RES_CTLR or when mem_cgroup_disabled(); but the
corresponding lru_sizes would be a waste in those cases, because
they then just duplicate vm_stat[NR_INACTIVE_ANON..NR_UNEVICTABLE].

And we want to keep vm_stat[NR_INACTIVE_ANON..NR_UNEVICTABLE],
because we do want those global LRU sizes even in the memcg case.

Of course, we could put unused lru_size fields in anyway, it would
not waste much space.

But I'd prefer to hold off for now: I imagine that we're moving
towards a future in which even !CONFIG_CGROUP_MEM_RES_CTLR will have a
root_mem_cgroup, and it will become clearer what to place where then.

We use the lruvec heavily in the per-memcg per-zone locking patches,
as something low-level code can operate on without needing to know
if it's memcg or global; but have not actually needed to move the
lru_sizes into the structure (perhaps it's a hack: there is one place
I use container_of to go from the lruvec pointer to the lru_sizes).

(I might want to move the reclaim_stat into the lruvec, don't know
yet: I only just noticed that there are places where I'm not locking
the reclaim_stat properly: it's not such a big deal that it was ever
obvious, but I ought to get it right.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
