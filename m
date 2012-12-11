Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id E60E96B0069
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 11:01:55 -0500 (EST)
Received: by mail-oa0-f41.google.com with SMTP id k14so4828390oag.14
        for <linux-mm@kvack.org>; Tue, 11 Dec 2012 08:01:55 -0800 (PST)
Date: Tue, 11 Dec 2012 17:01:49 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch v2 4/6] memcg: simplify mem_cgroup_iter
Message-ID: <20121211160149.GE1612@dhcp22.suse.cz>
References: <1353955671-14385-1-git-send-email-mhocko@suse.cz>
 <1353955671-14385-5-git-send-email-mhocko@suse.cz>
 <CALWz4ixgQzhZeqt_9JiMT0XOGFOh1co6xYo1dkS9Rrksey7KUA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALWz4ixgQzhZeqt_9JiMT0XOGFOh1co6xYo1dkS9Rrksey7KUA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>

On Mon 10-12-12 20:35:20, Ying Han wrote:
> On Mon, Nov 26, 2012 at 10:47 AM, Michal Hocko <mhocko@suse.cz> wrote:
> > Current implementation of mem_cgroup_iter has to consider both css and
> > memcg to find out whether no group has been found (css==NULL - aka the
> > loop is completed) and that no memcg is associated with the found node
> > (!memcg - aka css_tryget failed because the group is no longer alive).
> > This leads to awkward tweaks like tests for css && !memcg to skip the
> > current node.
> >
> > It will be much easier if we got rid off css variable altogether and
> > only rely on memcg. In order to do that the iteration part has to skip
> > dead nodes. This sounds natural to me and as a nice side effect we will
> > get a simple invariant that memcg is always alive when non-NULL and all
> > nodes have been visited otherwise.
> >
> > We could get rid of the surrounding while loop but keep it in for now to
> > make review easier. It will go away in the following patch.
> >
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > ---
> >  mm/memcontrol.c |   56 +++++++++++++++++++++++++++----------------------------
> >  1 file changed, 27 insertions(+), 29 deletions(-)
> >
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 6bcc97b..d1bc0e8 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -1086,7 +1086,6 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
> >         rcu_read_lock();
> >         while (!memcg) {
> >                 struct mem_cgroup_reclaim_iter *uninitialized_var(iter);
> > -               struct cgroup_subsys_state *css = NULL;
> >
> >                 if (reclaim) {
> >                         int nid = zone_to_nid(reclaim->zone);
> > @@ -1112,53 +1111,52 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
> >                  * explicit visit.
> >                  */
> >                 if (!last_visited) {
		    ^^^^^^^^
		    here

> > -                       css = &root->css;
> > +                       memcg = root;
> >                 } else {
> >                         struct cgroup *prev_cgroup, *next_cgroup;
> >
> >                         prev_cgroup = (last_visited == root) ? NULL
> >                                 : last_visited->css.cgroup;
> > -                       next_cgroup = cgroup_next_descendant_pre(prev_cgroup,
> > -                                       root->css.cgroup);
> > -                       if (next_cgroup)
> > -                               css = cgroup_subsys_state(next_cgroup,
> > -                                               mem_cgroup_subsys_id);
> > -               }
> > +skip_node:
> > +                       next_cgroup = cgroup_next_descendant_pre(
> > +                                       prev_cgroup, root->css.cgroup);
> >
> > -               /*
> > -                * Even if we found a group we have to make sure it is alive.
> > -                * css && !memcg means that the groups should be skipped and
> > -                * we should continue the tree walk.
> > -                * last_visited css is safe to use because it is protected by
> > -                * css_get and the tree walk is rcu safe.
> > -                */
> > -               if (css == &root->css || (css && css_tryget(css)))
> > -                       memcg = mem_cgroup_from_css(css);
> > +                       /*
> > +                        * Even if we found a group we have to make sure it is
> > +                        * alive. css && !memcg means that the groups should be
> > +                        * skipped and we should continue the tree walk.
> > +                        * last_visited css is safe to use because it is
> > +                        * protected by css_get and the tree walk is rcu safe.
> > +                        */
> > +                       if (next_cgroup) {
> > +                               struct mem_cgroup *mem = mem_cgroup_from_cont(
> > +                                               next_cgroup);
> > +                               if (css_tryget(&mem->css))
> > +                                       memcg = mem;
> 
> I see a functional change after this, where we now hold a refcnt of
> css if memcg is root. It is not the case before this change.

I know it is a bit obscure but this is not the case.
cgroup_next_descendant_pre never visits its root. That's why we have
that if (!last_visited) test above. We have to handle it separately.

Makes sense?

> 
> --Ying
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
