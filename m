Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0C0A228042D
	for <linux-mm@kvack.org>; Wed,  6 Sep 2017 09:42:14 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id f64so3394559itf.4
        for <linux-mm@kvack.org>; Wed, 06 Sep 2017 06:42:14 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id h194si1517938itb.135.2017.09.06.06.42.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Sep 2017 06:42:12 -0700 (PDT)
Date: Wed, 6 Sep 2017 14:41:42 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v7 2/5] mm, oom: cgroup-aware OOM killer
Message-ID: <20170906134142.GA15796@castle.DHCP.thefacebook.com>
References: <20170904142108.7165-1-guro@fb.com>
 <20170904142108.7165-3-guro@fb.com>
 <20170905145700.fd7jjd37xf4tb55h@dhcp22.suse.cz>
 <20170905202357.GA10535@castle.DHCP.thefacebook.com>
 <20170906083158.gvqx6pekrsy2ya47@dhcp22.suse.cz>
 <20170906125750.GB12904@castle>
 <20170906132249.c2llo5zyrzgviqzc@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170906132249.c2llo5zyrzgviqzc@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Sep 06, 2017 at 03:22:49PM +0200, Michal Hocko wrote:
> On Wed 06-09-17 13:57:50, Roman Gushchin wrote:
> > On Wed, Sep 06, 2017 at 10:31:58AM +0200, Michal Hocko wrote:
> > > On Tue 05-09-17 21:23:57, Roman Gushchin wrote:
> > > > On Tue, Sep 05, 2017 at 04:57:00PM +0200, Michal Hocko wrote:
> > > [...]
> > > > > Hmm. The changelog says "By default, it will look for the biggest leaf
> > > > > cgroup, and kill the largest task inside." But you are accumulating
> > > > > oom_score up the hierarchy and so parents will have higher score than
> > > > > the layer of their children and the larger the sub-hierarchy the more
> > > > > biased it will become. Say you have
> > > > > 	root
> > > > >          /\
> > > > >         /  \
> > > > >        A    D
> > > > >       / \
> > > > >      B   C
> > > > > 
> > > > > B (5), C(15) thus A(20) and D(20). Unless I am missing something we are
> > > > > going to go down A path and then chose C even though D is the largest
> > > > > leaf group, right?
> > > > 
> > > > You're right, changelog is not accurate, I'll fix it.
> > > > The behavior is correct, IMO.
> > > 
> > > Please explain why. This is really a non-intuitive semantic. Why should
> > > larger hierarchies be punished more than shallow ones? I would
> > > completely agree if the whole hierarchy would be a killable entity (aka
> > > A would be kill-all).
> > 
> > I think it's a reasonable and clear policy: we're looking for a memcg
> > with the smallest oom_priority and largest memory footprint recursively.
> 
> But this can get really complex for non-trivial setups. Anything with
> deeper and larger hierarchies will get quite complex IMHO.
> 
> Btw. do you have any specific usecase for the priority based oom
> killer? I remember David was asking for this because it _would_ be
> useful but you didn't have it initially. And I agree with that I am
> just not sure the semantic is thought through wery well. I am thinking
> whether it would be easier to push this further without priority thing
> for now and add it later with a clear example of the configuration and
> how it should work and a more thought through semantic. Would that sound
> acceptable? I believe the rest is quite useful to get merged on its own.

Any way to set up which memcgs should be killed in first order,
and which in the last will more or less suit me.
Initially I did have somewhat similar to the per-cgroup oom_score_adj.
But I really like David's idea here.
It's just much more simple and also more powerful:
clear semantics and long priority range will allow implementing
policies in userspace.

All priority-related stuff except docs is already separated.
Of course, I can split docs too.

Although, I don't think the whole thing is useful without any way
to adjust the memcg selection, so we can't postpone if for too long.
Anyway, if you think it's a way to go forward, let's do it.

> 
> > Then we reclaim some memory from it (by killing the biggest process
> > or all processes, depending on memcg preferences).
> > 
> > In general, if there are two memcgs of equal importance (which is defined
> > by setting the oom_priority), we're choosing the largest, because there
> > are more chances that it contain a leaking process. The same is true
> > right now for processes.
> 
> Yes except this is not the case as shown above. We can easily select a
> smaller leaf memcg just because it is in a larger hierarchy and that
> sounds very dubious to me. Even when all the priorities are the same.
> 
> > I agree, that for size-based comparison we could use a different policy:
> > comparing leaf cgroups despite their level. But I don't see a clever
> > way to apply oom_priorities in this case. Comparing oom_priority
> > on each level is a simple and powerful policy, and it works well
> > for delegation.
> 
> You are already shaping semantic around the implementation and that is a
> clear sign of problem.
>  
> > > [...]
> > > > > I do not understand why do we have to handle root cgroup specially here.
> > > > > select_victim_memcg already iterates all memcgs in the oom hierarchy
> > > > > (including root) so if the root memcg is the largest one then we
> > > > > should simply consider it no?
> > > > 
> > > > We don't have necessary stats for the root cgroup, so we can't calculate
> > > > it's oom_score.
> > > 
> > > We used to charge pages to the root memcg as well so we might resurrect
> > > that idea. In any case this is something that could be hidden in
> > > memcg_oom_badness rather then special cased somewhere else.
> > 
> > In theory I agree, but I do not see a good way to calculate root memcg
> > oom_score.
> 
> Why cannot you emulate that by the largest task in the root? The same
> way you actually do in select_victim_root_cgroup_task now?

Hm, this sounds good! Then I can apply the same policy for root memcg,
treating it as level 1 leaf memcg.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
