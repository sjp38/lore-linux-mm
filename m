Date: Fri, 22 Feb 2008 09:24:36 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
In-Reply-To: <20080220155049.094056ac.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0802220916290.18145@blonde.site>
References: <20080219215431.1aa9fa8a.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0802191449490.6254@blonde.site> <20080220.152753.98212356.taka@valinux.co.jp>
 <20080220155049.094056ac.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, yamamoto@valinux.co.jp, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Wed, 20 Feb 2008, KAMEZAWA Hiroyuki wrote:
> On Wed, 20 Feb 2008 15:27:53 +0900 (JST)
> Hirokazu Takahashi <taka@valinux.co.jp> wrote:
> 
> > > Unlike the unsafeties of force_empty, this is liable to hit anyone
> > > running with MEM_CONT compiled in, they don't have to be consciously
> > > using mem_cgroups at all.
> > 
> > As for force_empty, though this may not be the main topic here,
> > mem_cgroup_force_empty_list() can be implemented simpler.
> > It is possible to make the function just call mem_cgroup_uncharge_page()
> > instead of releasing page_cgroups by itself. The tips is to call get_page()
> > before invoking mem_cgroup_uncharge_page() so the page won't be released
> > during this function.
> > 
> > Kamezawa-san, you may want look into the attached patch.
> > I think you will be free from the weired complexity here.
> > 
> > This code can be optimized but it will be enough since this function
> > isn't critical.
> > 
> > Thanks.
> > 
> > 
> > Signed-off-by: Hirokazu Takahashi <taka@vallinux.co.jp>

Hirokazu-san, may I change that to <taka@valinux.co.jp>?

>...
>
> Seems simple. But isn't there following case ?
> 
> ==in force_empty==
> 
> pc1 = list_entry(list->prev, struct page_cgroup, lru);
> page = pc1->page;
> get_page(page)
> spin_unlock_irqrestore(&mz->lru_lock, flags)
> mem_cgroup_uncharge_page(page);
> 	=> lock_page_cgroup(page);
> 		=> pc2 = page_get_page_cgroup(page);
> 
> Here, pc2 != pc1 and pc2->mem_cgroup != pc1->mem_cgroup.
> maybe need some check.
> 
> But maybe yours is good direction.

I like Hirokazu-san's approach very much.

Although I eventually completed the locking for my mem_cgroup_move_lists
(SLAB_DESTROY_BY_RCU didn't help there, actually, because it left a
possibility that the same page_cgroup got reused for the same page
but a different mem_cgroup: in which case we got the wrong spinlock),
his reversal in force_empty lets us use straightforward locking in
mem_cgroup_move_lists (though it still has to try_lock_page_cgroup).
So I want to take Hirokazu-san's patch into my bugfix and cleanup
series, where it's testing out fine so far.

Regarding your point above, Kamezawa-san: you're surely right that can
happen, but is it a case that we actually need to avoid?  Aren't we
entitled to take the page out of pc2->mem_cgroup there, because if any
such race occurs, it could easily have happened the other way around,
removing the page from pc1->mem_cgroup just after pc2->mem_cgroup
touched it, so ending up with that page in neither?

I'd just prefer not to handle it as you did in your patch, because
earlier in my series I'd removed the mem_cgroup_uncharge level (which
just gets in the way, requiring a silly lock_page_cgroup at the end
just to match the unlock_page_cgroup at the mem_cgroup_uncharge_page
level), and don't much want to add it back in.

While we're thinking of races...

It seemed to me that mem_cgroup_uncharge should be doing its css_put
after its __mem_cgroup_remove_list: doesn't doing it before leave open
a slight danger that the struct mem_cgroup could be freed before the
remove_list?  Perhaps there's some other refcounting that makes that
impossible, but I've felt safer shifting those around.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
