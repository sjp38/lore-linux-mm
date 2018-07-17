Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BAE0C6B000D
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 00:06:32 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id k9-v6so8986095pff.5
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 21:06:32 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j24-v6sor6268916pfe.146.2018.07.16.21.06.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Jul 2018 21:06:31 -0700 (PDT)
Date: Mon, 16 Jul 2018 21:06:30 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v3 -mm 3/6] mm, memcg: add hierarchical usage oom
 policy
In-Reply-To: <20180716181613.GA28327@castle>
Message-ID: <alpine.DEB.2.21.1807162101170.157949@chino.kir.corp.google.com>
References: <alpine.DEB.2.20.1803121755590.192200@chino.kir.corp.google.com> <alpine.DEB.2.20.1803151351140.55261@chino.kir.corp.google.com> <alpine.DEB.2.20.1803161405410.209509@chino.kir.corp.google.com> <alpine.DEB.2.20.1803221451370.17056@chino.kir.corp.google.com>
 <alpine.DEB.2.21.1807131604560.217600@chino.kir.corp.google.com> <alpine.DEB.2.21.1807131605590.217600@chino.kir.corp.google.com> <20180716181613.GA28327@castle>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 16 Jul 2018, Roman Gushchin wrote:

> Hello, David!
> 
> I think that there is an inconsistency in the memory.oom_policy definition.
> "none" and "cgroup" policies defining how the OOM scoped to this particular
> memory cgroup (or system, if set on root) is handled. And all sub-tree
> settings do not matter at all, right? Also, if a memory cgroup has no
> memory.max set, there is no meaning in setting memory.oom_policy.
> 

Hi Roman,

The effective oom policy is based on the mem cgroup that is oom.  That can 
occur when memory.max is set, yes.

If a mem cgroup does not become oom itself, its oom policy doesn't do 
anything until, well, it's oom :)

> And "tree" is different. It actually changes how the selection algorithm works,
> and sub-tree settings do matter in this case.
> 

"Tree" is considering the entity as a single indivisible memory consumer, 
it is compared with siblings based on its hierarhical usage.  It has 
cgroup oom policy.

It would be possible to separate this out, if you'd prefer, to account 
an intermediate cgroup as the largest descendant or the sum of all 
descendants.  I hadn't found a usecase for that, however, but it doesn't 
mean there isn't one.  If you'd like, I can introduce another tunable.
