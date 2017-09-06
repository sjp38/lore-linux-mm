Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id DBB9C280428
	for <linux-mm@kvack.org>; Wed,  6 Sep 2017 09:22:54 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id e64so6217335wmi.0
        for <linux-mm@kvack.org>; Wed, 06 Sep 2017 06:22:54 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m185si316476wmm.206.2017.09.06.06.22.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Sep 2017 06:22:53 -0700 (PDT)
Date: Wed, 6 Sep 2017 15:22:49 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v7 2/5] mm, oom: cgroup-aware OOM killer
Message-ID: <20170906132249.c2llo5zyrzgviqzc@dhcp22.suse.cz>
References: <20170904142108.7165-1-guro@fb.com>
 <20170904142108.7165-3-guro@fb.com>
 <20170905145700.fd7jjd37xf4tb55h@dhcp22.suse.cz>
 <20170905202357.GA10535@castle.DHCP.thefacebook.com>
 <20170906083158.gvqx6pekrsy2ya47@dhcp22.suse.cz>
 <20170906125750.GB12904@castle>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170906125750.GB12904@castle>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 06-09-17 13:57:50, Roman Gushchin wrote:
> On Wed, Sep 06, 2017 at 10:31:58AM +0200, Michal Hocko wrote:
> > On Tue 05-09-17 21:23:57, Roman Gushchin wrote:
> > > On Tue, Sep 05, 2017 at 04:57:00PM +0200, Michal Hocko wrote:
> > [...]
> > > > Hmm. The changelog says "By default, it will look for the biggest leaf
> > > > cgroup, and kill the largest task inside." But you are accumulating
> > > > oom_score up the hierarchy and so parents will have higher score than
> > > > the layer of their children and the larger the sub-hierarchy the more
> > > > biased it will become. Say you have
> > > > 	root
> > > >          /\
> > > >         /  \
> > > >        A    D
> > > >       / \
> > > >      B   C
> > > > 
> > > > B (5), C(15) thus A(20) and D(20). Unless I am missing something we are
> > > > going to go down A path and then chose C even though D is the largest
> > > > leaf group, right?
> > > 
> > > You're right, changelog is not accurate, I'll fix it.
> > > The behavior is correct, IMO.
> > 
> > Please explain why. This is really a non-intuitive semantic. Why should
> > larger hierarchies be punished more than shallow ones? I would
> > completely agree if the whole hierarchy would be a killable entity (aka
> > A would be kill-all).
> 
> I think it's a reasonable and clear policy: we're looking for a memcg
> with the smallest oom_priority and largest memory footprint recursively.

But this can get really complex for non-trivial setups. Anything with
deeper and larger hierarchies will get quite complex IMHO.

Btw. do you have any specific usecase for the priority based oom
killer? I remember David was asking for this because it _would_ be
useful but you didn't have it initially. And I agree with that I am
just not sure the semantic is thought through wery well. I am thinking
whether it would be easier to push this further without priority thing
for now and add it later with a clear example of the configuration and
how it should work and a more thought through semantic. Would that sound
acceptable? I believe the rest is quite useful to get merged on its own.

> Then we reclaim some memory from it (by killing the biggest process
> or all processes, depending on memcg preferences).
> 
> In general, if there are two memcgs of equal importance (which is defined
> by setting the oom_priority), we're choosing the largest, because there
> are more chances that it contain a leaking process. The same is true
> right now for processes.

Yes except this is not the case as shown above. We can easily select a
smaller leaf memcg just because it is in a larger hierarchy and that
sounds very dubious to me. Even when all the priorities are the same.

> I agree, that for size-based comparison we could use a different policy:
> comparing leaf cgroups despite their level. But I don't see a clever
> way to apply oom_priorities in this case. Comparing oom_priority
> on each level is a simple and powerful policy, and it works well
> for delegation.

You are already shaping semantic around the implementation and that is a
clear sign of problem.
 
> > [...]
> > > > I do not understand why do we have to handle root cgroup specially here.
> > > > select_victim_memcg already iterates all memcgs in the oom hierarchy
> > > > (including root) so if the root memcg is the largest one then we
> > > > should simply consider it no?
> > > 
> > > We don't have necessary stats for the root cgroup, so we can't calculate
> > > it's oom_score.
> > 
> > We used to charge pages to the root memcg as well so we might resurrect
> > that idea. In any case this is something that could be hidden in
> > memcg_oom_badness rather then special cased somewhere else.
> 
> In theory I agree, but I do not see a good way to calculate root memcg
> oom_score.

Why cannot you emulate that by the largest task in the root? The same
way you actually do in select_victim_root_cgroup_task now?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
