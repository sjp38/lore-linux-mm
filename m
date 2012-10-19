Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 5139C6B005D
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 09:24:42 -0400 (EDT)
Date: Fri, 19 Oct 2012 15:24:38 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/6] memcg: Simplify mem_cgroup_force_empty_list error
 handling
Message-ID: <20121019132438.GD799@dhcp22.suse.cz>
References: <1350480648-10905-1-git-send-email-mhocko@suse.cz>
 <1350480648-10905-4-git-send-email-mhocko@suse.cz>
 <20121018221654.GP13370@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121018221654.GP13370@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>

On Thu 18-10-12 15:16:54, Tejun Heo wrote:
> Hello, Michal.
> 
> On Wed, Oct 17, 2012 at 03:30:45PM +0200, Michal Hocko wrote:
> > mem_cgroup_force_empty_list currently tries to remove all pages from
> > the given LRU. To prevent from temoporary failures (EBUSY returned by
> > mem_cgroup_move_parent) it uses a margin to the current LRU pages and
> > returns the true if there are still some pages left on the list.
> > 
> > If we consider that mem_cgroup_move_parent fails only when we are racing
> > with somebody else removing the page (resp. uncharging it) or when the
> > page is migrated then it is obvious that all those failures are only
> > temporal and so we can safely retry later.
> > Let's get rid of the safety margin and make the loop really wait for the
> > empty LRU. The caller should still make sure that all charges have been
> > removed from the res_counter because mem_cgroup_replace_page_cache might
> > add a page to the LRU after the check (it doesn't touch res_counter
> > though).
> > This catches most of the cases except for shmem which might call
> > mem_cgroup_replace_page_cache with a page which is not charged and on
> > the LRU yet but this was the case also without this patch. In order to
> > fix this we need a guarantee that try_get_mem_cgroup_from_page falls
> > back to the current mm's cgroup so it needs css_tryget to fail. This
> > will be fixed up in a later patch because it nees a help from cgroup
> > core.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> 
> In the sense that "I looked at it and nothing seemed too scary".
> 
>  Reviewed-by: Tejun Heo <tj@kernel.org>

Thanks

> 
> Some nitpicks below.
> 
> >  /*
> > - * move charges to its parent.
> > + * move charges to its parent or the root cgroup if the group
> > + * has no parent (aka use_hierarchy==0).
> > + * Although this might fail the failure is always temporary and it
> > + * signals a race with a page removal/uncharge or migration. In the
> > + * first case the page will vanish from the LRU on the next attempt
> > + * and the call should be retried later.
> >   */
> > -
> 
> Maybe convert to proper /** function comment while at it?  

these are internal functions and we usually do not create kerneldoc for
them. But I can surely change it - it would deserve a bigger clean up
then.

> I also think it would be helpful to actually comment on each possible
> failure case explaining why the failure condition is temporal.

What about:
"
 * Although this might fail (get_page_unless_zero, isolate_lru_page or
 * mem_cgroup_move_account fails) the failure is always temporary and
 * it signals a race with a page removal/uncharge or migration. In the
 * first case the page is on the way out and it will vanish from the LRU
 * on the next attempt and the call should be retried later.
 * Isolation from the LRU fails only if page has been isolated from
 * the LRU since we looked at it and that usually means either global
 * reclaim or migration going on. The page will either get back to the
 * LRU or vanish.
 * Finaly mem_cgroup_move_account fails only if the page got uncharged
 * (!PageCgroupUsed) or moved to a different group. The page will
 * disappear in the next attempt.
"

Better? Or should it rather be in the changelog?

> 
> >  /*
> >   * Traverse a specified page_cgroup list and try to drop them all.  This doesn't
> > - * reclaim the pages page themselves - it just removes the page_cgroups.
> > - * Returns true if some page_cgroups were not freed, indicating that the caller
> > - * must retry this operation.
> > + * reclaim the pages page themselves - pages are moved to the parent (or root)
> > + * group.
> >   */
> 
> Ditto.
> 
> > -static bool mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
> > +static void mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
> >  				int node, int zid, enum lru_list lru)
> >  {
> >  	struct mem_cgroup_per_zone *mz;
> > -	unsigned long flags, loop;
> > +	unsigned long flags;
> >  	struct list_head *list;
> >  	struct page *busy;
> >  	struct zone *zone;
> > @@ -3696,11 +3701,8 @@ static bool mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
> >  	mz = mem_cgroup_zoneinfo(memcg, node, zid);
> >  	list = &mz->lruvec.lists[lru];
> >  
> > -	loop = mz->lru_size[lru];
> > -	/* give some margin against EBUSY etc...*/
> > -	loop += 256;
> >  	busy = NULL;
> > -	while (loop--) {
> > +	do {
> >  		struct page_cgroup *pc;
> >  		struct page *page;
> >  
> > @@ -3726,8 +3728,7 @@ static bool mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
> >  			cond_resched();
> >  		} else
> >  			busy = NULL;
> > -	}
> > -	return !list_empty(list);
> > +	} while (!list_empty(list));
> >  }
> 
> Is there anything which can keep failing until migration to another
> cgroup is complete?  

This is not about migration to another cgroup. Remember there are no
tasks in the group so we have no origin for the migration. I was talking
about migrate_pages.

> I think there is, e.g., if mmap_sem is busy or memcg is co-mounted
> with other controllers and another controller's ->attach() is blocking
> on something.

I am not sure I understand your concern. There are no tasks and we will
break out the loop if some appear. And yes we can retry a lot in
pathological cases. But this is a group removal path which is not hot.

> If so, busy-looping blindly probably isn't a good idea and we would
> want at least msleep between retries (e.g. have two lists, throw
> failed ones to the other and sleep shortly when switching the front
> and back lists).

we do cond_resched if we fail.

> > +		/*
> > +		 * This is a safety check because mem_cgroup_force_empty_list
> > +		 * could have raced with mem_cgroup_replace_page_cache callers
> > +		 * so the lru seemed empty but the page could have been added
> > +		 * right after the check. RES_USAGE should be safe as we always
> > +		 * charge before adding to the LRU.
> > +		 */
> > +	} while (res_counter_read_u64(&memcg->res, RES_USAGE) > 0);
> 
> Maybe we want to trigger some warning if retry count gets too high?
> At least for now?

We can but is this really worth it?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
