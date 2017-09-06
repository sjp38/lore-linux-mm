Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 94033280428
	for <linux-mm@kvack.org>; Wed,  6 Sep 2017 08:58:33 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id j141so1192417ioj.0
        for <linux-mm@kvack.org>; Wed, 06 Sep 2017 05:58:33 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id h187si1331771ita.120.2017.09.06.05.58.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Sep 2017 05:58:32 -0700 (PDT)
Date: Wed, 6 Sep 2017 13:57:50 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v7 2/5] mm, oom: cgroup-aware OOM killer
Message-ID: <20170906125750.GB12904@castle>
References: <20170904142108.7165-1-guro@fb.com>
 <20170904142108.7165-3-guro@fb.com>
 <20170905145700.fd7jjd37xf4tb55h@dhcp22.suse.cz>
 <20170905202357.GA10535@castle.DHCP.thefacebook.com>
 <20170906083158.gvqx6pekrsy2ya47@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170906083158.gvqx6pekrsy2ya47@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Sep 06, 2017 at 10:31:58AM +0200, Michal Hocko wrote:
> On Tue 05-09-17 21:23:57, Roman Gushchin wrote:
> > On Tue, Sep 05, 2017 at 04:57:00PM +0200, Michal Hocko wrote:
> [...]
> > > Hmm. The changelog says "By default, it will look for the biggest leaf
> > > cgroup, and kill the largest task inside." But you are accumulating
> > > oom_score up the hierarchy and so parents will have higher score than
> > > the layer of their children and the larger the sub-hierarchy the more
> > > biased it will become. Say you have
> > > 	root
> > >          /\
> > >         /  \
> > >        A    D
> > >       / \
> > >      B   C
> > > 
> > > B (5), C(15) thus A(20) and D(20). Unless I am missing something we are
> > > going to go down A path and then chose C even though D is the largest
> > > leaf group, right?
> > 
> > You're right, changelog is not accurate, I'll fix it.
> > The behavior is correct, IMO.
> 
> Please explain why. This is really a non-intuitive semantic. Why should
> larger hierarchies be punished more than shallow ones? I would
> completely agree if the whole hierarchy would be a killable entity (aka
> A would be kill-all).

I think it's a reasonable and clear policy: we're looking for a memcg
with the smallest oom_priority and largest memory footprint recursively.
Then we reclaim some memory from it (by killing the biggest process
or all processes, depending on memcg preferences).

In general, if there are two memcgs of equal importance (which is defined
by setting the oom_priority), we're choosing the largest, because there
are more chances that it contain a leaking process. The same is true
right now for processes.

I agree, that for size-based comparison we could use a different policy:
comparing leaf cgroups despite their level. But I don't see a clever
way to apply oom_priorities in this case. Comparing oom_priority
on each level is a simple and powerful policy, and it works well
for delegation.

>  
> [...]
> > > I do not understand why do we have to handle root cgroup specially here.
> > > select_victim_memcg already iterates all memcgs in the oom hierarchy
> > > (including root) so if the root memcg is the largest one then we
> > > should simply consider it no?
> > 
> > We don't have necessary stats for the root cgroup, so we can't calculate
> > it's oom_score.
> 
> We used to charge pages to the root memcg as well so we might resurrect
> that idea. In any case this is something that could be hidden in
> memcg_oom_badness rather then special cased somewhere else.

In theory I agree, but I do not see a good way to calculate root memcg
oom_score.

> 
> > > You are skipping root there because of
> > > memcg_has_children but I suspect this and the whole accumulate up the
> > > hierarchy approach just makes the whole thing more complex than necessary. With
> > > "tasks only in leafs" cgroup policy we should only see any pages on LRUs
> > > on the global root memcg and leaf cgroups. The same applies to memcg
> > > stats. So why cannot we simply do the tree walk, calculate
> > > badness/check the priority and select the largest memcg in one go?
> > 
> > We have to traverse from top to bottom to make priority-based decision,
> > but size-based oom_score is calculated as sum of descending leaf cgroup scores.
> > 
> > For example:
> >  	root
> >           /\
> >          /  \
> >         A    D
> >        / \
> >       B   C
> > A and D have same priorities, B has larger priority than C.
> > 
> > In this case we need to calculate size-based score for A, which requires
> > summing oom_score of the sub-tree (B an C), despite we don't need it
> > for choosing between B and C.
> > 
> > Maybe I don't see it, but I don't know how to implement it more optimal.
> 
> I have to think about the priority based oom killing some more to be
> honest. Do we really want to allow setting a priority to non-leaf
> memcgs? How are you going to manage the whole tree consistency? Say your
> above example have prio(A) < prio(D) && prio(C) > prio(D). Your current
> implementation would kill D, right?

Right.

> Isn't that counter intuitive
> behavior again. If anything we should prio(A) = max(tree_prio(A)). Again
> I could understand comparing priorities only on killable entities.

Answered above.
Also, I don't think any per-memcg knobs should have global meaning,
despite parent memcg settings. It will break delegation model.

Thanks!

Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
