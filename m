Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 39AF76B004D
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 04:45:32 -0500 (EST)
Date: Wed, 18 Jan 2012 10:45:23 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/2] mm: memcg: hierarchical soft limit reclaim
Message-ID: <20120118094523.GJ24386@cmpxchg.org>
References: <1326207772-16762-1-git-send-email-hannes@cmpxchg.org>
 <1326207772-16762-3-git-send-email-hannes@cmpxchg.org>
 <20120113120406.GC17060@tiehlicka.suse.cz>
 <20120113155001.GB1653@cmpxchg.org>
 <20120113163423.GG17060@tiehlicka.suse.cz>
 <CALWz4iyj4SMMyYhbuZ3HUq-jvcZUCGarceYY7vxm4b7X=yvCMg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CALWz4iyj4SMMyYhbuZ3HUq-jvcZUCGarceYY7vxm4b7X=yvCMg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jan 13, 2012 at 01:45:30PM -0800, Ying Han wrote:
> On Fri, Jan 13, 2012 at 8:34 AM, Michal Hocko <mhocko@suse.cz> wrote:
> > On Fri 13-01-12 16:50:01, Johannes Weiner wrote:
> >> On Fri, Jan 13, 2012 at 01:04:06PM +0100, Michal Hocko wrote:
> >> > On Tue 10-01-12 16:02:52, Johannes Weiner wrote:
> > [...]
> >> > > +bool mem_cgroup_over_softlimit(struct mem_cgroup *root,
> >> > > +                        struct mem_cgroup *memcg)
> >> > > +{
> >> > > + if (mem_cgroup_disabled())
> >> > > +         return false;
> >> > > +
> >> > > + if (!root)
> >> > > +         root = root_mem_cgroup;
> >> > > +
> >> > > + for (; memcg; memcg = parent_mem_cgroup(memcg)) {
> >> > > +         /* root_mem_cgroup does not have a soft limit */
> >> > > +         if (memcg == root_mem_cgroup)
> >> > > +                 break;
> >> > > +         if (res_counter_soft_limit_excess(&memcg->res))
> >> > > +                 return true;
> >> > > +         if (memcg == root)
> >> > > +                 break;
> >> > > + }
> >> > > + return false;
> >> > > +}
> >> >
> >> > Well, this might be little bit tricky. We do not check whether memcg and
> >> > root are in a hierarchy (in terms of use_hierarchy) relation.
> >> >
> >> > If we are under global reclaim then we iterate over all memcgs and so
> >> > there is no guarantee that there is a hierarchical relation between the
> >> > given memcg and its parent. While, on the other hand, if we are doing
> >> > memcg reclaim then we have this guarantee.
> >> >
> >> > Why should we punish a group (subtree) which is perfectly under its soft
> >> > limit just because some other subtree contributes to the common parent's
> >> > usage and makes it over its limit?
> >> > Should we check memcg->use_hierarchy here?
> >>
> >> We do, actually.  parent_mem_cgroup() checks the res_counter parent,
> >> which is only set when ->use_hierarchy is also set.
> >
> > Of course I am blind.. We do not setup res_counter parent for
> > !use_hierarchy case. Sorry for noise...
> > Now it makes much better sense. I was wondering how !use_hierarchy could
> > ever work, this should be a signal that I am overlooking something
> > terribly.
> >
> > [...]
> >> > > @@ -2121,8 +2121,16 @@ static void shrink_zone(int priority, struct zone *zone,
> >> > >                   .mem_cgroup = memcg,
> >> > >                   .zone = zone,
> >> > >           };
> >> > > +         int epriority = priority;
> >> > > +         /*
> >> > > +          * Put more pressure on hierarchies that exceed their
> >> > > +          * soft limit, to push them back harder than their
> >> > > +          * well-behaving siblings.
> >> > > +          */
> >> > > +         if (mem_cgroup_over_softlimit(root, memcg))
> >> > > +                 epriority = 0;
> >> >
> >> > This sounds too aggressive to me. Shouldn't we just double the pressure
> >> > or something like that?
> >>
> >> That's the historical value.  When I tried priority - 1, it was not
> >> aggressive enough.
> >
> > Probably because we want to reclaim too much. Maybe we should do
> > reduce nr_to_reclaim (ugly) or reclaim only overlimit groups until certain
> > priority level as Ying suggested in her patchset.
> 
> I plan to post that change on top of this, and this patch set does the
> basic stuff to allow us doing further improvement.
> 
> I still like the design to skip over_soft_limit cgroups until certain
> priority. One way to set up the soft limit for each cgroup is to base
> on its actual working set size, and we prefer to punish A first with
> lots of page cache ( cold file pages above soft limit) than reclaiming
> anon pages from B ( below soft limit ). Unless we can not get enough
> pages reclaimed from A, we will start reclaiming from B.
> 
> This might not be the ideal solution, but should be a good start. Thoughts?

I don't like this design at all because unless you add weird code to
detect if soft limits apply to any memcgs on the reclaimed hierarchy
you may iterate over the same bunch of memcgs doing nothing for
several times.  For example in the default case of no softlimits set
anywhere and you repeatedly walk ALL memcgs in the system doing jack
until you reach your threshold priority level.  Elegant is something
else in my book.

Once we invert soft limits to mean guarantees and make the default
soft limit not infinity but zero, then we can ignore memcgs below
their soft limit for a few priority levels just fine because being
below the soft limit is the exception.  But I don't really want to
make this quite invasive behavioural change a requirement for a
refactoring patch if possible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
