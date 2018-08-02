Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id C7EDC6B0003
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 08:14:52 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id w1-v6so1255805ply.12
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 05:14:52 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g1-v6si1336718plo.176.2018.08.02.05.14.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Aug 2018 05:14:51 -0700 (PDT)
Date: Thu, 2 Aug 2018 14:14:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 3/3] mm, oom: introduce memory.oom.group
Message-ID: <20180802121446.GK10808@dhcp22.suse.cz>
References: <20180802003201.817-1-guro@fb.com>
 <20180802003201.817-4-guro@fb.com>
 <879f1767-8b15-4e83-d9ef-d8df0e8b4d83@i-love.sakura.ne.jp>
 <20180802112114.GG10808@dhcp22.suse.cz>
 <712a319f-c9da-230a-f2cb-af980daff704@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <712a319f-c9da-230a-f2cb-af980daff704@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Thu 02-08-18 20:53:14, Tetsuo Handa wrote:
> On 2018/08/02 20:21, Michal Hocko wrote:
> > On Thu 02-08-18 19:53:13, Tetsuo Handa wrote:
> >> On 2018/08/02 9:32, Roman Gushchin wrote:
> > [...]
> >>> +struct mem_cgroup *mem_cgroup_get_oom_group(struct task_struct *victim,
> >>> +					    struct mem_cgroup *oom_domain)
> >>> +{
> >>> +	struct mem_cgroup *oom_group = NULL;
> >>> +	struct mem_cgroup *memcg;
> >>> +
> >>> +	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys))
> >>> +		return NULL;
> >>> +
> >>> +	if (!oom_domain)
> >>> +		oom_domain = root_mem_cgroup;
> >>> +
> >>> +	rcu_read_lock();
> >>> +
> >>> +	memcg = mem_cgroup_from_task(victim);
> >>
> >> Isn't this racy? I guess that memcg of this "victim" can change to
> >> somewhere else from the one as of determining the final candidate.
> > 
> > How is this any different from the existing code? We select a victim and
> > then kill it. The victim might move away and won't be part of the oom
> > memcg anymore but we will still kill it. I do not remember this ever
> > being a problem. Migration is a privileged operation. If you loose this
> > restriction you shouldn't allow to move outside of the oom domain.
> 
> The existing code kills one process (plus other processes sharing mm if any).
> But oom_cgroup kills multiple processes. Thus, whether we made decision based
> on correct memcg becomes important.

Yes but a proper configuration should already mitigate the harm because
you shouldn't be able to migrate the task outside of the oom domain.
	A (oom.group = 1)
       / \
      B   C

moving task between B and C should be harmless while moving it out of A
subtree completely is a dubious configuration.

> >> This "victim" might have already passed exit_mm()/cgroup_exit() from do_exit().
> > 
> > Why does this matter? The victim hasn't been killed yet so if it exists
> > by its own I do not think we really have to tear the whole cgroup down.
> 
> The existing code does not send SIGKILL if find_lock_task_mm() failed. Who can
> guarantee that the victim is not inside do_exit() yet when this code is executed?

I do not follow. Why does this matter at all?

-- 
Michal Hocko
SUSE Labs
