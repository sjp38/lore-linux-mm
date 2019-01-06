Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id B66B98E0001
	for <linux-mm@kvack.org>; Sun,  6 Jan 2019 09:37:59 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id j85so24802179oih.3
        for <linux-mm@kvack.org>; Sun, 06 Jan 2019 06:37:59 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id a19si29188671otq.65.2019.01.06.06.37.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 06 Jan 2019 06:37:58 -0800 (PST)
Subject: Re: KASAN: stack-out-of-bounds Read in check_stack_object
References: <000000000000ae2357057eca1fa5@google.com>
 <CACT4Y+Y+dph0wyKOLffXMPFPsvbviYzfn1nrJJgOL1ngkQLtVw@mail.gmail.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <40577a65-3947-aec9-3b82-ac71f150e586@I-love.SAKURA.ne.jp>
Date: Sun, 6 Jan 2019 23:37:45 +0900
MIME-Version: 1.0
In-Reply-To: <CACT4Y+Y+dph0wyKOLffXMPFPsvbviYzfn1nrJJgOL1ngkQLtVw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, syzbot <syzbot+05fc3a636f5ee8830a99@syzkaller.appspotmail.com>
Cc: Chris von Recklinghausen <crecklin@redhat.com>, Kees Cook <keescook@chromium.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>

On 2019/01/06 22:48, Dmitry Vyukov wrote:
> On Sun, Jan 6, 2019 at 2:31 PM syzbot
> <syzbot+05fc3a636f5ee8830a99@syzkaller.appspotmail.com> wrote:
>>
>> Hello,
>>
>> syzbot found the following crash on:
>>
>> HEAD commit:    3fed6ae4b027 ia64: fix compile without swiotlb
>> git tree:       upstream
>> console output: https://syzkaller.appspot.com/x/log.txt?x=161ce1d7400000
>> kernel config:  https://syzkaller.appspot.com/x/.config?x=7308e68273924137
>> dashboard link: https://syzkaller.appspot.com/bug?extid=05fc3a636f5ee8830a99
>> compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
>> userspace arch: i386
>> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=10b3769f400000
>>
>> IMPORTANT: if you fix the bug, please add the following tag to the commit:
>> Reported-by: syzbot+05fc3a636f5ee8830a99@syzkaller.appspotmail.com
> 
> I suspect this is another incarnation of:
> https://syzkaller.appspot.com/bug?id=4821de869e3d78a255a034bf212a4e009f6125a7
> Any other ideas?



>> CPU: 0 PID: -1455013312 Comm:  Not tainted 4.20.0+ #10

"current->pid < 0" suggests that "struct task_struct" was overwritten.

>> #PF error: [normal kernel read fault]

>> Thread overran stack, or stack corrupted

And "struct task_struct" might be overwritten by stack overrun?

The cause of overrun is unknown, but given that
"fou6: Prevent unbounded recursion in GUE error handler" is not yet
applied to linux.git tree, this might be a dup of that bug.
