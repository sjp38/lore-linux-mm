Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id C245B6B06BF
	for <linux-mm@kvack.org>; Sun, 13 May 2018 10:35:53 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id f35-v6so9082914plb.10
        for <linux-mm@kvack.org>; Sun, 13 May 2018 07:35:53 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n29-v6sor2648647pgf.333.2018.05.13.07.35.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 13 May 2018 07:35:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201805132329.CEB90134.OFFSMHOFtVJQLO@I-love.SAKURA.ne.jp>
References: <94eb2c03c9bc75aff2055f70734c@google.com> <001a113f711a528a3f0560b08e76@google.com>
 <20180512215222.GC817@sol.localdomain> <201805131106.GFF73973.OOtMVQFSFOJFHL@I-love.SAKURA.ne.jp>
 <20180513033220.GA654@sol.localdomain> <201805132329.CEB90134.OFFSMHOFtVJQLO@I-love.SAKURA.ne.jp>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Sun, 13 May 2018 16:35:31 +0200
Message-ID: <CACT4Y+YzZJHnjeBwKV8ZgOVG_+g0yPq2tw1Jhx4A2qdbsVggtQ@mail.gmail.com>
Subject: Re: BUG: workqueue lockup (2)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Eric Biggers <ebiggers3@gmail.com>, syzbot <bot+e38be687a2450270a3b593bacb6b5795a7a74edb@syzkaller.appspotmail.com>, Peter Hurley <peter@hurleysoftware.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Philippe Ombredanne <pombredanne@nexb.com>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Thomas Gleixner <tglx@linutronix.de>

On Sun, May 13, 2018 at 4:29 PM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
> Eric Biggers wrote:
>> Generally it's best to close syzbot bug reports once the original cause is
>> fixed, so that syzbot can continue to report other bugs with the same signature.
>
> That's difficult to judge. Closing as soon as the original cause is fixed allows
> syzbot to try to report different reproducer for different bugs. But at the same time,
> different/similar bugs which were reported in that report (or comments in the discussion
> for that report) will become almost invisible from users (because users unlikely check
> other reports in already fixed bugs).
>
> An example is
>
>   general protection fault in kernfs_kill_sb (2)
>   https://syzkaller.appspot.com/bug?id=903af3e08fc7ec60e57d9c9b93b035f4fb038d9a
>
> where the cause of above report was already pointed out in the discussion for
> the below report.
>
>   general protection fault in kernfs_kill_sb
>   https://syzkaller.appspot.com/bug?id=d7db6ecf34f099248e4ff404cd381a19a4075653
>
> Since the latter is marked as "fixed on May 08 18:30", I worry that quite few
> users would check the relationship.
>
>> Note also that a "workqueue lockup" can be caused by almost anything in the
>> kernel, I think.  This one for example is probably in the sound subsystem:
>> https://syzkaller.appspot.com/text?tag=CrashReport&x=1767232b800000
>>
>
> Right. Maybe we should not stop the test upon "workqueue lockup" message, for
> it is likely that the cause of lockup is that somebody is busy looping which
> should have been reported shortly as "rcu detected stall".
>
> Of course, there is possibility that "workqueue lockup" is reported because
> cond_resched() was used when explicit schedule_timeout_*() is required, which
> was the reason commit 82607adcf9cdf40f ("workqueue: implement lockup detector")
> was added.
>
> If we stop the test upon "workqueue lockup" message, maybe longer timeout (e.g.
> 300 seconds) is better so that rcu stall or hung task messages are reported
> if rcu stall or hung task is occurring.

Yes, we need order different stalls/lockups/hangs/etc according to
what can trigger what. E.g. rcu stall can trigger task hung and
workqueue lockup, but not the other way around.
There is https://github.com/google/syzkaller/issues/516 to track this.
But I did not yet have time to figure out all required changes.
If you have additional details, please add them there.
