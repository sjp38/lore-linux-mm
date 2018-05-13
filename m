Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2A3CA6B06BD
	for <linux-mm@kvack.org>; Sun, 13 May 2018 10:29:54 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 62-v6so8463440pfw.21
        for <linux-mm@kvack.org>; Sun, 13 May 2018 07:29:54 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id h16-v6si3679524pli.53.2018.05.13.07.29.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 13 May 2018 07:29:50 -0700 (PDT)
Subject: Re: BUG: workqueue lockup (2)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <94eb2c03c9bc75aff2055f70734c@google.com>
	<001a113f711a528a3f0560b08e76@google.com>
	<20180512215222.GC817@sol.localdomain>
	<201805131106.GFF73973.OOtMVQFSFOJFHL@I-love.SAKURA.ne.jp>
	<20180513033220.GA654@sol.localdomain>
In-Reply-To: <20180513033220.GA654@sol.localdomain>
Message-Id: <201805132329.CEB90134.OFFSMHOFtVJQLO@I-love.SAKURA.ne.jp>
Date: Sun, 13 May 2018 23:29:41 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ebiggers3@gmail.com
Cc: bot+e38be687a2450270a3b593bacb6b5795a7a74edb@syzkaller.appspotmail.com, peter@hurleysoftware.com, dvyukov@google.com, gregkh@linuxfoundation.org, kstewart@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pombredanne@nexb.com, syzkaller-bugs@googlegroups.com, tglx@linutronix.de

Eric Biggers wrote:
> Generally it's best to close syzbot bug reports once the original cause is
> fixed, so that syzbot can continue to report other bugs with the same signature.

That's difficult to judge. Closing as soon as the original cause is fixed allows
syzbot to try to report different reproducer for different bugs. But at the same time,
different/similar bugs which were reported in that report (or comments in the discussion
for that report) will become almost invisible from users (because users unlikely check
other reports in already fixed bugs).

An example is

  general protection fault in kernfs_kill_sb (2)
  https://syzkaller.appspot.com/bug?id=903af3e08fc7ec60e57d9c9b93b035f4fb038d9a

where the cause of above report was already pointed out in the discussion for
the below report.

  general protection fault in kernfs_kill_sb
  https://syzkaller.appspot.com/bug?id=d7db6ecf34f099248e4ff404cd381a19a4075653

Since the latter is marked as "fixed on May 08 18:30", I worry that quite few
users would check the relationship.

> Note also that a "workqueue lockup" can be caused by almost anything in the
> kernel, I think.  This one for example is probably in the sound subsystem:
> https://syzkaller.appspot.com/text?tag=CrashReport&x=1767232b800000
> 

Right. Maybe we should not stop the test upon "workqueue lockup" message, for
it is likely that the cause of lockup is that somebody is busy looping which
should have been reported shortly as "rcu detected stall".

Of course, there is possibility that "workqueue lockup" is reported because
cond_resched() was used when explicit schedule_timeout_*() is required, which
was the reason commit 82607adcf9cdf40f ("workqueue: implement lockup detector")
was added.

If we stop the test upon "workqueue lockup" message, maybe longer timeout (e.g.
300 seconds) is better so that rcu stall or hung task messages are reported
if rcu stall or hung task is occurring.
