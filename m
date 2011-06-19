Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0B6B36B0012
	for <linux-mm@kvack.org>; Sun, 19 Jun 2011 19:48:30 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 7EFF23EE0C8
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 08:48:26 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2CF2E2AEA8F
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 08:48:26 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id F05A7266CC2
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 08:48:25 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DB62A1DB8052
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 08:48:25 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 99FBD1DB804A
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 08:48:25 +0900 (JST)
Date: Mon, 20 Jun 2011 08:41:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/7] memcg: add memory.scan_stat
Message-Id: <20110620084123.c63d3e12.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTimYEr9k3Sk5JoaRrrQH4mGoTmL1Wf5gadYVGDuNpxofHw@mail.gmail.com>
References: <20110616124730.d6960b8b.kamezawa.hiroyu@jp.fujitsu.com>
	<20110616125314.4f78b1e0.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTimYEr9k3Sk5JoaRrrQH4mGoTmL1Wf5gadYVGDuNpxofHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Andrew Bresticker <abrestic@google.com>

On Fri, 17 Jun 2011 15:04:18 -0700
Ying Han <yinghan@google.com> wrote:

> On Wed, Jun 15, 2011 at 8:53 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > From e08990dd9ada13cf236bec1ef44b207436434b8e Mon Sep 17 00:00:00 2001
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Date: Wed, 15 Jun 2011 14:11:01 +0900
> > Subject: [PATCH 3/7] memcg: add memory.scan_stat
> >
> > commit log of commit 0ae5e89 " memcg: count the soft_limit reclaim in..."
> > says it adds scanning stats to memory.stat file. But it doesn't because
> > we considered we needed to make a concensus for such new APIs.
> >
> > This patch is a trial to add memory.scan_stat. This shows
> > A - the number of scanned pages
> > A - the number of recleimed pages
> > A - the number of elaplsed time (including sleep/pause time)
> > A for both of direct/soft reclaim and shrinking caused by changing limit
> > A or force_empty.
> >
> > The biggest difference with oringinal Ying's one is that this file
> > can be reset by some write, as
> >
> > A # echo 0 ...../memory.scan_stat
> >
> > [kamezawa@bluextal ~]$ cat /cgroup/memory/A/memory.scan_stat
> > scanned_pages_by_limit 358470
> > freed_pages_by_limit 180795
> > elapsed_ns_by_limit 21629927
> > scanned_pages_by_system 0
> > freed_pages_by_system 0
> > elapsed_ns_by_system 0
> > scanned_pages_by_shrink 76646
> > freed_pages_by_shrink 38355
> > elappsed_ns_by_shrink 31990670
> > total_scanned_pages_by_limit 358470
> > total_freed_pages_by_limit 180795
> > total_elapsed_ns_by_hierarchical 216299275
> > total_scanned_pages_by_system 0
> > total_freed_pages_by_system 0
> > total_elapsed_ns_by_system 0
> > total_scanned_pages_by_shrink 76646
> > total_freed_pages_by_shrink 38355
> > total_elapsed_ns_by_shrink 31990670
> >
> > total_xxxx is for hierarchy management.
> >
> > This will be useful for further memcg developments and need to be
> > developped before we do some complicated rework on LRU/softlimit
> > management.
> 
> Agreed. Actually we are also looking into adding a per-memcg API for
> adding visibility of
> page reclaim path. It would be helpful for us to settle w/ the API first.
> 
> I am not a fan of names, but how about
> "/dev/cgroup/memory/memory.reclaim_stat" ?
> 

Hm, ok, I have no favorite. 


> >
> > Now, scan/free/elapsed_by_system is incomplete but future works of
> > Johannes at el. will fill remaining information and then, we can
> > look into problems of isolation between memcgs.
> >
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> > A Documentation/cgroups/memory.txt | A  33 +++++++++
> > A include/linux/memcontrol.h A  A  A  | A  16 ++++
> > A include/linux/swap.h A  A  A  A  A  A  | A  A 6 -
> > A mm/memcontrol.c A  A  A  A  A  A  A  A  A | A 135 +++++++++++++++++++++++++++++++++++++--
> > A mm/vmscan.c A  A  A  A  A  A  A  A  A  A  A | A  27 ++++++-
> > A 5 files changed, 199 insertions(+), 18 deletions(-)
> >
> > Index: mmotm-0615/Documentation/cgroups/memory.txt
> > ===================================================================
> > --- mmotm-0615.orig/Documentation/cgroups/memory.txt
> > +++ mmotm-0615/Documentation/cgroups/memory.txt
> > @@ -380,7 +380,7 @@ will be charged as a new owner of it.
> >
> > A 5.2 stat file
> >
> > -memory.stat file includes following statistics
> > +5.2.1 memory.stat file includes following statistics
> >
> > A # per-memory cgroup local status
> > A cache A  A  A  A  A - # of bytes of page cache memory.
> > @@ -438,6 +438,37 @@ Note:
> > A  A  A  A  file_mapped is accounted only when the memory cgroup is owner of page
> > A  A  A  A  cache.)
> >
> > +5.2.2 memory.scan_stat
> > +
> > +memory.scan_stat includes statistics information for memory scanning and
> > +freeing, reclaiming. The statistics shows memory scanning information since
> > +memory cgroup creation and can be reset to 0 by writing 0 as
> > +
> > + #echo 0 > ../memory.scan_stat
> > +
> > +This file contains following statistics.
> > +
> > +scanned_pages_by_limit - # of scanned pages at hitting limit.
> > +freed_pages_by_limit A  - # of freed pages at hitting limit.
> 
> How those stats different from Johannes's patch? I feel we should keep
> them into this API instead of memory.stat
> "pgscan_direct_limit"
> "pgreclaim_direct_limit"
> 

It's unclear the unit of number from that name.
And, I can't find what it means "direct_limit". Only "limit" is meaningful.



> > +elapsed_ns_by_limit A  A - nano sec of elappsed time at LRU scan at
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A hitting limit.(this includes sleep time.)
> 
> 
> > +
> > +scanned_pages_by_system A  A  A  A - # of scanned pages by the kernel.
> > + A  A  A  A  A  A  A  A  A  A  A  A  (Now, this value means global memory reclaim
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  caused by system memory shortage with a hint
> > + A  A  A  A  A  A  A  A  A  A  A  A  A of softlimit. "No soft limit" case will be
> > + A  A  A  A  A  A  A  A  A  A  A  A  A supported in future.)
> > +freed_pages_by_system A - # of freed pages by the kernel.
> 
> The same for the following which I assume the same meaning with:
> "pgscan_direct_hierarchy"
> "pgreclaim_direct_hierarchy"
> 

Doesn't make sense. What hierarchy means, here?

Above 2 is for showing "amount of scanned/reclaimed memory by system's memory
pressure". 
(But now, it just shows "softlimit" information until Johannes' work comes.)

For hierarchy information, I have "total_xxxx_by_xxxx" parameter. 

> > +elapsed_ns_by_system A  - nano sec of elappsed time by kernel.
> > +
> > +scanned_pages_by_shrink A  A  A  A - # of scanned pages by shrinking.
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  (i.e. changes of limit, force_empty, etc.)
> > +freed_pages_by_shrink A - # of freed pages by shirkining.
> 
> So those stats are not included in the ones above?
> 

Yes.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
