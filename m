Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 56A9C831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 15:42:03 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id n75so38944575pfh.0
        for <linux-mm@kvack.org>; Thu, 18 May 2017 12:42:03 -0700 (PDT)
Received: from mail-pf0-x22f.google.com (mail-pf0-x22f.google.com. [2607:f8b0:400e:c00::22f])
        by mx.google.com with ESMTPS id r10si5990943pfl.269.2017.05.18.12.42.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 May 2017 12:42:02 -0700 (PDT)
Received: by mail-pf0-x22f.google.com with SMTP id 9so28568817pfj.1
        for <linux-mm@kvack.org>; Thu, 18 May 2017 12:42:02 -0700 (PDT)
Message-ID: <1495136464.21894.1.camel@gmail.com>
Subject: Re: [RFC PATCH] mm, oom: cgroup-aware OOM-killer
From: Balbir Singh <bsingharora@gmail.com>
Date: Fri, 19 May 2017 05:41:04 +1000
In-Reply-To: <20170518192050.GA1648@castle>
References: <1495124884-28974-1-git-send-email-guro@fb.com>
	 <20170518173002.GC30148@dhcp22.suse.cz>
	 <CAKTCnzkBNV9bsQSg4kzhxY=i=-y3x78StbbXfV9mvXLsJhGHig@mail.gmail.com>
	 <20170518192050.GA1648@castle>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, kernel-team@fb.com, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "open
 list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Thu, 2017-05-18 at 20:20 +0100, Roman Gushchin wrote:
> On Fri, May 19, 2017 at 04:37:27AM +1000, Balbir Singh wrote:
> > On Fri, May 19, 2017 at 3:30 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > > On Thu 18-05-17 17:28:04, Roman Gushchin wrote:
> > > > Traditionally, the OOM killer is operating on a process level.
> > > > Under oom conditions, it finds a process with the highest oom score
> > > > and kills it.
> > > > 
> > > > This behavior doesn't suit well the system with many running
> > > > containers. There are two main issues:
> > > > 
> > > > 1) There is no fairness between containers. A small container with
> > > > a few large processes will be chosen over a large one with huge
> > > > number of small processes.
> > > > 
> > > > 2) Containers often do not expect that some random process inside
> > > > will be killed. So, in general, a much safer behavior is
> > > > to kill the whole cgroup. Traditionally, this was implemented
> > > > in userspace, but doing it in the kernel has some advantages,
> > > > especially in a case of a system-wide OOM.
> > > > 
> > > > To address these issues, cgroup-aware OOM killer is introduced.
> > > > Under OOM conditions, it looks for a memcg with highest oom score,
> > > > and kills all processes inside.
> > > > 
> > > > Memcg oom score is calculated as a size of active and inactive
> > > > anon LRU lists, unevictable LRU list and swap size.
> > > > 
> > > > For a cgroup-wide OOM, only cgroups belonging to the subtree of
> > > > the OOMing cgroup are considered.
> > > 
> > > While this might make sense for some workloads/setups it is not a
> > > generally acceptable policy IMHO. We have discussed that different OOM
> > > policies might be interesting few years back at LSFMM but there was no
> > > real consensus on how to do that. One possibility was to allow bpf like
> > > mechanisms. Could you explore that path?
> > 
> > I agree, I think it needs more thought. I wonder if the real issue is something
> > else. For example
> > 
> > 1. Did we overcommit a particular container too much?
> 
> Imagine, you have a machine with multiple containers,
> each with it's own process tree, and the machine is overcommited,
> i.e. sum of container's memory limits is larger the amount available RAM.
> 
> In a case of a system-wide OOM some random container will be affected.
> 

The random container containing the most expensive task, yes!

> Historically, this problem was solving by some user-space daemon,
> which was monitoring OOM events and cleaning up affected containers.
> But this approach can't solve the main problem: non-optimal selection
> of a victim. 

Why do you think the problem is non-optimal selection, is it because
we believe that memory cgroup limits should play a role in decision
making of global OOM?


> 
> > 2. Do we need something like https://urldefense.proofpoint.com/v2/url?u=https-3A__lwn.net_Articles_604212_&d=DwIBaQ&c=5VD0RTtNlTh3ycd41b3MUw&r=jJYgtDM7QT-W-Fz_d29HYQ&m=9jV4id5lmsjFJj1kQjJk0auyQ3bzL27-f6Ur6ZNw36c&s=ElsS25CoZSPba6ke7O-EIsR7lN0psP6tDVyLnGqCMfs&e=  to solve
> > the problem?
>
 
The URL got changed to something non-parsable, probably for security, but
could you email client please not do that.

> I don't think it's related.

I was thinking that if we have virtual memory limits and we could set
some sane ones, we could avoid OOM altogether. OOM is a big hammer and
having allocations fail is far more acceptable than killing processes.
I believe that several applications may have much larger VM than actual
memory usage, but I believe with a good overcommit/virtual memory limiter
the problem can be better tackled.

> 
> > 3. We have oom notifiers now, could those be used (assuming you are interested
> > in non memcg related OOM's affecting a container
> 
> They can be used to inform an userspace daemon about an already happened OOM,
> but they do not affect victim selection.

Yes, the whole point is for the OS to select the victim, the notifiers
provide an opportunity for us to do reclaim to probably prevent OOM

In oom_kill, I see

                blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
                if (freed > 0)
                        /* Got some memory back in the last second. */
                        return true;

Could the notification to user space then decide what to cleanup to free
memory? We also have event notification inside of memcg. I am trying to
understand why these are not sufficient?

We also have soft limits to push containers to a smaller size at the
time of global pressure.

> 
> > 4. How do we determine limits for these containers? From a fariness
> > perspective
> 
> Limits are usually set from some high-level understanding of the nature
> of tasks which are working inside, but overcommiting the machine is
> a common place, I assume.

Agreed overcommit is a given and that is why we wrote the cgroup controllers.
I was wondering if the container limits not being set correctly could cause
these issues. I am also trying to understand with the infrastructure we
have for notification and control, do we need more?

> 
> Thank you!
> 
> Roman

Cheers,
Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
