Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3CD9C6B7DAE
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 05:37:18 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id g9-v6so6987275pgc.16
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 02:37:18 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v126-v6sor1195327pgv.289.2018.09.07.02.37.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Sep 2018 02:37:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180907082745.GB19621@dhcp22.suse.cz>
References: <CACT4Y+Yp6ZbusCWg5C1zaJpcS8=XnGPboKgWfyxVk1axQA2nbw@mail.gmail.com>
 <201809060553.w865rmpj036017@www262.sakura.ne.jp> <CACT4Y+YKJWJr-5rBQidt6nY7+VF=BAsvHyh+XTaf8spwNy3qPA@mail.gmail.com>
 <58aa0543-86d0-b2ad-7fb9-9bed7c6a1f6c@i-love.sakura.ne.jp>
 <20180906112306.GO14951@dhcp22.suse.cz> <1611e45d-235e-67e9-26e3-d0228255fa2f@i-love.sakura.ne.jp>
 <20180906115320.GS14951@dhcp22.suse.cz> <7f50772a-f2ef-d16e-4d09-7f34f4bf9227@i-love.sakura.ne.jp>
 <20180906143905.GC14951@dhcp22.suse.cz> <32c58019-5e2d-b3a1-a6ad-ea374ccd8b60@i-love.sakura.ne.jp>
 <20180907082745.GB19621@dhcp22.suse.cz>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 7 Sep 2018 11:36:55 +0200
Message-ID: <CACT4Y+bS+kqf+8fp11qSpQ4WtaZt_sVYmvwi_9LFX_=Dwk1N4A@mail.gmail.com>
Subject: Re: [PATCH] mm, oom: Introduce time limit for dump_tasks duration.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, syzbot <syzbot+f0fc7f62e88b1de99af3@syzkaller.appspotmail.com>, 'Dmitry Vyukov' via syzkaller-upstream-moderation <syzkaller-upstream-moderation@googlegroups.com>, linux-mm <linux-mm@kvack.org>

On Fri, Sep 7, 2018 at 10:27 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Fri 07-09-18 05:58:06, Tetsuo Handa wrote:
>> On 2018/09/06 23:39, Michal Hocko wrote:
>> >>>> I know /proc/sys/vm/oom_dump_tasks . Showing some entries while not always
>> >>>> printing all entries might be helpful.
>> >>>
>> >>> Not really. It could be more confusing than helpful. The main purpose of
>> >>> the listing is to double check the list to understand the oom victim
>> >>> selection. If you have a partial list you simply cannot do that.
>> >>
>> >> It serves as a safeguard for avoiding RCU stall warnings.
>> >>
>> >>>
>> >>> If the iteration takes too long and I can imagine it does with zillions
>> >>> of tasks then the proper way around it is either release the lock
>> >>> periodically after N tasks is processed or outright skip the whole thing
>> >>> if there are too many tasks. The first option is obviously tricky to
>> >>> prevent from duplicate entries or other artifacts.
>> >>>
>> >>
>> >> Can we add rcu_lock_break() like check_hung_uninterruptible_tasks() does?
>> >
>> > This would be a better variant of your timeout based approach. But it
>> > can still produce an incomplete task list so it still consumes a lot of
>> > resources to print a long list of tasks potentially while that list is not
>> > useful for any evaluation. Maybe that is good enough. I don't know. I
>> > would generally recommend to disable the whole thing with workloads with
>> > many tasks though.
>> >
>>
>> The "safeguard" is useful when there are _unexpectedly_ many tasks (like
>> syzbot in this case). Why not to allow those who want to avoid lockup to
>> avoid lockup rather than forcing them to disable the whole thing?
>
> So you get an rcu lockup splat and what? Unless you have panic_on_rcu_stall
> then this should be recoverable thing (assuming we cannot really
> livelock as described by Dmitry).


Should I add "vm.oom_dump_tasks = 0" to /etc/sysctl.conf on syzbot?
It looks like it will make things faster, not pollute console output,
prevent these stalls and that output does not seem to be too useful
for debugging.

But I am still concerned as to what has changed recently. Potentially
this happens only on linux-next, at least that's where I saw all
existing reports.
New tasks seem to be added to the tail of the tasks list, but this
part does not seem to be changed recently in linux-next..
