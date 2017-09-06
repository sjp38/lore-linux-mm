Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1D3A6280415
	for <linux-mm@kvack.org>; Wed,  6 Sep 2017 04:32:03 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l19so5735361wmi.1
        for <linux-mm@kvack.org>; Wed, 06 Sep 2017 01:32:03 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q13si1928379wrd.352.2017.09.06.01.32.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Sep 2017 01:32:01 -0700 (PDT)
Date: Wed, 6 Sep 2017 10:31:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v7 2/5] mm, oom: cgroup-aware OOM killer
Message-ID: <20170906083158.gvqx6pekrsy2ya47@dhcp22.suse.cz>
References: <20170904142108.7165-1-guro@fb.com>
 <20170904142108.7165-3-guro@fb.com>
 <20170905145700.fd7jjd37xf4tb55h@dhcp22.suse.cz>
 <20170905202357.GA10535@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170905202357.GA10535@castle.DHCP.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 05-09-17 21:23:57, Roman Gushchin wrote:
> On Tue, Sep 05, 2017 at 04:57:00PM +0200, Michal Hocko wrote:
[...]
> > Hmm. The changelog says "By default, it will look for the biggest leaf
> > cgroup, and kill the largest task inside." But you are accumulating
> > oom_score up the hierarchy and so parents will have higher score than
> > the layer of their children and the larger the sub-hierarchy the more
> > biased it will become. Say you have
> > 	root
> >          /\
> >         /  \
> >        A    D
> >       / \
> >      B   C
> > 
> > B (5), C(15) thus A(20) and D(20). Unless I am missing something we are
> > going to go down A path and then chose C even though D is the largest
> > leaf group, right?
> 
> You're right, changelog is not accurate, I'll fix it.
> The behavior is correct, IMO.

Please explain why. This is really a non-intuitive semantic. Why should
larger hierarchies be punished more than shallow ones? I would
completely agree if the whole hierarchy would be a killable entity (aka
A would be kill-all).
 
[...]
> > I do not understand why do we have to handle root cgroup specially here.
> > select_victim_memcg already iterates all memcgs in the oom hierarchy
> > (including root) so if the root memcg is the largest one then we
> > should simply consider it no?
> 
> We don't have necessary stats for the root cgroup, so we can't calculate
> it's oom_score.

We used to charge pages to the root memcg as well so we might resurrect
that idea. In any case this is something that could be hidden in
memcg_oom_badness rather then special cased somewhere else.

> > You are skipping root there because of
> > memcg_has_children but I suspect this and the whole accumulate up the
> > hierarchy approach just makes the whole thing more complex than necessary. With
> > "tasks only in leafs" cgroup policy we should only see any pages on LRUs
> > on the global root memcg and leaf cgroups. The same applies to memcg
> > stats. So why cannot we simply do the tree walk, calculate
> > badness/check the priority and select the largest memcg in one go?
> 
> We have to traverse from top to bottom to make priority-based decision,
> but size-based oom_score is calculated as sum of descending leaf cgroup scores.
> 
> For example:
>  	root
>           /\
>          /  \
>         A    D
>        / \
>       B   C
> A and D have same priorities, B has larger priority than C.
> 
> In this case we need to calculate size-based score for A, which requires
> summing oom_score of the sub-tree (B an C), despite we don't need it
> for choosing between B and C.
> 
> Maybe I don't see it, but I don't know how to implement it more optimal.

I have to think about the priority based oom killing some more to be
honest. Do we really want to allow setting a priority to non-leaf
memcgs? How are you going to manage the whole tree consistency? Say your
above example have prio(A) < prio(D) && prio(C) > prio(D). Your current
implementation would kill D, right? Isn't that counter intuitive
behavior again. If anything we should prio(A) = max(tree_prio(A)). Again
I could understand comparing priorities only on killable entities.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
