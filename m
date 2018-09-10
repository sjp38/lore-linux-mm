Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id EF4AA8E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 07:27:40 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id h5-v6so38502322itb.3
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 04:27:40 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id v14-v6si12041798jan.6.2018.09.10.04.27.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 04:27:38 -0700 (PDT)
Subject: Re: [PATCH v2] mm, oom: Fix unnecessary killing of additional
 processes.
References: <1536382452-3443-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180910095433.GE10951@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <2a35203b-4220-9758-b332-f10ce3604227@i-love.sakura.ne.jp>
Date: Mon, 10 Sep 2018 20:27:21 +0900
MIME-Version: 1.0
In-Reply-To: <20180910095433.GE10951@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Roman Gushchin <guro@fb.com>

On 2018/09/10 18:54, Michal Hocko wrote:
> On Sat 08-09-18 13:54:12, Tetsuo Handa wrote:
> [...]
> 
> I will not comment on the above because I have already done so and you
> keep ignoring it so I will not waste my time again.

Then, your NACK no longer stands.

>                                                     But let me ask about
> the following though
> 
>> This patch also fixes three possible bugs
>>
>>   (1) oom_task_origin() tasks can be selected forever because it did not
>>       check for MMF_OOM_SKIP.
> 
> Is this a real problem. Could you point to any path that wouldn't bail
> out and oom_origin task would keep trying for ever? If such a path
> doesn't exist and you believe it is too fragile and point out the older
> bugs proving that then I can imagine we should care.

My confusion. MMF_OOM_SKIP is checked before oom_task_origin() test.

> 
>>   (2) sysctl_oom_kill_allocating_task path can be selected forever
>>       because it did not check for MMF_OOM_SKIP.
> 
> Why is that a problem? sysctl_oom_kill_allocating_task doesn't have any
> well defined semantic. It is a gross hack to save long and expensive oom
> victim selection. If we were too strict we should even not allow anybody
> else but an allocating task to be killed. So selecting it multiple times
> doesn't sound harmful to me.

After current thread was selected as an OOM victim by that code path and
the OOM reaper reaped current thread's memory, the OOM killer has to select
next OOM victim, for such situation means that current thread cannot bail
out due to __GFP_NOFAIL allocation. That is, similar to what you ignored

  if (tsk_is_oom_victim(current) && !(oc->gfp_mask & __GFP_NOFAIL))
      return true;

change. That is, when

  If current thread is an OOM victim, it is guaranteed to make forward
  progress (unless __GFP_NOFAIL) by failing that allocation attempt after
  trying memory reserves. The OOM path does not need to do anything at all.

failed due to __GFP_NOFAIL, sysctl_oom_kill_allocating_task has to select
next OOM victim.

> 
>>   (3) CONFIG_MMU=n kernels might livelock because nobody except
>>       is_global_init() case in __oom_kill_process() sets MMF_OOM_SKIP.
> 
> And now the obligatory question. Is this a real problem?

I SAID "POSSIBLE BUGS". You have never heard is not a proof that the problem
is not occurring in the world. Not everybody is skillful enough to report
OOM (or low memory) problems to you!

>  
>> which prevent proof of "the forward progress guarantee"
>> and adds one optimization
>>
>>   (4) oom_evaluate_task() was calling oom_unkillable_task() twice because
>>       oom_evaluate_task() needs to check for !MMF_OOM_SKIP and
>>       oom_task_origin() tasks before calling oom_badness().
> 
> ENOPARSE
> 

Not difficult to parse at all.

oom_evaluate_task() {

  if (oom_unkillable_task(task, NULL, oc->nodemask))
    goto next;

  if (!is_sysrq_oom(oc) && tsk_is_oom_victim(task)) {
    if (test_bit(MMF_OOM_SKIP, &task->signal->oom_mm->flags))
      goto next;
    goto abort;
  }

  if (oom_task_origin(task)) {
    points = ULONG_MAX;
    goto select;
  }

  points = oom_badness(task, NULL, oc->nodemask, oc->totalpages) {

    if (oom_unkillable_task(p, memcg, nodemask))
      return 0;

  }
}

By moving oom_task_origin() to inside oom_badness(), and
by bringing !MMF_OOM_SKIP test earlier, we can eliminate

  oom_unkillable_task(task, NULL, oc->nodemask)

test in oom_evaluate_task().
