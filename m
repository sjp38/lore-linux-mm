Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id E943F6B0284
	for <linux-mm@kvack.org>; Mon,  1 Jan 2018 10:28:04 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id s3so6925619otd.16
        for <linux-mm@kvack.org>; Mon, 01 Jan 2018 07:28:04 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id c2si12682244oif.164.2018.01.01.07.28.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 01 Jan 2018 07:28:03 -0800 (PST)
Subject: Re: INFO: task hung in filemap_fault
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <001a11444d0e7bfd7f05609956c6@google.com>
	<82d89066-7dd2-12fe-3cc0-c8d624fe0d51@I-love.SAKURA.ne.jp>
	<CACT4Y+baPvzHB7w8gv=Cger80qoiyOKWO-KPgBAd7mcMD9QNLA@mail.gmail.com>
In-Reply-To: <CACT4Y+baPvzHB7w8gv=Cger80qoiyOKWO-KPgBAd7mcMD9QNLA@mail.gmail.com>
Message-Id: <201801020027.GIG26598.OFSMVLQtFHJOOF@I-love.SAKURA.ne.jp>
Date: Tue, 2 Jan 2018 00:27:43 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dvyukov@google.com
Cc: bot+980f5e5fc060c37505bd65abb49a963518b269d9@syzkaller.appspotmail.com, ak@linux.intel.com, akpm@linux-foundation.org, jack@suse.cz, jlayton@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mgorman@techsingularity.net, mingo@kernel.org, npiggin@gmail.com, rgoldwyn@suse.com, syzkaller-bugs@googlegroups.com, axboe@kernel.dk, tom.leiming@gmail.com, hare@suse.de, osandov@fb.com, shli@fb.com

Dmitry Vyukov wrote:
> On Mon, Dec 18, 2017 at 3:52 PM, Tetsuo Handa
> <penguin-kernel@i-love.sakura.ne.jp> wrote:
> > On 2017/12/18 17:43, syzbot wrote:
> >> Hello,
> >>
> >> syzkaller hit the following crash on 6084b576dca2e898f5c101baef151f7bfdbb606d
> >> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/master
> >> compiler: gcc (GCC) 7.1.1 20170620
> >> .config is attached
> >> Raw console output is attached.
> >>
> >> Unfortunately, I don't have any reproducer for this bug yet.
> >>
> >
> > This log has a lot of mmap() but also has Android's binder messages.
> >
> > r9 = syz_open_dev$binder(&(0x7f0000000000)='/dev/binder#\x00', 0x0, 0x800)
> >
> > [   49.200735] binder: 9749:9755 IncRefs 0 refcount change on invalid ref 2 ret -22
> > [   49.221514] binder: 9749:9755 Acquire 1 refcount change on invalid ref 4 ret -22
> > [   49.233325] binder: 9749:9755 Acquire 1 refcount change on invalid ref 0 ret -22
> > [   49.241979] binder: binder_mmap: 9749 205a3000-205a7000 bad vm_flags failed -1
> > [   49.256949] binder: 9749:9755 unknown command 0
> > [   49.262470] binder: 9749:9755 ioctl c0306201 20000fd0 returned -22
> > [   49.293365] binder: 9749:9755 IncRefs 0 refcount change on invalid ref 2 ret -22
> > [   49.301297] binder: binder_mmap: 9749 205a3000-205a7000 bad vm_flags failed -1
> > [   49.314146] binder: 9749:9755 Acquire 1 refcount change on invalid ref 4 ret -22
> > [   49.322732] binder: 9749:9755 Acquire 1 refcount change on invalid ref 0 ret -22
> > [   49.332063] binder: 9749:9755 Release 1 refcount change on invalid ref 1 ret -22
> > [   49.340796] binder: 9749:9755 Acquire 1 refcount change on invalid ref 2 ret -22
> > [   49.349457] binder: 9749:9755 BC_DEAD_BINDER_DONE 0000000000000001 not found
> > [   49.349462] binder: 9749:9755 BC_DEAD_BINDER_DONE 0000000000000000 not found
> >
> > [  246.752088] INFO: task syz-executor7:10280 blocked for more than 120 seconds.
> >
> > Anything that hung in 126.75 >= uptime > 6.75 can be reported at uptime = 246.75, can't it?
> > khungtaskd warning with 120 seconds check interval can be delayed for up to 240 seconds.
> >
> > Is it possible to reproduce this problem by running the same program?
> 
> 
> Hi Tetsuo,
> 
> syzbot always re-runs the same workload on a new machine. If it
> manages to reproduce the problem, it provides a reproducer. In this
> case it didn't.

Even if it did not manage to reproduce the problem, showing raw.log in
C format is helpful for me. For example,

  ioctl$LOOP_CHANGE_FD(r3, 0x4c00, r1)

is confusing. 0x4c00 is not LOOP_CHANGE_FD but LOOP_SET_FD.
If the message were

  ioctl(r3, 0x4c00, r1)

more people will be able to read what the program tried to do.
There are many operations done on loop devices, but are too hard
for me to pick up only loop related actions.

> 
> The program that triggered this is this one (number 7 matches task
> syz-executor7):
> 
> 2017/12/18 06:16:18 executing program 7:
> 
> It has only 2 mmaps. The first one is pretty standard, but the second
> one mmaps loop device:
> 
> r7 = syz_open_dev$loop(&(0x7f0000e58000-0xb)='/dev/loop#\x00', 0x0, 0x4102)
> mmap(&(0x7f0000e5b000/0x1000)=nil, 0x1000, 0x3, 0x2011, r7, 0x0)
> 
> We have a bunch of hangs around /dev/loop:
> 
> https://groups.google.com/forum/#!msg/syzkaller-bugs/qzz2v1M93O4/DjHEEvq5AQAJ
> https://groups.google.com/forum/#!msg/syzkaller-bugs/jy-bXYbRh7c/a1dQYyD9CgAJ
> https://groups.google.com/forum/#!msg/syzkaller-bugs/vjGYuMMspAU/K3oOF_eHCgAJ
> https://groups.google.com/forum/#!msg/syzkaller-bugs/BwpEc6q6gFY/5kHDMGElAgAJ
> 
> Probably related to these ones.
> +loop maintainers.
> 

I suggest syzbot to try linux.git before reporting bugs in linux-next.git.
You know there are many duplicates caused by an invalid free in pcrypt.
Soft lockups in ioctl(LOOP_SET_FD) are

	/* Avoid recursion */
	f = file;
	while (is_loop_device(f)) {
		struct loop_device *l;

		if (f->f_mapping->host->i_bdev == bdev)
			goto out_putf;

		l = f->f_mapping->host->i_bdev->bd_disk->private_data;
		if (l->lo_state == Lo_unbound) {
			error = -EINVAL;
			goto out_putf;
		}
		f = l->lo_backing_file;
	}

loop which means that something (maybe memory corruption) is forming circular
chain, and there seems to be some encryption related parameters/values in
raw.log file. It is nice to retest a kernel without encryption related things
and/or a kernel without known encryption related bugs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
