Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 11BB98D0039
	for <linux-mm@kvack.org>; Sat, 19 Feb 2011 01:22:47 -0500 (EST)
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
Date: Fri, 18 Feb 2011 22:22:32 -0800
In-Reply-To: <AANLkTimO=M5xG_mnDBSxPKwSOTrp3JhHVBa8=wHsiVHY@mail.gmail.com>
	(Linus Torvalds's message of "Fri, 18 Feb 2011 08:39:02 -0800")
Message-ID: <m1oc68ilw7.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Subject: Re: BUG: Bad page map in process udevd (anon_vma: (null)) in 2.6.38-rc4
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Eric Dumazet <eric.dumazet@gmail.com>

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
>
>                     Linus

It looks like the same problematic dellink pattern made it into net_namespace.c,
and your new LIST_DEBUG changes caught it.

I will cook up a patch after I get some sleep.

Eric


------------[ cut here ]------------
WARNING: at lib/list_debug.c:53 __list_del_entry+0xa1/0xd0()
Hardware name: X7DWU
list_del corruption. prev->next should be ffff88005fc12140, but was           (null)
Modules linked in: macvtap ipt_LOG xt_limit ipt_REJECT xt_hl xt_state dummy tulip xt_tcpudp iptable_filter inet_diag veth macvlan nfsd lockd nfs_acl auth_rpcgss exportfs sunrpc dm_mirror dm_region_hash dm_log uinput bonding ipv6 kvm_intel kvm fuse xt_multiport iptable_nat ip_tables nf_nat x_tables nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 tun 8021q iTCO_wdt microcode iTCO_vendor_support ghes hed sg i5k_amb i5400_edac ioatdma edac_core i2c_i801 serio_raw pcspkr dca shpchp radeon ttm drm_kms_helper drm hwmon i2c_algo_bit i2c_core sr_mod ehci_hcd cdrom netxen_nic uhci_hcd igb dm_mod [last unloaded: mperf]
Pid: 4865, comm: kworker/u:0 Tainted: G        W   2.6.38-rc4-359399.2010AroraKernelBeta.fc14.x86_64 #1
Call Trace:
 [<ffffffff8104d6ba>] ? warn_slowpath_common+0x7a/0xb0
 [<ffffffff8104d791>] ? warn_slowpath_fmt+0x41/0x50
 [<ffffffff81430b02>] ? rtnl_lock+0x12/0x20
 [<ffffffff814328a0>] ? __rtnl_unlock+0x10/0x20
 [<ffffffff8129ab31>] ? __list_del_entry+0xa1/0xd0
 [<ffffffff81423644>] ? unregister_netdevice_queue+0x34/0xa0
 [<ffffffffa0427200>] ? veth_dellink+0x20/0x40 [veth]
 [<ffffffff81423711>] ? default_device_exit_batch+0x61/0xe0
 [<ffffffff8141c1d3>] ? ops_exit_list.clone.0+0x53/0x60
 [<ffffffff8141c520>] ? cleanup_net+0x100/0x1b0
 [<ffffffff81068c47>] ? process_one_work+0x187/0x4b0
 [<ffffffff81068be1>] ? process_one_work+0x121/0x4b0
 [<ffffffff8141c420>] ? cleanup_net+0x0/0x1b0
 [<ffffffff8106a65c>] ? worker_thread+0x15c/0x330
 [<ffffffff8106a500>] ? worker_thread+0x0/0x330
 [<ffffffff8106f226>] ? kthread+0xb6/0xc0
 [<ffffffff81003c24>] ? kernel_thread_helper+0x4/0x10
 [<ffffffff814df02b>] ? _raw_spin_unlock_irq+0x2b/0x40
 [<ffffffff814df854>] ? restore_args+0x0/0x30
 [<ffffffff8106f170>] ? kthread+0x0/0xc0
 [<ffffffff81003c20>] ? kernel_thread_helper+0x0/0x10
---[ end trace bcdbebbab42b1e76 ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
