Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id C5BF76B13E0
	for <linux-mm@kvack.org>; Sun, 19 Aug 2018 10:23:59 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id u11-v6so11677752oif.22
        for <linux-mm@kvack.org>; Sun, 19 Aug 2018 07:23:59 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 7-v6si4176062oin.132.2018.08.19.07.23.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Aug 2018 07:23:58 -0700 (PDT)
Subject: Re: [PATCH 4/4] mm, oom: Fix unnecessary killing of additional
 processes.
References: <1533389386-3501-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1533389386-3501-4-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180806134550.GO19540@dhcp22.suse.cz>
 <alpine.DEB.2.21.1808061315220.43071@chino.kir.corp.google.com>
 <20180806205121.GM10003@dhcp22.suse.cz>
 <alpine.DEB.2.21.1808091311030.244858@chino.kir.corp.google.com>
 <20180810090735.GY1644@dhcp22.suse.cz>
 <be42a7c0-015e-2992-a40d-20af21e8c0fc@i-love.sakura.ne.jp>
 <20180810111604.GA1644@dhcp22.suse.cz>
 <d9595c92-6763-35cb-b989-0848cf626cb9@i-love.sakura.ne.jp>
 <20180814113359.GF32645@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <49a73f8a-a472-a464-f5bf-ebd7994ce2d3@i-love.sakura.ne.jp>
Date: Sun, 19 Aug 2018 23:23:41 +0900
MIME-Version: 1.0
In-Reply-To: <20180814113359.GF32645@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On 2018/08/14 20:33, Michal Hocko wrote:
> On Sat 11-08-18 12:12:52, Tetsuo Handa wrote:
>> On 2018/08/10 20:16, Michal Hocko wrote:
>>>> How do you decide whether oom_reaper() was not able to reclaim much?
>>>
>>> Just a rule of thumb. If it freed at least few kBs then we should be good
>>> to MMF_OOM_SKIP.
>>
>> I don't think so. We are talking about situations where MMF_OOM_SKIP is set
>> before memory enough to prevent the OOM killer from selecting next OOM victim
>> was reclaimed.
> 
> There is nothing like enough memory to prevent a new victim selection.
> Just think of streaming source of allocation without any end. There is
> simply no way to tell that we have freed enough. We have to guess and
> tune based on reasonable workloads.

I'm not talking about "allocation without any end" case.
We already inserted fatal_signal_pending(current) checks (except vmalloc()
where tsk_is_oom_victim(current) would be used instead).

What we are talking about is a situation where we could avoid selecting next
OOM victim if we waited for some more time after MMF_OOM_SKIP was set.

>> Apart from the former is "sequential processing" and "the OOM reaper pays the cost
>> for reclaiming" while the latter is "parallel (or round-robin) processing" and "the
>> allocating thread pays the cost for reclaiming", both are timeout based back off
>> with number of retry attempt with a cap.
> 
> And it is exactly the who pays the price concern I've already tried to
> explain that bothers me.

Are you aware that we can fall into situation where nobody can pay the price for
reclaiming memory?

> 
> I really do not see how making the code more complex by ensuring that
> allocators share a fair part of the direct oom repaing will make the
> situation any easier.

You are completely ignoring/misunderstanding the background of
commit 9bfe5ded054b8e28 ("mm, oom: remove sleep from under oom_lock").

That patch was applied in order to mitigate a lockup problem caused by the fact
that allocators can deprive the OOM reaper of all CPU resources for making progress
due to very very broken assumption at

        /*
         * Acquire the oom lock.  If that fails, somebody else is
         * making progress for us.
         */
        if (!mutex_trylock(&oom_lock)) {
                *did_some_progress = 1;
                schedule_timeout_uninterruptible(1);
                return NULL;
        }

on the allocator side.

Direct OOM reaping is a method for ensuring that allocators spend _some_ CPU
resources for making progress. I already showed how to prevent allocators from
trying to reclaim all (e.g. multiple TB) memory at once because you worried it.

>                       Really there are basically two issues we really
> should be after. Improve the oom reaper to tear down wider range of
> memory (namely mlock) and to improve the cooperation with the exit path
> to handle free_pgtables more gracefully because it is true that some
> processes might really consume a lot of memory in page tables without
> mapping  a lot of anonymous memory. Neither of the two is addressed by
> your proposal. So if you want to help then try to think about the two
> issues.

Your "improvement" is to tear down wider range of memory whereas
my "improvement" is to ensure that CPU resource is spent for reclaiming memory and
David's "improvement" is to mitigate unnecessary killing of additional processes.
Therefore, your "Neither of the two is addressed by your proposal." is pointless.
