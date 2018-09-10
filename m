Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id DED928E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 10:37:17 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id s14-v6so761756ioc.0
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 07:37:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z189-v6sor10098695itd.16.2018.09.10.07.37.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Sep 2018 07:37:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACT4Y+b8zxX+y4djztg=qnQBLzBT4rFpHCToJAwsF5ZiBWYfdA@mail.gmail.com>
References: <CACT4Y+YKJWJr-5rBQidt6nY7+VF=BAsvHyh+XTaf8spwNy3qPA@mail.gmail.com>
 <58aa0543-86d0-b2ad-7fb9-9bed7c6a1f6c@i-love.sakura.ne.jp>
 <20180906112306.GO14951@dhcp22.suse.cz> <1611e45d-235e-67e9-26e3-d0228255fa2f@i-love.sakura.ne.jp>
 <20180906115320.GS14951@dhcp22.suse.cz> <7f50772a-f2ef-d16e-4d09-7f34f4bf9227@i-love.sakura.ne.jp>
 <20180906143905.GC14951@dhcp22.suse.cz> <32c58019-5e2d-b3a1-a6ad-ea374ccd8b60@i-love.sakura.ne.jp>
 <20180907082745.GB19621@dhcp22.suse.cz> <CACT4Y+bS+kqf+8fp11qSpQ4WtaZt_sVYmvwi_9LFX_=Dwk1N4A@mail.gmail.com>
 <20180907110817.GG19621@dhcp22.suse.cz> <CACT4Y+b8zxX+y4djztg=qnQBLzBT4rFpHCToJAwsF5ZiBWYfdA@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 10 Sep 2018 16:36:55 +0200
Message-ID: <CACT4Y+b55n5bVR8+=+YqRcmMHUb2d712HtK=UN+NhgsofA1saQ@mail.gmail.com>
Subject: Re: [PATCH] mm, oom: Introduce time limit for dump_tasks duration.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, syzbot <syzbot+f0fc7f62e88b1de99af3@syzkaller.appspotmail.com>, 'Dmitry Vyukov' via syzkaller-upstream-moderation <syzkaller-upstream-moderation@googlegroups.com>, linux-mm <linux-mm@kvack.org>

On Sat, Sep 8, 2018 at 4:00 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Fri, Sep 7, 2018 at 1:08 PM, Michal Hocko <mhocko@kernel.org> wrote:
>>> >> >>>> I know /proc/sys/vm/oom_dump_tasks . Showing some entries while not always
>>> >> >>>> printing all entries might be helpful.
>>> >> >>>
>>> >> >>> Not really. It could be more confusing than helpful. The main purpose of
>>> >> >>> the listing is to double check the list to understand the oom victim
>>> >> >>> selection. If you have a partial list you simply cannot do that.
>>> >> >>
>>> >> >> It serves as a safeguard for avoiding RCU stall warnings.
>>> >> >>
>>> >> >>>
>>> >> >>> If the iteration takes too long and I can imagine it does with zillions
>>> >> >>> of tasks then the proper way around it is either release the lock
>>> >> >>> periodically after N tasks is processed or outright skip the whole thing
>>> >> >>> if there are too many tasks. The first option is obviously tricky to
>>> >> >>> prevent from duplicate entries or other artifacts.
>>> >> >>>
>>> >> >>
>>> >> >> Can we add rcu_lock_break() like check_hung_uninterruptible_tasks() does?
>>> >> >
>>> >> > This would be a better variant of your timeout based approach. But it
>>> >> > can still produce an incomplete task list so it still consumes a lot of
>>> >> > resources to print a long list of tasks potentially while that list is not
>>> >> > useful for any evaluation. Maybe that is good enough. I don't know. I
>>> >> > would generally recommend to disable the whole thing with workloads with
>>> >> > many tasks though.
>>> >> >
>>> >>
>>> >> The "safeguard" is useful when there are _unexpectedly_ many tasks (like
>>> >> syzbot in this case). Why not to allow those who want to avoid lockup to
>>> >> avoid lockup rather than forcing them to disable the whole thing?
>>> >
>>> > So you get an rcu lockup splat and what? Unless you have panic_on_rcu_stall
>>> > then this should be recoverable thing (assuming we cannot really
>>> > livelock as described by Dmitry).
>>>
>>>
>>> Should I add "vm.oom_dump_tasks = 0" to /etc/sysctl.conf on syzbot?
>>> It looks like it will make things faster, not pollute console output,
>>> prevent these stalls and that output does not seem to be too useful
>>> for debugging.
>>
>> I think that oom_dump_tasks has only very limited usefulness for your
>> testing.
>>
>>> But I am still concerned as to what has changed recently. Potentially
>>> this happens only on linux-next, at least that's where I saw all
>>> existing reports.
>>> New tasks seem to be added to the tail of the tasks list, but this
>>> part does not seem to be changed recently in linux-next..
>>
>> Yes, that would be interesting to find out.
>
>
> Looking at another similar report:
> https://syzkaller.appspot.com/bug?extid=0d867757fdc016c0157e
> It looks like it can be just syzkaller learning how to do fork bombs
> after all (same binary multiplied infinite amount of times). Probably
> required some creativity because test programs do not contain loops
> per se and clone syscall does not accept start function pc.
> I will set vm.oom_dump_tasks = 0 and try to additionally restrict it
> with cgroups.


FTR, syzkaller now restricts test processes with pids.max=32. This
should prevent any fork bombs.
https://github.com/google/syzkaller/commit/f167cb6b0957d34f95b1067525aa87083f264035
