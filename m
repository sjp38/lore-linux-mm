Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id E68B16B032E
	for <linux-mm@kvack.org>; Fri, 26 Oct 2018 21:10:27 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id o8-v6so2610635iom.6
        for <linux-mm@kvack.org>; Fri, 26 Oct 2018 18:10:27 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id s4-v6si2394913jad.111.2018.10.26.18.10.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Oct 2018 18:10:26 -0700 (PDT)
Subject: Re: [RFC PATCH 2/2] memcg: do not report racy no-eligible OOM tasks
References: <20181022071323.9550-1-mhocko@kernel.org>
 <20181022071323.9550-3-mhocko@kernel.org>
 <20181026142531.GA27370@cmpxchg.org> <20181026192551.GC18839@dhcp22.suse.cz>
 <20181026193304.GD18839@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <dfafc626-2233-db9b-49fa-9d4bae16d4aa@i-love.sakura.ne.jp>
Date: Sat, 27 Oct 2018 10:10:06 +0900
MIME-Version: 1.0
In-Reply-To: <20181026193304.GD18839@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 2018/10/27 4:25, Michal Hocko wrote:
>> out_of_memory() bails on task_will_free_mem(current), which
>> specifically *excludes* already reaped tasks. Why are we then adding a
>> separate check before that to bail on already reaped victims?
> 
> 696453e66630a has introduced the bail out.
> 
>> Do we want to bail if current is a reaped victim or not?
>>
>> I don't see how we could skip it safely in general: the current task
>> might have been killed and reaped and gotten access to the memory
>> reserve and still fail to allocate on its way out. It needs to kill
>> the next task if there is one, or warn if there isn't another
>> one. Because we're genuinely oom without reclaimable tasks.
> 
> Yes, this would be the case for the global case which is a real OOM
> situation. Memcg oom is somehow more relaxed because the oom is local.

We can handle possibility of genuinely OOM without reclaimable tasks.
Only __GFP_NOFAIL OOM has to select next OOM victim. There is no need to
select next OOM victim unless __GFP_NOFAIL. Commit 696453e66630ad45
("mm, oom: task_will_free_mem should skip oom_reaped tasks") was too simple.

On 2018/10/27 4:33, Michal Hocko wrote:
> On Fri 26-10-18 21:25:51, Michal Hocko wrote:
>> On Fri 26-10-18 10:25:31, Johannes Weiner wrote:
> [...]
>>> There is of course the scenario brought forward in this thread, where
>>> multiple threads of a process race and the second one enters oom even
>>> though it doesn't need to anymore. What the global case does to catch
>>> this is to grab the oom lock and do one last alloc attempt. Should
>>> memcg lock the oom_lock and try one more time to charge the memcg?
>>
>> That would be another option. I agree that making it more towards the
>> global case makes it more attractive. My tsk_is_oom_victim is more
>> towards "plug this particular case".
> 
> Nevertheless let me emphasise that tsk_is_oom_victim will close the race
> completely, while mem_cgroup_margin will always be racy. So the question
> is whether we want to close the race because it is just too easy for
> userspace to hit it or keep the global and memcg oom handling as close
> as possible.
> 

Yes, adding tsk_is_oom_victim(current) before calling out_of_memory() from
both global OOM and memcg OOM paths can close the race completely. (But
note that tsk_is_oom_victim(current) for global OOM path needs to check for
__GFP_NOFAIL in order to handle genuinely OOM case.)
