Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1C1FC8E0001
	for <linux-mm@kvack.org>; Sat,  8 Sep 2018 11:15:27 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id o27-v6so8872796pfj.6
        for <linux-mm@kvack.org>; Sat, 08 Sep 2018 08:15:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e7-v6sor2204019plk.26.2018.09.08.08.15.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 08 Sep 2018 08:15:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAGXu5jLLYCGnN66UNeYqcPCPN4EAb=PzGLuQj4-UZr_A0AHp-g@mail.gmail.com>
References: <000000000000e16cba057549aab6@google.com> <14d5bccf-f12d-0fc1-eddc-9fb24dc0cf14@I-love.SAKURA.ne.jp>
 <CAGXu5jLLYCGnN66UNeYqcPCPN4EAb=PzGLuQj4-UZr_A0AHp-g@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Sat, 8 Sep 2018 17:15:03 +0200
Message-ID: <CACT4Y+Y5J_i1CpV3d5MFH0jZCqKyOTzaP8uDQ0CH3HD33m+UZA@mail.gmail.com>
Subject: Re: BUG: bad usercopy in __check_object_size (2)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@google.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, syzbot <syzbot+a3c9d2673837ccc0f22b@syzkaller.appspotmail.com>, Chris von Recklinghausen <crecklin@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Thomas Gleixner <tglx@linutronix.de>, X86 ML <x86@kernel.org>

On Fri, Sep 7, 2018 at 9:57 PM, Kees Cook <keescook@google.com> wrote:
> On Fri, Sep 7, 2018 at 9:17 AM, Tetsuo Handa
> <penguin-kernel@i-love.sakura.ne.jp> wrote:
>> On 2018/09/08 0:29, syzbot wrote:
>>> syzbot has found a reproducer for the following crash on:
>>>
>>> HEAD commit:    28619527b8a7 Merge git://git.kernel.org/pub/scm/linux/kern..
>>> git tree:       bpf
>>> console output: https://syzkaller.appspot.com/x/log.txt?x=124e64d1400000
>>> kernel config:  https://syzkaller.appspot.com/x/.config?x=62e9b447c16085cf
>>> dashboard link: https://syzkaller.appspot.com/bug?extid=a3c9d2673837ccc0f22b
>>> compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
>>> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=179f9cd1400000
>>> C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=11b3e8be400000
>>>
>>> IMPORTANT: if you fix the bug, please add the following tag to the commit:
>>> Reported-by: syzbot+a3c9d2673837ccc0f22b@syzkaller.appspotmail.com
>>>
>>>  entry_SYSCALL_64_after_hwframe+0x49/0xbe
>>> RIP: 0033:0x440479
>>> usercopy: Kernel memory overwrite attempt detected to spans multiple pages (offset 0, size 64)!
>>
>> Kees, is this because check_page_span() is failing to allow on-stack variable
>>
>>    u8 opcodes[OPCODE_BUFSIZE];
>>
>> which by chance crossed PAGE_SIZE boundary?
>
> There are a lot of failure conditions for the PAGESPAN check. This
> might be one (and one that I'm hoping to solve separately).

Disabled CONFIG_HARDENED_USERCOPY_PAGESPAN on syzbot:
https://github.com/google/syzkaller/commit/be20da425029ecd45b18e99fa5f09691ba0658ea

#syz invalid
