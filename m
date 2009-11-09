Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B8C5C6B004D
	for <linux-mm@kvack.org>; Sun,  8 Nov 2009 20:52:10 -0500 (EST)
Date: Mon, 9 Nov 2009 10:44:46 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH -mmotm 0/8] memcg: recharge at task move
Message-Id: <20091109104446.b2d9ef66.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091106154542.5ca9bb61.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091106141011.3ded1551.nishimura@mxp.nes.nec.co.jp>
	<20091106154542.5ca9bb61.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 6 Nov 2009 15:45:42 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 6 Nov 2009 14:10:11 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > Hi.
> > 
> > In current memcg, charges associated with a task aren't moved to the new cgroup
> > at task move. These patches are for this feature, that is, for recharging to
> > the new cgroup and, of course, uncharging from old cgroup at task move.
> > 
> > Current virsion supports only recharge of non-shared(mapcount == 1) anonymous pages
> > and swaps of those pages. I think it's enough as a first step.
> > 
> > [1/8] cgroup: introduce cancel_attach()
> > [2/8] memcg: move memcg_tasklist mutex
> > [3/8] memcg: add mem_cgroup_cancel_charge()
> > [4/8] memcg: cleanup mem_cgroup_move_parent()
> > [5/8] memcg: add interface to recharge at task move
> > [6/8] memcg: recharge charges of anonymous page
> > [7/8] memcg: avoid oom during recharge at task move
> > [8/8] memcg: recharge charges of anonymous swap
> > 
> > 2 is dependent on 1 and 4 is dependent on 3.
> > 3 and 4 are just for cleanups.
> > 5-8 are the body of this feature.
> > 
> > Major Changes from Oct13:
> > - removed "[RFC]".
> > - rebased on mmotm-2009-11-01-10-01.
> > - dropped support for file cache and shmem/tmpfs(revisit in future).
> > - Updated Documentation/cgroup/memory.txt.
> > 
> 
> Seems much nicer but I have some nitpicks as already commented.
> 
> For [8/8], mm->swap_usage counter may be a help for making it faster.
> Concern is how it's shared but will not be very big error.
> 
will change as I mentioned in another mail.

I'll repost 3 and 4 as cleanup(I think they are ready for inclusion),
and post removal-of-memcg_tasklist as a separate patch.

I'll postpone the body of this feature(waiting for your percpu change
and per-process swap counter at least).

> > TODO:
> > - add support for file cache, shmem/tmpfs, and shared(mapcount > 1) pages.
> > - implement madvise(2) to let users decide the target vma for recharge.
> > 
> 
> About this, I think "force_move_shared_account" flag is enough, I think.
> But we have to clarify "mmap()ed but not on page table" entries are not
> moved....
> 
You mean swap entries of shmem/tmpfs, do you ? I agree they are hard to handle..


My concern is:

- I want to add support for private file caches, shmes/tmpfs pages(including swaps of them),
  and "shared" pages by some means in future, and let an admin or a middle-ware
  decide how to handle them.
- Once this feature has been merged(at .33?), I don't want to change the behavior
  when a user set "recharge_at_immigrate=1".
  So, I'll "extend" the meaning of "recharge_at_immigrate" or add a new flag file
  to support other type of charges.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
