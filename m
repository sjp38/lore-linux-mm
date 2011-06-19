Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8AC2A6B0012
	for <linux-mm@kvack.org>; Sun, 19 Jun 2011 19:51:57 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 83DFF3EE0B6
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 08:51:54 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 64A2945DE53
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 08:51:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4205E45DE4F
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 08:51:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 34A5C1DB8041
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 08:51:54 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E4CB41DB8037
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 08:51:53 +0900 (JST)
Date: Mon, 20 Jun 2011 08:44:54 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 5/7] Fix not good check of mem_cgroup_local_usage()
Message-Id: <20110620084454.85f048f9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTi=4o-xY46OtsvNCxVKUT-qJBXRMMFZCe-m7eMV-_mesXw@mail.gmail.com>
References: <20110616124730.d6960b8b.kamezawa.hiroyu@jp.fujitsu.com>
	<20110616125443.23584d78.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTi=4o-xY46OtsvNCxVKUT-qJBXRMMFZCe-m7eMV-_mesXw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On Fri, 17 Jun 2011 15:27:36 -0700
Ying Han <yinghan@google.com> wrote:

> On Wed, Jun 15, 2011 at 8:54 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > From fcfc6ee9847b0b2571cd6e9847572d7c70e1e2b2 Mon Sep 17 00:00:00 2001
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Date: Thu, 16 Jun 2011 09:23:54 +0900
> > Subject: [PATCH 5/7] Fix not good check of mem_cgroup_local_usage()
> >
> > Now, mem_cgroup_local_usage(memcg) is used as hint for scanning memory
> > cgroup hierarchy. If it returns true, the memcg has some reclaimable memory.
> >
> > But this function doesn't take care of
> > A - unevictable pages
> > A - anon pages on swapless system.
> >
> > This patch fixes the function to use LRU information.
> > For NUMA, for avoid scanning, numa scan bitmap is used. If it's
> > empty, some more precise check will be done.
> >
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> > A mm/memcontrol.c | A  43 +++++++++++++++++++++++++++++++++----------
> > A 1 files changed, 33 insertions(+), 10 deletions(-)
> >
> > Index: mmotm-0615/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-0615.orig/mm/memcontrol.c
> > +++ mmotm-0615/mm/memcontrol.c
> > @@ -632,15 +632,6 @@ static long mem_cgroup_read_stat(struct
> > A  A  A  A return val;
> > A }
> >
> > -static long mem_cgroup_local_usage(struct mem_cgroup *mem)
> > -{
> > - A  A  A  long ret;
> > -
> > - A  A  A  ret = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_RSS);
> > - A  A  A  ret += mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_CACHE);
> > - A  A  A  return ret;
> > -}
> > -
> > A static void mem_cgroup_swap_statistics(struct mem_cgroup *mem,
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  bool charge)
> > A {
> > @@ -1713,6 +1704,23 @@ static void mem_cgroup_numascan_init(str
> > A  A  A  A mutex_init(&mem->numascan_mutex);
> > A }
> >
> > +static bool mem_cgroup_reclaimable(struct mem_cgroup *mem, bool noswap)
> > +{
> > + A  A  A  if (!nodes_empty(mem->scan_nodes))
> > + A  A  A  A  A  A  A  return true;
> > + A  A  A  /* slow path */
> > + A  A  A  if (mem_cgroup_get_local_zonestat(mem, LRU_INACTIVE_FILE))
> > + A  A  A  A  A  A  A  return true;
> > + A  A  A  if (mem_cgroup_get_local_zonestat(mem, LRU_ACTIVE_FILE))
> > + A  A  A  A  A  A  A  return true;
> 
> Wondering if we can simplify this like:
> 
> if (mem_cgroup_nr_file_lru_pages(mem))
>    return true;
> 
> 
> > + A  A  A  if (noswap || !total_swap_pages)
> > + A  A  A  A  A  A  A  return false;
> > + A  A  A  if (mem_cgroup_get_local_zonestat(mem, LRU_INACTIVE_ANON))
> > + A  A  A  A  A  A  A  return true;
> > + A  A  A  if (mem_cgroup_get_local_zonestat(mem, LRU_ACTIVE_ANON))
> > + A  A  A  A  A  A  A  return true;
> 
> the same:
> if (mem_cgroup_nr_anon_lru_pages(mem))
>    return true;
> 
> > + A  A  A  return false;
> > +}
> 
> The two functions above are part of memory.numa_stat patch which is in
> mmotm i believe. Just feel the functionality a bit duplicate except
> the noswap parameter and scan_nodes.
> 

Ah, I didn't noticed such function.


Hm, considering more, I think we don't have to scann all nodes and
make sum of number because what we check is whether pages == 0 or
pages != 0.

I'll make an update.

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
