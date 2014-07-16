Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id CA5EC6B00B8
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 12:04:20 -0400 (EDT)
Received: by mail-wg0-f51.google.com with SMTP id b13so1157942wgh.10
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 09:04:20 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id he9si3994487wib.100.2014.07.16.09.04.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 16 Jul 2014 09:04:19 -0700 (PDT)
Date: Wed, 16 Jul 2014 12:04:14 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/3] mm: memcontrol: rewrite uncharge API fix - double
 migration
Message-ID: <20140716160414.GA29639@cmpxchg.org>
References: <1404759133-29218-1-git-send-email-hannes@cmpxchg.org>
 <1404759133-29218-3-git-send-email-hannes@cmpxchg.org>
 <alpine.LSU.2.11.1407141246340.17669@eggly.anvils>
 <20140715144539.GR29639@cmpxchg.org>
 <20140716083456.GC7121@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140716083456.GC7121@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jul 16, 2014 at 10:34:56AM +0200, Michal Hocko wrote:
> [Sorry I have missed this thread]
> 
> On Tue 15-07-14 10:45:39, Johannes Weiner wrote:
> [...]
> > From 274b94ad83b38fe7dc1707a8eb4015b3ab1673c5 Mon Sep 17 00:00:00 2001
> > From: Johannes Weiner <hannes@cmpxchg.org>
> > Date: Thu, 10 Jul 2014 01:02:11 +0000
> > Subject: [patch] mm: memcontrol: rewrite uncharge API fix - double migration
> > 
> > Hugh reports:
> > 
> > VM_BUG_ON_PAGE(!(pc->flags & PCG_MEM))
> > mm/memcontrol.c:6680!
> > page had count 1 mapcount 0 mapping anon index 0x196
> > flags locked uptodate reclaim swapbacked, pcflags 1, memcg not root
> > mem_cgroup_migrate < move_to_new_page < migrate_pages < compact_zone <
> > compact_zone_order < try_to_compact_pages < __alloc_pages_direct_compact <
> > __alloc_pages_nodemask < alloc_pages_vma < do_huge_pmd_anonymous_page <
> > handle_mm_fault < __do_page_fault
> > 
> > mem_cgroup_migrate() assumes that a page is only migrated once and
> > then freed immediately after.
> > 
> > However, putting the page back on the LRU list and dropping the
> > isolation refcount is not done atomically.  This allows a PFN-based
> > migrator like compaction to isolate the page, see the expected
> > anonymous page refcount of 1, and migrate the page once more.
> > 
> > Furthermore, once the charges are transferred to the new page, the old
> > page no longer has a pin on the memcg, which might get released before
> > the page itself now.  pc->mem_cgroup is invalid at this point, but
> > PCG_USED suggests otherwise, provoking use-after-free.
> 
> The same applies to to the new page because we are transferring only
> statistics. The old page with PCG_USED would uncharge the res_counter
> and so the new page is not backed by any and so memcg can go away.
> This sounds like a more probable scenario to me because old page should
> go away quite early after successful migration.

No, the charges are carried by PCG_MEM and PCG_MEMSW, not PCG_USED.

> > Properly uncharge the page after it's been migrated, including the
> > clearing of PCG_USED, so that a subsequent charge migration attempt
> > will be able to detect it and bail out.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > Reported-by: Hugh Dickins <hughd@google.com>
> > ---
> >  mm/memcontrol.c | 8 +++++++-
> >  1 file changed, 7 insertions(+), 1 deletion(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 1e3b27f8dc2f..1439537fe7c9 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -6655,7 +6655,6 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
> >  
> >  	VM_BUG_ON_PAGE(!(pc->flags & PCG_MEM), oldpage);
> >  	VM_BUG_ON_PAGE(do_swap_account && !(pc->flags & PCG_MEMSW), oldpage);
> > -	pc->flags &= ~(PCG_MEM | PCG_MEMSW);
> >  
> >  	if (PageTransHuge(oldpage)) {
> >  		nr_pages <<= compound_order(oldpage);
> > @@ -6663,6 +6662,13 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
> >  		VM_BUG_ON_PAGE(!PageTransHuge(newpage), newpage);
> >  	}
> >  
> > +	pc->flags = 0;
> > +
> > +	local_irq_disable();
> > +	mem_cgroup_charge_statistics(pc->mem_cgroup, oldpage, -nr_pages);
> > +	memcg_check_events(pc->mem_cgroup, oldpage);
> > +	local_irq_enable();
> > +
> >  	commit_charge(newpage, pc->mem_cgroup, nr_pages, lrucare);
> >  }
> 
> Looks good to me. I am just wondering whether we should really
> fiddle with stats and events when actually nothing changed during
> the transition. I would simply extract core of commit_charge into
> __commit_charge which would be called from here.
> 
> The impact is minimal because events are rate limited and stats are
> per-cpu so it is not a big deal it just looks ugly to me.

Agreed.  This is the minimal change to get it functionally right (we
are already at -rc5), it can always be optimized later.  I'll send a
patch soon.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
