Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B55C06B0003
	for <linux-mm@kvack.org>; Fri,  8 Jun 2018 06:47:44 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id z1-v6so6074483pfh.3
        for <linux-mm@kvack.org>; Fri, 08 Jun 2018 03:47:44 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id f4-v6si13686618pgc.522.2018.06.08.03.47.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jun 2018 03:47:43 -0700 (PDT)
Subject: Re: [PATCH 1/4] mm,oom: Don't call schedule_timeout_killable() with
 oom_lock held.
References: <1528369223-7571-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180607111137.GK32433@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <7e4a311b-29e3-2fd2-eb27-d7713c3e9fd3@i-love.sakura.ne.jp>
Date: Fri, 8 Jun 2018 19:47:18 +0900
MIME-Version: 1.0
In-Reply-To: <20180607111137.GK32433@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On 2018/06/07 20:28, Michal Hocko wrote:
> On Thu 07-06-18 20:00:23, Tetsuo Handa wrote:
> OK, this looks like a nice shortcut. I am quite surprise that all your
> NOMMU concerns are gone now while you clearly regress that case because
> inflight victims are not detected anymore AFAICS. Not that I care all
> that much, just sayin'.
> 
> Anyway, I would suggest splitting this into two patches. One to add an
> early check for inflight oom victims and one removing the detection from
> oom_evaluate_task. Just to make it easier to revert if somebody on nommu
> actually notices a regression.

Sure. Making it easier to revert is a good thing.
But this patch comes after PATCH 3/4. Need to solve previous problem.

On 2018/06/07 20:16, Michal Hocko wrote:
> Acked-by: Michal Hocko <mhocko@suse.com>
> 
> with a minor nit
> 
>> ---
>>  mm/oom_kill.c | 13 ++++++++-----
>>  1 file changed, 8 insertions(+), 5 deletions(-)
>>
>> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
>> index 23ce67f..5a6f1b1 100644
>> --- a/mm/oom_kill.c
>> +++ b/mm/oom_kill.c
>> @@ -1073,15 +1073,18 @@ bool out_of_memory(struct oom_control *oc)
>>  	}
>>  
>>  	select_bad_process(oc);
>> +	if (oc->chosen == (void *)-1UL)
> 
> I think this one deserves a comment.
> 	/* There is an inflight oom victim *.
> 
>> +		return true;

OK. Though, this change will be reverted by PATCH 4/4.
But this patch comes after PATCH 1/4. Need to solve previous problem.

On 2018/06/07 20:13, Michal Hocko wrote:
> On Thu 07-06-18 20:00:21, Tetsuo Handa wrote:
> 
> Your s-o-b is missing here. And I suspect this should be From: /me
> but I do not care all that much.

How can I do that? Forge the From: line (assuming that mail server does not
reject forged From: line)?

But I am quite surprised that you did not respond PATCH 2/4 with Nacked-by:
because

On 2018/06/07 20:11, Michal Hocko wrote:
> On Thu 07-06-18 20:00:20, Tetsuo Handa wrote:
> [...]
>> @@ -4238,6 +4237,12 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
>>  	/* Retry as long as the OOM killer is making progress */
>>  	if (did_some_progress) {
>>  		no_progress_loops = 0;
>> +		/*
>> +		 * This schedule_timeout_*() serves as a guaranteed sleep for
>> +		 * PF_WQ_WORKER threads when __zone_watermark_ok() == false.
>> +		 */
>> +		if (!tsk_is_oom_victim(current))
>> +			schedule_timeout_uninterruptible(1);
>>  		goto retry;
>>  	}
> 
> Nacked-by: Michal Hocko <mhocko@suse.com>
> 
> as explainaed several times already. This moving code just to preserve
> the current logic without any arguments to back them must stop finally.
> We have way too much of this "just in case" code that nobody really
> understands and others just pile on top. Seriously this is not how the
> development should work.
> 

I am purposely splitting into PATCH 1/4 and PATCH 2/4 in order to make it
easier to revert (like you suggested doing so for PATCH 4/4) in case
somebody actually notices an unexpected side effect.

PATCH 1/4 is doing logically correct thing, no matter how you hate
the short sleep which will be removed by PATCH 2/4.

PATCH 1/4 is proven to be safe. But PATCH 2/4 is not tested to be safe.
PATCH 1/4 is safe for stable. But 2/4 might not be safe for stable.
Therefore, I insist on two separate patches.

If you can accept what PATCH 1/4 + PATCH 2/4 are doing, you are free to post
one squashed patch.
