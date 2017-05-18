Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id D40FE831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 15:44:57 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id t12so41639893pgo.7
        for <linux-mm@kvack.org>; Thu, 18 May 2017 12:44:57 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id m11si6051276pln.8.2017.05.18.12.44.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 May 2017 12:44:57 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id s62so7031955pgc.0
        for <linux-mm@kvack.org>; Thu, 18 May 2017 12:44:57 -0700 (PDT)
Message-ID: <1495136639.21894.3.camel@gmail.com>
Subject: Re: [RFC PATCH] mm, oom: cgroup-aware OOM-killer
From: Balbir Singh <bsingharora@gmail.com>
Date: Fri, 19 May 2017 05:43:59 +1000
In-Reply-To: <20170518192240.GA29914@cmpxchg.org>
References: <1495124884-28974-1-git-send-email-guro@fb.com>
	 <20170518173002.GC30148@dhcp22.suse.cz>
	 <CAKTCnzkBNV9bsQSg4kzhxY=i=-y3x78StbbXfV9mvXLsJhGHig@mail.gmail.com>
	 <20170518192240.GA29914@cmpxchg.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>, Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, kernel-team@fb.com, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "open
 list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Thu, 2017-05-18 at 15:22 -0400, Johannes Weiner wrote:
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
> > 2. Do we need something like https://lwn.net/Articles/604212/ to solve
> > the problem?
> 
> The occasional OOM kill is an unavoidable reality on our systems (and
> I bet on most deployments). If we tried not to overcommit, we'd waste
> a *lot* of memory.
> 
> The problem is when OOM happens, we really want the biggest *job* to
> get killed. Before cgroups, we assumed jobs were processes. But with
> cgroups, the user is able to define a group of processes as a job, and
> then an individual process is no longer a first-class memory consumer.
> 
> Without a patch like this, the OOM killer will compare the sizes of
> the random subparticles that the jobs in the system are composed of
> and kill the single biggest particle, leaving behind the incoherent
> remains of one of the jobs. That doesn't make a whole lot of sense.

I agree, but see my response on oom_notifiers in parallel that I sent
to Roman.

> 
> If you want to determine the most expensive car in a parking lot, you
> can't go off and compare the price of one car's muffler with the door
> handle of another, then point to a wind shield and yell "This is it!"
> 
> You need to compare the cars as a whole with each other.
> 
> > 3. We have oom notifiers now, could those be used (assuming you are interested
> > in non memcg related OOM's affecting a container
> 
> Right now, we watch for OOM notifications and then have userspace kill
> the rest of a job. That works - somewhat. What remains is the problem
> that I described above, that comparing individual process sizes is not
> meaningful when the terminal memory consumer is a cgroup.

Could the cgroup limit be used as the comparison point? stats inside
of the memory cgroup?

> 
> > 4. How do we determine limits for these containers? From a fariness
> > perspective
> 
> How do you mean?

How do we set them up so that the larger job gets more of the limits
as opposed to the small ones?

Balbir Singh.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
