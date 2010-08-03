Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 557586008E4
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 23:40:04 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o733iRNc018988
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 3 Aug 2010 12:44:29 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C32E545DE4F
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 12:44:27 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9805045DE4E
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 12:44:27 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7CBEE1DB8037
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 12:44:27 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 376671DB8038
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 12:44:27 +0900 (JST)
Date: Tue, 3 Aug 2010 12:39:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mm 3/5] memcg scalable file stat accounting method
Message-Id: <20100803123934.3aea00cc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100803033327.GD3863@balbir.in.ibm.com>
References: <20100802191113.05c982e4.kamezawa.hiroyu@jp.fujitsu.com>
	<20100802191559.6af0cded.kamezawa.hiroyu@jp.fujitsu.com>
	<20100803033327.GD3863@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, vgoyal@redhat.com, m-ikeda@ds.jp.nec.com, gthelen@google.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Aug 2010 09:03:27 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-08-02 19:15:59]:
> 
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > At accounting file events per memory cgroup, we need to find memory cgroup
> > via page_cgroup->mem_cgroup. Now, we use lock_page_cgroup().
> > 
> > But, considering the context which page-cgroup for files are accessed,
> > we can use alternative light-weight mutual execusion in the most case.
> > At handling file-caches, the only race we have to take care of is "moving"
> > account, IOW, overwriting page_cgroup->mem_cgroup. Because file status
> > update is done while the page-cache is in stable state, we don't have to
> > take care of race with charge/uncharge.
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
> > 
> > Changelog: 20100730
> >  - some cleanup.
> > Changelog: 20100729
> >  - replaced __this_cpu_xxx() with this_cpu_xxx
> >    (because we don't call spinlock)
> >  - added VM_BUG_ON().
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  mm/memcontrol.c |   78 +++++++++++++++++++++++++++++++++++++++++++++++---------
> >  1 file changed, 66 insertions(+), 12 deletions(-)
> > 
> > Index: mmotm-0727/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-0727.orig/mm/memcontrol.c
> > +++ mmotm-0727/mm/memcontrol.c
> > @@ -88,6 +88,7 @@ enum mem_cgroup_stat_index {
> >  	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
> >  	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
> >  	MEM_CGROUP_EVENTS,	/* incremented at every  pagein/pageout */
> > +	MEM_CGROUP_ON_MOVE,   /* A check for locking move account/status */
> > 
> >  	MEM_CGROUP_STAT_NSTATS,
> >  };
> > @@ -1074,7 +1075,49 @@ static unsigned int get_swappiness(struc
> >  	return swappiness;
> >  }
> > 
> > -/* A routine for testing mem is not under move_account */
> > +static void mem_cgroup_start_move(struct mem_cgroup *mem)
> > +{
> > +	int cpu;
> > +	/* for fast checking in mem_cgroup_update_file_stat() etc..*/
> > +	spin_lock(&mc.lock);
> > +	for_each_possible_cpu(cpu)
> > +		per_cpu(mem->stat->count[MEM_CGROUP_ON_MOVE], cpu) += 1;
> 
> Is for_each_possible really required? Won't online cpus suffice? There
> can be a race if a hotplug event happens between start and end move,
> shouldn't we handle that. My concern is that with something like 1024
> cpus possible today, we might need to optimize this further.
> 
yes. I have the same concern. But I don't have any justification to disable
cpu hotplug while moving pages , it may take several msec.

> May be we can do this first and optimize later.
> 
Maybe. For now, cpu-hotplug event hanlder tend to be a noise for this patch.
I would like to do it later.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
