Subject: Re: [BUG] mmotm-081130: null pointer deref in sigkill_pending()
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <604427e00812021046p3ebd6e24xf92e6ab29df35686@mail.gmail.com>
References: <1228223933.30995.28.camel@lts-notebook>
	 <604427e00812021046p3ebd6e24xf92e6ab29df35686@mail.gmail.com>
Content-Type: text/plain
Date: Tue, 02 Dec 2008 14:03:21 -0500
Message-Id: <1228244601.6202.13.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ying Han <yinghan@google.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-12-02 at 10:46 -0800, Ying Han wrote:
> On Tue, Dec 2, 2008 at 5:18 AM, Lee Schermerhorn
> <Lee.Schermerhorn@hp.com> wrote:
> > While testing mmotm [11/29, 11/30, likely in 12/01], I came across the
> > following bug after ~2 hours of heavy stress on x86_64 [same bug/trace
> > hit on ia64]:
> >
> > BUG: unable to handle kernel NULL pointer dereference at 0000000000000038
> > IP: [<ffffffff8024e679>] sigkill_pending+0x19/0x30
> > PGD 63be12067 PUD 7fd0cc067 PMD 0
> > Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
> > last sysfs file: /sys/block/hda/removable
> > CPU 7
> > Modules linked in: sunrpc ipv6 dm_mirror dm_region_hash dm_log dm_mod rfkill input_polldev pci_slot parport_pc lp parport ide_cd_mod cdrom serio_raw hpilo hpwdt button amd_rng pata_acpi i2c_amd756 libata i2c_core pcspkr mptspi mptscsih sym53c8xx scsi_transport_spi sd_mod scsi_mod mptbase ext3 jbd ehci_hcd ohci_hcd uhci_hcd
> > Pid: 19530, comm: ps Not tainted 2.6.28-rc6-mmotm-081130-2235 #10
> > RIP: 0010:[<ffffffff8024e679>]  [<ffffffff8024e679>] sigkill_pending+0x19/0x30
> > RSP: 0018:ffff8806a64efd38  EFLAGS: 00010246
> > RAX: 0000000000000000 RBX: 000000000000000e RCX: ffff8805fc96fb00
> > RDX: ffff8806a64efe38 RSI: 00007fff62423000 RDI: ffff88020c87abe0
> > RBP: ffff8806a64efd38 R08: 0000000000000000 R09: ffff8806a64efe30
> > R10: 0000000000000002 R11: 0000000000000000 R12: ffff8805fc96fb00
> > R13: 0000000000000000 R14: 0000000000000010 R15: ffff8806a64efe30
> > FS:  00007f32d4ac46f0(0000) GS:ffff8807fed46d80(0000) knlGS:0000000000000000
> > CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > CR2: 0000000000000038 CR3: 0000000784571000 CR4: 00000000000006e0
> > DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> > Process ps (pid: 19530, threadinfo ffff8806a64ee000, task ffff88062cf6d7c0)
> > Stack:
> >  ffff8806a64efdb8 ffffffff80298986 0000000000000001 ffff88062cf6d7c0
> >  ffff8803ad100680 ffff88020c87abe0 0000000000000000 ffff8806a64efe38
> >  ffff8806a64efe30 00000001804f0765 00007fff624236be 0000000000000000
> > Call Trace:
> >  [<ffffffff80298986>] __get_user_pages+0x166/0x440
> >  [<ffffffff80298c92>] get_user_pages+0x32/0x40
> >  [<ffffffff80298dab>] access_process_vm+0x10b/0x1e0
> >  [<ffffffff8030bd60>] proc_pid_cmdline+0x90/0x120
> >  [<ffffffff802ae568>] ? alloc_pages_current+0xa8/0x100
> >  [<ffffffff8030de5b>] proc_info_read+0x9b/0xe0
> >  [<ffffffff802c0ba4>] vfs_read+0xc4/0x160
> >  [<ffffffff802c1000>] sys_read+0x50/0x90
> >  [<ffffffff8020c3fb>] system_call_fastpath+0x16/0x1b
> > Code: e8 08 83 e0 01 c3 66 0f 1f 44 00 00 66 0f 1f 44 00 00 f6 87 49 05 00 00 01 55 b8 01 00 00 00 48 89 e5 75 12 48 8b 87 10 05 00 00 <48> 8b 40 38 48 c1 e8 08 83 e0 01 c9 c3 66 2e 0f 1f 84 00 00 00
> > RIP  [<ffffffff8024e679>] sigkill_pending+0x19/0x30
> >  RSP <ffff8806a64efd38>
> > CR2: 0000000000000038
> > ---[ end trace 80efa2c8bcce4fdc ]---
> >
> > Ad hoc instrumentation showed that this is likely the result of the
> > "make-get_user_pages-interruptible" patch in mmotm.  The test workload
> > includes a number of tasks that repeatedly run a list of miscellaneous
> > programs, including ps(1).  Occasionally, ps will catch a task with a
> > NULL "tsk->signal" [exiting?], resulting in a null pointer deref in
> > sigkill_pending() called from __get_user_pages().
> >
> > Before the aforementioned patch, sigkill_pending() was only called from
> > ptrace_stop() for tsk == current.  The comment block on ptrace_stop()
> > says:  "This must be called with current->sighand->siglock held."  So,
> > it doesn't look safe to call sigkill_pending() from
> > __get_user_pages()--especially on a task != current--without similar
> > locking.
> 
> >
> > I'm not sure what the correct fix should be here.
> I made a fix for the patch as Oleg suggested which replace the
> sigkill_pending() as fatal_signal_pending().
> Andrew deleted the original patch from mm tree this morning and i am
> about the post the new patch with
> the fix.

OK.  I've been working on a fix, but I'll await yours.  I have found
another interaction of this patch with munlock of mlocked vmas on exit
if the task was killed with SIGKILL.  Get_user_pages() fails and we
don't munlock the pages.   I have a fix for that [another internal
GUPS_FLAG], as well, but I'll wait until yours shows up in mmotm and
rebase atop that.  Meanwhile, my fix lets me continue to test on
mmotm-081201.

> >
> > Related:  the patch and it's update add the following to
> > __get_user_pages():
> >
> >        if (unlikely(sigkill_pending(current) ||
> >             sigkill_pending(tsk)))
> >                return i ? i : -ERESTARTSYS;
> >
> > As a minimum, I don't think we want to call the second sigkill_pending()
> > unless tsk != current.
> In most cases, (current == tsk) in get_user_pages. However in some
> situation current is calling get_user_pages on behalf of tsk and we
> want to interrupt the allocation in this case as well.

Agreed.  It was, in fact, the case where ps(1) was calling
get_user_pages() to access another [exiting] task's command line
via /proc that I hit the problem.

> I might change it something like this:
> 
> >        if (unlikely(sigkill_pending(current) ||
> >             ((current != tsk) && sigkill_pending(tsk))))
> >                return i ? i : -ERESTARTSYS;

Yes, that's what I was thinking.  

Thanks,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
