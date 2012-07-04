Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 9AD816B0071
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 09:13:13 -0400 (EDT)
Date: Wed, 4 Jul 2012 15:13:02 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 2/2] memcg: remove -ENOMEM at page migration.
Message-ID: <20120704131302.GC7881@cmpxchg.org>
References: <4FF3B0DC.5090508@jp.fujitsu.com>
 <4FF3B14E.2090300@jp.fujitsu.com>
 <20120704083019.GA7881@cmpxchg.org>
 <20120704120445.GC29842@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120704120445.GC29842@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>

On Wed, Jul 04, 2012 at 02:04:45PM +0200, Michal Hocko wrote:
> On Wed 04-07-12 10:30:19, Johannes Weiner wrote:
> > On Wed, Jul 04, 2012 at 11:58:22AM +0900, Kamezawa Hiroyuki wrote:
> > > >From 257a1e6603aab8c6a3bd25648872a11e8b85ef64 Mon Sep 17 00:00:00 2001
> > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > Date: Thu, 28 Jun 2012 19:07:24 +0900
> > > Subject: [PATCH 2/2] 
> > > 
> > > For handling many kinds of races, memcg adds an extra charge to
> > > page's memcg at page migration. But this affects the page compaction
> > > and make it fail if the memcg is under OOM.
> > > 
> > > This patch uses res_counter_charge_nofail() in page migration path
> > > and remove -ENOMEM. By this, page migration will not fail by the
> > > status of memcg.
> > > 
> > > Even though res_counter_charge_nofail can silently go over the memcg
> > > limit mem_cgroup_usage compensates that and it doesn't tell the real truth
> > > to the userspace.
> > > 
> > > Excessive charges are only temporal and done on a single page per-CPU in
> > > the worst case. This sounds tolerable and actually consumes less charges
> > > than the current per-cpu memcg_stock.
> > 
> > But it still means we end up going into reclaim on charges, limit
> > resizing etc. which we wouldn't without a bunch of pages under
> > migration.
> > 
> > Can we instead not charge the new page, just commit it while holding
> > on to a css refcount, and have end_migration call a version of
> > __mem_cgroup_uncharge_common() that updates the stats but leaves the
> > res counters alone?
> 
> Yes, this is also a way to go. Both approaches have to lie a bit and
> both have a discrepancy between stat and usage_in_bytes. I guess we can
> live with that.
> Kame's solution seems easier but yours prevent from a corner case when
> the reclaim is triggered due to artificial charges so I guess it is
> better to go with yours.
> Few (trivial) comments on the patch bellow.

It's true that the cache/rss statistics still account for both pages.
But they don't have behavioural impact and so I didn't bother.  We
could still fix this up later, but it's less urgent, I think.

> > @@ -2955,7 +2956,10 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
> >  		/* fallthrough */
> >  	case MEM_CGROUP_CHARGE_TYPE_DROP:
> >  		/* See mem_cgroup_prepare_migration() */
> > -		if (page_mapped(page) || PageCgroupMigration(pc))
> > +		if (page_mapped(page))
> > +			goto unlock_out;
> 
> Don't need that test or remove the one below (seems easier to read
> because those cases are really different things).
> 
> > +		if (page_mapped(page) || (!end_migration &&
> > +					  PageCgroupMigration(pc)))

My bad, I meant to remove this second page_mapped() and forgot.  Will
fix.  I take it

		if (page_mapped(page))
			goto unlock_out;
		if (!end_migration && PageCgroupMigration(pc))
			goto unlock_out;

is what you had in mind?

> > @@ -3166,19 +3170,18 @@ static inline int mem_cgroup_move_swap_account(swp_entry_t entry,
> >   * Before starting migration, account PAGE_SIZE to mem_cgroup that the old
> >   * page belongs to.
> >   */
> > -int mem_cgroup_prepare_migration(struct page *page,
> > +void mem_cgroup_prepare_migration(struct page *page,
> >  	struct page *newpage, struct mem_cgroup **memcgp, gfp_t gfp_mask)
> 
> gfp_mask is not needed anymore

Good catch, will fix.

> > @@ -3254,7 +3242,7 @@ int mem_cgroup_prepare_migration(struct page *page,
> >  	else
> >  		ctype = MEM_CGROUP_CHARGE_TYPE_SHMEM;
> >  	__mem_cgroup_commit_charge(memcg, newpage, 1, ctype, false);
> 
> Perhaps a comment that we are doing commit without charge because this
> is only temporal would be good?

Yes, I'll add something.

Thanks for the review!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
