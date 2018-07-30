Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 32FE26B0003
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 11:25:33 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id 22-v6so11174194oix.0
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 08:25:33 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id k189-v6si7842116oib.416.2018.07.30.08.25.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jul 2018 08:25:27 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: PF_WQ_WORKER threads must sleep at
 should_reclaim_retry().
References: <ca3da8b8-1bb5-c302-b190-fa6cebab58ca@I-love.SAKURA.ne.jp>
 <20180726113958.GE28386@dhcp22.suse.cz>
 <55c9da7f-e448-964a-5b50-47f89a24235b@i-love.sakura.ne.jp>
 <20180730093257.GG24267@dhcp22.suse.cz>
 <9158a23e-7793-7735-e35c-acd540ca59bf@i-love.sakura.ne.jp>
 <20180730144647.GX24267@dhcp22.suse.cz>
 <20180730145425.GE1206094@devbig004.ftw2.facebook.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <0018ac3b-94ee-5f09-e4e0-df53d2cbc925@i-love.sakura.ne.jp>
Date: Tue, 31 Jul 2018 00:25:04 +0900
MIME-Version: 1.0
In-Reply-To: <20180730145425.GE1206094@devbig004.ftw2.facebook.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2018/07/30 23:54, Tejun Heo wrote:
> Hello,
> 
> On Mon, Jul 30, 2018 at 04:46:47PM +0200, Michal Hocko wrote:
>> On Mon 30-07-18 23:34:23, Tetsuo Handa wrote:
>>> On 2018/07/30 18:32, Michal Hocko wrote:
>> [...]
>>>> This one is waiting for draining and we are in mm_percpu_wq WQ context
>>>> which has its rescuer so no other activity can block us for ever. So
>>>> this certainly shouldn't deadlock. It can be dead slow but well, this is
>>>> what you will get when your shoot your system to death.
>>>
>>> We need schedule_timeout_*() to allow such WQ_MEM_RECLAIM workqueues to wake up. (Tejun,
>>> is my understanding correct?) Lack of schedule_timeout_*() does block WQ_MEM_RECLAIM
>>> workqueues forever.
>>
>> Hmm. This doesn't match my understanding of what WQ_MEM_RECLAIM actually
>> guarantees. If you are right then the whole thing sounds quite fragile
>> to me TBH.
> 
> Workqueue doesn't think the cpu is stalled as long as one of the
> per-cpu kworkers is running.  The assumption is that kernel threads
> are not supposed to be busy-looping indefinitely (and they really
> shouldn't).

WQ_MEM_RECLAIM guarantees that "struct task_struct" is preallocated. But
WQ_MEM_RECLAIM does not guarantee that the pending work is started as soon
as an item was queued. Same rule applies to both WQ_MEM_RECLAIM workqueues 
and !WQ_MEM_RECLAIM workqueues regarding when to start a pending work (i.e.
when schedule_timeout_*() is called).

Is this correct?

>              We can add timeout mechanism to workqueue so that it
> kicks off other kworkers if one of them is in running state for too
> long, but idk, if there's an indefinite busy loop condition in kernel
> threads, we really should get rid of them and hung task watchdog is
> pretty effective at finding these cases (at least with preemption
> disabled).

Currently the page allocator has a path which can loop forever with
only cond_resched().

> 
> Thanks.
> 
