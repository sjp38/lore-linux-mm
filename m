Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 17D876B004D
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 22:20:14 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 7B0973EE0AE
	for <linux-mm@kvack.org>; Tue, 24 Jan 2012 12:20:08 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5890145DE55
	for <linux-mm@kvack.org>; Tue, 24 Jan 2012 12:20:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C8A345DE4E
	for <linux-mm@kvack.org>; Tue, 24 Jan 2012 12:20:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F287E08002
	for <linux-mm@kvack.org>; Tue, 24 Jan 2012 12:20:08 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D95E4E08008
	for <linux-mm@kvack.org>; Tue, 24 Jan 2012 12:20:07 +0900 (JST)
Date: Tue, 24 Jan 2012 12:18:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] [PATCH 7/7 v2] memcg: make mem_cgroup_begin_update_stat
 to use global pcpu.
Message-Id: <20120124121846.051d225b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <CAHH2K0ZzE55Dx=pz+cR1US3UnUbUxuyVjM=N3kf3NN+Rz8GJjQ@mail.gmail.com>
References: <20120113173001.ee5260ca.kamezawa.hiroyu@jp.fujitsu.com>
	<20120113174510.5e0f6131.kamezawa.hiroyu@jp.fujitsu.com>
	<CAHH2K0ZzE55Dx=pz+cR1US3UnUbUxuyVjM=N3kf3NN+Rz8GJjQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Ying Han <yinghan@google.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, "bsingharora@gmail.com" <bsingharora@gmail.com>

On Fri, 20 Jan 2012 00:40:34 -0800
Greg Thelen <gthelen@google.com> wrote:

> On Fri, Jan 13, 2012 at 12:45 AM, KAMEZAWA Hiroyuki

> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 8b67ccf..4836e8d 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -89,7 +89,6 @@ enum mem_cgroup_stat_index {
> > A  A  A  A MEM_CGROUP_STAT_FILE_MAPPED, A /* # of pages charged as file rss */
> > A  A  A  A MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
> > A  A  A  A MEM_CGROUP_STAT_DATA, /* end of data requires synchronization */
> > - A  A  A  MEM_CGROUP_ON_MOVE, A  A  /* someone is moving account between groups */
> > A  A  A  A MEM_CGROUP_STAT_NSTATS,
> > A };
> >
> > @@ -279,6 +278,8 @@ struct mem_cgroup {
> > A  A  A  A  * mem_cgroup ? And what type of charges should we move ?
> > A  A  A  A  */
> > A  A  A  A unsigned long A  move_charge_at_immigrate;
> > + A  A  A  /* set when a page under this memcg may be moving to other memcg */
> > + A  A  A  atomic_t A  A  A  A account_moving;
> > A  A  A  A /*
> > A  A  A  A  * percpu counter.
> > A  A  A  A  */
> > @@ -1250,20 +1251,27 @@ int mem_cgroup_swappiness(struct mem_cgroup *memcg)
> > A  A  A  A return memcg->swappiness;
> > A }
> >
> > +/*
> > + * For quick check, for avoiding looking up memcg, system-wide
> > + * per-cpu check is provided.
> > + */
> > +DEFINE_PER_CPU(int, mem_cgroup_account_moving);
> 
> Why is this a per-cpu counter?  Can this be an single atomic_t
> instead, or does cpu hotplug require per-cpu state?  In the common
> case, when there is no move in progress, then the counter would be
> zero and clean in all cpu caches that need it.  When moving pages,
> mem_cgroup_start_move() would atomic_inc the counter.
> 

Ok, atomic_t will be simple.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
