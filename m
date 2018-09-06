Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 74D236B78A2
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 08:09:05 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id a8-v6so5471000pla.10
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 05:09:05 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u26-v6sor938494pgl.244.2018.09.06.05.09.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Sep 2018 05:09:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180906115320.GS14951@dhcp22.suse.cz>
References: <0252ad5d-46e6-0d7f-ef91-4e316657a83d@i-love.sakura.ne.jp>
 <CACT4Y+Yp6ZbusCWg5C1zaJpcS8=XnGPboKgWfyxVk1axQA2nbw@mail.gmail.com>
 <201809060553.w865rmpj036017@www262.sakura.ne.jp> <CACT4Y+YKJWJr-5rBQidt6nY7+VF=BAsvHyh+XTaf8spwNy3qPA@mail.gmail.com>
 <58aa0543-86d0-b2ad-7fb9-9bed7c6a1f6c@i-love.sakura.ne.jp>
 <20180906112306.GO14951@dhcp22.suse.cz> <1611e45d-235e-67e9-26e3-d0228255fa2f@i-love.sakura.ne.jp>
 <20180906115320.GS14951@dhcp22.suse.cz>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 6 Sep 2018 14:08:43 +0200
Message-ID: <CACT4Y+byA7dLar5=9y+7RApT2WdxgVA9c29q83NEVkd5KCLgjg@mail.gmail.com>
Subject: Re: [PATCH] mm, oom: Introduce time limit for dump_tasks duration.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, syzbot <syzbot+f0fc7f62e88b1de99af3@syzkaller.appspotmail.com>, 'Dmitry Vyukov' via syzkaller-upstream-moderation <syzkaller-upstream-moderation@googlegroups.com>, linux-mm <linux-mm@kvack.org>

On Thu, Sep 6, 2018 at 1:53 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Thu 06-09-18 20:40:34, Tetsuo Handa wrote:
>> On 2018/09/06 20:23, Michal Hocko wrote:
>> > On Thu 06-09-18 19:58:25, Tetsuo Handa wrote:
>> > [...]
>> >> >From 18876f287dd69a7c33f65c91cfcda3564233f55e Mon Sep 17 00:00:00 2001
>> >> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
>> >> Date: Thu, 6 Sep 2018 19:53:18 +0900
>> >> Subject: [PATCH] mm, oom: Introduce time limit for dump_tasks duration.
>> >>
>> >> Since printk() is slow, printing one line takes nearly 0.01 second.
>> >> As a result, syzbot is stalling for 52 seconds trying to dump 5600
>> >> tasks at for_each_process() under RCU. Since such situation is almost
>> >> inflight fork bomb attack (the OOM killer will print similar tasks for
>> >> so many times), it makes little sense to print all candidate tasks.
>> >> Thus, this patch introduces 3 seconds limit for printing.
>> >>
>> >> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
>> >> Cc: Dmitry Vyukov <dvyukov@google.com>
>> >
>> > You really love timeout based solutions with randomly chosen timeouts,
>> > don't you. This is just ugly as hell. We already have means to disable
>> > tasks dumping (see /proc/sys/vm/oom_dump_tasks).
>>
>> I know /proc/sys/vm/oom_dump_tasks . Showing some entries while not always
>> printing all entries might be helpful.
>
> Not really. It could be more confusing than helpful. The main purpose of
> the listing is to double check the list to understand the oom victim
> selection. If you have a partial list you simply cannot do that.
>
> If the iteration takes too long and I can imagine it does with zillions
> of tasks then the proper way around it is either release the lock
> periodically after N tasks is processed or outright skip the whole thing
> if there are too many tasks. The first option is obviously tricky to
> prevent from duplicate entries or other artifacts.


So does anybody know if it can live lock picking up new tasks all the
time? That's what it looks like at first glance. I also don't remember
seeing anything similar in the past.
If it's a live lock and we resolve it, then we don't need to solve the
problem of too many tasks here.
