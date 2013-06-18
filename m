Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id EF2476B0032
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 06:40:05 -0400 (EDT)
Date: Tue, 18 Jun 2013 12:40:03 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: Add force_reclaim to reclaim tasks' memory in
 memcg.
Message-ID: <20130618104003.GG13677@dhcp22.suse.cz>
References: <021801ce65cb$f5b0bc50$e11234f0$%kim@samsung.com>
 <20130610152246.GB14295@dhcp22.suse.cz>
 <CAOK=xRM6aJsOQ+bD2Y=f70Jq28stzM95h8GbO-v+EXQ4tObznw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOK=xRM6aJsOQ+bD2Y=f70Jq28stzM95h8GbO-v+EXQ4tObznw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hyunhee Kim <hyunhee.kim@samsung.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>

On Tue 18-06-13 18:46:51, Hyunhee Kim wrote:
> 2013/6/11 Michal Hocko <mhocko@suse.cz>:
> > On Mon 10-06-13 20:16:31, Hyunhee Kim wrote:
> >> These days, platforms tend to manage memory on low memory state
> >> like andloid's lowmemory killer. These platforms might want to
> >> reclaim memory from background tasks as well as kill victims
> >> to guarantee free memory at use space level. This patch provides
> >> an interface to reclaim a given memcg.
> >
> >> After platform's low memory handler moves tasks that the platform
> >> wants to reclaim to a memcg and decides how many pages should be
> >> reclaimed, it can reclaim the pages from the tasks by writing the
> >> number of pages at memory.force_reclaim.
> >
> > Why cannot you simply set the soft limit to 0 for the target group which
> > would enforce reclaim during the next global reclaim instead?
> >
> > Or you can even use the hard limit for that. If you know how much memory
> > is used by those processes you can simply move them to a group with the
> > hard limit reduced by the amount of pages which you want to free and the
> > reclaim would happen during taks move.
> >
> 
> Thanks for the comments. However, having this kind of interface that
> can trigger reclaim the given number of pages is more simple and
> clear?

This is not about simplicity. You are suggesting a new user API which
will have to be supported _for ever_. As I already explained there is a
a way to accomplish the same thing by already existing API.

Something that might sounds simple and clear now might turn out a bigger
problem later on. Who knows whether future implementation would allow to
reclaim a particular number of pages.

> This also can start reclaim immediatlely. IMHO, calculating and
> resetting the hard limit every time we want to start reclaim should be
> done more carefully by knowing the exact number of pages charged by
> the moved task. I think that this kind of interface could be useful
> for platform which handles low memory state at the user space.

There are other means to accomplish the same thing. So I do not see any
reason for a new interface. So

Nacked-by: Michal Hocko <mhocko@suse.cz>

> >> Signed-off-by: Hyunhee Kim <hyunhee.kim@samsung.com>
> >> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> >> ---
> >>  mm/memcontrol.c |   26 ++++++++++++++++++++++++++
> >>  1 file changed, 26 insertions(+)
> >>
> >> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> >> index 010d6c1..21819c9 100644
> >> --- a/mm/memcontrol.c
> >> +++ b/mm/memcontrol.c
> >> @@ -4980,6 +4980,28 @@ static int mem_cgroup_force_empty_write(struct cgroup
> >> *cont, unsigned int event)
> >>       return ret;
> >>  }
> >>
> >> +static int mem_cgroup_force_reclaim(struct cgroup *cont, struct cftype
> >> *cft, u64 val)
> >> +{
> >> +
> >> +     struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
> >> +     unsigned long nr_to_reclaim = val;
> >> +     unsigned long total = 0;
> >> +     int loop;
> >> +
> >> +     for (loop = 0; loop < MEM_CGROUP_MAX_RECLAIM_LOOPS; loop++) {
> >> +             total += try_to_free_mem_cgroup_pages(memcg, GFP_KERNEL,
> >> false);
> >> +
> >> +             /*
> >> +              * If nothing was reclaimed after two attempts, there
> >> +              * may be no reclaimable pages in this hierarchy.
> >> +              * If more than nr_to_reclaim pages were already reclaimed,
> >> +              * finish force reclaim.
> >> +              */
> >> +             if (loop && (!total || total > nr_to_reclaim))
> >> +                     break;
> >> +     }
> >> +     return total;
> >> +}
> >>
> >>  static u64 mem_cgroup_hierarchy_read(struct cgroup *cont, struct cftype
> >> *cft)
> >>  {
> >> @@ -5938,6 +5960,10 @@ static struct cftype mem_cgroup_files[] = {
> >>               .trigger = mem_cgroup_force_empty_write,
> >>       },
> >>       {
> >> +             .name = "force_reclaim",
> >> +             .write_u64 = mem_cgroup_force_reclaim,
> >> +     },
> >> +     {
> >>               .name = "use_hierarchy",
> >>               .flags = CFTYPE_INSANE,
> >>               .write_u64 = mem_cgroup_hierarchy_write,
> >> --
> >> 1.7.9.5
> >>
> >>
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> > --
> > Michal Hocko
> > SUSE Labs
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
