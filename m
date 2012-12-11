Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id C30966B005A
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 13:10:44 -0500 (EST)
Received: by mail-oa0-f41.google.com with SMTP id k14so5031766oag.14
        for <linux-mm@kvack.org>; Tue, 11 Dec 2012 10:10:43 -0800 (PST)
Date: Tue, 11 Dec 2012 19:10:37 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch v2 3/6] memcg: rework mem_cgroup_iter to use cgroup
 iterators
Message-ID: <20121211181037.GH1612@dhcp22.suse.cz>
References: <1353955671-14385-1-git-send-email-mhocko@suse.cz>
 <1353955671-14385-4-git-send-email-mhocko@suse.cz>
 <CALWz4iwNvRd7AgEiSzd7Gr-7P5oh0uESS5A7rLZ7dZWeTjOzpQ@mail.gmail.com>
 <20121211155025.GB1612@dhcp22.suse.cz>
 <20121211161559.GF1612@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121211161559.GF1612@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>

On Tue 11-12-12 17:15:59, Michal Hocko wrote:
> On Tue 11-12-12 16:50:25, Michal Hocko wrote:
> > On Sun 09-12-12 08:59:54, Ying Han wrote:
> > > On Mon, Nov 26, 2012 at 10:47 AM, Michal Hocko <mhocko@suse.cz> wrote:
> > [...]
> > > > +               /*
> > > > +                * Even if we found a group we have to make sure it is alive.
> > > > +                * css && !memcg means that the groups should be skipped and
> > > > +                * we should continue the tree walk.
> > > > +                * last_visited css is safe to use because it is protected by
> > > > +                * css_get and the tree walk is rcu safe.
> > > > +                */
> > > > +               if (css == &root->css || (css && css_tryget(css)))
> > > > +                       memcg = mem_cgroup_from_css(css);
> > > >
> > > >                 if (reclaim) {
> > > > -                       iter->position = id;
> > > > +                       struct mem_cgroup *curr = memcg;
> > > > +
> > > > +                       if (last_visited)
> > > > +                               css_put(&last_visited->css);
> > > > +
> > > > +                       if (css && !memcg)
> > > > +                               curr = mem_cgroup_from_css(css);
> > > 
> > > In this case, the css_tryget() failed which implies the css is on the
> > > way to be removed. (refcnt ==0) If so, why it is safe to call
> > > css_get() directly on it below? It seems not preventing the css to be
> > > removed by doing so.
> > 
> > Well, I do not remember exactly but I guess the code is meant to say
> > that we need to store a half-dead memcg because the loop has to be
> > retried. As we are under RCU hood it is just half dead.
> > Now that you brought this up I think this is not safe as well because
> > another thread could have seen the cached value while we tried to retry
> > and his RCU is not protecting the group anymore.
> 
> Hmm, thinking about it some more, it _is_ be safe in the end.
> 
> We are safe because we are under RCU.

And I've just realized that one sentence vanished while I was writing
this.

So either we retry (while(!memcg)) and see the half-dead memcg with a
valid cgroup because we are under rcu so cgroup iterator will find a
next one. Or we race with somebody else on the iterator and that is
described bellow.

> And even if somebody else looked
> at the half-dead memcg from iter->last_visited it cannot disappear
> because the current one will retry without dropping RCU so the grace
> period couldn't have been finished.
> 
> 		CPU0					CPU1
> rcu_read_lock()						rcu_read_lock()
> while(!memcg) {						while(!memcg)
> [...]
> spin_lock(&iter->iter_lock)
> [...]
> if (css == &root->css ||
> 		(css && css_tryget(css)))
> 	memcg = mem_cgroup_from_css(css)
> [...]
> if (css && !memcg)
> 	curr = mem_cgroup_from_css(css)
> if (curr)
> 	css_get(curr);
> spin_unlock(&iter->iter_lock)
> 							spin_lock(&iter->iter_lock)
> 							/* sees the half dead memcg but its cgroup is still valid */ 
> 							[...]
> 							spin_unlock(&iter->iter_lock)
> /* we do retry */
> }
> rcu_read_unlock()
> 
> so the css_get will just helps to prevent from further code obfuscation.
> 
> Makes sense? The code gets much simplified later in the series,
> fortunately.
> -- 
> Michal Hocko
> SUSE Labs
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
