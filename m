Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 657BC6B00AF
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 20:19:24 -0500 (EST)
Date: Wed, 15 Dec 2010 17:18:09 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Transparent Hugepage Support #33
Message-Id: <20101215171809.0e0bc3d5.akpm@linux-foundation.org>
In-Reply-To: <20101216095408.3a60cbad.kamezawa.hiroyu@jp.fujitsu.com>
References: <20101215051540.GP5638@random.random>
	<20101216095408.3a60cbad.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>, Miklos Szeredi <miklos@szeredi.hu>, "Paul E. McKenney" <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 16 Dec 2010 09:54:08 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> I'll look into when -mm is shipped.

That might take a while - linux-next is a screwed-up catastrophe and I
suppose some sucker has some bisecting to do.

(The second trace below looks similar to https://bugzilla.kernel.org/show_bug.cgi?id=24942)

[  241.227687] INFO: task modprobe:904 blocked for more than 120 seconds.
[  241.227979] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  241.228264] modprobe        D 0000000000000007     0   904      1 0x00000000
[  241.228525]  ffff880255cbdc48 0000000000000046 ffff88009edd1dd8 ffff88025736e880
[  241.228973]  ffff880257a508c0 ffff88025736ebd8 0000000000000002 0000000100000000
[  241.229421]  0000000000000002 0000000000000000 ffff88009edd1dd8 0000000000000000
[  241.229879] Call Trace:
[  241.230043]  [<ffffffff81391496>] schedule_timeout+0x24/0x1b6
[  241.230202]  [<ffffffff81391293>] ? wait_for_common+0x3a/0x129
[  241.230364]  [<ffffffff8105e1ca>] ? trace_hardirqs_on+0xd/0xf
[  241.230522]  [<ffffffff81391322>] wait_for_common+0xc9/0x129
[  241.230681]  [<ffffffff810317d1>] ? default_wake_function+0x0/0xf
[  241.230850]  [<ffffffff8139141c>] wait_for_completion+0x18/0x1a
[  241.231010]  [<ffffffff8107e7bb>] synchronize_sched+0x51/0x58
[  241.231169]  [<ffffffff8104d3d0>] ? wakeme_after_rcu+0x0/0xf
[  241.231329]  [<ffffffff8106a772>] load_module+0xd4e/0xe81
[  241.231489]  [<ffffffff8106a8e5>] sys_init_module+0x40/0x1d7
[  241.231658]  [<ffffffff810029bb>] system_call_fastpath+0x16/0x1b
[  241.231831] INFO: lockdep is turned off.

and

[  271.500616] INFO: rcu_sched_state detected stall on CPU 5 (t=65032 jiffies)
[  271.500616] sending NMI to all CPUs:
[  271.500954] NMI backtrace for cpu 2
[  271.501110] CPU 2 
[  271.501157] Modules linked in: ipv6 dm_mirror dm_region_hash dm_log dm_multipath dm_mod video sbs sbshc battery ac lp parport sg snd_hda_intel snd_hda_codec snd_seq_oss snd_seq_midi_event snd_seq ide_cd_mod serio_raw snd_seq_device snd_pcm_oss shpchp cdrom option usb_wwan snd_mixer_oss snd_pcm usbserial snd_timer snd i2c_i801 soundcore button floppy i2c_core intel_rng(-) snd_page_alloc pcspkr ehci_hcd ohci_hcd uhci_hcd
[  271.503961] 
[  271.504122] Pid: 0, comm: kworker/0:1 Tainted: G        W   2.6.37-rc5-mm1 #1 /
[  271.504403] RIP: 0010:[<ffffffff81009c9b>]  [<ffffffff81009c9b>] mwait_idle+0x76/0x82
[  271.504662] RSP: 0018:ffff880257967f08  EFLAGS: 00000246
[  271.504662] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000000
[  271.504662] RDX: 0000000000000000 RSI: ffff880257966010 RDI: ffffffff81009c91
[  271.504662] RBP: ffff880257967f18 R08: 0000000000000000 R09: 0000000000000001
[  271.504662] R10: ffffffff8102b7d4 R11: ffffffff81396dcc R12: 0000000000000000
[  271.504662] R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000
[  271.504662] FS:  0000000000000000(0000) GS:ffff88009e200000(0000) knlGS:0000000000000000
[  271.504662] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  271.504662] CR2: 0000003e5f0948f0 CR3: 000000000179b000 CR4: 00000000000006e0
[  271.504662] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  271.504662] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  271.504662] Process kworker/0:1 (pid: 0, threadinfo ffff880257966000, task ffff8802579643c0)
[  271.504662] Stack:
[  271.504662]  0000000000000000 0000000000000002 ffff880257967f28 ffffffff810014cf
[  271.504662]  ffff880257967f48 ffffffff8138c3e8 ffffffff8138c25d 0000000000000000
[  271.504662]  0000000000000000 0000000000000000 0000000000000000 0000000000000000
[  271.504662] Call Trace:
[  271.504662]  [<ffffffff810014cf>] cpu_idle+0x48/0x68
[  271.504662]  [<ffffffff8138c3e8>] start_secondary+0x18b/0x18f
[  271.504662]  [<ffffffff8138c25d>] ? start_secondary+0x0/0x18f
[  271.504662] Code: 31 db 48 89 f0 48 89 d9 48 89 da 0f 01 c8 0f ae f0 48 8b 87 38 e0 ff ff a8 08 75 11 e8 2c 45 05 00 48 89 d8 48 89 d9 fb 0f 01 c9 <eb> 06 e8 1b 45 05 00 fb 58 5b c9 c3 55 ba e8 12 00 00 48 89 e5 
[  271.504662] Call Trace:
[  271.504662]  [<ffffffff810014cf>] cpu_idle+0x48/0x68
[  271.504662]  [<ffffffff8138c3e8>] start_secondary+0x18b/0x18f
[  271.504662]  [<ffffffff8138c25d>] ? start_secondary+0x0/0x18f
[  271.504662] Pid: 0, comm: kworker/0:1 Tainted: G        W   2.6.37-rc5-mm1 #1
[  271.504662] Call Trace:
[  271.504662]  <NMI>  [<ffffffff8139529d>] ? arch_trigger_all_cpu_backtrace_handler+0x64/0x80
[  271.504662]  [<ffffffff81396d97>] ? notifier_call_chain+0x81/0xb6
[  271.504662]  [<ffffffff81396e27>] ? __atomic_notifier_call_chain+0x5b/0x84
[  271.504662]  [<ffffffff81396dcc>] ? __atomic_notifier_call_chain+0x0/0x84
[  271.504662]  [<ffffffff81396e5f>] ? atomic_notifier_call_chain+0xf/0x11
[  271.504662]  [<ffffffff81396e8f>] ? notify_die+0x2e/0x30
[  271.504662]  [<ffffffff8139454d>] ? do_nmi+0xa7/0x2a1
[  271.504662]  [<ffffffff8139424a>] ? nmi+0x1a/0x2c
[  271.504662]  [<ffffffff81396dcc>] ? __atomic_notifier_call_chain+0x0/0x84
[  271.504662]  [<ffffffff8102b7d4>] ? finish_task_switch+0x44/0xb8
[  271.504662]  [<ffffffff81009c91>] ? mwait_idle+0x6c/0x82
[  271.504662]  [<ffffffff81009c9b>] ? mwait_idle+0x76/0x82
[  271.504662]  <<EOE>>  [<ffffffff810014cf>] ? cpu_idle+0x48/0x68
[  271.504662]  [<ffffffff8138c3e8>] ? start_secondary+0x18b/0x18f
[  271.504662]  [<ffffffff8138c25d>] ? start_secondary+0x0/0x18f
[  271.500616] NMI backtrace for cpu 5
[  271.500616] CPU 5 
[  271.500616] Modules linked in: ipv6 dm_mirror dm_region_hash dm_log dm_multipath dm_mod video sbs sbshc battery ac lp parport sg snd_hda_intel snd_hda_codec snd_seq_oss snd_seq_midi_event snd_seq ide_cd_mod serio_raw snd_seq_device snd_pcm_oss shpchp cdrom option usb_wwan snd_mixer_oss snd_pcm usbserial snd_timer snd i2c_i801 soundcore button floppy i2c_core intel_rng(-) snd_page_alloc pcspkr ehci_hcd ohci_hcd uhci_hcd
[  271.500616] 
[  271.500616] Pid: 0, comm: kworker/0:1 Tainted: G        W   2.6.37-rc5-mm1 #1 /
[  271.500616] RIP: 0010:[<ffffffff8119b624>]  [<ffffffff8119b624>] __bitmap_empty+0x5a/0x63
[  271.500616] RSP: 0018:ffff88009e803e90  EFLAGS: 00000046
[  271.500616] RAX: 0000000000000000 RBX: 0000000000002710 RCX: ffffffff8180e4e8
[  271.500616] RDX: 0000000000000000 RSI: 00000000000000ff RDI: ffffffff8180e4e0
[  271.500616] RBP: ffff88009e803e98 R08: 0000000000000003 R09: 0000000000000000
[  271.500616] R10: 0000000000000000 R11: ffff88025589aec0 R12: ffff88009e9ce760
[  271.500616] R13: ffffffff817b3080 R14: 0000000000000000 R15: ffffffff817b3180
[  271.500616] FS:  0000000000000000(0000) GS:ffff88009e800000(0000) knlGS:0000000000000000
[  271.500616] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  271.500616] CR2: 00000000008cfb80 CR3: 0000000255941000 CR4: 00000000000006e0
[  271.500616] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  271.500616] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  271.500616] Process kworker/0:1 (pid: 0, threadinfo ffff8802579e8000, task ffff8802579e66c0)
[  271.500616] Stack:
[  271.500616]  ffff88025589aec0 ffff88009e803eb8 ffffffff8101a53c ffff8802579e66c0
[  271.500616]  0000000000000005 ffff88009e803ef8 ffffffff8107ec29 ffff8802579e66c0
[  271.500616]  0000000000000005 0000000000000005 ffff8802579e66c0 0000000000000000
[  271.500616] Call Trace:
[  271.500616]  <IRQ> 
[  271.500616]  [<ffffffff8101a53c>] arch_trigger_all_cpu_backtrace+0x52/0x6a
[  271.500616]  [<ffffffff8107ec29>] __rcu_pending+0x7e/0x2f0
[  271.500616]  [<ffffffff8107ef1d>] rcu_check_callbacks+0x82/0xb3
[  271.500616]  [<ffffffff8104275f>] update_process_times+0x38/0x6e
[  271.500616]  [<ffffffff8105a0f8>] tick_periodic+0x63/0x6f
[  271.500616]  [<ffffffff8105a122>] tick_handle_periodic+0x1e/0x6b
[  271.500616]  [<ffffffff81019a37>] smp_apic_timer_interrupt+0x83/0x96
[  271.500616]  [<ffffffff810033d3>] apic_timer_interrupt+0x13/0x20
[  271.500616]  <EOI> 
[  271.500616]  [<ffffffff81396dcc>] ? __atomic_notifier_call_chain+0x0/0x84
[  271.500616]  [<ffffffff8102b7d4>] ? finish_task_switch+0x44/0xb8
[  271.500616]  [<ffffffff81009c91>] ? mwait_idle+0x6c/0x82
[  271.500616]  [<ffffffff81009c9b>] ? mwait_idle+0x76/0x82
[  271.500616]  [<ffffffff81009c91>] ? mwait_idle+0x6c/0x82
[  271.500616]  [<ffffffff810014cf>] cpu_idle+0x48/0x68
[  271.500616]  [<ffffffff8138c3e8>] start_secondary+0x18b/0x18f
[  271.500616]  [<ffffffff8138c25d>] ? start_secondary+0x0/0x18f
[  271.500616] Code: 89 f0 83 e0 3f 85 c0 74 24 89 f0 4c 63 c2 b9 40 00 00 00 99 f7 f9 b8 01 00 00 00 89 d1 48 d3 e0 48 ff c8 4a 85 04 c7 74 04 31 c0 <eb> 05 b8 01 00 00 00 c9 c3 55 ba 40 00 00 00 89 f1 48 89 e5 53 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
