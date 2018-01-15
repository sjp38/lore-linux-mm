Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id CB23A6B0038
	for <linux-mm@kvack.org>; Mon, 15 Jan 2018 05:45:08 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id p202so3562949iod.18
        for <linux-mm@kvack.org>; Mon, 15 Jan 2018 02:45:08 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id a69si7114460itc.154.2018.01.15.02.45.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 15 Jan 2018 02:45:06 -0800 (PST)
Subject: Re: INFO: task hung in filemap_fault
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <CACT4Y+baPvzHB7w8gv=Cger80qoiyOKWO-KPgBAd7mcMD9QNLA@mail.gmail.com>
	<201801020027.GIG26598.OFSMVLQtFHJOOF@I-love.SAKURA.ne.jp>
	<CACT4Y+ZPHerom6rNYj8HL8vSySi7n4ArySnpFbxQX31n-QumNg@mail.gmail.com>
	<201801081948.HAE82801.FQOSHtMOFVLFOJ@I-love.SAKURA.ne.jp>
	<CACT4Y+bkuk3dkwdn7QCbWWWJ=R_nW8Qi6+y35VofLEHYu+6m7w@mail.gmail.com>
In-Reply-To: <CACT4Y+bkuk3dkwdn7QCbWWWJ=R_nW8Qi6+y35VofLEHYu+6m7w@mail.gmail.com>
Message-Id: <201801151944.FII09821.FMVQFJtHOOOSLF@I-love.SAKURA.ne.jp>
Date: Mon, 15 Jan 2018 19:44:42 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dvyukov@google.com
Cc: bot+980f5e5fc060c37505bd65abb49a963518b269d9@syzkaller.appspotmail.com, ak@linux.intel.com, akpm@linux-foundation.org, jack@suse.cz, jlayton@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mgorman@techsingularity.net, mingo@kernel.org, npiggin@gmail.com, rgoldwyn@suse.com, syzkaller-bugs@googlegroups.com, axboe@kernel.dk, tom.leiming@gmail.com, hare@suse.de, osandov@fb.com, shli@fb.com

Dmitry Vyukov wrote:
> On Mon, Jan 8, 2018 at 11:48 AM, Tetsuo Handa
> <penguin-kernel@i-love.sakura.ne.jp> wrote:
> > Dmitry Vyukov wrote:
> >> >> Hi Tetsuo,
> >> >>
> >> >> syzbot always re-runs the same workload on a new machine. If it
> >> >> manages to reproduce the problem, it provides a reproducer. In this
> >> >> case it didn't.
> >> >
> >> > Even if it did not manage to reproduce the problem, showing raw.log in
> >> > C format is helpful for me. For example,
> >> >
> >> >   ioctl$LOOP_CHANGE_FD(r3, 0x4c00, r1)
> >> >
> >> > is confusing. 0x4c00 is not LOOP_CHANGE_FD but LOOP_SET_FD.
> >> > If the message were
> >> >
> >> >   ioctl(r3, 0x4c00, r1)
> >> >
> >> > more people will be able to read what the program tried to do.
> >> > There are many operations done on loop devices, but are too hard
> >> > for me to pick up only loop related actions.
> >>
> >>
> >> Hi Tetsuo,
> >>
> >> The main purpose of this format is different, this is a complete
> >> representation of programs that allows replaying them using syzkaller
> >> tools.
> >
> > What is ioctl$LOOP_CHANGE_FD(r3, 0x4c00, r1) ?
> > 0x4c00 is LOOP_SET_FD. Why LOOP_CHANGE_FD is there?
> 
> 
> In short, it specifies exact discrimination of the syscall which
> affects parsing of the rest of the arguments. For some syscalls
> (ioctl/setsockopt/sendmsg) kernel has hundreds of different
> discriminations with radically different arguments.
> Now if you are asking why the discrimination is LOOP_CHANGE_FD, but
> the actual command is LOOP_SET_FD, that's because this is a fuzzer,
> it's sole purpose is to mess things in unexpected ways.

??? I can't catch what you want to say.

I understand that a fuzzer intentionally tests various cases.
My question is simple. Why don't you use actual command name like
ioctl$LOOP_SET_FD(r3, 0x4c00, r1) ?
Writing like ioctl$LOOP_CHANGE_FD is confusing. I consider it as a bug.

> 
> 
> >>        We can't simply drop info from there. Do you propose to add
> >> another attached file that contains the same info in a different
> >> format? What is the exact format you are proposing?
> >
> > Plain C program which can be compiled without installing additional
> > program/library packages (except those needed for building kernels).
> >
> >>                                                     Is it just
> >> dropping the syscall name part after $ sign? Note that it's still not
> >> C, more complex syscall generally look as follows:
> >>
> >> perf_event_open(&(0x7f0000b5a000)={0x4000000002, 0x78, 0x1e2, 0x0,
> >> 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0xffff, 0x0,
> >> 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
> >> 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
> >> @perf_bp={&(0x7f0000000000)=0x0, 0x0}, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
> >> 0x0, 0x0}, 0x0, 0x0, 0xffffffffffffffff, 0x0)
> >> recvmmsg(0xffffffffffffffff, &(0x7f0000003000)=[{{0x0, 0x0,
> >> &(0x7f0000002000)=[{&(0x7f000000a000)=""/193, 0xc1},
> >> {&(0x7f0000007000-0x3d)=""/61, 0x3d}], 0x2,
> >> &(0x7f0000005000-0x67)=""/103, 0x67, 0x0}, 0x0}], 0x1, 0x0,
> >> &(0x7f0000003000-0x10)={0x77359400, 0x0})
> >> bpf$PROG_LOAD(0x5, &(0x7f0000000000)={0x1, 0x5,
> >> &(0x7f0000002000)=@framed={{0x18, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
> >> 0x0}, [@jmp={0x5, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0}], {0x95, 0x0, 0x0,
> >> 0x0}}, &(0x7f0000004000-0xa)='syzkaller\x00', 0x3, 0xc3,
> >> &(0x7f0000386000)=""/195, 0x0, 0x0, [0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
> >> 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0], 0x0}, 0x48)
> >>
> >> Note: you can convert any syzkaller program to equivalent C code using
> >> syz-prog2c utility that comes with syzkaller.
> >
> > I won't install go language into my environment for analyzing/reproducing your
> > reports. If syz-prog2c is provided as a CGI service (e.g. receive URL containing
> > raw.log and print the converted C program), I might try it.
> 
> 
> raw.log is not a _program_, it's hundreds of separate programs that
> were executed before the crash. It's also very compressed
> representation as compared to equivalent C programs. For example for
> this program:
> 
> mmap(&(0x7f0000000000/0xfff000)=nil, 0xfff000, 0x3, 0x32,
> 0xffffffffffffffff, 0x0)
> r0 = socket$nl_generic(0x10, 0x3, 0x10)
> sendmsg$nl_generic(r0,
> &(0x7f0000b3e000-0x38)={&(0x7f0000d4a000-0xc)={0x10, 0x0, 0x0, 0x0},
> 0xc, &(0x7f0000007000)={&(0x7f0000f7c000-0x15c)={0x24, 0x1c, 0x109,
> 0xffffffffffffffff, 0xffffffffffffffff, {0x4, 0x0, 0x0},
> [@nested={0x10, 0x9, [@typed={0xc, 0x0, @u32=0x0}]}]}, 0x24}, 0x1,
> 0x0, 0x0, 0x0}, 0x0)
> 
> you can get up to this amount of C code:
> https://gist.githubusercontent.com/dvyukov/eeaeb4e4ac45c3a251f72098c9295bf9/raw/700cd583507eca90711ba11b42e406f317553371/gistfile1.txt
> 
> that is, 700 lines of C source for 3 line program. So instead of a 1MB
> file that will be 100MB, and then it probably should be a gzip archive
> with hundreds of separate C files. There are people on this list
> complaining even about 200K of attachments. I don't see that this will
> be better and well accepted.
> 

No problem. In the "tty: User triggerable soft lockup." case, I manually
trimmed the reproducer at https://marc.info/?l=linux-mm&m=151368630414963 .
That is,

 (1) Can the problem be reproduced even if setup_tun(0, true); is commented out?

 (2) Can the problem be reproduced even if NONFAILING(A = B); is replaced with
     plain A = B; assignment?

 (3) Can the problem be reproduced even if install_segv_handler(); is commented
     out?

 (4) Can the problem be reproduced even if some syscalls (e.g. __NR_memfd_create,
     __NR_getsockopt, __NR_perf_event_open) are replaced with no-op?

and so on. Then, I finally reached a reproducer which I sent, and the bug was fixed.

What is important is that everyone can try simplifying the reproducer written
in plain C in order to narrow down the culprit. Providing a (e.g.) CGI service
which generates plain C reproducer like gistfile1.txt will be helpful to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
