Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id EB95A6B028F
	for <linux-mm@kvack.org>; Mon,  8 Jan 2018 04:17:26 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id t88so7252203pfg.17
        for <linux-mm@kvack.org>; Mon, 08 Jan 2018 01:17:26 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p33sor3802120pld.111.2018.01.08.01.17.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Jan 2018 01:17:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201801020027.GIG26598.OFSMVLQtFHJOOF@I-love.SAKURA.ne.jp>
References: <001a11444d0e7bfd7f05609956c6@google.com> <82d89066-7dd2-12fe-3cc0-c8d624fe0d51@I-love.SAKURA.ne.jp>
 <CACT4Y+baPvzHB7w8gv=Cger80qoiyOKWO-KPgBAd7mcMD9QNLA@mail.gmail.com> <201801020027.GIG26598.OFSMVLQtFHJOOF@I-love.SAKURA.ne.jp>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 8 Jan 2018 10:17:04 +0100
Message-ID: <CACT4Y+bJ6jNper2Xbj_fSHAuvgYZzJO3Q396mcjYBDbDSVo+4A@mail.gmail.com>
Subject: Re: INFO: task hung in filemap_fault
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: syzbot <bot+980f5e5fc060c37505bd65abb49a963518b269d9@syzkaller.appspotmail.com>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, jlayton@redhat.com, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, Ingo Molnar <mingo@kernel.org>, npiggin@gmail.com, rgoldwyn@suse.com, syzkaller-bugs@googlegroups.com, Jens Axboe <axboe@kernel.dk>, Ming Lei <tom.leiming@gmail.com>, Hannes Reinecke <hare@suse.de>, Omar Sandoval <osandov@fb.com>, shli@fb.com

On Mon, Jan 1, 2018 at 4:27 PM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
> I suggest syzbot to try linux.git before reporting bugs in linux-next.git.
> You know there are many duplicates caused by an invalid free in pcrypt.
> Soft lockups in ioctl(LOOP_SET_FD) are
>
>         /* Avoid recursion */
>         f = file;
>         while (is_loop_device(f)) {
>                 struct loop_device *l;
>
>                 if (f->f_mapping->host->i_bdev == bdev)
>                         goto out_putf;
>
>                 l = f->f_mapping->host->i_bdev->bd_disk->private_data;
>                 if (l->lo_state == Lo_unbound) {
>                         error = -EINVAL;
>                         goto out_putf;
>                 }
>                 f = l->lo_backing_file;
>         }
>
> loop which means that something (maybe memory corruption) is forming circular
> chain, and there seems to be some encryption related parameters/values in
> raw.log file. It is nice to retest a kernel without encryption related things
> and/or a kernel without known encryption related bugs.


Hi Tetsuo,

Let's forget about the single crypto bug. We can't build the system
that handles hundreds of bugs around that single bug which is fixed at
this point. What is the general improvement you are proposing?

Note that some bugs are only in linux.git, some are only in
linux-next.git, some are only in net, kvm, etc, or maybe in some
combination of these. And we generally don't know where a bug is
present and where it is not. We can try to do some assumption _if_ the
bug has a reproducer, but even then most kernel bugs are due to races
and can't be reproduced with 100% probability, or it can't be just
that the same bug can be reproduced on a different tree but requires a
slightly different reproducer. So any such assumptions won't be 100%
reliable, and any flaw in information syzbot provides usually provokes
lots of very negative reaction from kernel developers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
