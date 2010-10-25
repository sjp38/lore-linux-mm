Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E83DC8D0015
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 03:14:01 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9P7Dxsb024861
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 25 Oct 2010 16:13:59 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E426545DE52
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 16:13:58 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C471245DE50
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 16:13:58 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AA961E18002
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 16:13:58 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4758DE08001
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 16:13:58 +0900 (JST)
Date: Mon, 25 Oct 2010 16:08:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v2][memcg+dirtylimit] Fix  overwriting global vm dirty
 limit setting by memcg (Re: [PATCH v3 00/11] memcg: per cgroup dirty page
 accounting
Message-Id: <20101025160826.3889328c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4CC52BBB.8010407@linux.vnet.ibm.com>
References: <1287448784-25684-1-git-send-email-gthelen@google.com>
	<20101020122144.47f2b60b.kamezawa.hiroyu@jp.fujitsu.com>
	<20101020140255.5b8afb63.kamezawa.hiroyu@jp.fujitsu.com>
	<xr937hh7sa5l.fsf@ninji.mtv.corp.google.com>
	<4CC52BBB.8010407@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ciju Rajan K <ciju@linux.vnet.ibm.com>
Cc: Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Mon, 25 Oct 2010 12:33:23 +0530
Ciju Rajan K <ciju@linux.vnet.ibm.com> wrote:

> Greg Thelen wrote:
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:
> >
> >   
> >> Fixed one here.
> >> ==
> >> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >>
> >> Now, at calculating dirty limit, vm_dirty_param() is called.
> >> This function returns dirty-limit related parameters considering
> >> memory cgroup settings.
> >>
> >> Now, assume that vm_dirty_bytes=100M (global dirty limit) and
> >> memory cgroup has 1G of pages and 40 dirty_ratio, dirtyable memory is
> >> 500MB.
> >>
> >> In this case, global_dirty_limits will consider dirty_limt as
> >> 500 *0.4 = 200MB. This is bad...memory cgroup is not back door.
> >>
> >> This patch limits the return value of vm_dirty_param() considring
> >> global settings.
> >>
> >> Changelog:
> >>  - fixed an argument "mem" int to u64
> >>  - fixed to use global available memory to cap memcg's value.
> >>
> >> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >> ---
> >>  include/linux/memcontrol.h |    5 +++--
> >>  mm/memcontrol.c            |   30 +++++++++++++++++++++++++++++-
> >>  mm/page-writeback.c        |    3 ++-
> >>  3 files changed, 34 insertions(+), 4 deletions(-)
> >>
> >> Index: dirty_limit_new/mm/memcontrol.c
> >> ===================================================================
> >> --- dirty_limit_new.orig/mm/memcontrol.c
> >> +++ dirty_limit_new/mm/memcontrol.c
> >> @@ -1171,9 +1171,11 @@ static void __mem_cgroup_dirty_param(str
> >>   * can be moved after our access and writeback tends to take long time.  At
> >>   * least, "memcg" will not be freed while holding rcu_read_lock().
> >>   */
> >> -void vm_dirty_param(struct vm_dirty_param *param)
> >> +void vm_dirty_param(struct vm_dirty_param *param,
> >> +	 u64 mem, u64 global)
> >>  {
> >>  	struct mem_cgroup *memcg;
> >> +	u64 limit, bglimit;
> >>  
> >>  	if (mem_cgroup_disabled()) {
> >>  		global_vm_dirty_param(param);
> >> @@ -1183,6 +1185,32 @@ void vm_dirty_param(struct vm_dirty_para
> >>  	rcu_read_lock();
> >>  	memcg = mem_cgroup_from_task(current);
> >>  	__mem_cgroup_dirty_param(param, memcg);
> >> +	/*
> >> +	 * A limitation under memory cgroup is under global vm, too.
> >> +	 */
> >> +	if (vm_dirty_ratio)
> >> +		limit = global * vm_dirty_ratio / 100;
> >> +	else
> >> +		limit = vm_dirty_bytes;
> >> +	if (param->dirty_ratio) {
> >> +		param->dirty_bytes = mem * param->dirty_ratio / 100;
> >> +		param->dirty_ratio = 0;
> >> +	}
> >> +	if (param->dirty_bytes > limit)
> >> +		param->dirty_bytes = limit;
> >> +
> >> +	if (dirty_background_ratio)
> >> +		bglimit = global * dirty_background_ratio / 100;
> >> +	else
> >> +		bglimit = dirty_background_bytes;
> >> +
> >> +	if (param->dirty_background_ratio) {
> >> +		param->dirty_background_bytes =
> >> +			mem * param->dirty_background_ratio / 100;
> >> +		param->dirty_background_ratio = 0;
> >> +	}
> >> +	if (param->dirty_background_bytes > bglimit)
> >> +		param->dirty_background_bytes = bglimit;
> >>  	rcu_read_unlock();
> >>  }
> >>  
> >> Index: dirty_limit_new/include/linux/memcontrol.h
> >> ===================================================================
> >> --- dirty_limit_new.orig/include/linux/memcontrol.h
> >> +++ dirty_limit_new/include/linux/memcontrol.h
> >> @@ -171,7 +171,7 @@ static inline void mem_cgroup_dec_page_s
> >>  }
> >>  
> >>  bool mem_cgroup_has_dirty_limit(void);
> >> -void vm_dirty_param(struct vm_dirty_param *param);
> >> +void vm_dirty_param(struct vm_dirty_param *param, u64 mem, u64 global);
> >>  s64 mem_cgroup_page_stat(enum mem_cgroup_nr_pages_item item);
> >>  
> >>  unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
> >> @@ -360,7 +360,8 @@ static inline bool mem_cgroup_has_dirty_
> >>  	return false;
> >>  }
> >>  
> >> -static inline void vm_dirty_param(struct vm_dirty_param *param)
> >> +static inline void vm_dirty_param(struct vm_dirty_param *param,
> >> +		u64 mem, u64 global)
> >>  {
> >>  	global_vm_dirty_param(param);
> >>  }
> >> Index: dirty_limit_new/mm/page-writeback.c
> >> ===================================================================
> >> --- dirty_limit_new.orig/mm/page-writeback.c
> >> +++ dirty_limit_new/mm/page-writeback.c
> >> @@ -466,7 +466,8 @@ void global_dirty_limits(unsigned long *
> >>  	struct task_struct *tsk;
> >>  	struct vm_dirty_param dirty_param;
> >>  
> >> -	vm_dirty_param(&dirty_param);
> >> +	vm_dirty_param(&dirty_param,
> >> +		available_memory, global_dirtyable_memory());
> >>  
> >>  	if (dirty_param.dirty_bytes)
> >>  		dirty = DIV_ROUND_UP(dirty_param.dirty_bytes, PAGE_SIZE);
> >>     
> >
> > I think there is a problem with the patch above.  In the patch
> > vm_dirty_param() sets param->dirty_[background_]bytes to the smallest
> > limits considering the memcg and global limits.  Assuming the current
> > task is in a memcg, then the memcg dirty (not system-wide) usage is
> > always compared to the selected limits (which may be per-memcg or
> > system).  The problem is that if:
> > a) per-memcg dirty limit is smaller than system then vm_dirty_param()
> >    will select per-memcg dirty limit, and
> > b) per-memcg dirty usage is well below memcg dirty limit, and
> > b) system usage is at system limit
> > Then the above patch will not trigger writeback.  Example with two
> > memcg:
> >          sys
> >         B   C
> >       
> >       limit  usage
> >   sys  10     10
> >    B    7      6
> >    C    5      4
> >
> > If B wants to grow, the system will exceed system limit of 10 and should
> > be throttled.  However, the smaller limit (7) will be selected and
> > applied to memcg usage (6), which indicates no need to throttle, so the
> > system could get as bad as:
> >
> >       limit  usage
> >   sys  10     12
> >    B    7      7
> >    C    5      5
> >
> > In this case the system usage exceeds the system limit because each
> > the per-memcg checks see no per-memcg problems.
> >
> >   
> What about the following scenarios?
> a) limit usage
> sys 9 7
> B 8 6
> A 4 1
> Now assume B consumes 2 more. The total of B reaches 8 (memcg max) and 
> the system total reaches 9 (Global limit).
> The scenario will be like this.
> 
> limit usage
> sys 9 9
> B 8 8
> A 4 1
> 
> In this case, group A is not getting a fair chance to utilize its limit.
> Do we need to consider this case also?
> 

IMHO, it's admin's job to make the limitation fair.
In general, all cgroups should use the same dirty_ratio for getting fairness.

> b) Even though we are defining per cgroup dirty limit, it is not 
> actually the case.
> Is it indirectly dependent on the the total system wide limit in this 
> implementation?
> 
Yes, it should be. memory cgroup isn't a backdoor to break system's control.

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
