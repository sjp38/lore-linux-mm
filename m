Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id AA9906B0299
	for <linux-mm@kvack.org>; Mon,  8 Jan 2018 05:48:41 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id g59so6120382otg.3
        for <linux-mm@kvack.org>; Mon, 08 Jan 2018 02:48:41 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 99si3301028otn.113.2018.01.08.02.48.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 08 Jan 2018 02:48:40 -0800 (PST)
Subject: Re: INFO: task hung in filemap_fault
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <001a11444d0e7bfd7f05609956c6@google.com>
	<82d89066-7dd2-12fe-3cc0-c8d624fe0d51@I-love.SAKURA.ne.jp>
	<CACT4Y+baPvzHB7w8gv=Cger80qoiyOKWO-KPgBAd7mcMD9QNLA@mail.gmail.com>
	<201801020027.GIG26598.OFSMVLQtFHJOOF@I-love.SAKURA.ne.jp>
	<CACT4Y+ZPHerom6rNYj8HL8vSySi7n4ArySnpFbxQX31n-QumNg@mail.gmail.com>
In-Reply-To: <CACT4Y+ZPHerom6rNYj8HL8vSySi7n4ArySnpFbxQX31n-QumNg@mail.gmail.com>
Message-Id: <201801081948.HAE82801.FQOSHtMOFVLFOJ@I-love.SAKURA.ne.jp>
Date: Mon, 8 Jan 2018 19:48:16 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dvyukov@google.com
Cc: bot+980f5e5fc060c37505bd65abb49a963518b269d9@syzkaller.appspotmail.com, ak@linux.intel.com, akpm@linux-foundation.org, jack@suse.cz, jlayton@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mgorman@techsingularity.net, mingo@kernel.org, npiggin@gmail.com, rgoldwyn@suse.com, syzkaller-bugs@googlegroups.com, axboe@kernel.dk, tom.leiming@gmail.com, hare@suse.de, osandov@fb.com, shli@fb.com

Dmitry Vyukov wrote:
> >> Hi Tetsuo,
> >>
> >> syzbot always re-runs the same workload on a new machine. If it
> >> manages to reproduce the problem, it provides a reproducer. In this
> >> case it didn't.
> >
> > Even if it did not manage to reproduce the problem, showing raw.log in
> > C format is helpful for me. For example,
> >
> >   ioctl$LOOP_CHANGE_FD(r3, 0x4c00, r1)
> >
> > is confusing. 0x4c00 is not LOOP_CHANGE_FD but LOOP_SET_FD.
> > If the message were
> >
> >   ioctl(r3, 0x4c00, r1)
> >
> > more people will be able to read what the program tried to do.
> > There are many operations done on loop devices, but are too hard
> > for me to pick up only loop related actions.
> 
> 
> Hi Tetsuo,
> 
> The main purpose of this format is different, this is a complete
> representation of programs that allows replaying them using syzkaller
> tools.

What is ioctl$LOOP_CHANGE_FD(r3, 0x4c00, r1) ?
0x4c00 is LOOP_SET_FD. Why LOOP_CHANGE_FD is there?

>        We can't simply drop info from there. Do you propose to add
> another attached file that contains the same info in a different
> format? What is the exact format you are proposing?

Plain C program which can be compiled without installing additional
program/library packages (except those needed for building kernels).

>                                                     Is it just
> dropping the syscall name part after $ sign? Note that it's still not
> C, more complex syscall generally look as follows:
> 
> perf_event_open(&(0x7f0000b5a000)={0x4000000002, 0x78, 0x1e2, 0x0,
> 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0xffff, 0x0,
> 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
> 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
> @perf_bp={&(0x7f0000000000)=0x0, 0x0}, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
> 0x0, 0x0}, 0x0, 0x0, 0xffffffffffffffff, 0x0)
> recvmmsg(0xffffffffffffffff, &(0x7f0000003000)=[{{0x0, 0x0,
> &(0x7f0000002000)=[{&(0x7f000000a000)=""/193, 0xc1},
> {&(0x7f0000007000-0x3d)=""/61, 0x3d}], 0x2,
> &(0x7f0000005000-0x67)=""/103, 0x67, 0x0}, 0x0}], 0x1, 0x0,
> &(0x7f0000003000-0x10)={0x77359400, 0x0})
> bpf$PROG_LOAD(0x5, &(0x7f0000000000)={0x1, 0x5,
> &(0x7f0000002000)=@framed={{0x18, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
> 0x0}, [@jmp={0x5, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0}], {0x95, 0x0, 0x0,
> 0x0}}, &(0x7f0000004000-0xa)='syzkaller\x00', 0x3, 0xc3,
> &(0x7f0000386000)=""/195, 0x0, 0x0, [0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
> 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0], 0x0}, 0x48)
> 
> Note: you can convert any syzkaller program to equivalent C code using
> syz-prog2c utility that comes with syzkaller.

I won't install go language into my environment for analyzing/reproducing your
reports. If syz-prog2c is provided as a CGI service (e.g. receive URL containing
raw.log and print the converted C program), I might try it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
