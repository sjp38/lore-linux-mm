Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9D766831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 14:37:29 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id v27so17331354qtg.6
        for <linux-mm@kvack.org>; Thu, 18 May 2017 11:37:29 -0700 (PDT)
Received: from mail-qk0-x242.google.com (mail-qk0-x242.google.com. [2607:f8b0:400d:c09::242])
        by mx.google.com with ESMTPS id b1si4010682qke.97.2017.05.18.11.37.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 May 2017 11:37:28 -0700 (PDT)
Received: by mail-qk0-x242.google.com with SMTP id u75so7187713qka.1
        for <linux-mm@kvack.org>; Thu, 18 May 2017 11:37:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170518173002.GC30148@dhcp22.suse.cz>
References: <1495124884-28974-1-git-send-email-guro@fb.com> <20170518173002.GC30148@dhcp22.suse.cz>
From: Balbir Singh <bsingharora@gmail.com>
Date: Fri, 19 May 2017 04:37:27 +1000
Message-ID: <CAKTCnzkBNV9bsQSg4kzhxY=i=-y3x78StbbXfV9mvXLsJhGHig@mail.gmail.com>
Subject: Re: [RFC PATCH] mm, oom: cgroup-aware OOM-killer
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, kernel-team@fb.com, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Fri, May 19, 2017 at 3:30 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Thu 18-05-17 17:28:04, Roman Gushchin wrote:
>> Traditionally, the OOM killer is operating on a process level.
>> Under oom conditions, it finds a process with the highest oom score
>> and kills it.
>>
>> This behavior doesn't suit well the system with many running
>> containers. There are two main issues:
>>
>> 1) There is no fairness between containers. A small container with
>> a few large processes will be chosen over a large one with huge
>> number of small processes.
>>
>> 2) Containers often do not expect that some random process inside
>> will be killed. So, in general, a much safer behavior is
>> to kill the whole cgroup. Traditionally, this was implemented
>> in userspace, but doing it in the kernel has some advantages,
>> especially in a case of a system-wide OOM.
>>
>> To address these issues, cgroup-aware OOM killer is introduced.
>> Under OOM conditions, it looks for a memcg with highest oom score,
>> and kills all processes inside.
>>
>> Memcg oom score is calculated as a size of active and inactive
>> anon LRU lists, unevictable LRU list and swap size.
>>
>> For a cgroup-wide OOM, only cgroups belonging to the subtree of
>> the OOMing cgroup are considered.
>
> While this might make sense for some workloads/setups it is not a
> generally acceptable policy IMHO. We have discussed that different OOM
> policies might be interesting few years back at LSFMM but there was no
> real consensus on how to do that. One possibility was to allow bpf like
> mechanisms. Could you explore that path?

I agree, I think it needs more thought. I wonder if the real issue is something
else. For example

1. Did we overcommit a particular container too much?
2. Do we need something like https://lwn.net/Articles/604212/ to solve
the problem?
3. We have oom notifiers now, could those be used (assuming you are interested
in non memcg related OOM's affecting a container
4. How do we determine limits for these containers? From a fariness
perspective

Just trying to understand what leads to the issues you are seeing

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
