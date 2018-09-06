Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C33F56B7873
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 07:53:22 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id x20-v6so3548605eda.22
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 04:53:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i1-v6si4831235edj.108.2018.09.06.04.53.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 04:53:21 -0700 (PDT)
Date: Thu, 6 Sep 2018 13:53:20 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: Introduce time limit for dump_tasks duration.
Message-ID: <20180906115320.GS14951@dhcp22.suse.cz>
References: <0252ad5d-46e6-0d7f-ef91-4e316657a83d@i-love.sakura.ne.jp>
 <CACT4Y+Yp6ZbusCWg5C1zaJpcS8=XnGPboKgWfyxVk1axQA2nbw@mail.gmail.com>
 <201809060553.w865rmpj036017@www262.sakura.ne.jp>
 <CACT4Y+YKJWJr-5rBQidt6nY7+VF=BAsvHyh+XTaf8spwNy3qPA@mail.gmail.com>
 <58aa0543-86d0-b2ad-7fb9-9bed7c6a1f6c@i-love.sakura.ne.jp>
 <20180906112306.GO14951@dhcp22.suse.cz>
 <1611e45d-235e-67e9-26e3-d0228255fa2f@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1611e45d-235e-67e9-26e3-d0228255fa2f@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, syzbot <syzbot+f0fc7f62e88b1de99af3@syzkaller.appspotmail.com>, 'Dmitry Vyukov' via syzkaller-upstream-moderation <syzkaller-upstream-moderation@googlegroups.com>, linux-mm <linux-mm@kvack.org>

On Thu 06-09-18 20:40:34, Tetsuo Handa wrote:
> On 2018/09/06 20:23, Michal Hocko wrote:
> > On Thu 06-09-18 19:58:25, Tetsuo Handa wrote:
> > [...]
> >> >From 18876f287dd69a7c33f65c91cfcda3564233f55e Mon Sep 17 00:00:00 2001
> >> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> >> Date: Thu, 6 Sep 2018 19:53:18 +0900
> >> Subject: [PATCH] mm, oom: Introduce time limit for dump_tasks duration.
> >>
> >> Since printk() is slow, printing one line takes nearly 0.01 second.
> >> As a result, syzbot is stalling for 52 seconds trying to dump 5600
> >> tasks at for_each_process() under RCU. Since such situation is almost
> >> inflight fork bomb attack (the OOM killer will print similar tasks for
> >> so many times), it makes little sense to print all candidate tasks.
> >> Thus, this patch introduces 3 seconds limit for printing.
> >>
> >> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> >> Cc: Dmitry Vyukov <dvyukov@google.com>
> > 
> > You really love timeout based solutions with randomly chosen timeouts,
> > don't you. This is just ugly as hell. We already have means to disable
> > tasks dumping (see /proc/sys/vm/oom_dump_tasks).
> 
> I know /proc/sys/vm/oom_dump_tasks . Showing some entries while not always
> printing all entries might be helpful.

Not really. It could be more confusing than helpful. The main purpose of
the listing is to double check the list to understand the oom victim
selection. If you have a partial list you simply cannot do that.

If the iteration takes too long and I can imagine it does with zillions
of tasks then the proper way around it is either release the lock
periodically after N tasks is processed or outright skip the whole thing
if there are too many tasks. The first option is obviously tricky to
prevent from duplicate entries or other artifacts.
-- 
Michal Hocko
SUSE Labs
