Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 8F81D6B0169
	for <linux-mm@kvack.org>; Wed, 27 Jul 2011 20:01:56 -0400 (EDT)
Date: Wed, 27 Jul 2011 17:01:48 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 39632] New: kernel BUG at
 arch/x86/mm/fault.c:395
Message-Id: <20110727170148.0172a03c.akpm@linux-foundation.org>
In-Reply-To: <bug-39632-10286@https.bugzilla.kernel.org/>
References: <bug-39632-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: bugme-daemon@bugzilla.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, greenhostnl@gmail.com, Tejun Heo <tj@kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 20 Jul 2011 15:25:32 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=39632
> 
>            Summary: kernel BUG at arch/x86/mm/fault.c:395
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 3.0.0-RC7
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: akpm@linux-foundation.org
>         ReportedBy: greenhostnl@gmail.com
>         Regression: No

I think this is a plain old oops in mem_cgroup_charge_statistics(), but
for some reason it's treating the oopsing address as part of the
vmalloc arena.  Perhaps this is what a use-after-free looks like on the
new percpu area implementation?


> 
> This bug is triggered when the cgroup oom-killer is invoked and kills a child
> process in the cgroups hierarchy. It does not happen every time, but sometimes.
> The immediate result is a process hanging in the 'D' state.
> 
> The machine is AMD 64, kernel 3.0.0rc7, running as a paravirtualised Xen guest.
> Cgroups are configured. CONFIG_CGROUP_MEM_RES_CTLR=y (swap not used).
> 
> This kernel has been patched with Daniel Kiper's XEN memory-hotplug-ballooning
> patchset, queued for Linux 3.1, otherwise vanilla. I am unable to determine how
> relevant the patchset is to this problem.
> 
> Bug output follows:
> 
> [426900.196014] Memory cgroup out of memory: Kill process 22433 (php-cgi) score
> 924 or sacrifice child
> [426900.196014] Killed process 22433 (php-cgi) total-vm:289680kB,
> anon-rss:134272kB, file-rss:7136kB
> [426900.218250] ------------[ cut here ]------------
> [426900.218262] kernel BUG at arch/x86/mm/fault.c:395!
> [426900.218268] invalid opcode: 0000 [#1] SMP
> [426900.218276] CPU 0
> [426900.218279] Modules linked in: ipv6 evdev pcspkr xfs exportfs dm_mirror
> dm_region_hash dm_log dm_snapshot dm_mod
> [426900.218307]
> [426900.218312] Pid: 22433, comm: php-cgi Not tainted 3.0.0-rc7+ #1
> [426900.218323] RIP: e030:[<ffffffff8135854a>]  [<ffffffff8135854a>]
> vmalloc_fault+0x15a/0x2a0
> [426900.218339] RSP: e02b:ffff8800a53b38c8  EFLAGS: 00010046
> [426900.218345] RAX: 00000000c5cc2000 RBX: ffffe8fffff994e0 RCX:
> ffff880000000ff8
> [426900.218352] RDX: 0000000000000000 RSI: ffff8800c5cc2ff8 RDI:
> 0000000000000000
> [426900.218359] RBP: ffff88003c167e88 R08: 00003ffffffff000 R09:
> ffffffff81505880
> [426900.218367] R10: ffff880000000000 R11: dead000000200200 R12:
> ffffffff814cde88
> [426900.218372] R13: ffff8800a53b39f8 R14: 0000000000000029 R15:
> 0000000000000000
> [426900.218386] FS:  00007ff0228a8720(0000) GS:ffff88003fd61000(0000)
> knlGS:0000000000000000
> [426900.218393] CS:  e033 DS: 0000 ES: 0000 CR0: 000000008005003b
> [426900.218399] CR2: ffffe8fffff994e0 CR3: 000000003c167000 CR4:
> 0000000000000660
> [426900.218407] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> 0000000000000000
> [426900.218415] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> 0000000000000400
> [426900.218423] Process php-cgi (pid: 22433, threadinfo ffff8800a53b2000, task
> ffff8800bf556aa0)
> [426900.218432] Stack:
> [426900.218436]  ffff8800a53b3fd8 0000000000000001 ffffe8fffff994e0
> 0000000000000002
> [426900.218453]  ffff8800a53b39f8 ffffffff81358bd9 0000000000000060
> ffff8800bf556aa0
> [426900.218467]  ffff88003c2fd180 0000000000000002 0000000000000000
> 0000000200020200
> [426900.218483] Call Trace:
> [426900.218491]  [<ffffffff81358bd9>] ? do_page_fault+0x339/0x4e0
> [426900.218501]  [<ffffffff810b0d64>] ? __alloc_pages_nodemask+0x144/0x860
> [426900.218510]  [<ffffffff81355915>] ? page_fault+0x25/0x30
> [426900.218519]  [<ffffffff810df69a>] ? mem_cgroup_charge_statistics+0x3a/0x60
> [426900.218594]  [<ffffffff810e241d>] ? __mem_cgroup_uncharge_common+0xcd/0x1f0
> [426900.218604]  [<ffffffff810d0068>] ? page_remove_rmap+0x38/0x60
> [426900.218613]  [<ffffffff810c907b>] ? unmap_vmas+0x60b/0x8f0
> [426900.218622]  [<ffffffff810cb608>] ? exit_mmap+0x78/0x110
> [426900.218632]  [<ffffffff81041475>] ? mmput+0x25/0xe0
> [426900.218640]  [<ffffffff81045b45>] ? exit_mm+0x125/0x160
> [426900.218647]  [<ffffffff8104780b>] ? do_exit+0x16b/0x870
> [426900.218655]  [<ffffffff81047f4f>] ? do_group_exit+0x3f/0xb0
> [426900.218667]  [<ffffffff8105524d>] ? get_signal_to_deliver+0x1dd/0x400
> [426900.218676]  [<ffffffff8100a8cd>] ? __switch_to+0x26d/0x350
> [426900.218684]  [<ffffffff8100b360>] ? do_notify_resume+0x100/0x7f0
> [426900.218693]  [<ffffffff810e7b31>] ? vfs_read+0x161/0x180
> [426900.218700]  [<ffffffff8135575c>] ? retint_signal+0x48/0x8c
> [426900.218706] Code: 39 48 85 ff 74 25 ff 14 25 40 99 4d 81 48 89 c2 48 8b 3e
> ff 14 25 40 99 4d 81 4c 21 c2 4c 21 c0 4c 01 d2 4c 01 d0 48 39 c2 74 41 <0f> 0b
> eb fe 0f 0b eb fe 48 89 ef e8 66 d8 ca ff 66 90 e9 67 ff
> [426900.218826] RIP  [<ffffffff8135854a>] vmalloc_fault+0x15a/0x2a0
> [426900.218835]  RSP <ffff8800a53b38c8>
> [426900.218844] ---[ end trace 20f6f5477696edd2 ]---
> [426900.218850] Fixing recursive fault but reboot is needed!
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
