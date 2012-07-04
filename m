Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 9303C6B0071
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 09:38:04 -0400 (EDT)
Date: Wed, 4 Jul 2012 15:38:00 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 2/2] memcg: remove -ENOMEM at page migration.
Message-ID: <20120704133800.GH29842@tiehlicka.suse.cz>
References: <4FF3B0DC.5090508@jp.fujitsu.com>
 <4FF3B14E.2090300@jp.fujitsu.com>
 <20120704083019.GA7881@cmpxchg.org>
 <20120704120445.GC29842@tiehlicka.suse.cz>
 <20120704131302.GC7881@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120704131302.GC7881@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>

On Wed 04-07-12 15:13:02, Johannes Weiner wrote:
> On Wed, Jul 04, 2012 at 02:04:45PM +0200, Michal Hocko wrote:
> > On Wed 04-07-12 10:30:19, Johannes Weiner wrote:
[...]
> > > Can we instead not charge the new page, just commit it while holding
> > > on to a css refcount, and have end_migration call a version of
> > > __mem_cgroup_uncharge_common() that updates the stats but leaves the
> > > res counters alone?
> > 
> > Yes, this is also a way to go. Both approaches have to lie a bit and
> > both have a discrepancy between stat and usage_in_bytes. I guess we can
> > live with that.
> > Kame's solution seems easier but yours prevent from a corner case when
> > the reclaim is triggered due to artificial charges so I guess it is
> > better to go with yours.
> > Few (trivial) comments on the patch bellow.
> 
> It's true that the cache/rss statistics still account for both pages.
> But they don't have behavioural impact and so I didn't bother.  

Only if somebody watches those numbers and blows up if rss+cache >
limit_in_bytes. I can imagine an LTP test like that. But the test would
need to trigger migration in the background...

> We could still fix this up later, but it's less urgent, I think.

Yes, I guess so

> 
> > > @@ -2955,7 +2956,10 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
> > >  		/* fallthrough */
> > >  	case MEM_CGROUP_CHARGE_TYPE_DROP:
> > >  		/* See mem_cgroup_prepare_migration() */
> > > -		if (page_mapped(page) || PageCgroupMigration(pc))
> > > +		if (page_mapped(page))
> > > +			goto unlock_out;
> > 
> > Don't need that test or remove the one below (seems easier to read
> > because those cases are really different things).
> > 
> > > +		if (page_mapped(page) || (!end_migration &&
> > > +					  PageCgroupMigration(pc)))
> 
> My bad, I meant to remove this second page_mapped() and forgot.  Will
> fix.  I take it
> 
> 		if (page_mapped(page))
> 			goto unlock_out;
> 		if (!end_migration && PageCgroupMigration(pc))
> 			goto unlock_out;
> 
> is what you had in mind?

Yes

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
