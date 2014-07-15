Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 661246B0031
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 10:45:47 -0400 (EDT)
Received: by mail-wg0-f49.google.com with SMTP id k14so5103345wgh.32
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 07:45:46 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id k8si3127960wib.17.2014.07.15.07.45.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 15 Jul 2014 07:45:45 -0700 (PDT)
Date: Tue, 15 Jul 2014 10:45:39 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/3] mm: memcontrol: rewrite uncharge API fix - double
 migration
Message-ID: <20140715144539.GR29639@cmpxchg.org>
References: <1404759133-29218-1-git-send-email-hannes@cmpxchg.org>
 <1404759133-29218-3-git-send-email-hannes@cmpxchg.org>
 <alpine.LSU.2.11.1407141246340.17669@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1407141246340.17669@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Hugh,

On Mon, Jul 14, 2014 at 12:57:33PM -0700, Hugh Dickins wrote:
> On Mon, 7 Jul 2014, Johannes Weiner wrote:
> 
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
> > Catch pages that have already been migrated and abort migration
> > gracefully.
> > 
> > Reported-by: Hugh Dickins <hughd@google.com>
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > ---
> >  mm/memcontrol.c | 5 ++++-
> >  1 file changed, 4 insertions(+), 1 deletion(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 1e3b27f8dc2f..e4afdbdda0a7 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -6653,7 +6653,10 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
> >  	if (!PageCgroupUsed(pc))
> >  		return;
> >  
> > -	VM_BUG_ON_PAGE(!(pc->flags & PCG_MEM), oldpage);
> > +	/* Already migrated */
> > +	if (!(pc->flags & PCG_MEM))
> > +		return;
> > +
> 
> I am curious why you chose to fix the BUG in this way, instead of
> -	pc->flags &= ~(PCG_MEM | PCG_MEMSW);
> +	pc->flags = 0;
> a few lines further down.
> 
> The page that gets left behind with just PCG_USED is anomalous (for an
> LRU page, maybe not for a kmem page), isn'it it?  And liable to cause
> other problems.
> 
> For example, won't it go the wrong way in the "Surreptitiously" test
> in mem_cgroup_page_lruvec(): the page no longer has a hold on any
> memcg, so is in a danger of being placed on a gone-memcg's LRU?

I was worried about unusing the page before we have exclusive access
to it (migration_entry_to_page() can still work at this point, though
the current situation seems safe).

But you are right, with the charge belonging to the new page, the old
page no longer pins the memcg and we have to prevent use-after-free.

How about this as a drop-in replacement?

---
