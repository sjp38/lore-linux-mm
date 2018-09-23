Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id DA8E18E0001
	for <linux-mm@kvack.org>; Sun, 23 Sep 2018 12:33:59 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id s15-v6so35246360iob.11
        for <linux-mm@kvack.org>; Sun, 23 Sep 2018 09:33:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m191-v6sor6861200jab.142.2018.09.23.09.33.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 23 Sep 2018 09:33:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAKdAkRS7PSXv65MTnvKOewqESxt0_FtKohd86ioOuYR3R0z9dw@mail.gmail.com>
References: <000000000000e5f76c057664e73d@google.com> <CAKdAkRS7PSXv65MTnvKOewqESxt0_FtKohd86ioOuYR3R0z9dw@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Sun, 23 Sep 2018 18:33:37 +0200
Message-ID: <CACT4Y+YOb6M=xuPG64PAvd=0bcteicGtwQO60CevN_V67SJ=MQ@mail.gmail.com>
Subject: Re: WARNING: kmalloc bug in input_mt_init_slots
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Cc: syzbot+87829a10073277282ad1@syzkaller.appspotmail.com, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, "linux-input@vger.kernel.org" <linux-input@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>, Henrik Rydberg <rydberg@bitmath.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Linux-MM <linux-mm@kvack.org>

On Fri, Sep 21, 2018 at 7:52 PM, Dmitry Torokhov
<dmitry.torokhov@gmail.com> wrote:
> On Fri, Sep 21, 2018 at 10:24 AM syzbot
> <syzbot+87829a10073277282ad1@syzkaller.appspotmail.com> wrote:
>>
>> Hello,
>>
>> syzbot found the following crash on:
>>
>> HEAD commit:    234b69e3e089 ocfs2: fix ocfs2 read block panic
>> git tree:       upstream
>> console output: https://syzkaller.appspot.com/x/log.txt?x=131f761a400000
>> kernel config:  https://syzkaller.appspot.com/x/.config?x=5fa12be50bca08d8
>> dashboard link: https://syzkaller.appspot.com/bug?extid=87829a10073277282ad1
>> compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
>> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=126ca61a400000
>> C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=119d6511400000
>>
>> IMPORTANT: if you fix the bug, please add the following tag to the commit:
>> Reported-by: syzbot+87829a10073277282ad1@syzkaller.appspotmail.com
>>
>> input: syz0 as /devices/virtual/input/input25382
>> WARNING: CPU: 0 PID: 11238 at mm/slab_common.c:1031 kmalloc_slab+0x56/0x70
>> mm/slab_common.c:1031
>> Kernel panic - not syncing: panic_on_warn set ...
>
> This is coming from:
>
> commit 6286ae97d10ea2b5cd90532163797ab217bfdbdf
> Author: Christoph Lameter <cl@linux.com>
> Date:   Fri May 3 15:43:18 2013 +0000
>
>    slab: Return NULL for oversized allocations
>
>    The inline path seems to have changed the SLAB behavior for very large
>    kmalloc allocations with  commit e3366016 ("slab: Use common
>    kmalloc_index/kmalloc_size functions"). This patch restores the old
>    behavior but also adds diagnostics so that we can figure where in the
>    code these large allocations occur.
>
>    Reported-and-tested-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
>    Signed-off-by: Christoph Lameter <cl@linux.com>
>    Link: http://lkml.kernel.org/r/201305040348.CIF81716.OStQOHFJMFLOVF@I-love.SAKURA.ne.jp
>    [ penberg@kernel.org: use WARN_ON_ONCE ]
>    Signed-off-by: Pekka Enberg <penberg@kernel.org>
>
> You'll have to convince Cristoph that WARN_ON_ONCE() there is evil and
> has to be eradicated so that KASAN can run (but then we'd not know
> easily that some allocation failed because it was too big and never
> had a chance of succeeding vs. ordinary memory failure).
>
> Can I recommend that maybe you introduce infrastructure for
> panic_on_warn to ignore certain "well known" warnings?

Hi Christoph,

What was the motivation behind that WARNING about large allocations in
kmalloc? Why do we want to know about them? Is the general policy that
kmalloc calls with potentially large size requests need to use NOWARN?
If this WARNING still considered useful? Or we should change it to
pr_err?
