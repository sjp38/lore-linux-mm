Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 766408E0001
	for <linux-mm@kvack.org>; Sun,  6 Jan 2019 10:44:25 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id r65so45726171iod.12
        for <linux-mm@kvack.org>; Sun, 06 Jan 2019 07:44:25 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j79sor23528646jad.11.2019.01.06.07.44.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 06 Jan 2019 07:44:24 -0800 (PST)
MIME-Version: 1.0
References: <000000000000ae2357057eca1fa5@google.com> <CACT4Y+Y+dph0wyKOLffXMPFPsvbviYzfn1nrJJgOL1ngkQLtVw@mail.gmail.com>
 <40577a65-3947-aec9-3b82-ac71f150e586@I-love.SAKURA.ne.jp>
In-Reply-To: <40577a65-3947-aec9-3b82-ac71f150e586@I-love.SAKURA.ne.jp>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Sun, 6 Jan 2019 16:44:13 +0100
Message-ID: <CACT4Y+YLi95s04V0gNS1Vg15M0ey2eAQ4j6ADW3E30XfxAekoA@mail.gmail.com>
Subject: Re: KASAN: stack-out-of-bounds Read in check_stack_object
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: syzbot <syzbot+05fc3a636f5ee8830a99@syzkaller.appspotmail.com>, Chris von Recklinghausen <crecklin@redhat.com>, Kees Cook <keescook@chromium.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>

On Sun, Jan 6, 2019 at 3:37 PM Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
>
> On 2019/01/06 22:48, Dmitry Vyukov wrote:
> > On Sun, Jan 6, 2019 at 2:31 PM syzbot
> > <syzbot+05fc3a636f5ee8830a99@syzkaller.appspotmail.com> wrote:
> >>
> >> Hello,
> >>
> >> syzbot found the following crash on:
> >>
> >> HEAD commit:    3fed6ae4b027 ia64: fix compile without swiotlb
> >> git tree:       upstream
> >> console output: https://syzkaller.appspot.com/x/log.txt?x=161ce1d7400000
> >> kernel config:  https://syzkaller.appspot.com/x/.config?x=7308e68273924137
> >> dashboard link: https://syzkaller.appspot.com/bug?extid=05fc3a636f5ee8830a99
> >> compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> >> userspace arch: i386
> >> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=10b3769f400000
> >>
> >> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> >> Reported-by: syzbot+05fc3a636f5ee8830a99@syzkaller.appspotmail.com
> >
> > I suspect this is another incarnation of:
> > https://syzkaller.appspot.com/bug?id=4821de869e3d78a255a034bf212a4e009f6125a7
> > Any other ideas?
>
>
>
> >> CPU: 0 PID: -1455013312 Comm:  Not tainted 4.20.0+ #10
>
> "current->pid < 0" suggests that "struct task_struct" was overwritten.
>
> >> #PF error: [normal kernel read fault]
>
> >> Thread overran stack, or stack corrupted
>
> And "struct task_struct" might be overwritten by stack overrun?
>
> The cause of overrun is unknown, but given that
> "fou6: Prevent unbounded recursion in GUE error handler" is not yet
> applied to linux.git tree, this might be a dup of that bug.


#syz dup: kernel panic: stack is corrupted in udp4_lib_lookup2
