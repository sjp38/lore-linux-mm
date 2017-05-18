Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 00DFB831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 13:30:14 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id y106so10670139wrb.14
        for <linux-mm@kvack.org>; Thu, 18 May 2017 10:30:13 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n10si6496476edd.38.2017.05.18.10.30.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 18 May 2017 10:30:12 -0700 (PDT)
Date: Thu, 18 May 2017 19:30:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, oom: cgroup-aware OOM-killer
Message-ID: <20170518173002.GC30148@dhcp22.suse.cz>
References: <1495124884-28974-1-git-send-email-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1495124884-28974-1-git-send-email-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 18-05-17 17:28:04, Roman Gushchin wrote:
> Traditionally, the OOM killer is operating on a process level.
> Under oom conditions, it finds a process with the highest oom score
> and kills it.
> 
> This behavior doesn't suit well the system with many running
> containers. There are two main issues:
> 
> 1) There is no fairness between containers. A small container with
> a few large processes will be chosen over a large one with huge
> number of small processes.
> 
> 2) Containers often do not expect that some random process inside
> will be killed. So, in general, a much safer behavior is
> to kill the whole cgroup. Traditionally, this was implemented
> in userspace, but doing it in the kernel has some advantages,
> especially in a case of a system-wide OOM.
> 
> To address these issues, cgroup-aware OOM killer is introduced.
> Under OOM conditions, it looks for a memcg with highest oom score,
> and kills all processes inside.
> 
> Memcg oom score is calculated as a size of active and inactive
> anon LRU lists, unevictable LRU list and swap size.
> 
> For a cgroup-wide OOM, only cgroups belonging to the subtree of
> the OOMing cgroup are considered.

While this might make sense for some workloads/setups it is not a
generally acceptable policy IMHO. We have discussed that different OOM
policies might be interesting few years back at LSFMM but there was no
real consensus on how to do that. One possibility was to allow bpf like
mechanisms. Could you explore that path?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
