Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 43A0D8E0002
	for <linux-mm@kvack.org>; Sat, 19 Jan 2019 08:01:36 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id q23so7188860otn.3
        for <linux-mm@kvack.org>; Sat, 19 Jan 2019 05:01:36 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id i13si3813158ota.112.2019.01.19.05.01.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 Jan 2019 05:01:35 -0800 (PST)
Subject: Re: INFO: rcu detected stall in sys_sendfile64 (2)
References: <00000000000010b2fc057fcdfaba@google.com>
 <CACT4Y+ZSK4DDhsz5gCAUnW49mCJPGcKECqC8yAn=PAA0Tx8D3w@mail.gmail.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <1737a5e1-f93a-e7ea-80d0-c244b22d0b61@I-love.SAKURA.ne.jp>
Date: Sat, 19 Jan 2019 22:00:55 +0900
MIME-Version: 1.0
In-Reply-To: <CACT4Y+ZSK4DDhsz5gCAUnW49mCJPGcKECqC8yAn=PAA0Tx8D3w@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, syzbot <syzbot+1505c80c74256c6118a5@syzkaller.appspotmail.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Amir Goldstein <amir73il@gmail.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Dave Chinner <david@fromorbit.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Souptick Joarder <jrdr.linux@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Matthew Wilcox <willy@infradead.org>

On 2019/01/19 20:41, Dmitry Vyukov wrote:
> On Sat, Jan 19, 2019 at 12:32 PM syzbot
> <syzbot+1505c80c74256c6118a5@syzkaller.appspotmail.com> wrote:
>>
>> Hello,
>>
>> syzbot found the following crash on:
>>
>> HEAD commit:    2339e91d0e66 Merge tag 'media/v5.0-1' of git://git.kernel...
>> git tree:       upstream
>> console output: https://syzkaller.appspot.com/x/log.txt?x=175f2638c00000
>> kernel config:  https://syzkaller.appspot.com/x/.config?x=abc3dc9b7a900258
>> dashboard link: https://syzkaller.appspot.com/bug?extid=1505c80c74256c6118a5
>> compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
>> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=12c4dc28c00000
>> C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=15df4108c00000
> 
> Looking at the reproducer it looks like something with scheduler as it
> involves perf_event_open and sched_setattr. So +Peter and Mingo.
> Is it the same root cause as the other stalls involving sched_setattr?

Yes. I think sched_setattr() involves this problem.

Reproducers from "BUG: workqueue lockup (4)" at
https://syzkaller.appspot.com/text?tag=ReproC&x=13ec31a5400000
involves sched_setattr(SCHED_DEADLINE) and
https://syzkaller.appspot.com/text?tag=ReproC&x=104da690c00000
also involves sched_setattr().
