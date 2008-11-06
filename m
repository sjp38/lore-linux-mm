Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mA60MgDV001508
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 6 Nov 2008 09:22:42 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C598A45DD7C
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 09:22:41 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8997045DD7E
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 09:22:41 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B35F1DB803F
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 09:22:41 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 030ED1DB8037
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 09:22:41 +0900 (JST)
Date: Thu, 6 Nov 2008 09:22:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [mm][PATCH 0/4] Memory cgroup hierarchy introduction
Message-Id: <20081106092204.2e5dacfb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4911DD64.7010508@linux.vnet.ibm.com>
References: <20081101184812.2575.68112.sendpatchset@balbir-laptop>
	<20081104091510.01cf3a1e.kamezawa.hiroyu@jp.fujitsu.com>
	<4911A4D8.4010402@linux.vnet.ibm.com>
	<50093.10.75.179.62.1225902786.squirrel@webmail-b.css.fujitsu.com>
	<4911DD64.7010508@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 05 Nov 2008 23:22:36 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> >   Now,
> >         /group_root limit=1G, usage=990M
> >                     /group_A  usage=600M , no limit, no tasks for a while
> >                     /group_B  usage=10M  , no limit, no tasks
> >                     /group_C  usage=380M , no limit, 2 tasks
> > 
> >   A user run a new task in group_B.
> >   In your algorithm, group_A and B and C's memory are reclaimed
> >   to the same extent becasue there is no information to show
> >   "group A's memory are not accessed recently rather than B or C".
> > 
> >   This information is what we want for managing memory.
> > 
> 
> For that sort of implementation, we'll need a common LRU. I actually thought of
> implementing it by sharing a common LRU, but then we would end up with just one
> common LRU at the root :)
> 
> The reclaim algorithm is smart in that it knows what pages are commonly
> accessed. group A will get reclaimed more since those pages are not actively
> referenced. reclaim on group_C will be harder.
Why ? I think isolate_lru_page() removes SWAP_CLUSTER_MAX from each group.

> Simple experiments seem to show that.
> 
please remember the problem as problem and put that in TODO or FIXME, at least.
or add explanation "why this works well" in logical text.
As Andrew Morton said, vaildation for LRU management tend to need long time.


> >>> I'd like to show some other possible implementation of
> >>> try_to_free_mem_cgroup_pages() if I can.
> >>>
> >> Elaborate please!
> >>
> > ok. but, at least, please add
> >   - per-subtree hierarchy flag.
> >   - cgroup_lock to walk list of cgroups somewhere.
> > 
> > I already sent my version "shared LRU" just as a hint for you.
> > It is something extreme but contains something good, I think.
> > 
> >>> Anyway, I have to merge this with mem+swap controller.
> >> Cool! I'll send you an updated version.
> >>
> > 
> > Synchronized LRU patch may help you.
> 
> Let me get a good working version against current -mm and then we'll integrate
> our patches.
> 
A patch set I posted yesterday doesn't work ?
If not, please wait until next mmotm comes out.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
