Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 0BA376B0027
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 04:13:34 -0400 (EDT)
Date: Wed, 20 Mar 2013 09:13:32 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 3/5] memcg: make it suck faster
Message-ID: <20130320081332.GF20045@dhcp22.suse.cz>
References: <1362489058-3455-1-git-send-email-glommer@parallels.com>
 <1362489058-3455-4-git-send-email-glommer@parallels.com>
 <20130319135821.GG7869@dhcp22.suse.cz>
 <51495E73.8090409@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51495E73.8090409@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, handai.szj@gmail.com, anton.vorontsov@linaro.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>

On Wed 20-03-13 11:00:03, Glauber Costa wrote:
> Sorry all for taking a lot of time to reply to this. I've been really busy.
> 
> On 03/19/2013 05:58 PM, Michal Hocko wrote:
> > On Tue 05-03-13 17:10:56, Glauber Costa wrote:
> >> It is an accepted fact that memcg sucks. But can it suck faster?  Or in
> >> a more fair statement, can it at least stop draining everyone's
> >> performance when it is not in use?
> >>
> >> This experimental and slightly crude patch demonstrates that we can do
> >> that by using static branches to patch it out until the first memcg
> >> comes to life. There are edges to be trimmed, and I appreciate comments
> >> for direction. In particular, the events in the root are not fired, but
> >> I believe this can be done without further problems by calling a
> >> specialized event check from mem_cgroup_newpage_charge().
> >>
> >> My goal was to have enough numbers to demonstrate the performance gain
> >> that can come from it. I tested it in a 24-way 2-socket Intel box, 24 Gb
> >> mem. I used Mel Gorman's pft test, that he used to demonstrate this
> >> problem back in the Kernel Summit. There are three kernels:
> >>
> >> nomemcg  : memcg compile disabled.
> >> base     : memcg enabled, patch not applied.
> >> bypassed : memcg enabled, with patch applied.
> >>
> >>                 base    bypassed
> >> User          109.12      105.64
> >> System       1646.84     1597.98
> >> Elapsed       229.56      215.76
> >>
> >>              nomemcg    bypassed
> >> User          104.35      105.64
> >> System       1578.19     1597.98
> >> Elapsed       212.33      215.76
> > 
> > Do you have profiles for where we spend the time?
> > 
> 
> I don't *have* in the sense that I never saved them, but it is easy to
> grab. I've just run Mel's pft test with perf top -a in parallel, and
> that was mostly the charge and uncharge functions being run.

Would be nice to have this information to know which parts need
optimization with a higher priority. I do not think we will make it ~0%
cost in a single run.

> >>  #ifdef CONFIG_MEMCG
> >> +extern struct static_key memcg_in_use_key;
> >> +
> >> +static inline bool mem_cgroup_subsys_disabled(void)
> >> +{
> >> +	return !!mem_cgroup_subsys.disabled;
> >> +}
> >> +
> >> +static inline bool mem_cgroup_disabled(void)
> >> +{
> >> +	/*
> >> +	 * Will always be false if subsys is disabled, because we have no one
> >> +	 * to bump it up. So the test suffices and we don't have to test the
> >> +	 * subsystem as well
> >> +	 */
> > 
> > but static_key_false adds an atomic read here which is more costly so I
> > am not sure you are optimizing much.
> > 
> 
> No it doesn't. You're missing the point of static branches: The code is
> *patched out* until it is not used.

OK, I should have been more specific. It adds an atomic if static
branches are disabled.

> So it adds a predictable deterministic jump instruction to the false
> statement, and that's it (hence their previous name 'jump label').
> 
> >> +
> >> +extern int __mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
> >> +				     gfp_t gfp_mask);
> >> +static inline int
> >> +mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm, gfp_t gfp_mask)
> >> +{
> >> +	if (mem_cgroup_disabled())
> >> +		return 0;
> >> +
> >> +	return __mem_cgroup_cache_charge(page, mm, gfp_mask);
> >> +}
> > 
> > Are there any reasons to not get down to __mem_cgroup_try_charge? We
> > will not be perfect, all right, because some wrappers already do some
> > work but we should at least cover most of them.
> > 
> > I am also thinking whether this stab at charging path is not just an
> > overkill. Wouldn't it suffice to do something like:
> 
> I don't know. I could test. I just see no reason for that. Being able to
> patch out code in the caller level means we'll not incur even a function
> call. That's a generally accepted good thing to do in hot paths.

Agreed. I just think that the charging path is rather complicated and
changing it incrementally is a lower risk. Maybe we just find out that
the biggest overhead can be reduced by a simpler approach.

> Specially given the fact that the memcg overhead seems not to be
> concentrated in one single place, but as Christoph Lameter defined,
> "death by a thousand cuts", I'd much rather not even pay the function
> calls if I can avoid. If I introducing great complexity for that, fine,
> I could trade off. But honestly, the patch gets bigger but that's it.

And more code and all the charging paths are already quite complicated.
I do not want to add more, if possible.
 
> >>  struct lruvec *mem_cgroup_zone_lruvec(struct zone *, struct mem_cgroup *);
> >>  struct lruvec *mem_cgroup_page_lruvec(struct page *, struct zone *);
> > [...]
> >> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> >> index bfbf1c2..45c1886 100644
> >> --- a/mm/memcontrol.c
> >> +++ b/mm/memcontrol.c
> > [...]
> >> @@ -1335,6 +1345,20 @@ struct lruvec *mem_cgroup_page_lruvec(struct page *page, struct zone *zone)
> >>  	memcg = pc->mem_cgroup;
> > 
> > I would expect that you want to prevent lookup as well if there are no
> > other groups.
> >
> well, that function in specific seems to be mostly called during
> reclaim, where I wasn't terribly concerned about optimizations, unlike
> the steady state functions.

Not only from reclaim. Also when a page is uncharged.
Anyway we can get the optimization almost for free here ;)
 
> >>  	/*
> >> +	 * Because we lazily enable memcg only after first child group is
> >> +	 * created, we can have memcg == 0. Because page cgroup is created with
> >> +	 * GFP_ZERO, and after charging, all page cgroups will have a non-zero
> >> +	 * cgroup attached (even if root), we can be sure that this is a
> >> +	 * used-but-not-accounted page. (due to lazyness). We could get around
> >> +	 * that by scanning all pages on cgroup init is too expensive. We can
> >> +	 * ultimately pay, but prefer to just to defer the update until we get
> >> +	 * here. We could take the opportunity to set PageCgroupUsed, but it
> >> +	 * won't be that important for the root cgroup.
> >> +	 */
> >> +	if (!memcg && PageLRU(page))
> >> +		pc->mem_cgroup = memcg = root_mem_cgroup;
> > 
> > Why not return page_cgroup_zoneinfo(root_mem_cgroup, page);
> > This would require messing up with __mem_cgroup_uncharge_common but that
> > doesn't sound incredibly crazy (to the local standard of course ;)).
> > 
> 
> Could you clarify?

You can save some cycles by returning lruvec from here directly and do
not get through:
	if (!PageLRU(page) && !PageCgroupUsed(pc) && memcg != root_mem_cgroup)
		pc->mem_cgroup = memcg = root_mem_cgroup;

	mz = page_cgroup_zoneinfo(memcg, page);
	lruvec = &mz->lruvec; 

again. Just a nano optimization in that path
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
