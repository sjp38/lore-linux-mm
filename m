Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 5799F6B004A
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 07:22:59 -0500 (EST)
Date: Tue, 28 Feb 2012 13:22:50 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 4/6] memcg: use new logic for page stat accounting.
Message-ID: <20120228122250.GB1702@cmpxchg.org>
References: <20120217182426.86aebfde.kamezawa.hiroyu@jp.fujitsu.com>
 <20120217182743.2d5f629e.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120217182743.2d5f629e.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>

On Fri, Feb 17, 2012 at 06:27:43PM +0900, KAMEZAWA Hiroyuki wrote:
> >From 5bf592d432e4552db74e94a575afcd83aa652a9d Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Thu, 2 Feb 2012 11:49:59 +0900
> Subject: [PATCH 4/6] memcg: use new logic for page stat accounting.
> 
> Now, page-stat-per-memcg is recorded into per page_cgroup flag by
> duplicating page's status into the flag. The reason is that memcg
> has a feature to move a page from a group to another group and we
> have race between "move" and "page stat accounting",
> 
> Under current logic, assume CPU-A and CPU-B. CPU-A does "move"
> and CPU-B does "page stat accounting".
> 
> When CPU-A goes 1st,
> 
>             CPU-A                           CPU-B
>                                     update "struct page" info.
>     move_lock_mem_cgroup(memcg)
>     see pc->flags
>     copy page stat to new group
>     overwrite pc->mem_cgroup.
>     move_unlock_mem_cgroup(memcg)
>                                     move_lock_mem_cgroup(mem)
>                                     set pc->flags
>                                     update page stat accounting
>                                     move_unlock_mem_cgroup(mem)
> 
> stat accounting is guarded by move_lock_mem_cgroup() and "move"
> logic (CPU-A) doesn't see changes in "struct page" information.
> 
> But it's costly to have the same information both in 'struct page' and
> 'struct page_cgroup'. And, there is a potential problem.
> 
> For example, assume we have PG_dirty accounting in memcg.
> PG_..is a flag for struct page.
> PCG_ is a flag for struct page_cgroup.
> (This is just an example. The same problem can be found in any
>  kind of page stat accounting.)
> 
> 	  CPU-A                               CPU-B
>       TestSet PG_dirty
>       (delay)                        TestClear PG_dirty
>                                      if (TestClear(PCG_dirty))
>                                           memcg->nr_dirty--
>       if (TestSet(PCG_dirty))
>           memcg->nr_dirty++
> 
> Here, memcg->nr_dirty = +1, this is wrong.
> This race was reported by  Greg Thelen <gthelen@google.com>.
> Now, only FILE_MAPPED is supported but fortunately, it's serialized by
> page table lock and this is not real bug, _now_,
> 
> If this potential problem is caused by having duplicated information in
> struct page and struct page_cgroup, we may be able to fix this by using
> original 'struct page' information.
> But we'll have a problem in "move account"
> 
> Assume we use only PG_dirty.
> 
>          CPU-A                   CPU-B
>     TestSet PG_dirty
>     (delay)                    move_lock_mem_cgroup()
>                                if (PageDirty(page))
>                                       new_memcg->nr_dirty++
>                                pc->mem_cgroup = new_memcg;
>                                move_unlock_mem_cgroup()
>     move_lock_mem_cgroup()
>     memcg = pc->mem_cgroup
>     new_memcg->nr_dirty++
> 
> accounting information may be double-counted. This was original
> reason to have PCG_xxx flags but it seems PCG_xxx has another problem.
> 
> I think we need a bigger lock as
> 
>      move_lock_mem_cgroup(page)
>      TestSetPageDirty(page)
>      update page stats (without any checks)
>      move_unlock_mem_cgroup(page)
> 
> This fixes both of problems and we don't have to duplicate page flag
> into page_cgroup. Please note: move_lock_mem_cgroup() is held
> only when there are possibility of "account move" under the system.
> So, in most path, status update will go without atomic locks.
> 
> This patch introduce mem_cgroup_begin_update_page_stat() and
> mem_cgroup_end_update_page_stat() both should be called at modifying
> 'struct page' information if memcg takes care of it. as
> 
>      mem_cgroup_begin_update_page_stat()
>      modify page information
>      mem_cgroup_update_page_stat()
>      => never check any 'struct page' info, just update counters.
>      mem_cgroup_end_update_page_stat().
> 
> This patch is slow because we need to call begin_update_page_stat()/
> end_update_page_stat() regardless of accounted will be changed or not.
> A following patch adds an easy optimization and reduces the cost.
> 
> Changes since v4
>  - removed unused argument *lock
>  - added more comments.
> Changes since v3
>  - fixed typos
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
