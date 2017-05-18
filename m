Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id AAE68831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 16:15:42 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id u96so790890wrc.7
        for <linux-mm@kvack.org>; Thu, 18 May 2017 13:15:42 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 27si6143522edv.178.2017.05.18.13.15.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 May 2017 13:15:41 -0700 (PDT)
Date: Thu, 18 May 2017 16:15:24 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH] mm, oom: cgroup-aware OOM-killer
Message-ID: <20170518201524.GA32135@cmpxchg.org>
References: <1495124884-28974-1-git-send-email-guro@fb.com>
 <20170518173002.GC30148@dhcp22.suse.cz>
 <CAKTCnzkBNV9bsQSg4kzhxY=i=-y3x78StbbXfV9mvXLsJhGHig@mail.gmail.com>
 <20170518192240.GA29914@cmpxchg.org>
 <1495136639.21894.3.camel@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1495136639.21894.3.camel@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, kernel-team@fb.com, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Fri, May 19, 2017 at 05:43:59AM +1000, Balbir Singh wrote:
> On Thu, 2017-05-18 at 15:22 -0400, Johannes Weiner wrote:
> > On Fri, May 19, 2017 at 04:37:27AM +1000, Balbir Singh wrote:
> > > On Fri, May 19, 2017 at 3:30 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > > > On Thu 18-05-17 17:28:04, Roman Gushchin wrote:
> > > > > Traditionally, the OOM killer is operating on a process level.
> > > > > Under oom conditions, it finds a process with the highest oom score
> > > > > and kills it.
> > > > > 
> > > > > This behavior doesn't suit well the system with many running
> > > > > containers. There are two main issues:
> > > > > 
> > > > > 1) There is no fairness between containers. A small container with
> > > > > a few large processes will be chosen over a large one with huge
> > > > > number of small processes.
> > > > > 
> > > > > 2) Containers often do not expect that some random process inside
> > > > > will be killed. So, in general, a much safer behavior is
> > > > > to kill the whole cgroup. Traditionally, this was implemented
> > > > > in userspace, but doing it in the kernel has some advantages,
> > > > > especially in a case of a system-wide OOM.
> > > > > 
> > > > > To address these issues, cgroup-aware OOM killer is introduced.
> > > > > Under OOM conditions, it looks for a memcg with highest oom score,
> > > > > and kills all processes inside.
> > > > > 
> > > > > Memcg oom score is calculated as a size of active and inactive
> > > > > anon LRU lists, unevictable LRU list and swap size.
> > > > > 
> > > > > For a cgroup-wide OOM, only cgroups belonging to the subtree of
> > > > > the OOMing cgroup are considered.
> > > > 
> > > > While this might make sense for some workloads/setups it is not a
> > > > generally acceptable policy IMHO. We have discussed that different OOM
> > > > policies might be interesting few years back at LSFMM but there was no
> > > > real consensus on how to do that. One possibility was to allow bpf like
> > > > mechanisms. Could you explore that path?
> > > 
> > > I agree, I think it needs more thought. I wonder if the real issue is something
> > > else. For example
> > > 
> > > 1. Did we overcommit a particular container too much?
> > > 2. Do we need something like https://lwn.net/Articles/604212/ to solve
> > > the problem?
> > 
> > The occasional OOM kill is an unavoidable reality on our systems (and
> > I bet on most deployments). If we tried not to overcommit, we'd waste
> > a *lot* of memory.
> > 
> > The problem is when OOM happens, we really want the biggest *job* to
> > get killed. Before cgroups, we assumed jobs were processes. But with
> > cgroups, the user is able to define a group of processes as a job, and
> > then an individual process is no longer a first-class memory consumer.
> > 
> > Without a patch like this, the OOM killer will compare the sizes of
> > the random subparticles that the jobs in the system are composed of
> > and kill the single biggest particle, leaving behind the incoherent
> > remains of one of the jobs. That doesn't make a whole lot of sense.
> 
> I agree, but see my response on oom_notifiers in parallel that I sent
> to Roman.

I don't see how they're related to an abstraction problem in the
victim evaluation.

> > If you want to determine the most expensive car in a parking lot, you
> > can't go off and compare the price of one car's muffler with the door
> > handle of another, then point to a wind shield and yell "This is it!"
> > 
> > You need to compare the cars as a whole with each other.
> > 
> > > 3. We have oom notifiers now, could those be used (assuming you are interested
> > > in non memcg related OOM's affecting a container
> > 
> > Right now, we watch for OOM notifications and then have userspace kill
> > the rest of a job. That works - somewhat. What remains is the problem
> > that I described above, that comparing individual process sizes is not
> > meaningful when the terminal memory consumer is a cgroup.
> 
> Could the cgroup limit be used as the comparison point? stats inside
> of the memory cgroup?

The OOM is a result of physical memory shortage, but the limits don't
tell you how much physical memory you are consuming - only how much
you might if it weren't for a lack of physical memory.

We *do* use the stats inside of the cgroup, namely the amount of
memory they consumed overall, to compare them against each other.

As far as configurable priorities comparable to the oom score on the
system level goes, that's seems like a separate discussion. We could
add memory.oom_score, we could think about subtracting memory.low from
the badness of each cgroup (as that's the portion the group is
supposed to be able to consume in peace, and which we always expect to
be available in physical memory, so we want to kill the group with the
most overage above the memory.low limit) etc.

Either way, it's always possible to add configurability as patch 2/2.
Again, this patch is first and foremost about functionality, not about
interfacing and configurability.

> > > 4. How do we determine limits for these containers? From a fariness
> > > perspective
> > 
> > How do you mean?
> 
> How do we set them up so that the larger job gets more of the limits
> as opposed to the small ones?

I'm afraid I still don't entirely understand.

Is this about comparing groups not just by their physical size, but
also by their *intended* size and the difference between the two?
Meaning that a 10G-limit group with 9G allocated could be considered a
larger consumer than a 20G-limit group with 10G worth of memory?

If yes, I think that's where the fact that you overcommit comes
in. Because clearly you don't have 30G - the sum of the memory.max
limits - to hand out, seeing that you OOMed when these groups have
only 19G combined. So the memory.max settings cannot be considered the
intended distribution of memory in the system.

But that's exactly what memory.low is for.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
