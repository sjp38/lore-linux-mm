Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A8ECF280415
	for <linux-mm@kvack.org>; Wed,  6 Sep 2017 04:29:04 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 187so5705348wmn.2
        for <linux-mm@kvack.org>; Wed, 06 Sep 2017 01:29:04 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f8si2079832wra.259.2017.09.06.01.29.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Sep 2017 01:29:03 -0700 (PDT)
Date: Wed, 6 Sep 2017 10:28:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v7 5/5] mm, oom: cgroup v2 mount option to disable cgroup-aware
 OOM killer
Message-ID: <20170906082859.qlqenftxuib64j35@dhcp22.suse.cz>
References: <20170904142108.7165-1-guro@fb.com>
 <20170904142108.7165-6-guro@fb.com>
 <20170905134412.qdvqcfhvbdzmarna@dhcp22.suse.cz>
 <20170905215344.GA27427@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170905215344.GA27427@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 05-09-17 17:53:44, Johannes Weiner wrote:
> On Tue, Sep 05, 2017 at 03:44:12PM +0200, Michal Hocko wrote:
> > Why is this an opt out rather than opt-in? IMHO the original oom logic
> > should be preserved by default and specific workloads should opt in for
> > the cgroup aware logic. Changing the global behavior depending on
> > whether cgroup v2 interface is in use is more than unexpected and IMHO
> > wrong approach to take. I think we should instead go with 
> > oom_strategy=[alloc_task,biggest_task,cgroup]
> > 
> > we currently have alloc_task (via sysctl_oom_kill_allocating_task) and
> > biggest_task which is the default. You are adding cgroup and the more I
> > think about the more I agree that it doesn't really make sense to try to
> > fit thew new semantic into the existing one (compare tasks to kill-all
> > memcgs). Just introduce a new strategy and define a new semantic from
> > scratch. Memcg priority and kill-all are a natural extension of this new
> > strategy. This will make the life easier and easier to understand by
> > users.
> 
> oom_kill_allocating_task is actually a really good example of why
> cgroup-awareness *should* be the new default.
> 
> Before we had the oom killer victim selection, we simply killed the
> faulting/allocating task. While a valid answer to the problem, it's
> not very fair or representative of what the user wants or intends.
> 
> Then we added code to kill the biggest offender instead, which should
> have been the case from the start and was hence made the new default.
> The oom_kill_allocating_task was added on the off-chance that there
> might be setups who, for historical reasons, rely on the old behavior.
> But our default was chosen based on what behavior is fair, expected,
> and most reflective of the user's intentions.

I am not sure this is how things evolved actually. This is way before
my time so my git log interpretation might be imprecise. We do have
oom_badness heuristic since out_of_memory has been introduced and
oom_kill_allocating_task has been introduced much later because of large
boxes with zillions of tasks (SGI I suspect) which took too long to
select a victim so David has added this heuristic.
 
> The cgroup-awareness in the OOM killer is exactly the same thing. It
> should have been the default from the beginning, because the user
> configures a group of tasks to be an interdependent, terminal unit of
> memory consumption, and it's undesirable for the OOM killer to ignore
> this intention and compare members across these boundaries.

I would agree if that was true in general. I can completely see how the
cgroup awareness is useful in e.g. containerized environments (especially
with kill-all enabled) but memcgs are used in a large variety of
usecases and I cannot really say all of them really demand the new
semantic. Say I have a workload which doesn't want to see reclaim
interference from others on the same machine. Why should I kill a
process from that particular memcg just because it is the largest one
when there is a memory hog/leak outside of this memcg?

>From my point of view the safest (in a sense of the least surprise)
way to go with opt-in for the new heuristic. I am pretty sure all who
would benefit from the new behavior will enable it while others will not
regress in unexpected way.

We can talk about the way _how_ to control these oom strategies, of
course. But I would be really reluctant to change the default which is
used for years and people got used to it.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
