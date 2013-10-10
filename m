Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 2B1EC6B0031
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 22:46:21 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so1919985pdj.22
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 19:46:20 -0700 (PDT)
Date: Thu, 10 Oct 2013 10:46:13 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [uml-devel] BUG: soft lockup for a user mode linux image
Message-ID: <20131010024613.GA10719@localhost>
References: <524E57BA.805@nod.at>
 <52517109.90605@gmx.de>
 <CAMuHMdXrU0e_6AxvdboMkDs+N+tSWD+b8ou92j28c0vsq2eQQA@mail.gmail.com>
 <5251C334.3010604@gmx.de>
 <CAMuHMdUo8dSd4s3089ZDEc485wL1sFxBKLeaExJuqNiQY+S-Lw@mail.gmail.com>
 <5251CF94.5040101@gmx.de>
 <CAMuHMdWs6Y7y12STJ+YXKJjxRF0k5yU9C9+0fiPPmq-GgeW-6Q@mail.gmail.com>
 <525591AD.4060401@gmx.de>
 <5255A3E6.6020100@nod.at>
 <20131009214733.GB25608@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20131009214733.GB25608@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Richard Weinberger <richard@nod.at>, Toralf =?utf-8?Q?F=C3=B6rster?= <toralf.foerster@gmx.de>, Geert Uytterhoeven <geert@linux-m68k.org>, UML devel <user-mode-linux-devel@lists.sourceforge.net>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, hannes@cmpxchg.org, darrick.wong@oracle.com, Michal Hocko <mhocko@suse.cz>, Gu Zheng <guz.fnst@cn.fujitsu.com>, Benjamin LaHaise <bcrl@kvack.org>

On Wed, Oct 09, 2013 at 11:47:33PM +0200, Jan Kara wrote:
> On Wed 09-10-13 20:43:50, Richard Weinberger wrote:
> > CC'ing mm folks.
> > Please see below.
>   Added Fenguang to CC since he is the author of this code.

Thanks!

> > Am 09.10.2013 19:26, schrieb Toralf FA?rster:
> > > On 10/08/2013 10:07 PM, Geert Uytterhoeven wrote:
> > >> On Sun, Oct 6, 2013 at 11:01 PM, Toralf FA?rster <toralf.foerster@gmx.de> wrote:
> > >>>> Hmm, now pages_dirtied is zero, according to the backtrace, but the BUG_ON()
> > >>>> asserts its strict positive?!?
> > >>>>
> > >>>> Can you please try the following instead of the BUG_ON():
> > >>>>
> > >>>> if (pause < 0) {
> > >>>>         printk("pages_dirtied = %lu\n", pages_dirtied);
> > >>>>         printk("task_ratelimit = %lu\n", task_ratelimit);
> > >>>>         printk("pause = %ld\n", pause);
> > >>>> }
> > >>>>
> > >>>> Gr{oetje,eeting}s,
> > >>>>
> > >>>>                         Geert
> > >>> I tried it in different ways already - I'm completely unsuccessful in getting any printk output.
> > >>> As soon as the issue happens I do have a
> > >>>
> > >>> BUG: soft lockup - CPU#0 stuck for 22s! [trinity-child0:1521]
> > >>>
> > >>> at stderr of the UML and then no further input is accepted. With uml_mconsole I'm however able
> > >>> to run very basic commands like a crash dump, sysrq ond so on.
> > >>
> > >> You may get an idea of the magnitude of pages_dirtied by using a chain of
> > >> BUG_ON()s, like:
> > >>
> > >> BUG_ON(pages_dirtied > 2000000000);
> > >> BUG_ON(pages_dirtied > 1000000000);
> > >> BUG_ON(pages_dirtied > 100000000);
> > >> BUG_ON(pages_dirtied > 10000000);
> > >> BUG_ON(pages_dirtied > 1000000);
> > >>
> > >> Probably 1 million is already too much for normal operation?
> > >>
> > > period = HZ * pages_dirtied / task_ratelimit;
> > > 		BUG_ON(pages_dirtied > 2000000000);
> > > 		BUG_ON(pages_dirtied > 1000000000);      <-------------- this is line 1467
> > 
> > Summary for mm people:
> > 
> > Toralf runs trinty on UML/i386.
> > After some time pages_dirtied becomes very large.
> > More than 1000000000 pages in this case.
>   Huh, this is really strange. pages_dirtied is passed into
> balance_dirty_pages() from current->nr_dirtied. So I wonder how a value
> over 10^9 can get there.

I noticed aio_setup_ring() in the call trace and find it recently
added a SetPageDirty() call in a loop by commit 36bc08cc01 ("fs/aio:
Add support to aio ring pages migration"). So added CC to its authors.

> After all that is over 4TB so I somewhat doubt the
> task was ever able to dirty that much during its lifetime (but correct me
> if I'm wrong here, with UML and memory backed disks it is not totally
> impossible)... I went through the logic of handling ->nr_dirtied but
> I didn't find any obvious problem there. Hum, maybe one thing - what
> 'task_ratelimit' values do you see in balance_dirty_pages? If that one was
> huge, we could possibly accumulate huge current->nr_dirtied.
> 
> > Thus, period = HZ * pages_dirtied / task_ratelimit overflows
> > and period/pause becomes extremely large.

Yes, that's possible.

> > It looks like io_schedule_timeout() get's called with a very large timeout.
> > I don't know why "if (unlikely(pause > max_pause)) {" does not help.

The test will sure work and limit pause to <= max_pause. However it's
very possible balance_dirty_pages() cannot break out of the loop (or
being called repeatedly) and block the task.

I'm afraid there are no one to clear the dirty pages, which makes
balance_dirty_pages() waiting for ever.

Thanks,
Fengguang

> > 
> > > the back trace is :
> > > 
> > > tfoerste@n22 ~/devel/linux $ gdb --core=/mnt/ramdisk/core /home/tfoerste/devel/linux/linux -batch -ex bt
> > > [New LWP 6911]
> > > Core was generated by `/home/tfoerste/devel/linux/linux earlyprintk ubda=/home/tfoerste/virtual/uml/tr'.
> > > Program terminated with signal 6, Aborted.
> > > #0  0xb77a7424 in __kernel_vsyscall ()
> > > #0  0xb77a7424 in __kernel_vsyscall ()
> > > #1  0x083bdf35 in kill ()
> > > #2  0x0807296d in uml_abort () at arch/um/os-Linux/util.c:93
> > > #3  0x08072ca5 in os_dump_core () at arch/um/os-Linux/util.c:148
> > > #4  0x080623c4 in panic_exit (self=0x85c1558 <panic_exit_notifier>, unused1=0, unused2=0x85f76e0 <buf.16221>) at arch/um/kernel/um_arch.c:240
> > > #5  0x0809ba86 in notifier_call_chain (nl=0x0, val=0, v=0x85f76e0 <buf.16221>, nr_to_call=-2, nr_calls=0x0) at kernel/notifier.c:93
> > > #6  0x0809bba1 in __atomic_notifier_call_chain (nh=0x85f76c4 <panic_notifier_list>, val=0, v=0x85f76e0 <buf.16221>, nr_to_call=0, nr_calls=0x0) at kernel/notifier.c:182
> > > #7  0x0809bbdf in atomic_notifier_call_chain (nh=0x0, val=0, v=0x0) at kernel/notifier.c:191
> > > #8  0x0841b5bc in panic (fmt=0x0) at kernel/panic.c:130
> > > #9  0x0841c470 in balance_dirty_pages (pages_dirtied=23, mapping=<optimized out>) at mm/page-writeback.c:1467
> > > #10 0x080d3595 in balance_dirty_pages_ratelimited (mapping=0x6) at mm/page-writeback.c:1661
> > > #11 0x080e4a3f in __do_fault (mm=0x45ba3600, vma=0x48777b90, address=1084678144, pmd=0x0, pgoff=0, flags=0, orig_pte=<incomplete type>) at mm/memory.c:3452
> > > #12 0x080e6e0f in do_linear_fault (orig_pte=..., flags=<optimized out>, pmd=<optimized out>, address=<optimized out>, vma=<optimized out>, mm=<optimized out>, page_table=<optimized out>) at mm/memory.c:3486
> > > #13 handle_pte_fault (flags=<optimized out>, pmd=<optimized out>, pte=<optimized out>, address=<optimized out>, vma=<optimized out>, mm=<optimized out>) at mm/memory.c:3710
> > > #14 __handle_mm_fault (flags=<optimized out>, address=<optimized out>, vma=<optimized out>, mm=<optimized out>) at mm/memory.c:3845
> > > #15 handle_mm_fault (mm=0x45ba3600, vma=0x487034c8, address=1084678144, flags=1) at mm/memory.c:3868
> > > #16 0x080e7817 in __get_user_pages (tsk=0x48705800, mm=0x45ba3600, start=1084678144, nr_pages=1025, gup_flags=519, pages=0x48558000, vmas=0x0, nonblocking=0x0) at mm/memory.c:1822
> > > #17 0x080e7ae3 in get_user_pages (tsk=0x0, mm=0x0, start=0, nr_pages=0, write=1, force=0, pages=0x48777b90, vmas=0x6) at mm/memory.c:2019
> > > #18 0x08143dc6 in aio_setup_ring (ctx=<optimized out>) at fs/aio.c:340
> > > #19 ioctx_alloc (nr_events=<optimized out>) at fs/aio.c:605
> > > #20 SYSC_io_setup (ctxp=<optimized out>, nr_events=<optimized out>) at fs/aio.c:1122
> > > #21 SyS_io_setup (nr_events=65535, ctxp=135081984) at fs/aio.c:1105
> > > #22 0x08062984 in handle_syscall (r=0x487059d4) at arch/um/kernel/skas/syscall.c:35
> > > #23 0x08074fb5 in handle_trap (local_using_sysemu=<optimized out>, regs=<optimized out>, pid=<optimized out>) at arch/um/os-Linux/skas/process.c:198
> > > #24 userspace (regs=0x487059d4) at arch/um/os-Linux/skas/process.c:431
> > > #25 0x0805f750 in fork_handler () at arch/um/kernel/process.c:160
> > > #26 0x00000000 in ?? ()
> 
> 								Honza
> -- 
> Jan Kara <jack@suse.cz>
> SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
