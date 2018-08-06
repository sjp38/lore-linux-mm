Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3D41E6B000C
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 07:58:01 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id g13-v6so5489153pgv.11
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 04:58:01 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r9-v6sor3039324plo.33.2018.08.06.04.57.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Aug 2018 04:57:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180806110224.GI19540@dhcp22.suse.cz>
References: <0000000000005e979605729c1564@google.com> <20180806091552.GE19540@dhcp22.suse.cz>
 <CACT4Y+Ystnwv4M6Uh+HBKbdADAnJ6otfR0GoA20crzqV+b2onQ@mail.gmail.com>
 <20180806094827.GH19540@dhcp22.suse.cz> <CACT4Y+ZJsDo1gjzHvbFVqHcrL=tFJXTAAWLs9mAJSv3+LiCdmA@mail.gmail.com>
 <20180806110224.GI19540@dhcp22.suse.cz>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 6 Aug 2018 13:57:38 +0200
Message-ID: <CACT4Y+awxBatn3GQc7EWHVfHqMLKC9eVKjQMbJkCk0Po-X4VDQ@mail.gmail.com>
Subject: Re: WARNING in try_charge
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: syzbot <syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com>, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Dmitry Torokhov <dtor@google.com>

On Mon, Aug 6, 2018 at 1:02 PM, Michal Hocko <mhocko@kernel.org> wrote:
>> >> > More interesting stuff is higher in the kernel log
>> >> > : [  366.435015] oom-kill:constraint=CONSTRAINT_MEMCG,nodemask=(null),cpuset=/,mems_allowed=0,oom_memcg=/ile0,task_memcg=/ile0,task=syz-executor3,pid=23766,uid=0
>> >> > : [  366.449416] memory: usage 112kB, limit 0kB, failcnt 1605
>> >> >
>> >> > Are you sure you want to have hard limit set to 0?
>> >>
>> >> syzkaller really does not mind to have it.
>> >
>> > So what do you use it for? What do you actually test by this setting?
>>
>> syzkaller is kernel fuzzer, it finds kernel bugs by doing whatever is
>> doable from user-space. Some of that may not make sense, but it does
>> not matter because kernel should still stand still.
>
> I am not questioning that. What I am saying is that the configuration
> doesn't make much sense and the kernel warns about it.
>
>> > [...]
>> >> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> >> > index 4603ad75c9a9..852cd3dbdcd9 100644
>> >> > --- a/mm/memcontrol.c
>> >> > +++ b/mm/memcontrol.c
>> >> > @@ -1388,6 +1388,8 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>> >> >         bool ret;
>> >> >
>> >> >         mutex_lock(&oom_lock);
>> >> > +       pr_info("task=%s pid=%d invoked memcg oom killer. oom_victim=%d\n",
>> >> > +                       current->comm, current->pid, tsk_is_oom_victim(current));
>> >> >         ret = out_of_memory(&oc);
>> >> >         mutex_unlock(&oom_lock);
>> >> >         return ret;
>> >> >
>> >> > Anyway your memcg setup is indeed misconfigured. Memcg with 0 hard limit
>> >> > and basically no memory charged by existing tasks is not going to fly
>> >> > and the warning is exactly to call that out.
>> >>
>> >>
>> >> Please-please-please do not mix kernel bugs and notices to user into
>> >> the same bucket:
>> >
>> > Well, WARN_ON used to be a standard way to make user aware of a
>> > misbehavior. In this case it warns about a pottential runaway when memcg
>> > is misconfigured. I do not insist on using WARN_ON here of course. If
>> > there is a general agreement that such a condition is better handled by
>> > pr_err then I am fine with it. Users tend to be more sensitive on
>> > WARN_ONs though.
>>
>> The docs change was acked by Greg, and Andrew took it into mm, Linus
>> was CCed too. It missed the release because I guess it's comments only
>> change, but otherwise it should reach upstream tree on the next merge
>> window.
>>
>> WARN is _not_ a common way to notify users today. syzbot reports _all_
>> WARN occurrences and you can see there are not many of them now
>> (probably 1 another now, +dtor for that one):
>> https://syzkaller.appspot.com#upstream
>> There is probably some long tail that we need to fix. We really do
>> want systematic testing capability. You do not want every of 2 billion
>> linux users to come to you with this kernel splat, just so that you
>> can explain to them that it's some programs of their machines doing
>> something wrong, right?
>
> [This is an orthogonal discussion I believe]
>
> How does it differ from pr_err though?

pr_err output looks very different, says that it is the user program
that does something wrong, explains what exactly is done wrong and
does not contain traces, offsets of hex numbers that scare end users.
WARN for kernel bugs/pr_err for user separation allows to easily
understand (including by computer programs) if it is a kernel bugs
(something to notify kernel developers about) or not. In particular if
it would be the case here, we would not have this bug report and would
not spent time here.

>> WARN is really a bad way to inform a user about something. Consider a
>> non-kernel developer, perhaps even non-programmer. What they see is
>> "WARNING: CPU: 1 PID: 23767 at mm/memcontrol.c:1710
>> try_charge+0x734/0x1680" followed by some obscure things and hex
>> numbers. File:line reference is pointless, they don't what what/where
>> it is.
>
> Well, you get a precise location where the problem happens and the
> backtrace to see how it happened. This is much more information than,
> pr_err without dump_stack.

This information is important for kernel bugs, but not for invalid
values passed by user programs. For the latter the exact location
where the problem happened is not there, it's in some user program.
For the latter it is more important to explain in readable language
what exactly arguments to what call were wrong.
Say, if you enter a wrong pin in ATM, it says "you entered wrong pin"
and not dumps some internal state in hex.

>> This one is slightly better because it prints "Memory cgroup
>> charge failed because of no reclaimable memory! This looks like a
>> misconfiguration or a kernel bug." before the warning. But still it
>> says "or a kernel bug", which means that they will come to you.
>
> Yeah, and that was the purpose of the thing.

Why? Was it clear how exactly if can happen? Can we refine it now?

>> A much
>> friendlier for user way to say this would be print a message at the
>> point of misconfiguration saying what exactly is wrong, e.g. "pid $PID
>> misconfigures cgroup /cgroup/path with mem.limit=0" without a stack
>> trace (does not give any useful info for user). And return EINVAL if
>> it can't fly at all? And then leave the "or a kernel bug" part for the
>> WARNING each occurrence of which we do want to be reported to kernel
>> developers.
>
> But this is not applicable here. Your misconfiguration is quite obvious
> because you simply set the hard limit to 0. This is not the only
> situation when this can happen. There is no clear point to tell, you are
> doing this wrong. If it was we would do it at that point obviously.

But, isn't there a point were hard limit is set to 0? I would expect
there is a something like cgroup file write handler with a value of 0
or something.

> If you have a strong reason to believe that this is an abuse of WARN I
> am all happy to change that. But I haven't heard any yet, to be honest.

WARN must not be used for anything that is not kernel bugs. If this is
not kernel bug, WARN must not be used here.
