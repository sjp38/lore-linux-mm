Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id A2A526B0031
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 18:16:25 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fb1so60233pad.28
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 15:16:25 -0700 (PDT)
Received: from mail-pd0-x232.google.com (mail-pd0-x232.google.com [2607:f8b0:400e:c02::232])
        by mx.google.com with ESMTPS id bg5si6389177pdb.468.2014.07.15.15.16.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Jul 2014 15:16:24 -0700 (PDT)
Received: by mail-pd0-f178.google.com with SMTP id w10so65233pde.9
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 15:16:24 -0700 (PDT)
Date: Tue, 15 Jul 2014 15:14:42 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [patch 2/3] mm: memcontrol: rewrite uncharge API fix - double
 migration
In-Reply-To: <20140715144539.GR29639@cmpxchg.org>
Message-ID: <alpine.LSU.2.11.1407151509130.5059@eggly.anvils>
References: <1404759133-29218-1-git-send-email-hannes@cmpxchg.org> <1404759133-29218-3-git-send-email-hannes@cmpxchg.org> <alpine.LSU.2.11.1407141246340.17669@eggly.anvils> <20140715144539.GR29639@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 15 Jul 2014, Johannes Weiner wrote:
> On Mon, Jul 14, 2014 at 12:57:33PM -0700, Hugh Dickins wrote:
> > On Mon, 7 Jul 2014, Johannes Weiner wrote:
> > 
> > > Hugh reports:
> > > 
> > > VM_BUG_ON_PAGE(!(pc->flags & PCG_MEM))
> > > mm/memcontrol.c:6680!
> > > page had count 1 mapcount 0 mapping anon index 0x196
> > > flags locked uptodate reclaim swapbacked, pcflags 1, memcg not root
> > > mem_cgroup_migrate < move_to_new_page < migrate_pages < compact_zone <
> > > compact_zone_order < try_to_compact_pages < __alloc_pages_direct_compact <
> > > __alloc_pages_nodemask < alloc_pages_vma < do_huge_pmd_anonymous_page <
> > > handle_mm_fault < __do_page_fault
> > > 
> > > mem_cgroup_migrate() assumes that a page is only migrated once and
> > > then freed immediately after.
> > > 
> > > However, putting the page back on the LRU list and dropping the
> > > isolation refcount is not done atomically.  This allows a PFN-based
> > > migrator like compaction to isolate the page, see the expected
> > > anonymous page refcount of 1, and migrate the page once more.
> > > 
> > > Catch pages that have already been migrated and abort migration
> > > gracefully.
> > > 
> > > Reported-by: Hugh Dickins <hughd@google.com>
> > > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > > ---
> > >  mm/memcontrol.c | 5 ++++-
> > >  1 file changed, 4 insertions(+), 1 deletion(-)
> > > 
> > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > index 1e3b27f8dc2f..e4afdbdda0a7 100644
> > > --- a/mm/memcontrol.c
> > > +++ b/mm/memcontrol.c
> > > @@ -6653,7 +6653,10 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
> > >  	if (!PageCgroupUsed(pc))
> > >  		return;
> > >  
> > > -	VM_BUG_ON_PAGE(!(pc->flags & PCG_MEM), oldpage);
> > > +	/* Already migrated */
> > > +	if (!(pc->flags & PCG_MEM))
> > > +		return;
> > > +
> > 
> > I am curious why you chose to fix the BUG in this way, instead of
> > -	pc->flags &= ~(PCG_MEM | PCG_MEMSW);
> > +	pc->flags = 0;
> > a few lines further down.
> > 
> > The page that gets left behind with just PCG_USED is anomalous (for an
> > LRU page, maybe not for a kmem page), isn'it it?  And liable to cause
> > other problems.
> > 
> > For example, won't it go the wrong way in the "Surreptitiously" test
> > in mem_cgroup_page_lruvec(): the page no longer has a hold on any
> > memcg, so is in a danger of being placed on a gone-memcg's LRU?
> 
> I was worried about unusing the page before we have exclusive access
> to it (migration_entry_to_page() can still work at this point, though
> the current situation seems safe).
> 
> But you are right, with the charge belonging to the new page, the old
> page no longer pins the memcg and we have to prevent use-after-free.
> 
> How about this as a drop-in replacement?

Yes, that looks much better to me, thanks.  I had not realized that the
mem_cgroup_charge_statistics()/memcg_check_events() would also be needed,
but yes, that looks necessary to complement the commit_charge() on the
new page.  I _think_ it should all add up now, but I've certainly not
reviewed thoroughly.

Hugh

> 
> ---
> From 274b94ad83b38fe7dc1707a8eb4015b3ab1673c5 Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Thu, 10 Jul 2014 01:02:11 +0000
> Subject: [patch] mm: memcontrol: rewrite uncharge API fix - double migration
> 
> Hugh reports:
> 
> VM_BUG_ON_PAGE(!(pc->flags & PCG_MEM))
> mm/memcontrol.c:6680!
> page had count 1 mapcount 0 mapping anon index 0x196
> flags locked uptodate reclaim swapbacked, pcflags 1, memcg not root
> mem_cgroup_migrate < move_to_new_page < migrate_pages < compact_zone <
> compact_zone_order < try_to_compact_pages < __alloc_pages_direct_compact <
> __alloc_pages_nodemask < alloc_pages_vma < do_huge_pmd_anonymous_page <
> handle_mm_fault < __do_page_fault
> 
> mem_cgroup_migrate() assumes that a page is only migrated once and
> then freed immediately after.
> 
> However, putting the page back on the LRU list and dropping the
> isolation refcount is not done atomically.  This allows a PFN-based
> migrator like compaction to isolate the page, see the expected
> anonymous page refcount of 1, and migrate the page once more.
> 
> Furthermore, once the charges are transferred to the new page, the old
> page no longer has a pin on the memcg, which might get released before
> the page itself now.  pc->mem_cgroup is invalid at this point, but
> PCG_USED suggests otherwise, provoking use-after-free.
> 
> Properly uncharge the page after it's been migrated, including the
> clearing of PCG_USED, so that a subsequent charge migration attempt
> will be able to detect it and bail out.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Reported-by: Hugh Dickins <hughd@google.com>
> ---
>  mm/memcontrol.c | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 1e3b27f8dc2f..1439537fe7c9 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -6655,7 +6655,6 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
>  
>  	VM_BUG_ON_PAGE(!(pc->flags & PCG_MEM), oldpage);
>  	VM_BUG_ON_PAGE(do_swap_account && !(pc->flags & PCG_MEMSW), oldpage);
> -	pc->flags &= ~(PCG_MEM | PCG_MEMSW);
>  
>  	if (PageTransHuge(oldpage)) {
>  		nr_pages <<= compound_order(oldpage);
> @@ -6663,6 +6662,13 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
>  		VM_BUG_ON_PAGE(!PageTransHuge(newpage), newpage);
>  	}
>  
> +	pc->flags = 0;
> +
> +	local_irq_disable();
> +	mem_cgroup_charge_statistics(pc->mem_cgroup, oldpage, -nr_pages);
> +	memcg_check_events(pc->mem_cgroup, oldpage);
> +	local_irq_enable();
> +
>  	commit_charge(newpage, pc->mem_cgroup, nr_pages, lrucare);
>  }
>  
> -- 
> 2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
