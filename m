Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 54B386B02D8
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 09:40:37 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id f31-v6so2341540plb.10
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 06:40:37 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id n11-v6si13332446plk.225.2018.07.09.06.40.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 06:40:35 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: PF_WQ_WORKER should always sleep at
 should_reclaim_retry().
References: <1531046158-4010-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180709075731.GB22049@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <5a5ddca9-95fd-1035-b304-a9c6d50238b2@i-love.sakura.ne.jp>
Date: Mon, 9 Jul 2018 22:08:04 +0900
MIME-Version: 1.0
In-Reply-To: <20180709075731.GB22049@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <js1304@gmail.com>, Mel Gorman <mgorman@suse.de>, Vladimir Davydov <vdavydov@virtuozzo.com>, Vlastimil Babka <vbabka@suse.cz>

On 2018/07/09 16:57, Michal Hocko wrote:
> On Sun 08-07-18 19:35:58, Tetsuo Handa wrote:
>> From: Michal Hocko <mhocko@suse.com>
>>
>> should_reclaim_retry() should be a natural reschedule point. PF_WQ_WORKER
>> is a special case which needs a stronger rescheduling policy. However,
>> since schedule_timeout_uninterruptible(1) for PF_WQ_WORKER depends on
>> __zone_watermark_ok() == true, PF_WQ_WORKER is currently counting on
>> mutex_trylock(&oom_lock) == 0 in __alloc_pages_may_oom() which is a bad
>> expectation.
> 
> I think your reference to the oom_lock is more confusing than helpful
> actually. I would simply use the following from your previous [1]
> changelog:

Then, you can post yourself because

> : should_reclaim_retry() should be a natural reschedule point. PF_WQ_WORKER
> : is a special case which needs a stronger rescheduling policy. Doing that
> : unconditionally seems more straightforward than depending on a zone being
> : a good candidate for a further reclaim.
> : 
> : Thus, move the short sleep when we are waiting for the owner of oom_lock
> : (which coincidentally also serves as a guaranteed sleep for PF_WQ_WORKER
> : threads) to should_reclaim_retry().
> 
>> unconditionally seems more straightforward than depending on a zone being
>> a good candidate for a further reclaim.
> 
> [1] http://lkml.kernel.org/r/1528369223-7571-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
> 
> [Tetsuo: changelog]
>> Signed-off-by: Michal Hocko <mhocko@suse.com>
>> Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
>> Cc: David Rientjes <rientjes@google.com>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Joonsoo Kim <js1304@gmail.com>
>> Cc: Mel Gorman <mgorman@suse.de>
>> Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
>> Cc: Vladimir Davydov <vdavydov@virtuozzo.com>
>> Cc: Vlastimil Babka <vbabka@suse.cz>
> 
> Your s-o-b is still missing.

all code changes in this patch is from you. That is, my s-o-b is not missing.
