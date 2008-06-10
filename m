From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: 2.6.26-rc5-mm2
Date: Tue, 10 Jun 2008 18:48:21 +1000
References: <20080609223145.5c9a2878.akpm@linux-foundation.org> <200806101728.27486.nickpiggin@yahoo.com.au> <20080610013427.aa20a29b.akpm@linux-foundation.org>
In-Reply-To: <20080610013427.aa20a29b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200806101848.22237.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tuesday 10 June 2008 18:34, Andrew Morton wrote:
> On Tue, 10 Jun 2008 17:28:27 +1000 Nick Piggin <nickpiggin@yahoo.com.au> 
wrote:
> > On Tuesday 10 June 2008 15:31, Andrew Morton wrote:
> > > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.26-rc
> > >5/2. 6.26-rc5-mm2/
> >
> > BTW. would be trying to test this more myself, but last mm I based the
> > lockless patches on didn't boot, and this one dies pretty quickly when
> > you try to get into reclaim:
> >
> > ------------[ cut here ]------------
> > kernel BUG at mm/swap_state.c:77!
> > invalid opcode: 0000 [1] SMP DEBUG_PAGEALLOC
> > last sysfs file: /sys/devices/system/cpu/cpu7/cache/index2/shared_cpu_map
> > CPU 7
> > Modules linked in:
> > Pid: 13550, comm: sh Not tainted 2.6.26-rc5-mm2-dirty #412
> > RIP: 0010:[<ffffffff80288689>]  [<ffffffff80288689>]
> > add_to_swap_cache+0xd9/0x120
> > RSP: 0018:ffff81010c62d8a8  EFLAGS: 00010246
> > RAX: 2000000000020009 RBX: ffffe2000107da88 RCX: c000000000000000
> > RDX: 0000000000000020 RSI: 000000000000eea2 RDI: ffffe2000107da88
> > RBP: ffff81010c62d8c8 R08: fffffffffa48016e R09: 0000000000000000
> > R10: ffffffff80857fa0 R11: 2222222222222222 R12: ffff81012e126520
> > R13: 000000000000eea2 R14: ffff8100727bea20 R15: ffff81010c62d9b8
> > FS:  00002b5b33cafdc0(0000) GS:ffff81012ff07800(0000)
> > knlGS:0000000000000000 CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > CR2: 000000000175e280 CR3: 000000012e292000 CR4: 00000000000006e0
> > DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> > Process sh (pid: 13550, threadinfo ffff81010c62c000, task
> > ffff810116b01110) Stack:  ffff81010c62d8c8 ffffe2000107da88
> > ffff81012e126520 ffff81012e126400 ffff81010c62d908 ffffffff80292851
> > 000000000000eea2 ffff81012e126708 ffffe2000107da88 ffffffff80701420
> > ffff81010c62db68 ffff81010c62dc88 Call Trace:
> >  [<ffffffff80292851>] shmem_writepage+0x121/0x200
> >  [<ffffffff80277479>] shrink_page_list+0x559/0x6b0
> >  [<ffffffff802777ec>] shrink_list+0x21c/0x520
> >  [<ffffffff80273365>] ? determine_dirtyable_memory+0x15/0x30
> >  [<ffffffff802733a2>] ? get_dirty_limits+0x22/0x2a0
> >  [<ffffffff80277d31>] shrink_zone+0x241/0x330
> >  [<ffffffff80278207>] try_to_free_pages+0x237/0x3a0
> >  [<ffffffff80276530>] ? isolate_pages_global+0x0/0x270
> >  [<ffffffff80272546>] __alloc_pages_internal+0x206/0x4b0
> >  [<ffffffff8028dfd7>] alloc_pages_current+0x87/0xd0
> >  [<ffffffff802714fe>] __get_free_pages+0xe/0x60
> >  [<ffffffff802343ca>] copy_process+0xba/0x1240
> >  [<ffffffff80235682>] do_fork+0x82/0x2a0
> >  [<ffffffff8025a03d>] ? trace_hardirqs_on+0xd/0x10
> >  [<ffffffff805177ab>] ? _spin_unlock_irq+0x2b/0x40
> >  [<ffffffff8051703f>] ? trace_hardirqs_on_thunk+0x3a/0x3f
> >  [<ffffffff8020b6cb>] ? system_call_after_swapgs+0x7b/0x80
> >  [<ffffffff80209853>] sys_clone+0x23/0x30
> >
> > The tmpfs PageSwapBacked stuff seems rather broken. For
> > them write_begin/write_end path, it is filemap.c, not shmem.c,
> > which allocates the page, so its no wonder it goes bug. Will
> > try to do more testing without shmem.
>
> rikstuff.  Could be that the merge caused a problem?

Doesn't look like it, but I hadn't followed the changes too closely:
rather they just need to test loopback over tmpfs.


> > Also, just noticed
> > mm/memory.c:do_wp_page
> > //TODO:  is this safe?  do_anonymous_page() does it this way.
> >
> > That's a bit disheartening. Surely a question like that has to
> > be answered definitively?
>
> I asked that too.
>
> > (hopefully whatever is doing the
> > asking won't get merged until answered)
>
> It would be good if you could find a day to look through those changes
> please.  It's pretty important.

OK, I could have a look through them at some point.

Just something very quick while I have Rik's attention are all the
atomic SetPageSwapBacked bitops over a lot of mm/ fastpaths that I have
been slowly working away to get rid of over the past years. Maybe some
don't consider it a big deal, but a single one costs anywhere from
100 - 500 instructions on desktop CPUs, not including secondary effects
of ordering memory and and compiler barrier. Please go through and
ensure you know your page references and ->flags concurrency, and cut
these down to a bare minimum.

Is the plan to merge all reclaim changes in a big hit, rather than
slowly trickle in the different independent changes?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
