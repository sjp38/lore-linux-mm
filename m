Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A94B8831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 14:11:40 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id c202so10563298wme.10
        for <linux-mm@kvack.org>; Thu, 18 May 2017 11:11:40 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id r7si6478764edb.63.2017.05.18.11.11.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 May 2017 11:11:39 -0700 (PDT)
Date: Thu, 18 May 2017 14:11:17 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH] mm, oom: cgroup-aware OOM-killer
Message-ID: <20170518181117.GA27689@cmpxchg.org>
References: <1495124884-28974-1-git-send-email-guro@fb.com>
 <20170518173002.GC30148@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170518173002.GC30148@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, May 18, 2017 at 07:30:04PM +0200, Michal Hocko wrote:
> On Thu 18-05-17 17:28:04, Roman Gushchin wrote:
> > Traditionally, the OOM killer is operating on a process level.
> > Under oom conditions, it finds a process with the highest oom score
> > and kills it.
> > 
> > This behavior doesn't suit well the system with many running
> > containers. There are two main issues:
> > 
> > 1) There is no fairness between containers. A small container with
> > a few large processes will be chosen over a large one with huge
> > number of small processes.
> > 
> > 2) Containers often do not expect that some random process inside
> > will be killed. So, in general, a much safer behavior is
> > to kill the whole cgroup. Traditionally, this was implemented
> > in userspace, but doing it in the kernel has some advantages,
> > especially in a case of a system-wide OOM.
> > 
> > To address these issues, cgroup-aware OOM killer is introduced.
> > Under OOM conditions, it looks for a memcg with highest oom score,
> > and kills all processes inside.
> > 
> > Memcg oom score is calculated as a size of active and inactive
> > anon LRU lists, unevictable LRU list and swap size.
> > 
> > For a cgroup-wide OOM, only cgroups belonging to the subtree of
> > the OOMing cgroup are considered.
> 
> While this might make sense for some workloads/setups it is not a
> generally acceptable policy IMHO. We have discussed that different OOM
> policies might be interesting few years back at LSFMM but there was no
> real consensus on how to do that. One possibility was to allow bpf like
> mechanisms. Could you explore that path?

OOM policy is an orthogonal discussion, though.

The OOM killer's job is to pick a memory consumer to kill. Per default
the unit of the memory consumer is a process, but cgroups allow
grouping processes into compound consumers. Extending the OOM killer
to respect the new definition of "consumer" is not a new policy.

I don't think it's reasonable to ask the person who's trying to make
the OOM killer support group-consumers to design a dynamic OOM policy
framework instead.

All we want is the OOM policy, whatever it is, applied to cgroups.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
