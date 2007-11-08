Date: Thu, 8 Nov 2007 20:06:07 +0000
Subject: Re: Plans for Onezonelist patch series ???
Message-ID: <20071108200607.GD23882@skynet.ie>
References: <20071107011130.382244340@sgi.com> <1194535612.6214.9.camel@localhost> <1194537674.5295.8.camel@localhost> <Pine.LNX.4.64.0711081033570.7871@schroedinger.engr.sgi.com> <20071108184009.GC23882@skynet.ie> <Pine.LNX.4.64.0711081043420.7871@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0711081043420.7871@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, akpm@linux-foundatin.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (08/11/07 10:43), Christoph Lameter didst pronounce:
> On Thu, 8 Nov 2007, Mel Gorman wrote:
> 
> > There was two bugs that were resolved but I didn't repost after that as
> > mainline + -mm had gone to hell in a hand-basket and I didn't want to
> > add to the mess.
> 
> Hell? I must have missed it.
> 

Some time after rc1, things appeared in a mess - at least I didn't have
much luck figuring out what was going on when I looked. Admittedly, being
very ill at the time I didn't spend much effort on it. Either way things
were churning enough that there seemed to be enough going on without adding
one-zonelist to the mix.

I've rebased the patches to mm-broken-out-2007-11-06-02-32. However, the
vanilla -mm and the one with onezonelist applied are locking up in the
same manner. I'm way too behind at the moment to guess if it is a new bug
or reported already. At best, I can say the patches are not making things
any worse :) I'll go through the archives in the morning and do a bit more
testing to see what happens.

In case this is familiar to people, the lockup I see is;

[  115.548908] BUG: spinlock bad magic on CPU#0, sshd/2752
[  115.611371]  lock: c20029c8, .magic: ffffffff, .owner: <none>/-1, .owner_cpu: -1066669496
[  115.709027]  [<c010526a>] show_trace_log_lvl+0x1a/0x30
[  115.770560]  [<c0105c02>] show_trace+0x12/0x20
[  115.823787]  [<c0105d16>] dump_stack+0x16/0x20
[  115.877011]  [<c022c226>] spin_bug+0x96/0xf0
[  115.928172]  [<c022c429>] _raw_spin_lock+0x69/0x140
[  115.986580]  [<c033f05f>] _spin_lock+0x4f/0x60
[  116.039809]  [<c0224bae>] kobject_add+0x4e/0x1a0
[  116.095112]  [<c01314b4>] uids_user_create+0x54/0x80
[  116.154555]  [<c01318e2>] alloc_uid+0xd2/0x150
[  116.207784]  [<c01356db>] set_user+0x2b/0xb0
[  116.258951]  [<c01373c1>] sys_setreuid+0x141/0x150
[  116.316305]  [<c010429e>] syscall_call+0x7/0xb
[  116.369544]  =======================
[  127.680346] BUG: soft lockup - CPU#0 stuck for 11s! [sshd:2752]
[  127.750987] 
[  127.768781] Pid: 2752, comm: sshd Not tainted (2.6.24-rc1-mm1 #1)
[  127.841498] EIP: 0060:[<c02298c1>] EFLAGS: 00000246 CPU: 0
[  127.906948] EIP is at delay_tsc+0x1/0x20
[  127.953754] EAX: 00000001 EBX: c20029c8 ECX: b0953e83 EDX: 2b35cb6d
[  128.028533] ESI: 04b81d83 EDI: 00000000 EBP: c30f1ec4 ESP: c30f1ebc
[  128.103305]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
[  128.167717] CR0: 80050033 CR2: b7e45544 CR3: 02153000 CR4: 00000690
[  128.242490] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
[  128.317253] DR6: ffff0ff0 DR7: 00000400
[  128.363010]  [<c010526a>] show_trace_log_lvl+0x1a/0x30
[  128.424541]  [<c0105c02>] show_trace+0x12/0x20
[  128.477767]  [<c010250c>] show_regs+0x1c/0x20
[  128.529948]  [<c015ab6b>] softlockup_tick+0x11b/0x150
[  128.590446]  [<c0130fb2>] run_local_timers+0x12/0x20
[  128.649888]  [<c0131182>] update_process_times+0x42/0x90
[  128.713461]  [<c01440f5>] tick_periodic+0x25/0x80
[  128.769812]  [<c0144169>] tick_handle_periodic+0x19/0x80
[  128.833397]  [<c0107519>] timer_interrupt+0x49/0x50
[  128.891802]  [<c015aeb8>] handle_IRQ_event+0x28/0x60
[  128.951246]  [<c015c7f8>] handle_level_irq+0x78/0xe0
[  129.010693]  [<c01065f0>] do_IRQ+0x40/0x80
[  129.059782]  [<c0104c5f>] common_interrupt+0x23/0x28
[  129.119229]  [<c022c472>] _raw_spin_lock+0xb2/0x140
[  129.177635]  [<c033f05f>] _spin_lock+0x4f/0x60
[  129.230851]  [<c0224bae>] kobject_add+0x4e/0x1a0
[  129.286175]  [<c01314b4>] uids_user_create+0x54/0x80
[  129.345598]  [<c01318e2>] alloc_uid+0xd2/0x150
[  129.398830]  [<c01356db>] set_user+0x2b/0xb0
[  129.450005]  [<c01373c1>] sys_setreuid+0x141/0x150
[  129.507380]  [<c010429e>] syscall_call+0x7/0xb
[  129.560605]  =======================


-- 
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
