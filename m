Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 227F76B017E
	for <linux-mm@kvack.org>; Thu,  7 Nov 2013 16:48:36 -0500 (EST)
Received: by mail-pb0-f42.google.com with SMTP id jt11so1210296pbb.15
        for <linux-mm@kvack.org>; Thu, 07 Nov 2013 13:48:35 -0800 (PST)
Received: from psmtp.com ([74.125.245.137])
        by mx.google.com with SMTP id kn3si3953169pbc.274.2013.11.07.13.48.33
        for <linux-mm@kvack.org>;
        Thu, 07 Nov 2013 13:48:34 -0800 (PST)
Date: Thu, 7 Nov 2013 15:48:38 -0600
From: Alex Thorlton <athorlton@sgi.com>
Subject: Re: BUG: mm, numa: test segfaults, only when NUMA balancing is on
Message-ID: <20131107214838.GY3066@sgi.com>
References: <20131016155429.GP25735@sgi.com>
 <20131104145828.GA1218@suse.de>
 <20131104200346.GA3066@sgi.com>
 <20131106131048.GC4877@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131106131048.GC4877@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Nov 06, 2013 at 01:10:48PM +0000, Mel Gorman wrote:
> On Mon, Nov 04, 2013 at 02:03:46PM -0600, Alex Thorlton wrote:
> > On Mon, Nov 04, 2013 at 02:58:28PM +0000, Mel Gorman wrote:
> > > On Wed, Oct 16, 2013 at 10:54:29AM -0500, Alex Thorlton wrote:
> > > > Hi guys,
> > > > 
> > > > I ran into a bug a week or so ago, that I believe has something to do
> > > > with NUMA balancing, but I'm having a tough time tracking down exactly
> > > > what is causing it.  When running with the following configuration
> > > > options set:
> > > > 
> > > 
> > > Can you test with patches
> > > cd65718712469ad844467250e8fad20a5838baae..0255d491848032f6c601b6410c3b8ebded3a37b1
> > > applied? They fix some known memory corruption problems, were merged for
> > > 3.12 (so alternatively just test 3.12) and have been tagged for -stable.
> > 
> > I just finished testing with 3.12, and I'm still seeing the same issue.
> 
> Ok, I plugged your test into mmtests and ran it a few times but was not
> able to reproduce the same issue. It's a much smaller machine which
> might be a factor.
> 
> > I'll poke around a bit more on this in the next few days and see if I
> > can come up with any more information.  In the meantime, let me know if
> > you have any other suggestions.
> > 
> 
> Try the following patch on top of 3.12. It's a patch that is expected to
> be merged for 3.13. On its own it'll hurt automatic NUMA balancing in
> -stable but corruption trumps performance and the full series is not
> going to be considered acceptable for -stable

I gave this patch a shot, and it didn't seem to solve the problem.
Actually I'm running into what appear to be *worse* problems on the 3.12
kernel.  Here're a couple stack traces of what I get when I run the test
on 3.12, 512 cores:

(These are just two of the CPUs, obviously, but most of the memscale
processes appeared to be in one of these two spots)

Nov  7 13:54:39 uvpsw1 kernel: NMI backtrace for cpu 6
Nov  7 13:54:39 uvpsw1 kernel: CPU: 6 PID: 17759 Comm: thp_memscale Not tainted 3.12.0-rc7-medusa-00006-g0255d49 #381
Nov  7 13:54:39 uvpsw1 kernel: Hardware name: Intel Corp. Stoutland Platform, BIOS 2.20 UEFI2.10 PI1.0 X64 2013-09-20
Nov  7 13:54:39 uvpsw1 kernel: task: ffff8810647e0300 ti: ffff88106413e000 task.ti: ffff88106413e000
Nov  7 13:54:39 uvpsw1 kernel: RIP: 0010:[<ffffffff8151c7d5>]  [<ffffffff8151c7d5>] _raw_spin_lock+0x1a/0x25
Nov  7 13:54:39 uvpsw1 kernel: RSP: 0018:ffff88106413fd38  EFLAGS: 00000283
Nov  7 13:54:39 uvpsw1 kernel: RAX: 00000000a1a9a0fe RBX: 0000000000000206 RCX: ffff880000000000
Nov  7 13:54:41 uvpsw1 kernel: RDX: 000000000000a1a9 RSI: 00003ffffffff000 RDI: ffff8907ded35494
Nov  7 13:54:41 uvpsw1 kernel: RBP: ffff88106413fd38 R08: 0000000000000006 R09: 0000000000000002
Nov  7 13:54:41 uvpsw1 kernel: R10: 0000000000000007 R11: ffff88106413ff40 R12: ffff8907ded35494
Nov  7 13:54:42 uvpsw1 kernel: R13: ffff88106413fe1c R14: ffff8810637a05f0 R15: 0000000000000206
Nov  7 13:54:42 uvpsw1 kernel: FS:  00007fffd5def700(0000) GS:ffff88107d980000(0000) knlGS:0000000000000000
Nov  7 13:54:42 uvpsw1 kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Nov  7 13:54:42 uvpsw1 kernel: CR2: 00007fffd5ded000 CR3: 00000107dfbcf000 CR4: 00000000000007e0
Nov  7 13:54:42 uvpsw1 kernel: Stack:
Nov  7 13:54:42 uvpsw1 kernel:  ffff88106413fda8 ffffffff810d670a 0000000000000002 0000000000000006
Nov  7 13:54:42 uvpsw1 kernel:  00007fff57dde000 ffff8810640e1cc0 000002006413fe10 ffff8907ded35440
Nov  7 13:54:45 uvpsw1 kernel:  ffff88106413fda8 0000000000000206 0000000000000002 0000000000000000
Nov  7 13:54:45 uvpsw1 kernel: Call Trace:
Nov  7 13:54:45 uvpsw1 kernel:  [<ffffffff810d670a>] follow_page_mask+0x123/0x3f1
Nov  7 13:54:45 uvpsw1 kernel:  [<ffffffff810d7c4e>] __get_user_pages+0x3e3/0x488
Nov  7 13:54:45 uvpsw1 kernel:  [<ffffffff810d7d90>] get_user_pages+0x4d/0x4f
Nov  7 13:54:45 uvpsw1 kernel:  [<ffffffff810ec869>] SyS_get_mempolicy+0x1a9/0x3e0
Nov  7 13:54:45 uvpsw1 kernel:  [<ffffffff8151d422>] system_call_fastpath+0x16/0x1b
Nov  7 13:54:46 uvpsw1 kernel: Code: b1 17 39 c8 ba 01 00 00 00 74 02 31 d2 89 d0 c9 c3 55 48 89 e5 b8 00 00 01 00 f0 0f c1 07 89 c2 c1 ea 10 66 39 d0 74 0c 66 8b 07 <66> 39 d0 74 04 f3 90 eb f4 c9 c3 55 48 89 e5 9c 59 fa b8 00 00

Nov  7 13:55:59 uvpsw1 kernel: NMI backtrace for cpu 8
Nov  7 13:55:59 uvpsw1 kernel: INFO: NMI handler (arch_trigger_all_cpu_backtrace_handler) took too long to run: 1.099 msecs
Nov  7 13:56:04 uvpsw1 kernel: CPU: 8 PID: 17761 Comm: thp_memscale Not tainted 3.12.0-rc7-medusa-00006-g0255d49 #381
Nov  7 13:56:04 uvpsw1 kernel: Hardware name: Intel Corp. Stoutland Platform, BIOS 2.20 UEFI2.10 PI1.0 X64 2013-09-20
Nov  7 13:56:04 uvpsw1 kernel: task: ffff881063c56380 ti: ffff8810621b8000 task.ti: ffff8810621b8000
Nov  7 13:56:04 uvpsw1 kernel: RIP: 0010:[<ffffffff8151c7d5>]  [<ffffffff8151c7d5>] _raw_spin_lock+0x1a/0x25
Nov  7 13:56:04 uvpsw1 kernel: RSP: 0018:ffff8810621b9c98  EFLAGS: 00000283
Nov  7 13:56:04 uvpsw1 kernel: RAX: 00000000a20aa0ff RBX: ffff8810621002b0 RCX: 8000000000000025
Nov  7 13:56:04 uvpsw1 kernel: RDX: 000000000000a20a RSI: ffff8810621002b0 RDI: ffff8907ded35494
Nov  7 13:56:04 uvpsw1 kernel: RBP: ffff8810621b9c98 R08: 0000000000000001 R09: 0000000000000001
Nov  7 13:56:04 uvpsw1 kernel: R10: 000000000000000a R11: 0000000000000246 R12: ffff881062f726b8
Nov  7 13:56:04 uvpsw1 kernel: R13: 0000000000000001 R14: ffff8810621002b0 R15: ffff881062f726b8
Nov  7 13:56:09 uvpsw1 kernel: FS:  00007fff79512700(0000) GS:ffff88107da00000(0000) knlGS:0000000000000000
Nov  7 13:56:09 uvpsw1 kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Nov  7 13:56:09 uvpsw1 kernel: CR2: 00007fff79510000 CR3: 00000107dfbcf000 CR4: 00000000000007e0
Nov  7 13:56:09 uvpsw1 kernel: Stack:
Nov  7 13:56:09 uvpsw1 kernel:  ffff8810621b9cb8 ffffffff810f3e57 8000000000000025 ffff881062f726b8
Nov  7 13:56:09 uvpsw1 kernel:  ffff8810621b9ce8 ffffffff810f3edb 80000187dd73e166 00007fe2dae00000
Nov  7 13:56:09 uvpsw1 kernel:  ffff881063708ff8 00007fe2db000000 ffff8810621b9dc8 ffffffff810def2c
Nov  7 13:56:09 uvpsw1 kernel: Call Trace:
Nov  7 13:56:09 uvpsw1 kernel:  [<ffffffff810f3e57>] __pmd_trans_huge_lock+0x1a/0x7c
Nov  7 13:56:10 uvpsw1 kernel:  [<ffffffff810f3edb>] change_huge_pmd+0x22/0xcc
Nov  7 13:56:14 uvpsw1 kernel:  [<ffffffff810def2c>] change_protection+0x200/0x591
Nov  7 13:56:14 uvpsw1 kernel:  [<ffffffff810ecb07>] change_prot_numa+0x16/0x2c
Nov  7 13:56:14 uvpsw1 kernel:  [<ffffffff8106c247>] task_numa_work+0x224/0x29a
Nov  7 13:56:14 uvpsw1 kernel:  [<ffffffff810551b1>] task_work_run+0x81/0x99
Nov  7 13:56:14 uvpsw1 kernel:  [<ffffffff810025e1>] do_notify_resume+0x539/0x54b
Nov  7 13:56:14 uvpsw1 kernel:  [<ffffffff810c3ce9>] ? put_page+0x10/0x24
Nov  7 13:56:14 uvpsw1 kernel:  [<ffffffff810ec9fa>] ? SyS_get_mempolicy+0x33a/0x3e0
Nov  7 13:56:14 uvpsw1 kernel:  [<ffffffff8151d6aa>] int_signal+0x12/0x17
Nov  7 13:56:14 uvpsw1 kernel: Code: b1 17 39 c8 ba 01 00 00 00 74 02 31 d2 89 d0 c9 c3 55 48 89 e5 b8 00 00 01 00 f0 0f c1 07 89 c2 c1 ea 10 66 39 d0 74 0c 66 8b 07 <66> 39 d0 74 04 f3 90 eb f4 c9 c3 55 48 89 e5 9c 59 fa b8 00 00

I managed to bisect the issue down to this commit:

0255d491848032f6c601b6410c3b8ebded3a37b1 is the first bad commit
commit 0255d491848032f6c601b6410c3b8ebded3a37b1
Author: Mel Gorman <mgorman@suse.de>
Date:   Mon Oct 7 11:28:47 2013 +0100

    mm: Account for a THP NUMA hinting update as one PTE update

    A THP PMD update is accounted for as 512 pages updated in vmstat.  This is
    large difference when estimating the cost of automatic NUMA balancing and
    can be misleading when comparing results that had collapsed versus split
    THP. This patch addresses the accounting issue.

    Signed-off-by: Mel Gorman <mgorman@suse.de>
    Reviewed-by: Rik van Riel <riel@redhat.com>
    Cc: Andrea Arcangeli <aarcange@redhat.com>
    Cc: Johannes Weiner <hannes@cmpxchg.org>
    Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
    Cc: <stable@kernel.org>
    Signed-off-by: Peter Zijlstra <peterz@infradead.org>
    Link: http://lkml.kernel.org/r/1381141781-10992-10-git-send-email-mgorman@suse.de
    Signed-off-by: Ingo Molnar <mingo@kernel.org>

:040000 040000 e5a44a1f0eea2f41d2cccbdf07eafee4e171b1e2 ef030a7c78ef346095ac991c3e3aa139498ed8e7 M      mm

I haven't had a chance yet to dig into the code for this commit to see
what might be causing the crashes, but I have confirmed that this is
where the new problem started (checked the commit before this, and we
don't get the crash, just segfaults like we were getting before).  So,
in summary, we still have the segfault issue, but this new issue seems
to be a bit more serious, so I'm going to try and chase this one down
first.

Let me know if you'd like any more information from me and I'll be glad
to provide it.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
