Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id CDD9F6B000C
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 13:54:01 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id p5-v6so8943094pfh.11
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 10:54:01 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k34-v6sor2963631pgl.92.2018.08.06.10.54.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Aug 2018 10:54:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180806173000.GA10003@dhcp22.suse.cz>
References: <0000000000005e979605729c1564@google.com> <20180806091552.GE19540@dhcp22.suse.cz>
 <CACT4Y+Ystnwv4M6Uh+HBKbdADAnJ6otfR0GoA20crzqV+b2onQ@mail.gmail.com>
 <20180806094827.GH19540@dhcp22.suse.cz> <CACT4Y+ZJsDo1gjzHvbFVqHcrL=tFJXTAAWLs9mAJSv3+LiCdmA@mail.gmail.com>
 <20180806110224.GI19540@dhcp22.suse.cz> <CACT4Y+awxBatn3GQc7EWHVfHqMLKC9eVKjQMbJkCk0Po-X4VDQ@mail.gmail.com>
 <20180806142124.GP19540@dhcp22.suse.cz> <CACT4Y+Y+fwJ1-v89kw3vgyHO_BWk97WOVOE1BsZdqDiiSFcGzQ@mail.gmail.com>
 <20180806173000.GA10003@dhcp22.suse.cz>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 6 Aug 2018 19:53:39 +0200
Message-ID: <CACT4Y+ZvE7GgFz7Gq72bY_LL24aED9ZCLRxZa2TUfpEXYGtPWg@mail.gmail.com>
Subject: Re: WARNING in try_charge
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: syzbot <syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com>, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Dmitry Torokhov <dtor@google.com>

On Mon, Aug 6, 2018 at 7:30 PM, Michal Hocko <mhocko@kernel.org> wrote:
>> >> >> A much
>> >> >> friendlier for user way to say this would be print a message at the
>> >> >> point of misconfiguration saying what exactly is wrong, e.g. "pid $PID
>> >> >> misconfigures cgroup /cgroup/path with mem.limit=0" without a stack
>> >> >> trace (does not give any useful info for user). And return EINVAL if
>> >> >> it can't fly at all? And then leave the "or a kernel bug" part for the
>> >> >> WARNING each occurrence of which we do want to be reported to kernel
>> >> >> developers.
>> >> >
>> >> > But this is not applicable here. Your misconfiguration is quite obvious
>> >> > because you simply set the hard limit to 0. This is not the only
>> >> > situation when this can happen. There is no clear point to tell, you are
>> >> > doing this wrong. If it was we would do it at that point obviously.
>> >>
>> >> But, isn't there a point were hard limit is set to 0? I would expect
>> >> there is a something like cgroup file write handler with a value of 0
>> >> or something.
>> >
>> > Yeah, but this is only one instance of the problem. Other is that the
>> > memcg is not reclaimable for any other reasons. And we do not know what
>> > those might be
>> >
>> >>
>> >> > If you have a strong reason to believe that this is an abuse of WARN I
>> >> > am all happy to change that. But I haven't heard any yet, to be honest.
>> >>
>> >> WARN must not be used for anything that is not kernel bugs. If this is
>> >> not kernel bug, WARN must not be used here.
>> >
>> > This is rather strong wording without any backing arguments. I strongly
>> > doubt 90% of existing WARN* match this expectation. WARN* has
>> > traditionally been a way to tell that something suspicious is going on.
>> > Those situation are mostly likely not fatal but it is good to know they
>> > are happening.
>> >
>> > Sure there is that panic_on_warn thingy which you seem to be using and I
>> > suspect it is a reason why you are so careful about warnings in general
>> > but my experience tells me that this configuration is barely usable
>> > except for testing (which is your case).
>> >
>> > But as I've said, I do not insist on WARN here. All I care about is to
>> > warn user that something might go south and this may be either due to
>> > misconfiguration or a subtly wrong memcg reclaim/OOM handler behavior.
>>
>> I am a bit lost. Can limit=0 legally lead to the warnings? Or there is
>> also a kernel bug on top of that and it's actually a kernel bug that
>> provokes the warning?
>
> As I've tried to tell already. I cannot tell for sure. It is the killed
> oom victim which triggered thw warning and that shouldn't really
> happen. Considering this doesn't reproduce with the current linux next
> nor linus tree and the oom code has changed since the version you have
> tested then I would suspect there was something wrong with the memcg oom
> code. But maybe the test doesn't really reproduce reliably.
>
>> If it's a kernel bug, then I propose to stop arguing about
>> configuration and concentrate on the bug.
>> If it's just the misconfiguration that triggers the warning,  then can
>> we separate the 2 causes of the warning (user misconfiguration and
>> kernel bugs)? Say, return EINVAL when mem limit is set to 0 (and print
>> a line to console if necessary)? Or if the limit=0 is somehow not
>> possible/desirable to detect right away, check limit=0 at the point of
>> the warning and don't want?
>
> No we simply cannot. There is numerous situations when this can trigger.
> Say you set the hard limit to N and then try to fault in shmem file with
> the size >= N. No oom killer will help to reclaim memory. Or say you
> migrate the all tasks away from the memcg and then somebody triggers the
> memcg OOM in that group. There is simply nobody to kill. See the point?
> There is simply no direct contection between the configuration and
> actual problem. Too many things might happen between those two points.
> Let me repeat. We do warn because we want to hear if this happens. WARN
> tends to be a good way to get that attention. If you strongly believe
> this is an abuse I won't mind seeing a patch to turn it into something
> different.

I don't believe it is an abuse, I don't know this code well. Let's
assume the misconfiguration is a red-herring for now then.
