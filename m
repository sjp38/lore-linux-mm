Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id 0667E6B0031
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 11:09:48 -0400 (EDT)
Received: by mail-we0-f175.google.com with SMTP id k48so5646081wev.6
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 08:09:48 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id vn7si20249893wjc.45.2014.07.15.08.09.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 15 Jul 2014 08:09:47 -0700 (PDT)
Date: Tue, 15 Jul 2014 11:09:37 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 13/13] mm: memcontrol: rewrite uncharge API
Message-ID: <20140715150937.GS29639@cmpxchg.org>
References: <1403124045-24361-1-git-send-email-hannes@cmpxchg.org>
 <1403124045-24361-14-git-send-email-hannes@cmpxchg.org>
 <20140715082545.GA9366@dhcp22.suse.cz>
 <20140715142350.GD9366@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140715142350.GD9366@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Jul 15, 2014 at 04:23:50PM +0200, Michal Hocko wrote:
> On Tue 15-07-14 10:25:45, Michal Hocko wrote:
> [...]
> > diff --git a/Documentation/cgroups/memcg_test.txt b/Documentation/cgroups/memcg_test.txt
> > index bcf750d3cecd..8870b0212150 100644
> > --- a/Documentation/cgroups/memcg_test.txt
> > +++ b/Documentation/cgroups/memcg_test.txt
> [...]
> >  6. Shmem(tmpfs) Page Cache
> > -	Memcg's charge/uncharge have special handlers of shmem. The best way
> > -	to understand shmem's page state transition is to read mm/shmem.c.
> > +	The best way to understand shmem's page state transition is to read
> > +	mm/shmem.c.
> 
> :D
> 
> [...]
> >  7. Page Migration
> > -   	One of the most complicated functions is page-migration-handler.
> > -	Memcg has 2 routines. Assume that we are migrating a page's contents
> > -	from OLDPAGE to NEWPAGE.
> > -
> > -	Usual migration logic is..
> > -	(a) remove the page from LRU.
> > -	(b) allocate NEWPAGE (migration target)
> > -	(c) lock by lock_page().
> > -	(d) unmap all mappings.
> > -	(e-1) If necessary, replace entry in radix-tree.
> > -	(e-2) move contents of a page.
> > -	(f) map all mappings again.
> > -	(g) pushback the page to LRU.
> > -	(-) OLDPAGE will be freed.
> > -
> > -	Before (g), memcg should complete all necessary charge/uncharge to
> > -	NEWPAGE/OLDPAGE.
> > -
> > -	The point is....
> > -	- If OLDPAGE is anonymous, all charges will be dropped at (d) because
> > -          try_to_unmap() drops all mapcount and the page will not be
> > -	  SwapCache.
> > -
> > -	- If OLDPAGE is SwapCache, charges will be kept at (g) because
> > -	  __delete_from_swap_cache() isn't called at (e-1)
> > -
> > -	- If OLDPAGE is page-cache, charges will be kept at (g) because
> > -	  remove_from_swap_cache() isn't called at (e-1)
> > -
> > -	memcg provides following hooks.
> > -
> > -	- mem_cgroup_prepare_migration(OLDPAGE)
> > -	  Called after (b) to account a charge (usage += PAGE_SIZE) against
> > -	  memcg which OLDPAGE belongs to.
> > -
> > -        - mem_cgroup_end_migration(OLDPAGE, NEWPAGE)
> > -	  Called after (f) before (g).
> > -	  If OLDPAGE is used, commit OLDPAGE again. If OLDPAGE is already
> > -	  charged, a charge by prepare_migration() is automatically canceled.
> > -	  If NEWPAGE is used, commit NEWPAGE and uncharge OLDPAGE.
> > -
> > -	  But zap_pte() (by exit or munmap) can be called while migration,
> > -	  we have to check if OLDPAGE/NEWPAGE is a valid page after commit().
> > +
> > +	mem_cgroup_migrate()
> 
> This doesn't tell us anything abouta the page migration. On the other
> hand I am not entirely sure the documentation here is very much helpful.
> There is some outdated information. I wouldn't be opposed to remove
> everything up to "9. Typical Tests." section which should be the primary
> target of the file anyway.

Yeah, documentation of the implementation should be directly in the
source code and this file is kind of pointless.  So all I did there
was remove things that were wrong after my changes.  But I agree it
can probably be removed completely.

> > @@ -382,9 +382,13 @@ static inline int mem_cgroup_swappiness(struct mem_cgroup *mem)
> >  }
> >  #endif
> >  #ifdef CONFIG_MEMCG_SWAP
> > -extern void mem_cgroup_uncharge_swap(swp_entry_t ent);
> > +extern void mem_cgroup_swapout(struct page *page, swp_entry_t entry);
> > +extern void mem_cgroup_uncharge_swap(swp_entry_t entry);
> 
> Wouldn't it be nicer to have those two with symmetric names?
> mem_cgroup_{un}charge_swap?

I thought about that when I wrote them, but their operation is not
actually symmetrical.  The first one migrates a memsw charge from a
page to a swap entry when the page gets reclaimed - rather than when
the swap entry is allocated, the second one uncharges the swap entry
once the swap entry is released.

> > @@ -2760,15 +2752,15 @@ static void commit_charge(struct page *page, struct mem_cgroup *memcg,
> >  		spin_unlock_irq(&zone->lru_lock);
> >  	}
> >  
> > -	mem_cgroup_charge_statistics(memcg, page, anon, nr_pages);
> > -	unlock_page_cgroup(pc);
> > -
> > +	local_irq_disable();
> > +	mem_cgroup_charge_statistics(memcg, page, nr_pages);
> >  	/*
> >  	 * "charge_statistics" updated event counter. Then, check it.
> >  	 * Insert ancestor (and ancestor's ancestors), to softlimit RB-tree.
> >  	 * if they exceeds softlimit.
> >  	 */
> >  	memcg_check_events(memcg, page);
> > +	local_irq_enable();
> 
> preempt_{enable,disbale} should be sufficient for
> mem_cgroup_charge_statistics and memcg_check_events no?
> The first one is about per-cpu accounting (and that should be atomic
> wrt. IRQ on the same CPU) and the later one uses IRQ safe locks down in
> mem_cgroup_update_tree.

How could it be atomic wrt. IRQ on the local CPU when IRQs that modify
the counters can fire on the local CPU?

> > @@ -780,11 +780,14 @@ static int move_to_new_page(struct page *newpage, struct page *page,
> >  		rc = fallback_migrate_page(mapping, newpage, page, mode);
> >  
> >  	if (rc != MIGRATEPAGE_SUCCESS) {
> > -		newpage->mapping = NULL;
> > +		if (!PageAnon(newpage))
> > +			newpage->mapping = NULL;
> 
> OK, I am probably washed out from looking into this for too long but I
> cannot figure why have you done this...

mem_cgroup_uncharge() relies on PageAnon() working.  Usually, anon
pages retain their page->mapping until they hit the page allocator,
the exception was old migration pages.

> >  	} else {
> > +		mem_cgroup_migrate(page, newpage, false);
> >  		if (remap_swapcache)
> >  			remove_migration_ptes(page, newpage);
> > -		page->mapping = NULL;
> > +		if (!PageAnon(page))
> > +			page->mapping = NULL;
> >  	}
> >  
> >  	unlock_page(newpage);
> 
> [...]
> 
> The semantic is much cleaner now. I have to digest details about the
> patch because it is really huge. But nothing really jumped at me during
> the review (except for few minor things mentioned here and one mentioned
> in other email regarding USED flag).
> 
> Good work! 

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
