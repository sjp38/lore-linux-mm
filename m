Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 75BF48D0039
	for <linux-mm@kvack.org>; Fri, 18 Feb 2011 13:09:05 -0500 (EST)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <20110216185234.GA11636@tiehlicka.suse.cz>
	<20110216193700.GA6377@elte.hu>
	<AANLkTinDxxbVjrUViCs=UaMD9Wg9PR7b0ShNud5zKE3w@mail.gmail.com>
	<AANLkTi=xnbcs5BKj3cNE_aLtBO7W5m+2uaUacu7M8g_S@mail.gmail.com>
	<20110217090910.GA3781@tiehlicka.suse.cz>
	<AANLkTikPKpNHxDQAYBd3fiQsmVozLtCVDsNn=+eF_q2r@mail.gmail.com>
	<20110217163531.GF14168@elte.hu> <m1pqqqfpzh.fsf@fess.ebiederm.org>
	<AANLkTinB=EgDGNv-v-qD-MvHVAmstfP_CyyLNhhotkZx@mail.gmail.com>
	<20110218122938.GB26779@tiehlicka.suse.cz>
	<20110218162623.GD4862@tiehlicka.suse.cz>
	<AANLkTimO=M5xG_mnDBSxPKwSOTrp3JhHVBa8=wHsiVHY@mail.gmail.com>
Date: Fri, 18 Feb 2011 10:08:52 -0800
In-Reply-To: <AANLkTimO=M5xG_mnDBSxPKwSOTrp3JhHVBa8=wHsiVHY@mail.gmail.com>
	(Linus Torvalds's message of "Fri, 18 Feb 2011 08:39:02 -0800")
Message-ID: <m17hcx43m3.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Subject: Re: BUG: Bad page map in process udevd (anon_vma: (null)) in 2.6.38-rc4
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org

Linus Torvalds <torvalds@linux-foundation.org> writes:

> On Fri, Feb 18, 2011 at 8:26 AM, Michal Hocko <mhocko@suse.cz> wrote:
>>> Now, I will try with the 2 patches patches in this thread. I will also
>>> turn on DEBUG_LIST and DEBUG_PAGEALLOC.
>>
>> I am not able to reproduce with those 2 patches applied.
>
> Thanks for verifying. Davem/EricD - you can add Michal's tested-by to
> the patches too.
>
> And I think we can consider this whole thing solved. It hopefully also
> explains all the other random crashes that EricB saw - just random
> memory corruption in other datastructures.
>
> EricB - do all your stress-testers run ok now?

Things are looking better and PAGEALLOC debug isn't firing.
So this looks like one bug down.  I have not seen the bad page map
symptom.

I am still getting programs segfaulting but that is happening on other
machines running on older kernels so I am going to chalk that up to a
buggy test and a false positive.

I am have OOM problems getting my tests run to complete.  On a good
day that happens about 1 time in 3 right now.  I'm guess I will have
to turn off DEBUG_PAGEALLOC to get everything to complete.
DEBUG_PAGEALLOC causes us to use more memory doesn't it?

The most interesting thing I have right now is a networking lockdep
issue.  Does anyone know what is going on there?

Eric


=================================
[ INFO: inconsistent lock state ]
2.6.38-rc4-359399.2010AroraKernelBeta.fc14.x86_64 #1
---------------------------------
inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.
kworker/u:1/10833 [HC0[0]:SC0[0]:HE1:SE1] takes:
 (tcp_death_row.death_lock){+.?...}, at: [<ffffffff81460e69>] inet_twsk_deschedule+0x29/0xa0
{IN-SOFTIRQ-W} state was registered at:
  [<ffffffff810840ce>] __lock_acquire+0x70e/0x1d30
  [<ffffffff81085cff>] lock_acquire+0x9f/0x120
  [<ffffffff814deb6c>] _raw_spin_lock+0x2c/0x40
  [<ffffffff8146066b>] inet_twsk_schedule+0x3b/0x1e0
  [<ffffffff8147bf7d>] tcp_time_wait+0x20d/0x380
  [<ffffffff8146b46e>] tcp_fin.clone.39+0x10e/0x1c0
  [<ffffffff8146c628>] tcp_data_queue+0x798/0xd50
  [<ffffffff8146fdd9>] tcp_rcv_state_process+0x799/0xbb0
  [<ffffffff814786d8>] tcp_v4_do_rcv+0x238/0x500
  [<ffffffff8147a90a>] tcp_v4_rcv+0x86a/0xbe0
  [<ffffffff81455d4d>] ip_local_deliver_finish+0x10d/0x380
  [<ffffffff81456180>] ip_local_deliver+0x80/0x90
  [<ffffffff81455832>] ip_rcv_finish+0x192/0x5a0
  [<ffffffff814563c4>] ip_rcv+0x234/0x300
  [<ffffffff81420e83>] __netif_receive_skb+0x443/0x700
  [<ffffffff81421d68>] netif_receive_skb+0xb8/0xf0
  [<ffffffff81421ed8>] napi_skb_finish+0x48/0x60
  [<ffffffff81422d35>] napi_gro_receive+0xb5/0xc0
  [<ffffffffa006b4cf>] igb_poll+0x89f/0xd20 [igb]
  [<ffffffff81422279>] net_rx_action+0x149/0x270
  [<ffffffff81054bc0>] __do_softirq+0xc0/0x1f0
  [<ffffffff81003d1c>] call_softirq+0x1c/0x30
  [<ffffffff81005825>] do_softirq+0xa5/0xe0
  [<ffffffff81054dfd>] irq_exit+0x8d/0xa0
  [<ffffffff81005391>] do_IRQ+0x61/0xe0
  [<ffffffff814df793>] ret_from_intr+0x0/0x1a
  [<ffffffff810ec9ed>] ____pagevec_lru_add+0x16d/0x1a0
  [<ffffffff810ed073>] lru_add_drain+0x73/0xe0
  [<ffffffff8110a44c>] exit_mmap+0x5c/0x180
  [<ffffffff8104aad2>] mmput+0x52/0xe0
  [<ffffffff810513c0>] exit_mm+0x120/0x150
  [<ffffffff81051522>] do_exit+0x132/0x8c0
  [<ffffffff81051f39>] do_group_exit+0x59/0xd0
  [<ffffffff81051fc2>] sys_exit_group+0x12/0x20
  [<ffffffff81002d92>] system_call_fastpath+0x16/0x1b
irq event stamp: 187417
hardirqs last  enabled at (187417): [<ffffffff81127db5>] kmem_cache_free+0x125/0x160
hardirqs last disabled at (187416): [<ffffffff81127d02>] kmem_cache_free+0x72/0x160
softirqs last  enabled at (187410): [<ffffffff81411c52>] sk_common_release+0x62/0xc0
softirqs last disabled at (187408): [<ffffffff814dec41>] _raw_write_lock_bh+0x11/0x40
other info that might help us debug this:
3 locks held by kworker/u:1/10833:
 #0:  (netns){.+.+.+}, at: [<ffffffff81068be1>] process_one_work+0x121/0x4b0
 #1:  (net_cleanup_work){+.+.+.}, at: [<ffffffff81068be1>] process_one_work+0x121/0x4b0
 #2:  (net_mutex){+.+.+.}, at: [<ffffffff8141c4a0>] cleanup_net+0x80/0x1b0

stack backtrace:
Pid: 10833, comm: kworker/u:1 Not tainted 2.6.38-rc4-359399.2010AroraKernelBeta.fc14.x86_64 #1
Call Trace:
 [<ffffffff810835b0>] ? print_usage_bug+0x170/0x180
 [<ffffffff8108393f>] ? mark_lock+0x37f/0x400
 [<ffffffff81084150>] ? __lock_acquire+0x790/0x1d30
 [<ffffffff81083d8f>] ? __lock_acquire+0x3cf/0x1d30
 [<ffffffff81124acf>] ? check_object+0xaf/0x270
 [<ffffffff81460e69>] ? inet_twsk_deschedule+0x29/0xa0
 [<ffffffff81085cff>] ? lock_acquire+0x9f/0x120
 [<ffffffff81460e69>] ? inet_twsk_deschedule+0x29/0xa0
 [<ffffffff81410f49>] ? __sk_free+0xd9/0x160
 [<ffffffff814deb6c>] ? _raw_spin_lock+0x2c/0x40
 [<ffffffff81460e69>] ? inet_twsk_deschedule+0x29/0xa0
 [<ffffffff81460e69>] ? inet_twsk_deschedule+0x29/0xa0
 [<ffffffff81460fd6>] ? inet_twsk_purge+0xf6/0x180
 [<ffffffff81460f10>] ? inet_twsk_purge+0x30/0x180
 [<ffffffff814760fc>] ? tcp_sk_exit_batch+0x1c/0x20
 [<ffffffff8141c1d3>] ? ops_exit_list.clone.0+0x53/0x60
 [<ffffffff8141c520>] ? cleanup_net+0x100/0x1b0
 [<ffffffff81068c47>] ? process_one_work+0x187/0x4b0
 [<ffffffff81068be1>] ? process_one_work+0x121/0x4b0
 [<ffffffff8141c420>] ? cleanup_net+0x0/0x1b0
 [<ffffffff8106a65c>] ? worker_thread+0x15c/0x330
 [<ffffffff8106a500>] ? worker_thread+0x0/0x330
 [<ffffffff8106f226>] ? kthread+0xb6/0xc0
 [<ffffffff8108678d>] ? trace_hardirqs_on_caller+0x13d/0x180
 [<ffffffff81003c24>] ? kernel_thread_helper+0x4/0x10
 [<ffffffff814df854>] ? restore_args+0x0/0x30
 [<ffffffff8106f170>] ? kthread+0x0/0xc0
 [<ffffffff81003c20>] ? kernel_thread_helper+0x0/0x10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
