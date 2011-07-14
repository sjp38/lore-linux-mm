Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5C9556B004A
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 08:56:04 -0400 (EDT)
Date: Thu, 14 Jul 2011 14:55:55 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2] memcg: make oom_lock 0 and 1 based rather than
 coutner
Message-ID: <20110714125555.GA27954@tiehlicka.suse.cz>
References: <50d526ee242916bbfb44b9df4474df728c4892c6.1310561078.git.mhocko@suse.cz>
 <20110714100259.cedbf6af.kamezawa.hiroyu@jp.fujitsu.com>
 <20110714115913.cf8d1b9d.kamezawa.hiroyu@jp.fujitsu.com>
 <20110714090017.GD19408@tiehlicka.suse.cz>
 <20110714183014.8b15e9b9.kamezawa.hiroyu@jp.fujitsu.com>
 <20110714095152.GG19408@tiehlicka.suse.cz>
 <20110714191728.058859cd.kamezawa.hiroyu@jp.fujitsu.com>
 <20110714110935.GK19408@tiehlicka.suse.cz>
 <20110714113009.GL19408@tiehlicka.suse.cz>
 <20110714205012.8b78691e.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110714205012.8b78691e.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org

On Thu 14-07-11 20:50:12, KAMEZAWA Hiroyuki wrote:
> On Thu, 14 Jul 2011 13:30:09 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
[...]
> >  static bool mem_cgroup_oom_lock(struct mem_cgroup *mem)
> >  {
> > -	int x, lock_count = 0;
> > -	struct mem_cgroup *iter;
> > +	int x, lock_count = -1;
> > +	struct mem_cgroup *iter, *failed = NULL;
> > +	bool cond = true;
> >  
> > -	for_each_mem_cgroup_tree(iter, mem) {
> > -		x = atomic_inc_return(&iter->oom_lock);
> > -		lock_count = max(x, lock_count);
> > +	for_each_mem_cgroup_tree_cond(iter, mem, cond) {
> > +		x = !!atomic_add_unless(&iter->oom_lock, 1, 1);
> > +		if (lock_count == -1)
> > +			lock_count = x;
> > +		else if (lock_count != x) {
> > +			/*
> > +			 * this subtree of our hierarchy is already locked
> > +			 * so we cannot give a lock.
> > +			 */
> > +			lock_count = 0;
> > +			failed = iter;
> > +			cond = false;
> > +		}
> >  	}
> 
> Hm ? assuming B-C-D is locked and a new thread tries a lock on A-B-C-D-E.
> And for_each_mem_cgroup_tree will find groups in order of A->B->C->D->E.
> Before lock
>   A  0
>   B  1
>   C  1
>   D  1
>   E  0
> 
> After lock
>   A  1
>   B  1
>   C  1
>   D  1
>   E  0
> 
> here, failed = B, cond = false. Undo routine will unlock A.
> Hmm, seems to work in this case.
> 
> But....A's oom_lock==0 and memcg_oom_wakeup() at el will not able to
> know "A" is in OOM. wakeup processes in A which is waiting for oom recover..

Hohm, we need to have 2 different states. lock and mark_oom.
oom_recovert would check only the under_oom.

> 
> Will this work ?

No it won't because the rest of the world has no idea that A is
under_oom as well.

> ==
>  # cgcreate -g memory:A
>  # cgset -r memory.use_hierarchy=1 A
>  # cgset -r memory.oom_control=1   A
>  # cgset -r memory.limit_in_bytes= 100M
>  # cgset -r memory.memsw.limit_in_bytes= 100M
>  # cgcreate -g memory:A/B
>  # cgset -r memory.oom_control=1 A/B
>  # cgset -r memory.limit_in_bytes=20M
>  # cgset -r memory.memsw.limit_in_bytes=20M
> 
>  Assume malloc XXX is a program allocating XXX Megabytes of memory.
> 
>  # cgexec -g memory:A/B malloc 30  &    #->this will be blocked by OOM of group B
>  # cgexec -g memory:A   malloc 80  &    #->this will be blocked by OOM of group A
> 
> 
> Here, 2 procs are blocked by OOM. Here, relax A's limitation and clear OOM.
> 
>  # cgset -r memory.memsw.limit_in_bytes=300M A
>  # cgset -r memory.limit_in_bytes=300M A
> 
>  malloc 80 will end.

What about yet another approach? Very similar what you proposed, I
guess. Again not tested and needs some cleanup just to illustrate.
What do you think?
--- 
