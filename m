Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 6B5A86B0062
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 10:57:30 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id v19so4112549obq.14
        for <linux-mm@kvack.org>; Tue, 11 Dec 2012 07:57:29 -0800 (PST)
Date: Tue, 11 Dec 2012 16:57:24 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch v2 4/6] memcg: simplify mem_cgroup_iter
Message-ID: <20121211155724.GD1612@dhcp22.suse.cz>
References: <1353955671-14385-1-git-send-email-mhocko@suse.cz>
 <1353955671-14385-5-git-send-email-mhocko@suse.cz>
 <CALWz4iw3v08Q3=nJRssOYjvpFa=yAJdmewYugogLcX_FBC1GmQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALWz4iw3v08Q3=nJRssOYjvpFa=yAJdmewYugogLcX_FBC1GmQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>

On Sun 09-12-12 09:01:48, Ying Han wrote:
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
	    ^^^^^^^^
	    here

> >         while (!memcg) {
> >                 struct mem_cgroup_reclaim_iter *uninitialized_var(iter);
> > -               struct cgroup_subsys_state *css = NULL;
> >
> >                 if (reclaim) {
> >                         int nid = zone_to_nid(reclaim->zone);
[...]
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
> > +                               else {
> > +                                       prev_cgroup = next_cgroup;
> 
> I might be missing something here, but the comment says the
> last_visited is safe to use but not the next_cgroup. What is
> preventing it to be
> removed ?

rcu_read_lock. cgroup cannot disappear inside rcu.

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
