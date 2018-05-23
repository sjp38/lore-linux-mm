Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A15C06B0006
	for <linux-mm@kvack.org>; Wed, 23 May 2018 09:19:37 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n78-v6so13164767pfj.4
        for <linux-mm@kvack.org>; Wed, 23 May 2018 06:19:37 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id r18-v6si1031297pgu.467.2018.05.23.06.19.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 May 2018 06:19:34 -0700 (PDT)
Subject: Re: [PATCH 6/7] psi: pressure stall information for CPU, memory, and
 IO
References: <20180507210135.1823-1-hannes@cmpxchg.org>
 <20180507210135.1823-7-hannes@cmpxchg.org>
 <87060553-2e09-2e2a-13a2-a91345d6df30@codeaurora.org>
 <20180523131747.GA4086@cmpxchg.org>
From: Vinayak Menon <vinmenon@codeaurora.org>
Message-ID: <47beeaa6-74aa-35d0-2808-e5c54be854a6@codeaurora.org>
Date: Wed, 23 May 2018 18:49:25 +0530
MIME-Version: 1.0
In-Reply-To: <20180523131747.GA4086@cmpxchg.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, cgroups@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Mike Galbraith <efault@gmx.de>, Oliver Yang <yangoliver@me.com>, Shakeel Butt <shakeelb@google.com>, xxx xxx <x.qendo@gmail.com>, Taras Kondratiuk <takondra@cisco.com>, Daniel Walker <danielwa@cisco.com>, Ruslan Ruslichenko <rruslich@cisco.com>, kernel-team@fb.com


On 5/23/2018 6:47 PM, Johannes Weiner wrote:
> On Wed, May 09, 2018 at 04:33:24PM +0530, Vinayak Menon wrote:
>> On 5/8/2018 2:31 AM, Johannes Weiner wrote:
>>> +	/* Kick the stats aggregation worker if it's gone to sleep */
>>> +	if (!delayed_work_pending(&group->clock_work))
>> This causes a crash when the work is scheduled before system_wq is up. In my case when the first
>> schedule was called from kthreadd. And I had to do this to make it work.
>> if (keventd_up() && !delayed_work_pending(&group->clock_work))
>>
>>> +		schedule_delayed_work(&group->clock_work, MY_LOAD_FREQ);
> I was trying to figure out how this is possible, and it didn't make
> sense because we do initialize the system_wq way before kthreadd.
>
> Did you by any chance backport this to a pre-4.10 kernel which does
> not have 3347fa092821 ("workqueue: make workqueue available early
> during boot") yet?

Sorry I did not mention that. I was trying on 4.9 kernel. It's clear now. Thanks.

>>> +void psi_task_change(struct task_struct *task, u64 now, int clear, int set)
>>> +{
>>> +	struct cgroup *cgroup, *parent;
>> unused variables
> They're used in the next patch, I'll fix that up.
>
> Thanks
