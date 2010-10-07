Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id EE64F6B004A
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 20:54:08 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o970s5t6020361
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 7 Oct 2010 09:54:05 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BE96F45DE57
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 09:54:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 91BC245DE5D
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 09:54:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E7E01DB8044
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 09:54:04 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 83ABE1DB803F
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 09:54:03 +0900 (JST)
Date: Thu, 7 Oct 2010 09:48:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 07/10] memcg: add dirty limits to mem_cgroup
Message-Id: <20101007094845.9e6a1b0f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <xr937hhuj19a.fsf@ninji.mtv.corp.google.com>
References: <1286175485-30643-1-git-send-email-gthelen@google.com>
	<1286175485-30643-8-git-send-email-gthelen@google.com>
	<20101005094302.GA4314@linux.develer.com>
	<xr93eic4wjlq.fsf@ninji.mtv.corp.google.com>
	<20101007091343.82ca9f7d.kamezawa.hiroyu@jp.fujitsu.com>
	<xr937hhuj19a.fsf@ninji.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrea Righi <arighi@develer.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 06 Oct 2010 17:27:13 -0700
Greg Thelen <gthelen@google.com> wrote:

> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:
> 
> > On Tue, 05 Oct 2010 12:00:17 -0700
> > Greg Thelen <gthelen@google.com> wrote:
> >
> >> Andrea Righi <arighi@develer.com> writes:
> >> 
> >> > On Sun, Oct 03, 2010 at 11:58:02PM -0700, Greg Thelen wrote:
> >> >> Extend mem_cgroup to contain dirty page limits.  Also add routines
> >> >> allowing the kernel to query the dirty usage of a memcg.
> >> >> 
> >> >> These interfaces not used by the kernel yet.  A subsequent commit
> >> >> will add kernel calls to utilize these new routines.
> >> >
> >> > A small note below.
> >> >
> >> >> 
> >> >> Signed-off-by: Greg Thelen <gthelen@google.com>
> >> >> Signed-off-by: Andrea Righi <arighi@develer.com>
> >> >> ---
> >> >>  include/linux/memcontrol.h |   44 +++++++++++
> >> >>  mm/memcontrol.c            |  180 +++++++++++++++++++++++++++++++++++++++++++-
> >> >>  2 files changed, 223 insertions(+), 1 deletions(-)
> >> >> 
> >> >> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> >> >> index 6303da1..dc8952d 100644
> >> >> --- a/include/linux/memcontrol.h
> >> >> +++ b/include/linux/memcontrol.h
> >> >> @@ -19,6 +19,7 @@
> >> >>  
> >> >>  #ifndef _LINUX_MEMCONTROL_H
> >> >>  #define _LINUX_MEMCONTROL_H
> >> >> +#include <linux/writeback.h>
> >> >>  #include <linux/cgroup.h>
> >> >>  struct mem_cgroup;
> >> >>  struct page_cgroup;
> >> >> @@ -33,6 +34,30 @@ enum mem_cgroup_write_page_stat_item {
> >> >>  	MEMCG_NR_FILE_UNSTABLE_NFS, /* # of NFS unstable pages */
> >> >>  };
> >> >>  
> >> >> +/* Cgroup memory statistics items exported to the kernel */
> >> >> +enum mem_cgroup_read_page_stat_item {
> >> >> +	MEMCG_NR_DIRTYABLE_PAGES,
> >> >> +	MEMCG_NR_RECLAIM_PAGES,
> >> >> +	MEMCG_NR_WRITEBACK,
> >> >> +	MEMCG_NR_DIRTY_WRITEBACK_PAGES,
> >> >> +};
> >> >> +
> >> >> +/* Dirty memory parameters */
> >> >> +struct vm_dirty_param {
> >> >> +	int dirty_ratio;
> >> >> +	int dirty_background_ratio;
> >> >> +	unsigned long dirty_bytes;
> >> >> +	unsigned long dirty_background_bytes;
> >> >> +};
> >> >> +
> >> >> +static inline void get_global_vm_dirty_param(struct vm_dirty_param *param)
> >> >> +{
> >> >> +	param->dirty_ratio = vm_dirty_ratio;
> >> >> +	param->dirty_bytes = vm_dirty_bytes;
> >> >> +	param->dirty_background_ratio = dirty_background_ratio;
> >> >> +	param->dirty_background_bytes = dirty_background_bytes;
> >> >> +}
> >> >> +
> >> >>  extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
> >> >>  					struct list_head *dst,
> >> >>  					unsigned long *scanned, int order,
> >> >> @@ -145,6 +170,10 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
> >> >>  	mem_cgroup_update_page_stat(page, idx, -1);
> >> >>  }
> >> >>  
> >> >> +bool mem_cgroup_has_dirty_limit(void);
> >> >> +void get_vm_dirty_param(struct vm_dirty_param *param);
> >> >> +s64 mem_cgroup_page_stat(enum mem_cgroup_read_page_stat_item item);
> >> >> +
> >> >>  unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
> >> >>  						gfp_t gfp_mask);
> >> >>  u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
> >> >> @@ -326,6 +355,21 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
> >> >>  {
> >> >>  }
> >> >>  
> >> >> +static inline bool mem_cgroup_has_dirty_limit(void)
> >> >> +{
> >> >> +	return false;
> >> >> +}
> >> >> +
> >> >> +static inline void get_vm_dirty_param(struct vm_dirty_param *param)
> >> >> +{
> >> >> +	get_global_vm_dirty_param(param);
> >> >> +}
> >> >> +
> >> >> +static inline s64 mem_cgroup_page_stat(enum mem_cgroup_read_page_stat_item item)
> >> >> +{
> >> >> +	return -ENOSYS;
> >> >> +}
> >> >> +
> >> >>  static inline
> >> >>  unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
> >> >>  					    gfp_t gfp_mask)
> >> >> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> >> >> index f40839f..6ec2625 100644
> >> >> --- a/mm/memcontrol.c
> >> >> +++ b/mm/memcontrol.c
> >> >> @@ -233,6 +233,10 @@ struct mem_cgroup {
> >> >>  	atomic_t	refcnt;
> >> >>  
> >> >>  	unsigned int	swappiness;
> >> >> +
> >> >> +	/* control memory cgroup dirty pages */
> >> >> +	struct vm_dirty_param dirty_param;
> >> >> +
> >> >>  	/* OOM-Killer disable */
> >> >>  	int		oom_kill_disable;
> >> >>  
> >> >> @@ -1132,6 +1136,172 @@ static unsigned int get_swappiness(struct mem_cgroup *memcg)
> >> >>  	return swappiness;
> >> >>  }
> >> >>  
> >> >> +/*
> >> >> + * Returns a snapshot of the current dirty limits which is not synchronized with
> >> >> + * the routines that change the dirty limits.  If this routine races with an
> >> >> + * update to the dirty bytes/ratio value, then the caller must handle the case
> >> >> + * where both dirty_[background_]_ratio and _bytes are set.
> >> >> + */
> >> >> +static void __mem_cgroup_get_dirty_param(struct vm_dirty_param *param,
> >> >> +					 struct mem_cgroup *mem)
> >> >> +{
> >> >> +	if (mem && !mem_cgroup_is_root(mem)) {
> >> >> +		param->dirty_ratio = mem->dirty_param.dirty_ratio;
> >> >> +		param->dirty_bytes = mem->dirty_param.dirty_bytes;
> >> >> +		param->dirty_background_ratio =
> >> >> +			mem->dirty_param.dirty_background_ratio;
> >> >> +		param->dirty_background_bytes =
> >> >> +			mem->dirty_param.dirty_background_bytes;
> >> >> +	} else {
> >> >> +		get_global_vm_dirty_param(param);
> >> >> +	}
> >> >> +}
> >> >> +
> >> >> +/*
> >> >> + * Get dirty memory parameters of the current memcg or global values (if memory
> >> >> + * cgroups are disabled or querying the root cgroup).
> >> >> + */
> >> >> +void get_vm_dirty_param(struct vm_dirty_param *param)
> >> >> +{
> >> >> +	struct mem_cgroup *memcg;
> >> >> +
> >> >> +	if (mem_cgroup_disabled()) {
> >> >> +		get_global_vm_dirty_param(param);
> >> >> +		return;
> >> >> +	}
> >> >> +
> >> >> +	/*
> >> >> +	 * It's possible that "current" may be moved to other cgroup while we
> >> >> +	 * access cgroup. But precise check is meaningless because the task can
> >> >> +	 * be moved after our access and writeback tends to take long time.  At
> >> >> +	 * least, "memcg" will not be freed under rcu_read_lock().
> >> >> +	 */
> >> >> +	rcu_read_lock();
> >> >> +	memcg = mem_cgroup_from_task(current);
> >> >> +	__mem_cgroup_get_dirty_param(param, memcg);
> >> >> +	rcu_read_unlock();
> >> >> +}
> >> >> +
> >> >> +/*
> >> >> + * Check if current memcg has local dirty limits.  Return true if the current
> >> >> + * memory cgroup has local dirty memory settings.
> >> >> + */
> >> >> +bool mem_cgroup_has_dirty_limit(void)
> >> >> +{
> >> >> +	struct mem_cgroup *mem;
> >> >> +
> >> >> +	if (mem_cgroup_disabled())
> >> >> +		return false;
> >> >> +
> >> >> +	mem = mem_cgroup_from_task(current);
> >> >> +	return mem && !mem_cgroup_is_root(mem);
> >> >> +}
> >> >
> >> > We only check the pointer without dereferencing it, so this is probably
> >> > ok, but maybe this is safer:
> >> >
> >> > bool mem_cgroup_has_dirty_limit(void)
> >> > {
> >> > 	struct mem_cgroup *mem;
> >> > 	bool ret;
> >> >
> >> > 	if (mem_cgroup_disabled())
> >> > 		return false;
> >> >
> >> > 	rcu_read_lock();
> >> > 	mem = mem_cgroup_from_task(current);
> >> > 	ret = mem && !mem_cgroup_is_root(mem);
> >> > 	rcu_read_unlock();
> >> >
> >> > 	return ret;
> >> > }
> >> >
> >> > rcu_read_lock() should be held in mem_cgroup_from_task(), otherwise
> >> > lockdep could detect this as an error.
> >> >
> >> > Thanks,
> >> > -Andrea
> >> 
> >> Good suggestion.  I agree that lockdep might catch this.  There are some
> >> unrelated debug_locks failures (even without my patches) that I worked
> >> around to get lockdep to complain about this one.  I applied your
> >> suggested fix and lockdep was happy.  I will incorporate this fix into
> >> the next revision of the patch series.
> >> 
> >
> > Hmm, considering other parts, shouldn't we define mem_cgroup_from_task
> > as macro ?
> >
> > Thanks,
> > -Kame
> 
> Is your motivation to increase performance with the same functionality?
> If so, then would a 'static inline' be performance equivalent to a
> preprocessor macro yet be safer to use?
> 
Ah, if lockdep finds this as bug, I think other parts will hit this, too.

like this.
> static struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
> {
>         struct mem_cgroup *mem = NULL;
> 
>         if (!mm)
>                 return NULL;
>         /*
>          * Because we have no locks, mm->owner's may be being moved to other
>          * cgroup. We use css_tryget() here even if this looks
>          * pessimistic (rather than adding locks here).
>          */
>         rcu_read_lock();
>         do {
>                 mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
>                 if (unlikely(!mem))
>                         break;
>         } while (!css_tryget(&mem->css));
>         rcu_read_unlock();
>         return mem;
> }

mem_cgroup_from_task() is designed to be used as this.
If defined as macro, I think it will not be catched.


> Maybe it makes more sense to find a way to perform this check in
> mem_cgroup_has_dirty_limit() without needing to grab the rcu lock.  I
> think this lock grab is unneeded.  I am still collecting performance
> data, but suspect that this may be making the code slower than it needs
> to be.
> 

Hmm. css_set[] itself is freed by RCU..what idea to remove rcu_read_lock() do
you have ? Adding some flags ?

Ah...I noticed that you should do

 mem = mem_cgroup_from_task(current->mm->owner);

to check has_dirty_limit...

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
