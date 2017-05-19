Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2E4CA831F4
	for <linux-mm@kvack.org>; Fri, 19 May 2017 04:02:13 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id j27so3516353wre.3
        for <linux-mm@kvack.org>; Fri, 19 May 2017 01:02:13 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c14si8444973edf.153.2017.05.19.01.02.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 May 2017 01:02:11 -0700 (PDT)
Date: Fri, 19 May 2017 10:02:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, oom: cgroup-aware OOM-killer
Message-ID: <20170519080208.GD13041@dhcp22.suse.cz>
References: <1495124884-28974-1-git-send-email-guro@fb.com>
 <20170518173002.GC30148@dhcp22.suse.cz>
 <20170518181117.GA27689@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170518181117.GA27689@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 18-05-17 14:11:17, Johannes Weiner wrote:
> On Thu, May 18, 2017 at 07:30:04PM +0200, Michal Hocko wrote:
> > On Thu 18-05-17 17:28:04, Roman Gushchin wrote:
> > > Traditionally, the OOM killer is operating on a process level.
> > > Under oom conditions, it finds a process with the highest oom score
> > > and kills it.
> > > 
> > > This behavior doesn't suit well the system with many running
> > > containers. There are two main issues:
> > > 
> > > 1) There is no fairness between containers. A small container with
> > > a few large processes will be chosen over a large one with huge
> > > number of small processes.
> > > 
> > > 2) Containers often do not expect that some random process inside
> > > will be killed. So, in general, a much safer behavior is
> > > to kill the whole cgroup. Traditionally, this was implemented
> > > in userspace, but doing it in the kernel has some advantages,
> > > especially in a case of a system-wide OOM.
> > > 
> > > To address these issues, cgroup-aware OOM killer is introduced.
> > > Under OOM conditions, it looks for a memcg with highest oom score,
> > > and kills all processes inside.
> > > 
> > > Memcg oom score is calculated as a size of active and inactive
> > > anon LRU lists, unevictable LRU list and swap size.
> > > 
> > > For a cgroup-wide OOM, only cgroups belonging to the subtree of
> > > the OOMing cgroup are considered.
> > 
> > While this might make sense for some workloads/setups it is not a
> > generally acceptable policy IMHO. We have discussed that different OOM
> > policies might be interesting few years back at LSFMM but there was no
> > real consensus on how to do that. One possibility was to allow bpf like
> > mechanisms. Could you explore that path?
> 
> OOM policy is an orthogonal discussion, though.
> 
> The OOM killer's job is to pick a memory consumer to kill. Per default
> the unit of the memory consumer is a process, but cgroups allow
> grouping processes into compound consumers. Extending the OOM killer
> to respect the new definition of "consumer" is not a new policy.

I do not want to play word games here but picking a task or more tasks
is a policy from my POV but that is not all that important. My primary
point is that this new "implementation" is most probably not what people
who use memory cgroups outside of containers want. Why? Mostly because
they do not care that only a part of the memcg is still alive pretty
much like the current global OOM behavior when a single task (or its
children) are gone all of the sudden. Why should I kill the whole user
slice just because one of its processes went wild?
 
> I don't think it's reasonable to ask the person who's trying to make
> the OOM killer support group-consumers to design a dynamic OOM policy
> framework instead.
> 
> All we want is the OOM policy, whatever it is, applied to cgroups.

And I am not dismissing this usecase. I believe it is valid but not
universally applicable when memory cgroups are deployed. That is why
I think that we need a way to define those policies in some sane way.
Our current oom policies are basically random -
/proc/sys/vm/oom_kill_allocating_task resp. /proc/sys/vm/panic_on_oom.

I am not really sure we want another hardcoded one e.g.
/proc/sys/vm/oom_kill_container because even that might turn out not the
great fit for different container usecases. Do we want to kill the
largest container or the one with the largest memory hog? Should some
containers have a higher priority over others? I am pretty sure more
criterion would pop up with more usecases.

That's why I think that the current OOM killer implementation should
stay as a last resort and be process oriented and we should think about
a way to override it for particular usecases. The exact mechanism is not
completely clear to me to be honest.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
