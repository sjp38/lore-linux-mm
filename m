Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id F1F1E6B0047
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 01:00:23 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8E50KIM023256
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 14 Sep 2010 14:00:21 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C2BE45DE51
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 14:00:20 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6BE3D45DE4F
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 14:00:20 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A764E18001
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 14:00:20 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A2A14E08001
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 14:00:19 +0900 (JST)
Date: Tue, 14 Sep 2010 13:55:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: avoid lock in updating file_mapped (Was fix race
 in file_mapped accouting flag management
Message-Id: <20100914135513.06e2b57f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100913172619.GN17950@balbir.in.ibm.com>
References: <20100913160822.0c2cd732.kamezawa.hiroyu@jp.fujitsu.com>
	<20100913161309.9d733e6b.kamezawa.hiroyu@jp.fujitsu.com>
	<20100913170151.aef94e26.kamezawa.hiroyu@jp.fujitsu.com>
	<20100913172619.GN17950@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, gthelen@google.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 13 Sep 2010 22:56:19 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-09-13 17:01:51]:
> 
> > 
> > Very sorry, subject was wrong..(reposting).
> > 
> > ==
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > At accounting file events per memory cgroup, we need to find memory cgroup
> > via page_cgroup->mem_cgroup. Now, we use lock_page_cgroup() for guarantee
> > pc->mem_cgroup is not overwritten while we make use of it.
> > 
> > But, considering the context which page-cgroup for files are accessed,
> > we can use alternative light-weight mutual execusion in the most case.
> > 
> > At handling file-caches, the only race we have to take care of is "moving"
> > account, IOW, overwriting page_cgroup->mem_cgroup. 
> > (See comment in the patch)
> > 
> > Unlike charge/uncharge, "move" happens not so frequently. It happens only when
> > rmdir() and task-moving (with a special settings.)
> > This patch adds a race-checker for file-cache-status accounting v.s. account
> > moving. The new per-cpu-per-memcg counter MEM_CGROUP_ON_MOVE is added.
> > The routine for account move 
> >   1. Increment it before start moving
> >   2. Call synchronize_rcu()
> >   3. Decrement it after the end of moving.
> > By this, file-status-counting routine can check it needs to call
> > lock_page_cgroup(). In most case, I doesn't need to call it.
> > 
> > Following is a perf data of a process which mmap()/munmap 32MB of file cache
> > in a minute.
> > 
> > Before patch:
> >     28.25%     mmap  mmap               [.] main
> >     22.64%     mmap  [kernel.kallsyms]  [k] page_fault
> >      9.96%     mmap  [kernel.kallsyms]  [k] mem_cgroup_update_file_mapped
> >      3.67%     mmap  [kernel.kallsyms]  [k] filemap_fault
> >      3.50%     mmap  [kernel.kallsyms]  [k] unmap_vmas
> >      2.99%     mmap  [kernel.kallsyms]  [k] __do_fault
> >      2.76%     mmap  [kernel.kallsyms]  [k] find_get_page
> > 
> > After patch:
> >     30.00%     mmap  mmap               [.] main
> >     23.78%     mmap  [kernel.kallsyms]  [k] page_fault
> >      5.52%     mmap  [kernel.kallsyms]  [k] mem_cgroup_update_file_mapped
> >      3.81%     mmap  [kernel.kallsyms]  [k] unmap_vmas
> >      3.26%     mmap  [kernel.kallsyms]  [k] find_get_page
> >      3.18%     mmap  [kernel.kallsyms]  [k] __do_fault
> >      3.03%     mmap  [kernel.kallsyms]  [k] filemap_fault
> >      2.40%     mmap  [kernel.kallsyms]  [k] handle_mm_fault
> >      2.40%     mmap  [kernel.kallsyms]  [k] do_page_fault
> > 
> > This patch reduces memcg's cost to some extent.
> > (mem_cgroup_update_file_mapped is called by both of map/unmap)
> > 
> > Note: It seems some more improvements are required..but no idea.
> >       maybe removing set/unset flag is required.
> > 
> > Changelog: 20100913
> >  - decoupled with ID patches.
> >  - updated comments.
> > 
> > Changelog: 20100901
> >  - changes id_to_memcg(pc, true) to be id_to_memcg(pc, false)
> >    in update_file_mapped()
> >  - updated comments on lock rule of update_file_mapped()
> > Changelog: 20100825
> >  - added a comment about mc.lock
> >  - fixed bad lock.
> > Changelog: 20100804
> >  - added a comment for possible optimization hint.
> > Changelog: 20100730
> >  - some cleanup.
> > Changelog: 20100729
> >  - replaced __this_cpu_xxx() with this_cpu_xxx
> >    (because we don't call spinlock)
> >  - added VM_BUG_ON().
> > 
> > Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  mm/memcontrol.c |   99 ++++++++++++++++++++++++++++++++++++++++++++++++--------
> >  1 file changed, 85 insertions(+), 14 deletions(-)
> > 
> > Index: lockless-update/mm/memcontrol.c
> > ===================================================================
> > --- lockless-update.orig/mm/memcontrol.c
> > +++ lockless-update/mm/memcontrol.c
> > @@ -90,6 +90,7 @@ enum mem_cgroup_stat_index {
> >  	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
> >  	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
> >  	MEM_CGROUP_EVENTS,	/* incremented at every  pagein/pageout */
> > +	MEM_CGROUP_ON_MOVE,	/* someone is moving account between groups */
> > 
> >  	MEM_CGROUP_STAT_NSTATS,
> >  };
> > @@ -1051,7 +1052,46 @@ static unsigned int get_swappiness(struc
> >  	return swappiness;
> >  }
> > 
> > -/* A routine for testing mem is not under move_account */
> > +static void mem_cgroup_start_move(struct mem_cgroup *mem)
> > +{
> > +	int cpu;
> > +	/* Because this is for moving account, reuse mc.lock */
> > +	spin_lock(&mc.lock);
> > +	for_each_possible_cpu(cpu)
> 
> for_each_possible_cpu() might be too much, no?
> 
> I recommend we use a get_online_cpus()/put_online_cpus() pair
> around the call and optimize.
> 
That makes the patch big, I will have to add cpu hotplug notifier.
If you really want, I'll write an add-on and some clean ups.

And get_online_cpus() requires hotplug notifiers, anyway.

If not using notifier,

	get_onlie_cpus()
	per_cpu(MEM_CGROUP_ON_MOVE) += 1;
	.....do very heavy work, which can sleep.
	per_cpu(MEM_CGROUP_ON_MOVE) -= 1;
	put_online_cpu()

This cannot be justified in mission critical servers.

Now, this code itself is only called at rmdir() and move_task().
Both are very slow.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
