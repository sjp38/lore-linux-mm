Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3C4D46B026B
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 11:07:49 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id n4-v6so5689869pgp.8
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 08:07:49 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q8-v6sor3197145pgr.350.2018.08.06.08.07.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Aug 2018 08:07:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180806142124.GP19540@dhcp22.suse.cz>
References: <0000000000005e979605729c1564@google.com> <20180806091552.GE19540@dhcp22.suse.cz>
 <CACT4Y+Ystnwv4M6Uh+HBKbdADAnJ6otfR0GoA20crzqV+b2onQ@mail.gmail.com>
 <20180806094827.GH19540@dhcp22.suse.cz> <CACT4Y+ZJsDo1gjzHvbFVqHcrL=tFJXTAAWLs9mAJSv3+LiCdmA@mail.gmail.com>
 <20180806110224.GI19540@dhcp22.suse.cz> <CACT4Y+awxBatn3GQc7EWHVfHqMLKC9eVKjQMbJkCk0Po-X4VDQ@mail.gmail.com>
 <20180806142124.GP19540@dhcp22.suse.cz>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 6 Aug 2018 17:07:26 +0200
Message-ID: <CACT4Y+bbKG4SQoEY+DVYRzyYN4aBJ1goC+B1R26dGtMVPkMonQ@mail.gmail.com>
Subject: Re: WARNING in try_charge
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: syzbot <syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com>, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Dmitry Torokhov <dtor@google.com>

On Mon, Aug 6, 2018 at 4:21 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Mon 06-08-18 13:57:38, Dmitry Vyukov wrote:
>> On Mon, Aug 6, 2018 at 1:02 PM, Michal Hocko <mhocko@kernel.org> wrote:
> [...]
>> >> A much
>> >> friendlier for user way to say this would be print a message at the
>> >> point of misconfiguration saying what exactly is wrong, e.g. "pid $PID
>> >> misconfigures cgroup /cgroup/path with mem.limit=0" without a stack
>> >> trace (does not give any useful info for user). And return EINVAL if
>> >> it can't fly at all? And then leave the "or a kernel bug" part for the
>> >> WARNING each occurrence of which we do want to be reported to kernel
>> >> developers.
>> >
>> > But this is not applicable here. Your misconfiguration is quite obvious
>> > because you simply set the hard limit to 0. This is not the only
>> > situation when this can happen. There is no clear point to tell, you are
>> > doing this wrong. If it was we would do it at that point obviously.
>>
>> But, isn't there a point were hard limit is set to 0? I would expect
>> there is a something like cgroup file write handler with a value of 0
>> or something.
>
> Yeah, but this is only one instance of the problem. Other is that the
> memcg is not reclaimable for any other reasons. And we do not know what
> those might be
>
>>
>> > If you have a strong reason to believe that this is an abuse of WARN I
>> > am all happy to change that. But I haven't heard any yet, to be honest.
>>
>> WARN must not be used for anything that is not kernel bugs. If this is
>> not kernel bug, WARN must not be used here.
>
> This is rather strong wording without any backing arguments. I strongly
> doubt 90% of existing WARN* match this expectation. WARN* has
> traditionally been a way to tell that something suspicious is going on.
> Those situation are mostly likely not fatal but it is good to know they
> are happening.

Today syzbot covers about 1M lines of kernel code, and we fuzz for
several years with panic_on_warn=1 and each unique crash is recorded
and reported. Over several thousands bugs that we reported, there were
maybe 2 dozens of such cases (WARN on invalid user inputs, ENOMEM,
etc). The solution always was to remove the WARNING on covert to
pr_err. As of now, I see only 2 such cases open: this one and WARN on
ENOMEM in input subsystem.

Either way, we do badly need this separation. If there are deviations
we need to continue fixing them.
