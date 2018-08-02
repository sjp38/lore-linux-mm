Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id AEB0D6B0008
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 07:53:37 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id y13-v6so1406632iop.3
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 04:53:37 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id g132-v6si1224432ita.112.2018.08.02.04.53.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Aug 2018 04:53:36 -0700 (PDT)
Subject: Re: [PATCH v2 3/3] mm, oom: introduce memory.oom.group
References: <20180802003201.817-1-guro@fb.com>
 <20180802003201.817-4-guro@fb.com>
 <879f1767-8b15-4e83-d9ef-d8df0e8b4d83@i-love.sakura.ne.jp>
 <20180802112114.GG10808@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <712a319f-c9da-230a-f2cb-af980daff704@i-love.sakura.ne.jp>
Date: Thu, 2 Aug 2018 20:53:14 +0900
MIME-Version: 1.0
In-Reply-To: <20180802112114.GG10808@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On 2018/08/02 20:21, Michal Hocko wrote:
> On Thu 02-08-18 19:53:13, Tetsuo Handa wrote:
>> On 2018/08/02 9:32, Roman Gushchin wrote:
> [...]
>>> +struct mem_cgroup *mem_cgroup_get_oom_group(struct task_struct *victim,
>>> +					    struct mem_cgroup *oom_domain)
>>> +{
>>> +	struct mem_cgroup *oom_group = NULL;
>>> +	struct mem_cgroup *memcg;
>>> +
>>> +	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys))
>>> +		return NULL;
>>> +
>>> +	if (!oom_domain)
>>> +		oom_domain = root_mem_cgroup;
>>> +
>>> +	rcu_read_lock();
>>> +
>>> +	memcg = mem_cgroup_from_task(victim);
>>
>> Isn't this racy? I guess that memcg of this "victim" can change to
>> somewhere else from the one as of determining the final candidate.
> 
> How is this any different from the existing code? We select a victim and
> then kill it. The victim might move away and won't be part of the oom
> memcg anymore but we will still kill it. I do not remember this ever
> being a problem. Migration is a privileged operation. If you loose this
> restriction you shouldn't allow to move outside of the oom domain.

The existing code kills one process (plus other processes sharing mm if any).
But oom_cgroup kills multiple processes. Thus, whether we made decision based
on correct memcg becomes important.

> 
>> This "victim" might have already passed exit_mm()/cgroup_exit() from do_exit().
> 
> Why does this matter? The victim hasn't been killed yet so if it exists
> by its own I do not think we really have to tear the whole cgroup down.

The existing code does not send SIGKILL if find_lock_task_mm() failed. Who can
guarantee that the victim is not inside do_exit() yet when this code is executed?
