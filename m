Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 220F96B0007
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 13:45:21 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id k21-v6so16192334qtj.23
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 10:45:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g32-v6sor8130980qve.43.2018.08.01.10.45.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Aug 2018 10:45:20 -0700 (PDT)
Date: Wed, 1 Aug 2018 13:48:14 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/3] mm, oom: introduce memory.oom.group
Message-ID: <20180801174814.GC11386@cmpxchg.org>
References: <20180730180100.25079-1-guro@fb.com>
 <20180730180100.25079-4-guro@fb.com>
 <20180731090700.GF4557@dhcp22.suse.cz>
 <20180801011447.GB25953@castle.DHCP.thefacebook.com>
 <20180801055503.GB16767@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180801055503.GB16767@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Wed, Aug 01, 2018 at 07:55:03AM +0200, Michal Hocko wrote:
> On Tue 31-07-18 18:14:48, Roman Gushchin wrote:
> > On Tue, Jul 31, 2018 at 11:07:00AM +0200, Michal Hocko wrote:
> > > On Mon 30-07-18 11:01:00, Roman Gushchin wrote:
> > > > +struct mem_cgroup *mem_cgroup_get_oom_group(struct task_struct *victim,
> > > > +					    struct mem_cgroup *oom_domain)
> > > > +{
> > > > +	struct mem_cgroup *oom_group = NULL;
> > > > +	struct mem_cgroup *memcg;
> > > > +
> > > > +	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys))
> > > > +		return NULL;
> > > > +
> > > > +	if (!oom_domain)
> > > > +		oom_domain = root_mem_cgroup;
> > > > +
> > > > +	rcu_read_lock();
> > > > +
> > > > +	memcg = mem_cgroup_from_task(victim);
> > > > +	if (!memcg || memcg == root_mem_cgroup)
> > > > +		goto out;
> > > 
> > > When can we have memcg == NULL? victim should be always non-NULL.
> > > Also why do you need to special case the root_mem_cgroup here. The loop
> > > below should handle that just fine no?
> > 
> > Idk, I prefer to keep an explicit root_mem_cgroup check,
> > rather than traversing the tree and relying on an inability
> > to set oom_group on the root.
> 
> I will not insist but this just makes the code harder to read.

Just FYI, I'd prefer the explicit check. The loop would do the right
thing, but it's a little too implicit and subtle for my taste...
