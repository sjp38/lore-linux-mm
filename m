Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 5118B6B00AA
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 10:15:21 -0400 (EDT)
Received: by mail-wi0-f182.google.com with SMTP id d1so1378463wiv.3
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 07:15:18 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id pk8si24196865wjc.2.2014.07.16.07.15.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 16 Jul 2014 07:15:16 -0700 (PDT)
Date: Wed, 16 Jul 2014 10:14:47 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 13/13] mm: memcontrol: rewrite uncharge API
Message-ID: <20140716141447.GY29639@cmpxchg.org>
References: <1403124045-24361-1-git-send-email-hannes@cmpxchg.org>
 <1403124045-24361-14-git-send-email-hannes@cmpxchg.org>
 <20140715155537.GA19454@nhori.bos.redhat.com>
 <20140715160735.GB29269@dhcp22.suse.cz>
 <20140715173439.GU29639@cmpxchg.org>
 <20140715184358.GA31550@nhori.bos.redhat.com>
 <20140715190454.GW29639@cmpxchg.org>
 <20140715204953.GA21016@nhori.bos.redhat.com>
 <20140715214843.GX29639@cmpxchg.org>
 <20140716133050.GA4644@nhori.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140716133050.GA4644@nhori.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Jul 16, 2014 at 09:30:50AM -0400, Naoya Horiguchi wrote:
> On Tue, Jul 15, 2014 at 05:48:43PM -0400, Johannes Weiner wrote:
> > On Tue, Jul 15, 2014 at 04:49:53PM -0400, Naoya Horiguchi wrote:
> > > I feel that these 2 messages have the same cause (just appear differently).
> > > __add_to_page_cache_locked() (and mem_cgroup_try_charge()) can be called
> > > for hugetlb, while we avoid calling mem_cgroup_migrate()/mem_cgroup_uncharge()
> > > for hugetlb. This seems to make page_cgroup of the hugepage inconsistent,
> > > and results in the bad page bug ("page dumped because: cgroup check failed").
> > > So maybe some more PageHuge check is necessary around the charging code.
> > 
> > This struck me as odd because I don't remember removing a PageHuge()
> > call in the charge path and wondered how it worked before my changes:
> > apparently it just checked PageCompound() in mem_cgroup_charge_file().
> > 
> > So it's not fallout of the new uncharge batching code, but was already
> > broken during the rewrite of the charge API because then hugetlb pages
> > entered the charging code.
> > 
> > Anyway, we don't have file-specific charging code anymore, and the
> > PageCompound() check would have required changing anyway for THP
> > cache.  So I guess the solution is checking PageHuge() in charge,
> > uncharge, and migrate for now.  Oh well.
> > 
> > How about this?
> 
> With tweaking a bit, this patch solved the problem, thanks!
> 
> > diff --git a/mm/filemap.c b/mm/filemap.c
> > index 9c99d6868a5e..b61194273b56 100644
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -564,9 +564,12 @@ static int __add_to_page_cache_locked(struct page *page,
> >  	VM_BUG_ON_PAGE(!PageLocked(page), page);
> >  	VM_BUG_ON_PAGE(PageSwapBacked(page), page);
> >  
> > -	error = mem_cgroup_try_charge(page, current->mm, gfp_mask, &memcg);
> > -	if (error)
> > -		return error;
> > +	if (!PageHuge(page)) {
> > +		error = mem_cgroup_try_charge(page, current->mm,
> > +					      gfp_mask, &memcg);
> > +		if (error)
> > +			return error;
> > +	}
> >  
> >  	error = radix_tree_maybe_preload(gfp_mask & ~__GFP_HIGHMEM);
> >  	if (error) {
> 
> We have mem_cgroup_commit_charge() later in __add_to_page_cache_locked(),
> so adding "if (!PageHuge(page))" for it is necessary too.

You are right.  Annotated them all now.

> > diff --git a/mm/migrate.c b/mm/migrate.c
> > index 7f5a42403fae..dabed2f08609 100644
> > --- a/mm/migrate.c
> > +++ b/mm/migrate.c
> > @@ -781,7 +781,8 @@ static int move_to_new_page(struct page *newpage, struct page *page,
> >  		if (!PageAnon(newpage))
> >  			newpage->mapping = NULL;
> >  	} else {
> > -		mem_cgroup_migrate(page, newpage, false);
> > +		if (!PageHuge(page))
> > +			mem_cgroup_migrate(page, newpage, false);

I deleted this again as it was a followup fix to hugepages getting
wrongfully charged as file cache.  They shouldn't be, and
mem_cgroup_migrate() checks whether the page is charged.

> >  		if (remap_swapcache)
> >  			remove_migration_ptes(page, newpage);
> >  		if (!PageAnon(page))
> > diff --git a/mm/swap.c b/mm/swap.c
> > index 3461f2f5be20..97b6ec132398 100644
> > --- a/mm/swap.c
> > +++ b/mm/swap.c
> > @@ -62,12 +62,12 @@ static void __page_cache_release(struct page *page)
> >  		del_page_from_lru_list(page, lruvec, page_off_lru(page));
> >  		spin_unlock_irqrestore(&zone->lru_lock, flags);
> >  	}
> > -	mem_cgroup_uncharge(page);
> >  }
> >  
> >  static void __put_single_page(struct page *page)
> >  {
> >  	__page_cache_release(page);
> > +	mem_cgroup_uncharge_page(page);
> 
> My kernel is based on mmotm-2014-07-09-17-08, where mem_cgroup_uncharge_page()
> does not exist any more. Maybe mem_cgroup_uncharge(page) seems correct.

Sorry, I should have build tested.  The name is still reflex...

> >  	free_hot_cold_page(page, false);
> >  }
> >  
> > @@ -75,7 +75,10 @@ static void __put_compound_page(struct page *page)
> >  {
> >  	compound_page_dtor *dtor;
> >  
> > -	__page_cache_release(page);
> > +	if (!PageHuge(page)) {
> > +		__page_cache_release(page);
> > +		mem_cgroup_uncharge_page(page);

I reverted all these mm/swap.c changes again as well.  Instead,
mem_cgroup_uncharge() now does a preliminary check if the page is
charged before it touches page->lru.

That should be much more robust: now the vetting whether a page is
valid for memcg happens at charge time only, all other operations
check first if a page is charged before doing anything else to it.

These two places should be the only ones that need fixing then:

diff --git a/mm/filemap.c b/mm/filemap.c
index 9c99d6868a5e..bfe0745a704d 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -31,6 +31,7 @@
 #include <linux/security.h>
 #include <linux/cpuset.h>
 #include <linux/hardirq.h> /* for BUG_ON(!in_atomic()) only */
+#include <linux/hugetlb.h>
 #include <linux/memcontrol.h>
 #include <linux/cleancache.h>
 #include <linux/rmap.h>
@@ -558,19 +559,24 @@ static int __add_to_page_cache_locked(struct page *page,
 				      pgoff_t offset, gfp_t gfp_mask,
 				      void **shadowp)
 {
+	int huge = PageHuge(page);
 	struct mem_cgroup *memcg;
 	int error;
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(PageSwapBacked(page), page);
 
-	error = mem_cgroup_try_charge(page, current->mm, gfp_mask, &memcg);
-	if (error)
-		return error;
+	if (!huge) {
+		error = mem_cgroup_try_charge(page, current->mm,
+					      gfp_mask, &memcg);
+		if (error)
+			return error;
+	}
 
 	error = radix_tree_maybe_preload(gfp_mask & ~__GFP_HIGHMEM);
 	if (error) {
-		mem_cgroup_cancel_charge(page, memcg);
+		if (!huge)
+			mem_cgroup_cancel_charge(page, memcg);
 		return error;
 	}
 
@@ -585,14 +591,16 @@ static int __add_to_page_cache_locked(struct page *page,
 		goto err_insert;
 	__inc_zone_page_state(page, NR_FILE_PAGES);
 	spin_unlock_irq(&mapping->tree_lock);
-	mem_cgroup_commit_charge(page, memcg, false);
+	if (!huge)
+		mem_cgroup_commit_charge(page, memcg, false);
 	trace_mm_filemap_add_to_page_cache(page);
 	return 0;
 err_insert:
 	page->mapping = NULL;
 	/* Leave page->index set: truncation relies upon it */
 	spin_unlock_irq(&mapping->tree_lock);
-	mem_cgroup_cancel_charge(page, memcg);
+	if (!huge)
+		mem_cgroup_cancel_charge(page, memcg);
 	page_cache_release(page);
 	return error;
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 063080e35459..b5de5deddbfb 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6635,9 +6635,16 @@ static void uncharge_list(struct list_head *page_list)
  */
 void mem_cgroup_uncharge(struct page *page)
 {
+	struct page_cgroup *pc;
+
 	if (mem_cgroup_disabled())
 		return;
 
+	/* Don't touch page->lru of any random page, pre-check: */
+	pc = lookup_page_cgroup(page);
+	if (!PageCgroupUsed(pc))
+		return;
+
 	INIT_LIST_HEAD(&page->lru);
 	uncharge_list(&page->lru);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
