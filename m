Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 77B51831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 15:21:47 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id j13so17780470qta.13
        for <linux-mm@kvack.org>; Thu, 18 May 2017 12:21:47 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id b128si4420510qkf.321.2017.05.18.12.21.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 May 2017 12:21:46 -0700 (PDT)
Date: Thu, 18 May 2017 20:20:50 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [RFC PATCH] mm, oom: cgroup-aware OOM-killer
Message-ID: <20170518192050.GA1648@castle>
References: <1495124884-28974-1-git-send-email-guro@fb.com>
 <20170518173002.GC30148@dhcp22.suse.cz>
 <CAKTCnzkBNV9bsQSg4kzhxY=i=-y3x78StbbXfV9mvXLsJhGHig@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CAKTCnzkBNV9bsQSg4kzhxY=i=-y3x78StbbXfV9mvXLsJhGHig@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, kernel-team@fb.com, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Fri, May 19, 2017 at 04:37:27AM +1000, Balbir Singh wrote:
> On Fri, May 19, 2017 at 3:30 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Thu 18-05-17 17:28:04, Roman Gushchin wrote:
> >> Traditionally, the OOM killer is operating on a process level.
> >> Under oom conditions, it finds a process with the highest oom score
> >> and kills it.
> >>
> >> This behavior doesn't suit well the system with many running
> >> containers. There are two main issues:
> >>
> >> 1) There is no fairness between containers. A small container with
> >> a few large processes will be chosen over a large one with huge
> >> number of small processes.
> >>
> >> 2) Containers often do not expect that some random process inside
> >> will be killed. So, in general, a much safer behavior is
> >> to kill the whole cgroup. Traditionally, this was implemented
> >> in userspace, but doing it in the kernel has some advantages,
> >> especially in a case of a system-wide OOM.
> >>
> >> To address these issues, cgroup-aware OOM killer is introduced.
> >> Under OOM conditions, it looks for a memcg with highest oom score,
> >> and kills all processes inside.
> >>
> >> Memcg oom score is calculated as a size of active and inactive
> >> anon LRU lists, unevictable LRU list and swap size.
> >>
> >> For a cgroup-wide OOM, only cgroups belonging to the subtree of
> >> the OOMing cgroup are considered.
> >
> > While this might make sense for some workloads/setups it is not a
> > generally acceptable policy IMHO. We have discussed that different OOM
> > policies might be interesting few years back at LSFMM but there was no
> > real consensus on how to do that. One possibility was to allow bpf like
> > mechanisms. Could you explore that path?
> 
> I agree, I think it needs more thought. I wonder if the real issue is something
> else. For example
> 
> 1. Did we overcommit a particular container too much?

Imagine, you have a machine with multiple containers,
each with it's own process tree, and the machine is overcommited,
i.e. sum of container's memory limits is larger the amount available RAM.

In a case of a system-wide OOM some random container will be affected.

Historically, this problem was solving by some user-space daemon,
which was monitoring OOM events and cleaning up affected containers.
But this approach can't solve the main problem: non-optimal selection
of a victim. 

> 2. Do we need something like https://urldefense.proofpoint.com/v2/url?u=https-3A__lwn.net_Articles_604212_&d=DwIBaQ&c=5VD0RTtNlTh3ycd41b3MUw&r=jJYgtDM7QT-W-Fz_d29HYQ&m=9jV4id5lmsjFJj1kQjJk0auyQ3bzL27-f6Ur6ZNw36c&s=ElsS25CoZSPba6ke7O-EIsR7lN0psP6tDVyLnGqCMfs&e=  to solve
> the problem?

I don't think it's related.

> 3. We have oom notifiers now, could those be used (assuming you are interested
> in non memcg related OOM's affecting a container

They can be used to inform an userspace daemon about an already happened OOM,
but they do not affect victim selection.

> 4. How do we determine limits for these containers? From a fariness
> perspective

Limits are usually set from some high-level understanding of the nature
of tasks which are working inside, but overcommiting the machine is
a common place, I assume.

Thank you!

Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
