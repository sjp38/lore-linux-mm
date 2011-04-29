Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 71C55900001
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 14:02:42 -0400 (EDT)
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback
 related.
From: James Bottomley <James.Bottomley@suse.de>
In-Reply-To: <1304094672.2559.12.camel@mulgrave.site>
References: <1303920553.2583.7.camel@mulgrave.site>
	 <1303921583-sup-4021@think> <1303923000.2583.8.camel@mulgrave.site>
	 <1303923177-sup-2603@think> <1303924902.2583.13.camel@mulgrave.site>
	 <BANLkTimpMJRX0CF7tZ75_x1kWmTkFx3XxA@mail.gmail.com>
	 <1304091436.2559.8.camel@mulgrave.site>
	 <1304094672.2559.12.camel@mulgrave.site>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 29 Apr 2011 13:02:30 -0500
Message-ID: <1304100150.2559.28.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sedat.dilek@gmail.com
Cc: Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>

On Fri, 2011-04-29 at 11:31 -0500, James Bottomley wrote:
> On Fri, 2011-04-29 at 10:37 -0500, James Bottomley wrote:
> > On Fri, 2011-04-29 at 12:23 +0200, Sedat Dilek wrote:
> > > But as I see these RCU (CPU) stalls, the patch from [1] might be worth a try.
> > > First, I have seen negative effects on my UP-system was when playing
> > > with linux-next [2].
> > > It was not clear what the origin was and the the side-effects were
> > > somehow "bizarre".
> > > The issue could be easily reproduced by tar-ing the kernel build-dir
> > > to an external USB-hdd.
> > > The issue kept RCU and TIP folks really busy.
> > > Before stepping 4 weeks in the dark, give it a try and let me know in
> > > case of success.
> > 
> > Well, it's highly unlikely because that's a 2.6.39 artifact and the bug
> > showed up in 2.6.38 ... I tried it just in case with no effect, so we
> > know it isn't the cause.
> 
> Actually, I tell a lie: it does't stop kswapd spinning on PREEMPT, but
> it does seem to prevent non-PREEMPT from locking up totally (at least it
> survives three back to back untar runs).
> 
> It's probable it alters the memory pin conditions that cause the spin,
> so it's masking the problem rather than fixing it.

Confirmed ... it's just harder to reproduce with the hrtimers init fix.
The problem definitely still exists (I had to load up the system more
before doing the tar).

This time I've caught kswapd in mem_cgroup_shrink_node_zone.  sysrq-w
doesn't complete for an unknown reason

James

---

[  575.083025] BUG: soft lockup - CPU#2 stuck for 67s! [kswapd0:46]
[  575.083043] Modules linked in: netconsole configfs fuse sunrpc bluetooth cpufreq_ondemand acpi_cpufreq freq_table mperf ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables snd_hda_codec_hdmi snd_hda_codec_conexant arc4 snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device iwlagn snd_pcm uvcvideo videodev v4l2_compat_ioctl32 snd_timer iTCO_wdt mac80211 snd xhci_hcd i2c_i801 cfg80211 soundcore snd_page_alloc e1000e microcode iTCO_vendor_support wmi pcspkr joydev rfkill uinput ipv6 sdhci_pci sdhci mmc_core i915 drm_kms_helper drm i2c_algo_bit i2c_core video [last unloaded: scsi_wait_scan]
[  575.083251] CPU 2 
[  575.083255] Modules linked in: netconsole configfs fuse sunrpc bluetooth cpufreq_ondemand acpi_cpufreq freq_table mperf ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables snd_hda_codec_hdmi snd_hda_codec_conexant arc4 snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device iwlagn snd_pcm uvcvideo videodev v4l2_compat_ioctl32 snd_timer iTCO_wdt mac80211 snd xhci_hcd i2c_i801 cfg80211 soundcore snd_page_alloc e1000e microcode iTCO_vendor_support wmi pcspkr joydev rfkill uinput ipv6 sdhci_pci sdhci mmc_core i915 drm_kms_helper drm i2c_algo_bit i2c_core video [last unloaded: scsi_wait_scan]
[  575.083430] 
[  575.083437] Pid: 46, comm: kswapd0 Not tainted 2.6.39-rc4+ #6 LENOVO 4170CTO/4170CTO
[  575.083455] RIP: 0010:[<ffffffffa007ff8f>]  [<ffffffffa007ff8f>] i915_gem_inactive_shrink+0x6c/0x194 [i915]
[  575.083497] RSP: 0018:ffff88006dfb7d50  EFLAGS: 00000206
[  575.083504] RAX: ffff88005f018200 RBX: 00000000000000c0 RCX: 0000000000000000
[  575.083512] RDX: ffff88005f01bab0 RSI: 0000000000000000 RDI: ffff880037885820
[  575.083529] RBP: ffff88006dfb7d90 R08: 0000000000000000 R09: 0000000000017131
[  575.083535] R10: 0000000000000002 R11: ffffffff81a44e50 R12: ffffffff81482e0e
[  575.083541] R13: ffff88006dfb7cf0 R14: ffff88006dfb7cf8 R15: ffffffff810dd44d
[  575.083548] FS:  0000000000000000(0000) GS:ffff880100280000(0000) knlGS:0000000000000000
[  575.083555] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  575.083572] CR2: 00007f3934e8a000 CR3: 0000000001a03000 CR4: 00000000000406e0
[  575.083579] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  575.083587] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  575.083596] Process kswapd0 (pid: 46, threadinfo ffff88006dfb6000, task ffff88006dfb8000)
[  575.083602] Stack:
[  575.083608]  ffff88006dfb7d90 ffff880037709638 ffff88006dfb7d60 ffff8800377095f0
[  575.083626]  0000000000000000 0000000000000000 00000000000000d0 000000000005103b
[  575.083643]  ffff88006dfb7de0 ffffffff810e1d89 000000000000003d 0000000000000080
[  575.083660] Call Trace:
[  575.083676]  [<ffffffff810e1d89>] shrink_slab+0x6d/0x166
[  575.083686]  [<ffffffff810e49cc>] kswapd+0x533/0x798
[  575.083698]  [<ffffffff810e4499>] ? mem_cgroup_shrink_node_zone+0xe3/0xe3
[  575.083712]  [<ffffffff8106e157>] kthread+0x84/0x8c
[  575.083726]  [<ffffffff81483564>] kernel_thread_helper+0x4/0x10
[  575.083738]  [<ffffffff8106e0d3>] ? kthread_worker_fn+0x148/0x148
[  575.083750]  [<ffffffff81483560>] ? gs_change+0x13/0x13
[  575.083756] Code: e4 48 89 45 c8 75 37 48 8b 43 48 45 31 ed 48 83 c3 48 48 2d b0 00 00 00 eb 0a 48 8d 82 50 ff ff ff 41 ff c5 48 8b 90 b0 00 00 00 
[  575.083887]  05 b0 00 00 00 48 39 d8 0f 18 0a 75 e1 e9 da 00 00 00 4c 89 
[  575.083949] Call Trace:
[  575.083957]  [<ffffffff810e1d89>] shrink_slab+0x6d/0x166
[  575.083966]  [<ffffffff810e49cc>] kswapd+0x533/0x798
[  575.083976]  [<ffffffff810e4499>] ? mem_cgroup_shrink_node_zone+0xe3/0xe3
[  575.083986]  [<ffffffff8106e157>] kthread+0x84/0x8c
[  575.083998]  [<ffffffff81483564>] kernel_thread_helper+0x4/0x10
[  575.084010]  [<ffffffff8106e0d3>] ? kthread_worker_fn+0x148/0x148
[  575.084030]  [<ffffffff81483560>] ? gs_change+0x13/0x13
[  658.883363] BUG: soft lockup - CPU#2 stuck for 67s! [kswapd0:46]
[  658.883382] Modules linked in: netconsole configfs fuse sunrpc bluetooth cpufreq_ondemand acpi_cpufreq freq_table mperf ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables snd_hda_codec_hdmi snd_hda_codec_conexant arc4 snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device iwlagn snd_pcm uvcvideo videodev v4l2_compat_ioctl32 snd_timer iTCO_wdt mac80211 snd xhci_hcd i2c_i801 cfg80211 soundcore snd_page_alloc e1000e microcode iTCO_vendor_support wmi pcspkr joydev rfkill uinput ipv6 sdhci_pci sdhci mmc_core i915 drm_kms_helper drm i2c_algo_bit i2c_core video [last unloaded: scsi_wait_scan]
[  658.883574] CPU 2 
[  658.883579] Modules linked in: netconsole configfs fuse sunrpc bluetooth cpufreq_ondemand acpi_cpufreq freq_table mperf ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables snd_hda_codec_hdmi snd_hda_codec_conexant arc4 snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device iwlagn snd_pcm uvcvideo videodev v4l2_compat_ioctl32 snd_timer iTCO_wdt mac80211 snd xhci_hcd i2c_i801 cfg80211 soundcore snd_page_alloc e1000e microcode iTCO_vendor_support wmi pcspkr joydev rfkill uinput ipv6 sdhci_pci sdhci mmc_core i915 drm_kms_helper drm i2c_algo_bit i2c_core video [last unloaded: scsi_wait_scan]
[  658.883749] 
[  658.883757] Pid: 46, comm: kswapd0 Not tainted 2.6.39-rc4+ #6 LENOVO 4170CTO/4170CTO
[  658.883776] RIP: 0010:[<ffffffff81080bc0>]  [<ffffffff81080bc0>] arch_local_irq_restore+0xc/0xd
[  658.883797] RSP: 0018:ffff88006dfb7d98  EFLAGS: 00000246
[  658.883805] RAX: ffff8801005f9e68 RBX: ffff8801005e6e00 RCX: 0000000000004ae4
[  658.883813] RDX: ffff88006dfb8000 RSI: 0000000000000246 RDI: 0000000000000246
[  658.883821] RBP: ffff88006dfb7da0 R08: ffff8801005f9e70 R09: 00000000000007eb
[  658.883828] R10: 0000000000000000 R11: 00000000000000cd R12: ffffffff81482e0e
[  658.883835] R13: 0000000000016fd3 R14: 000000000000a731 R15: ffffffff810ddb31
[  658.883844] FS:  0000000000000000(0000) GS:ffff880100280000(0000) knlGS:0000000000000000
[  658.883853] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  658.883860] CR2: 00007f3934e8a000 CR3: 0000000001a03000 CR4: 00000000000406e0
[  658.883867] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  658.883875] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  658.883883] Process kswapd0 (pid: 46, threadinfo ffff88006dfb6000, task ffff88006dfb8000)
[  658.883890] Stack:
[  658.883895]  ffffffff8147bc8c ffff88006dfb7de0 ffffffff8106e7c3 ffff880000000002
[  658.883913]  0000000000000000 ffff8801005e6000 ffff8801005f9e68 0000000000000002
[  658.883929]  0000000000000000 ffff88006dfb7ee0 ffffffff810e45f0 0000000000000003
[  658.883947] Call Trace:
[  658.883961]  [<ffffffff8147bc8c>] ? _raw_spin_unlock_irqrestore+0x17/0x19
[  658.883976]  [<ffffffff8106e7c3>] prepare_to_wait+0x6c/0x78
[  658.883988]  [<ffffffff810e45f0>] kswapd+0x157/0x798
[  658.884000]  [<ffffffff8106e84e>] ? remove_wait_queue+0x3a/0x3a
[  658.884009]  [<ffffffff810e4499>] ? mem_cgroup_shrink_node_zone+0xe3/0xe3
[  658.884020]  [<ffffffff8106e157>] kthread+0x84/0x8c
[  658.884033]  [<ffffffff81483564>] kernel_thread_helper+0x4/0x10
[  658.884045]  [<ffffffff8106e0d3>] ? kthread_worker_fn+0x148/0x148
[  658.884057]  [<ffffffff81483560>] ? gs_change+0x13/0x13
[  658.884062] Code: 1f 44 00 00 66 ff 05 30 16 98 00 fb 66 0f 1f 44 00 00 5d c3 55 48 89 e5 0f 1f 44 00 00 5d c3 55 48 89 e5 57 9d 0f 1f 44 00 00 5d <c3> 55 48 89 e5 fa 66 0f 1f 44 00 00 5d c3 55 48 89 e5 50 9c 58 
[  658.884238] Call Trace:
[  658.884248]  [<ffffffff8147bc8c>] ? _raw_spin_unlock_irqrestore+0x17/0x19
[  658.884260]  [<ffffffff8106e7c3>] prepare_to_wait+0x6c/0x78
[  658.884269]  [<ffffffff810e45f0>] kswapd+0x157/0x798
[  658.884280]  [<ffffffff8106e84e>] ? remove_wait_queue+0x3a/0x3a
[  658.884289]  [<ffffffff810e4499>] ? mem_cgroup_shrink_node_zone+0xe3/0xe3
[  658.884299]  [<ffffffff8106e157>] kthread+0x84/0x8c
[  658.884311]  [<ffffffff81483564>] kernel_thread_helper+0x4/0x10
[  658.884322]  [<ffffffff8106e0d3>] ? kthread_worker_fn+0x148/0x148
[  658.884333]  [<ffffffff81483560>] ? gs_change+0x13/0x13
[  690.767137] SysRq : Show backtrace of all active CPUs
[  690.767158] sending NMI to all CPUs:
[  690.767171] NMI backtrace for cpu 2
[  690.767188] CPU 2 
[  690.767196] Modules linked in: netconsole configfs fuse sunrpc bluetooth cpufreq_ondemand acpi_cpufreq freq_table mperf ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables snd_hda_codec_hdmi snd_hda_codec_conexant arc4 snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device iwlagn snd_pcm uvcvideo videodev v4l2_compat_ioctl32 snd_timer iTCO_wdt mac80211 snd xhci_hcd i2c_i801 cfg80211 soundcore snd_page_alloc e1000e microcode iTCO_vendor_support wmi pcspkr joydev rfkill uinput ipv6 sdhci_pci sdhci mmc_core i915 drm_kms_helper drm i2c_algo_bit i2c_core video [last unloaded: scsi_wait_scan]
[  690.767457] 
[  690.767468] Pid: 46, comm: kswapd0 Not tainted 2.6.39-rc4+ #6 LENOVO 4170CTO/4170CTO
[  690.767493] RIP: 0010:[<ffffffff810e3980>]  [<ffffffff810e3980>] shrink_zone+0x221/0x4b3
[  690.767519] RSP: 0018:ffff88006dfb7d30  EFLAGS: 00000206
[  690.767529] RAX: 0000000000000000 RBX: ffff88006dfb7e58 RCX: 000000000000000c
[  690.767539] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000000
[  690.767550] RBP: ffff88006dfb7de0 R08: 0000000000000001 R09: 00000000000007eb
[  690.767561] R10: 0000000000000002 R11: 00000000000000f5 R12: ffff8801005e6000
[  690.767572] R13: ffff8801005e64d8 R14: 0000000000001572 R15: 00000000ffffffff
[  690.767584] FS:  0000000000000000(0000) GS:ffff880100280000(0000) knlGS:0000000000000000
[  690.767597] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  690.767607] CR2: 00007f3934e8a000 CR3: 0000000001a03000 CR4: 00000000000406e0
[  690.767618] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  690.767628] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  690.767640] Process kswapd0 (pid: 46, threadinfo ffff88006dfb6000, task ffff88006dfb8000)
[  690.767650] Stack:
[  690.767657]  0000000000000001 000000000000008c 000000000000003c 0000000000000000
[  690.767683]  ffffffffffffffff ffff8801005e6480 000000000000000c 0000000c81118591
[  690.767717]  0000000000000000 0000000000000000 ffff880100530380 0000000000000000
[  690.767742] Call Trace:
[  690.767764]  [<ffffffff810d9967>] ? zone_watermark_ok_safe+0xa1/0xae
[  690.767779]  [<ffffffff810e49a6>] kswapd+0x50d/0x798
[  690.767794]  [<ffffffff810e4499>] ? mem_cgroup_shrink_node_zone+0xe3/0xe3
[  690.767811]  [<ffffffff8106e157>] kthread+0x84/0x8c
[  690.767830]  [<ffffffff81483564>] kernel_thread_helper+0x4/0x10
[  690.767846]  [<ffffffff8106e0d3>] ? kthread_worker_fn+0x148/0x148
[  690.767861]  [<ffffffff81483560>] ? gs_change+0x13/0x13
[  690.767868] Code: e2 ff ff 83 7d 80 00 44 8b 85 50 ff ff ff 74 1b 8a 4d 8c 31 f6 41 83 ff 01 40 0f 96 c6 31 d2 48 d3 e8 48 0f af 44 f5 c0 49 f7 f6 
[  690.768028]  89 c1 48 8d 51 04 49 03 44 d5 00 48 83 f8 1f 49 89 44 d5 00 
[  690.768113] Call Trace:
[  690.768126]  [<ffffffff810d9967>] ? zone_watermark_ok_safe+0xa1/0xae
[  690.768139]  [<ffffffff810e49a6>] kswapd+0x50d/0x798
[  690.768154]  [<ffffffff810e4499>] ? mem_cgroup_shrink_node_zone+0xe3/0xe3
[  690.768168]  [<ffffffff8106e157>] kthread+0x84/0x8c
[  690.768183]  [<ffffffff81483564>] kernel_thread_helper+0x4/0x10
[  690.768199]  [<ffffffff8106e0d3>] ? kthread_worker_fn+0x148/0x148
[  690.768213]  [<ffffffff81483560>] ? gs_change+0x13/0x13
[  690.768223] NMI backtrace for cpu 3
[  690.768236] CPU 3 
[  690.768244] Modules linked in: netconsole configfs fuse sunrpc bluetooth cpufreq_ondemand acpi_cpufreq freq_table mperf ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables snd_hda_codec_hdmi snd_hda_codec_conexant arc4 snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device iwlagn snd_pcm uvcvideo videodev v4l2_compat_ioctl32 snd_timer iTCO_wdt mac80211 snd xhci_hcd i2c_i801 cfg80211 soundcore snd_page_alloc e1000e microcode iTCO_vendor_support wmi pcspkr joydev rfkill uinput ipv6 sdhci_pci sdhci mmc_core i915 drm_kms_helper drm i2c_algo_bit i2c_core video [last unloaded: scsi_wait_scan]
[  690.768832] 
[  690.768843] Pid: 0, comm: kworker/0:1 Not tainted 2.6.39-rc4+ #6 LENOVO 4170CTO/4170CTO
[  690.768867] RIP: 0010:[<ffffffff81275b36>]  [<ffffffff81275b36>] intel_idle+0xaa/0x100
[  690.768890] RSP: 0018:ffff8800715dfe68  EFLAGS: 00000046
[  690.768900] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  690.768912] RDX: 0000000000000000 RSI: ffff8800715dffd8 RDI: ffffffff81a0e640
[  690.768923] RBP: ffff8800715dfeb8 R08: 000000000000006d R09: 00000000000003c2
[  690.768934] R10: ffffffff00000003 R11: ffff8801002d3b40 R12: 0000000000000030
[  690.768946] R13: 12191803fa451798 R14: 0000000000000004 R15: 0000000000000003
[  690.768959] FS:  0000000000000000(0000) GS:ffff8801002c0000(0000) knlGS:0000000000000000
[  690.768971] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  690.768982] CR2: 0000000000429bf0 CR3: 0000000001a03000 CR4: 00000000000406e0
[  690.768993] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  690.769005] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  690.769017] Process kworker/0:1 (pid: 0, threadinfo ffff8800715de000, task ffff8800715e1700)
[  690.769027] Stack:
[  690.769034]  ffff8800715dfe88 ffffffff810731c0 ffff8801002d1280 0000000000011280
[  690.769063]  ffff8800715dfeb8 000000038139c77a ffffe8ffffcc0170 ffffe8ffffcc0170
[  690.769092]  ffffe8ffffcc0300 0000000000000000 ffff8800715dfef8 ffffffff8139b668
[  690.769121] Call Trace:
[  690.769137]  [<ffffffff810731c0>] ? pm_qos_request+0x3e/0x45
[  690.769153]  [<ffffffff8139b668>] cpuidle_idle_call+0xe7/0x166
[  690.769173]  [<ffffffff81008321>] cpu_idle+0xa5/0xdf
[  690.769191]  [<ffffffff8146ac57>] start_secondary+0x223/0x225
[  690.769203] Code: 28 e0 ff ff 80 e2 08 75 22 31 d2 48 83 c0 10 48 89 d1 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e0 0f 01 c9 <e8> 23 0b e0 ff 4c 29 e8 48 89 c7 e8 ab 2b de ff 4c 69 e0 40 42 
[  690.769477] Call Trace:
[  690.769491]  [<ffffffff810731c0>] ? pm_qos_request+0x3e/0x45
[  690.769506]  [<ffffffff8139b668>] cpuidle_idle_call+0xe7/0x166
[  690.769522]  [<ffffffff81008321>] cpu_idle+0xa5/0xdf
[  690.770451]  [<ffffffff810731c0>] ? pm_qos_request+0x3e/0x45
[  690.771380]  [<ffffffff81483f73>] ? smp_apic_timer_interrupt+0x7e/0x8c
[  692.887516] SysRq : Show Blocked State
[  692.887534]   task                        PC stack   pid father
[  692.887551] fsnotify_mark   D 0000000000000000     0    49      2 0x00000000
[  692.887567]  ffff88006dfb1cc0 0000000000000046 0000000000000000 0000000000000000
[  692.887585]  ffff88006dfbc500 ffff88006dfb1fd8 ffff88006dfb1fd8 0000000000013b40
[  692.887601]  ffff880071589700 ffff88006dfbc500 ffff88006dfb1cb0 000000010024f4c0
[  692.887618] Call Trace:
[  692.887635]  [<ffffffff8147aa4b>] schedule_timeout+0x34/0xde
[  692.887650]  [<ffffffff8104480b>] ? perf_event_task_sched_out+0x55/0x61
[  692.887662]  [<ffffffff8100eb84>] ? sched_clock+0x9/0xd
[  692.887673]  [<ffffffff810736dc>] ? sched_clock_cpu+0x42/0xc6
[  692.887683]  [<ffffffff8147a814>] wait_for_common+0xac/0x101
[  692.887692]  [<ffffffff8104c7af>] ? try_to_wake_up+0x226/0x226
[  692.887702]  [<ffffffff810ada0d>] ? synchronize_rcu_bh+0x5c/0x5c
[  692.887711]  [<ffffffff8147a91d>] wait_for_completion+0x1d/0x1f
[  692.887720]  [<ffffffff810ada67>] synchronize_sched+0x5a/0x5c
[  692.887730]  [<ffffffff8106bdb8>] ? find_ge_pid+0x43/0x43
[  692.887740]  [<ffffffff810726fc>] __synchronize_srcu+0x31/0x89
[  692.887751]  [<ffffffff81072780>] synchronize_srcu+0x15/0x17
[  692.887762]  [<ffffffff8114c8be>] fsnotify_mark_destroy+0x90/0x165
[  692.887774]  [<ffffffff8106e84e>] ? remove_wait_queue+0x3a/0x3a
[  692.887783]  [<ffffffff8114c82e>] ? fsnotify_put_mark+0x1c/0x1c
[  692.887793]  [<ffffffff8106e157>] kthread+0x84/0x8c
[  692.887806]  [<ffffffff81483564>] kernel_thread_helper+0x4/0x10
[  692.887818]  [<ffffffff8106e0d3>] ? kthread_worker_fn+0x148/0x148
[  692.887828]  [<ffffffff81483560>] ? gs_change+0x13/0x13
[  692.887840] jbd2/dm-1-8     D 0000000000000000     0   377      2 0x00000000
[  692.887854]  ffff88006d765cd0 0000000000000046 0000000000000000 0000000000000000
[  692.887871]  ffff88006d64dc00 ffff88006d765fd8 ffff88006d765fd8 0000000000013b40
[  692.887888]  ffff880071589700 ffff88006d64dc00 ffff88006d765cd0 000000018106e7c3
[  692.887905] Call Trace:
[  692.887917]  [<ffffffff811c8b44>] jbd2_journal_commit_transaction+0x1c4/0x1194
[  692.887928]  [<ffffffff8104480b>] ? perf_event_task_sched_out+0x55/0x61
[  692.887939]  [<ffffffff8100eb84>] ? sched_clock+0x9/0xd
[  692.887949]  [<ffffffff810736dc>] ? sched_clock_cpu+0x42/0xc6
[  692.887960]  [<ffffffff8100804e>] ? load_TLS+0x10/0x14
[  692.887971]  [<ffffffff81008714>] ? __switch_to+0xc6/0x220
[  692.887982]  [<ffffffff8106e84e>] ? remove_wait_queue+0x3a/0x3a
[  692.887992]  [<ffffffff8105ffef>] ? lock_timer_base+0x2c/0x52
[  692.888003]  [<ffffffff8147bc8c>] ? _raw_spin_unlock_irqrestore+0x17/0x19
[  692.888012]  [<ffffffff81060088>] ? try_to_del_timer_sync+0x73/0x81
[  692.888023]  [<ffffffff811cd1b6>] kjournald2+0xc9/0x20a
[  692.888033]  [<ffffffff8106e84e>] ? remove_wait_queue+0x3a/0x3a
[  692.888043]  [<ffffffff811cd0ed>] ? commit_timeout+0x10/0x10
[  692.888053]  [<ffffffff8106e157>] kthread+0x84/0x8c
[  692.888065]  [<ffffffff81483564>] kernel_thread_helper+0x4/0x10
[  692.888076]  [<ffffffff8106e0d3>] ? kthread_worker_fn+0x148/0x148
[  692.888087]  [<ffffffff81483560>] ? gs_change+0x13/0x13
[  692.888095] flush-253:1     D 0000000000000000     0   439      2 0x00000000
[  692.888117]  ffff88006d70f730 0000000000000046 ffff88006d70f6c0 ffffffff00000000
[  692.888135]  ffff880037b7ae00 ffff88006d70ffd8 ffff88006d70ffd8 0000000000013b40
[  692.888153]  ffff880071589700 ffff880037b7ae00 ffff8801002543c0 000000016d70f798
[  692.888170] Call Trace:
[  692.888180]  [<ffffffff8147a5c9>] io_schedule+0x63/0x7e
[  692.888190]  [<ffffffff81217900>] get_request_wait+0x102/0x18b
[  692.888200]  [<ffffffff8106e84e>] ? remove_wait_queue+0x3a/0x3a
[  692.888209]  [<ffffffff81218641>] __make_request+0x18a/0x2b8
[  692.888219]  [<ffffffff81217338>] generic_make_request+0x2a9/0x323
[  692.888227]  [<ffffffff81217490>] submit_bio+0xde/0xfd
[  692.888238]  [<ffffffff81199bd9>] ? ext4_bio_write_page+0x30d/0x320
[  692.888248]  [<ffffffff811998a0>] ext4_io_submit+0x2c/0x58
[  692.888257]  [<ffffffff81194b65>] mpage_da_submit_io+0x371/0x389
[  692.888267]  [<ffffffff8119527d>] ? ext4_mark_iloc_dirty+0x4db/0x543
[  692.888276]  [<ffffffff8119552d>] ? ext4_mark_inode_dirty+0x1c5/0x1f0
[  692.888287]  [<ffffffff8119850c>] mpage_da_map_and_submit+0x2b7/0x2cd
[  692.888298]  [<ffffffff811ab72a>] ? ext4_journal_start_sb+0x108/0x120
[  692.888308]  [<ffffffff81198be5>] ext4_da_writepages+0x2c1/0x44d
[  692.888319]  [<ffffffff810ddcb4>] do_writepages+0x21/0x2a
[  692.888331]  [<ffffffff8113c9b7>] writeback_single_inode+0xb2/0x1bc
[  692.888341]  [<ffffffff8113cd03>] writeback_sb_inodes+0xcd/0x161
[  692.888351]  [<ffffffff8113d207>] writeback_inodes_wb+0x119/0x12b
[  692.888361]  [<ffffffff8113d407>] wb_writeback+0x1ee/0x335
[  692.888371]  [<ffffffff810736dc>] ? sched_clock_cpu+0x42/0xc6
[  692.888381]  [<ffffffff810dd59a>] ? global_dirty_limits+0x2b/0xd1
[  692.888392]  [<ffffffff8113d6cd>] wb_do_writeback+0x17f/0x19d
[  692.888402]  [<ffffffff8113d773>] bdi_writeback_thread+0x88/0x1e5
[  692.888413]  [<ffffffff8113d6eb>] ? wb_do_writeback+0x19d/0x19d
[  692.888423]  [<ffffffff8106e157>] kthread+0x84/0x8c
[  692.888434]  [<ffffffff81483564>] kernel_thread_helper+0x4/0x10
[  692.888445]  [<ffffffff8106e0d3>] ? kthread_worker_fn+0x148/0x148
[  692.888455]  [<ffffffff81483560>] ? gs_change+0x13/0x13
[  692.888472] jbd2/dm-2-8     D ffff880071617380     0   791      2 0x00000000
[  692.888485]  ffff88006cfb1cd0 0000000000000046 0000000000000000 ffff880000000001
[  692.888501]  ffff88003769ae00 ffff88006cfb1fd8 ffff88006cfb1fd8 0000000000013b40
[  692.888517]  ffff880058cdc500 ffff88003769ae00 ffff88006cfb1cd0 000000018106e7c3
[  692.888533] Call Trace:
[  692.888547]  [<ffffffff811c8b44>] jbd2_journal_commit_transaction+0x1c4/0x1194
[  692.888559]  [<ffffffff8106e84e>] ? remove_wait_queue+0x3a/0x3a
[  692.888568]  [<ffffffff8105ffef>] ? lock_timer_base+0x2c/0x52
[  692.888578]  [<ffffffff8147bc8c>] ? _raw_spin_unlock_irqrestore+0x17/0x19
[  692.888587]  [<ffffffff81060088>] ? try_to_del_timer_sync+0x73/0x81
[  692.888597]  [<ffffffff811cd1b6>] kjournald2+0xc9/0x20a
[  692.888607]  [<ffffffff8106e84e>] ? remove_wait_queue+0x3a/0x3a
[  692.888617]  [<ffffffff811cd0ed>] ? commit_timeout+0x10/0x10
[  692.888627]  [<ffffffff8106e157>] kthread+0x84/0x8c
[  692.888637]  [<ffffffff81483564>] kernel_thread_helper+0x4/0x10
[  692.888648]  [<ffffffff8106e0d3>] ? kthread_worker_fn+0x148/0x148
[  692.888659]  [<ffffffff81483560>] ? gs_change+0x13/0x13
[  692.888665] NetworkManager  D 0000000000000000     0   809      1 0x00000000
[  692.888682]  ffff88006ff23ad8 0000000000000082 ffff880100293b40 0000000000000000
[  692.888697]  ffff88006cfe2e00 ffff88006ff23fd8 ffff88006ff23fd8 0000000000013b40
[  692.888713]  ffffffff81a0b020 ffff88006cfe2e00 ffff88006ff23ad8 000000018106e7c3
[  692.888729] Call Trace:
[  692.888738]  [<ffffffff811c6dd5>] start_this_handle+0x2e8/0x465
[  692.888753]  [<ffffffff8106e84e>] ? remove_wait_queue+0x3a/0x3a
[  692.888761]  [<ffffffff811c7218>] jbd2__journal_start+0x94/0xda
[  692.888770]  [<ffffffff811c7271>] jbd2_journal_start+0x13/0x15
[  692.888780]  [<ffffffff811ab72a>] ext4_journal_start_sb+0x108/0x120
[  692.888790]  [<ffffffff81044796>] ? delayacct_blkio_end+0x21/0x41
[  692.888799]  [<ffffffff8147a5df>] ? io_schedule+0x79/0x7e
[  692.888808]  [<ffffffff81198fb6>] ext4_dirty_inode+0x1d/0x4c
[  692.888818]  [<ffffffff8113c1d6>] __mark_inode_dirty+0x2f/0x175
[  692.888827]  [<ffffffff811320c7>] touch_atime+0x10e/0x131
[  692.888840]  [<ffffffff810d7160>] generic_file_aio_read+0x5d9/0x640
[  692.888851]  [<ffffffff8111ecaa>] do_sync_read+0xbf/0xff
[  692.888860]  [<ffffffff8103fd1f>] ? should_resched+0xe/0x2d
[  692.888872]  [<ffffffff811e9afe>] ? security_file_permission+0x2e/0x33
[  692.888884]  [<ffffffff8111ef96>] ? rw_verify_area+0xb0/0xcd
[  692.888894]  [<ffffffff8111f311>] vfs_read+0xa9/0xf0
[  692.888902]  [<ffffffff8111f3a2>] sys_read+0x4a/0x6e
[  692.888912]  [<ffffffff81482442>] system_call_fastpath+0x16/0x1b
[  692.888923] rs:main Q:Reg   D 0000000000000000     0   886      1 0x00000000
[  692.888935]  ffff88006ee35a38 0000000000000082 ffff88010028fa00 ffff880100000000
[  692.888950]  ffff88006ed5dc00 ffff88006ee35fd8 ffff88006ee35fd8 0000000000013b40
[  692.888966]  ffff880071589700 ffff88006ed5dc00 ffff88006ee35a38 000000018106e7c3
[  692.888986] Call Trace:
[  692.888994]  [<ffffffff811c6dd5>] start_this_handle+0x2e8/0x465
[  692.889005]  [<ffffffff8106e84e>] ? remove_wait_queue+0x3a/0x3a
[  692.889013]  [<ffffffff811c7218>] jbd2__journal_start+0x94/0xda
[  692.889022]  [<ffffffff811c7271>] jbd2_journal_start+0x13/0x15
[  692.889031]  [<ffffffff811ab72a>] ext4_journal_start_sb+0x108/0x120
[  692.889041]  [<ffffffff81198fb6>] ext4_dirty_inode+0x1d/0x4c
[  692.889050]  [<ffffffff8113c1d6>] __mark_inode_dirty+0x2f/0x175
[  692.889059]  [<ffffffff81131f95>] file_update_time+0xef/0x113
[  692.889070]  [<ffffffff810d69b8>] __generic_file_aio_write+0x15d/0x272
[  692.889086]  [<ffffffff8107cd0e>] ? futex_wait_queue_me+0xc4/0xe0
[  692.889099]  [<ffffffff810d6b2e>] generic_file_aio_write+0x61/0xba
[  692.889115]  [<ffffffff8118fc00>] ext4_file_write+0x1dc/0x234
[  692.889125]  [<ffffffff8111ebab>] do_sync_write+0xbf/0xff
[  692.889133]  [<ffffffff8114b810>] ? fsnotify+0x1ff/0x217
[  692.889144]  [<ffffffff811f1666>] ? selinux_file_permission+0x58/0xb4
[  692.889155]  [<ffffffff811e9afe>] ? security_file_permission+0x2e/0x33
[  692.889164]  [<ffffffff8111ef96>] ? rw_verify_area+0xb0/0xcd
[  692.889172]  [<ffffffff8111f221>] vfs_write+0xac/0xf3
[  692.889181]  [<ffffffff8111f410>] sys_write+0x4a/0x6e
[  692.889191]  [<ffffffff81482442>] system_call_fastpath+0x16/0x1b
[  692.889199] flush-253:2     D 0000000000000000     0   883      2 0x00000000
[  692.889211]  ffff88006ee736b0 0000000000000046 ffff88006ee73640 ffffffff00000000
[  692.889446]  ffff88006d5d9700 ffff88006ee73fd8 ffff88006ee73fd8 0000000000013b40
[  692.889462]  ffff880071589700 ffff88006d5d9700 ffff8801002543c0 000000016ee73718
[  692.889478] Call Trace:
[  692.889488]  [<ffffffff8147a5c9>] io_schedule+0x63/0x7e
[  692.889496]  [<ffffffff81217900>] get_request_wait+0x102/0x18b
[  692.889507]  [<ffffffff8106e84e>] ? remove_wait_queue+0x3a/0x3a
[  692.889516]  [<ffffffff81218641>] __make_request+0x18a/0x2b8
[  692.889525]  [<ffffffff81217338>] generic_make_request+0x2a9/0x323
[  692.889536]  [<ffffffff8147bd19>] ? _raw_read_unlock_irqrestore+0x17/0x19
[  692.889547]  [<ffffffff8138d520>] ? dm_target_exit+0x19/0x19
[  692.889555]  [<ffffffff81217490>] submit_bio+0xde/0xfd
[  692.889566]  [<ffffffff810ea4e1>] ? inc_zone_page_state+0x27/0x29
[  692.889576]  [<ffffffff810dc9fd>] ? account_page_writeback+0x25/0x29
[  692.889587]  [<ffffffff8122e200>] ? radix_tree_gang_lookup_slot+0x66/0x87
[  692.889597]  [<ffffffff811998a0>] ext4_io_submit+0x2c/0x58
[  692.889606]  [<ffffffff81199a48>] ext4_bio_write_page+0x17c/0x320
[  692.889616]  [<ffffffff810ea4a1>] ? mod_state+0x76/0x7d
[  692.889625]  [<ffffffff81194afa>] mpage_da_submit_io+0x306/0x389
[  692.889636]  [<ffffffff8119850c>] mpage_da_map_and_submit+0x2b7/0x2cd
[  692.889645]  [<ffffffff81198be5>] ext4_da_writepages+0x2c1/0x44d
[  692.889656]  [<ffffffff810ddcb4>] do_writepages+0x21/0x2a
[  692.889666]  [<ffffffff8113c9b7>] writeback_single_inode+0xb2/0x1bc
[  692.889677]  [<ffffffff8113cd03>] writeback_sb_inodes+0xcd/0x161
[  692.889687]  [<ffffffff8113d207>] writeback_inodes_wb+0x119/0x12b
[  692.889697]  [<ffffffff8113d407>] wb_writeback+0x1ee/0x335
[  692.889706]  [<ffffffff81080be3>] ? arch_local_irq_save+0x15/0x1b
[  692.889717]  [<ffffffff8147bc3a>] ? _raw_spin_lock_irqsave+0x12/0x2f
[  692.889727]  [<ffffffff810dd59a>] ? global_dirty_limits+0x2b/0xd1
[  692.889736]  [<ffffffff8113d6cd>] wb_do_writeback+0x17f/0x19d
[  692.889746]  [<ffffffff8147aac7>] ? schedule_timeout+0xb0/0xde
[  692.889756]  [<ffffffff8113d773>] bdi_writeback_thread+0x88/0x1e5
[  692.889766]  [<ffffffff8113d6eb>] ? wb_do_writeback+0x19d/0x19d
[  692.889776]  [<ffffffff8106e157>] kthread+0x84/0x8c
[  692.889787]  [<ffffffff81483564>] kernel_thread_helper+0x4/0x10
[  692.889798]  [<ffffffff8106e0d3>] ? kthread_worker_fn+0x148/0x148
[  692.889809]  [<ffffffff81483560>] ? gs_change+0x13/0x13
[  692.889815] abrt-dump-oops  D 0000000000000000     0   903    817 0x00000000
[  692.889827]  ffff88006eda1c78 0000000000000082 0000000000000005 0000000000000000
[  692.889843]  ffff880037698000 ffff88006eda1fd8 ffff88006eda1fd8 0000000000013b40
[  692.889860]  ffffffff81a0b020 ffff880037698000 ffff88006eda1c78 000000018106e7c3
[  692.889876] Call Trace:
[  692.889884]  [<ffffffff811c6dd5>] start_this_handle+0x2e8/0x465
[  692.889895]  [<ffffffff8106e84e>] ? remove_wait_queue+0x3a/0x3a
[  692.889904]  [<ffffffff811c7218>] jbd2__journal_start+0x94/0xda
[  692.889913]  [<ffffffff811c7271>] jbd2_journal_start+0x13/0x15
[  692.889923]  [<ffffffff811ab72a>] ext4_journal_start_sb+0x108/0x120
[  692.889934]  [<ffffffff8119ccaa>] ext4_mkdir+0xc9/0x33e
[  692.889944]  [<ffffffff811297a7>] vfs_mkdir+0x5f/0x9b
[  692.889954]  [<ffffffff8112b0ae>] sys_mkdirat+0x97/0xe8
[  692.889965]  [<ffffffff81122b89>] ? sys_newstat+0x2a/0x33
[  692.889975]  [<ffffffff8112b117>] sys_mkdir+0x18/0x1a
[  692.889984]  [<ffffffff81482442>] system_call_fastpath+0x16/0x1b
[  692.889998] Xorg            D 0000000000000000     0  1187   1183 0x00400084
[  692.890012]  ffff88007171ba38 0000000000000082 ffff8800177db2d8 ffff880000000000
[  692.890029]  ffff88006d581700 ffff88007171bfd8 ffff88007171bfd8 0000000000013b40
[  692.890046]  ffffffff81a0b020 ffff88006d581700 ffff88007171ba38
nc: Write error: No route to host
[  709.230547] SysRq : Show Blocked State
[  709.230567]   task                        PC stack   pid father
[  709.230584] fsnotify_mark   D 0000000000000000     0    49      2 0x00000000
[  709.230600]  ffff88006dfb1cc0 0000000000000046 0000000000000000 0000000000000000
[  709.230621]  ffff88006dfbc500 ffff88006dfb1fd8 ffff88006dfb1fd8 0000000000013b40
[  709.230638]  ffff880071589700 ffff88006dfbc500 ffff88006dfb1cb0 000000010024f4c0
[  709.230664] Call Trace:
[  709.230683]  [<ffffffff8147aa4b>] schedule_timeout+0x34/0xde
[  709.230697]  [<ffffffff8104480b>] ? perf_event_task_sched_out+0x55/0x61
[  709.230710]  [<ffffffff8100eb84>] ? sched_clock+0x9/0xd
[  709.230721]  [<ffffffff810736dc>] ? sched_clock_cpu+0x42/0xc6
[  709.230731]  [<ffffffff8147a814>] wait_for_common+0xac/0x101
[  709.230740]  [<ffffffff8104c7af>] ? try_to_wake_up+0x226/0x226
[  709.230751]  [<ffffffff810ada0d>] ? synchronize_rcu_bh+0x5c/0x5c
[  709.230761]  [<ffffffff8147a91d>] wait_for_completion+0x1d/0x1f
[  709.230769]  [<ffffffff810ada67>] synchronize_sched+0x5a/0x5c
[  709.230780]  [<ffffffff8106bdb8>] ? find_ge_pid+0x43/0x43
[  709.230790]  [<ffffffff810726fc>] __synchronize_srcu+0x31/0x89
[  709.230800]  [<ffffffff81072780>] synchronize_srcu+0x15/0x17
[  709.230810]  [<ffffffff8114c8be>] fsnotify_mark_destroy+0x90/0x165
[  709.230822]  [<ffffffff8106e84e>] ? remove_wait_queue+0x3a/0x3a
[  709.230831]  [<ffffffff8114c82e>] ? fsnotify_put_mark+0x1c/0x1c
[  709.230842]  [<ffffffff8106e157>] kthread+0x84/0x8c
[  709.230854]  [<ffffffff81483564>] kernel_thread_helper+0x4/0x10
[  709.230866]  [<ffffffff8106e0d3>] ? kthread_worker_fn+0x148/0x148
[  709.230876]  [<ffffffff81483560>] ? gs_change+0x13/0x13
[  709.230889] jbd2/dm-1-8     D 0000000000000000     0   377      2 0x00000000
[  709.230902]  ffff88006d765cd0 0000000000000046 0000000000000000 0000000000000000
[  709.230920]  ffff88006d64dc00 ffff88006d765fd8 ffff88006d765fd8 0000000000013b40
[  709.230937]  ffff880071589700 ffff88006d64dc00 ffff88006d765cd0 000000018106e7c3
[  709.230955] Call Trace:
[  709.230967]  [<ffffffff811c8b44>] jbd2_journal_commit_transaction+0x1c4/0x1194
[  709.230978]  [<ffffffff8104480b>] ? perf_event_task_sched_out+0x55/0x61
[  709.230989]  [<ffffffff8100eb84>] ? sched_clock+0x9/0xd
[  709.230999]  [<ffffffff810736dc>] ? sched_clock_cpu+0x42/0xc6
[  709.231011]  [<ffffffff8100804e>] ? load_TLS+0x10/0x14
[  709.231021]  [<ffffffff81008714>] ? __switch_to+0xc6/0x220
[  709.231033]  [<ffffffff8106e84e>] ? remove_wait_queue+0x3a/0x3a
[  709.231043]  [<ffffffff8105ffef>] ? lock_timer_base+0x2c/0x52
[  709.231055]  [<ffffffff8147bc8c>] ? _raw_spin_unlock_irqrestore+0x17/0x19
[  709.231064]  [<ffffffff81060088>] ? try_to_del_timer_sync+0x73/0x81
[  709.231075]  [<ffffffff811cd1b6>] kjournald2+0xc9/0x20a
[  709.231086]  [<ffffffff8106e84e>] ? remove_wait_queue+0x3a/0x3a
[  709.231096]  [<ffffffff811cd0ed>] ? commit_timeout+0x10/0x10
[  709.231106]  [<ffffffff8106e157>] kthread+0x84/0x8c
[  709.231117]  [<ffffffff81483564>] kernel_thread_helper+0x4/0x10
[  709.231129]  [<ffffffff8106e0d3>] ? kthread_worker_fn+0x148/0x148
[  709.231139]  [<ffffffff81483560>] ? gs_change+0x13/0x13
[  709.231147] flush-253:1     D 0000000000000000     0   439      2 0x00000000
[  709.231161]  ffff88006d70f730 0000000000000046 ffff88006d70f6c0 ffffffff00000000
[  709.231178]  ffff880037b7ae00 ffff88006d70ffd8 ffff88006d70ffd8 0000000000013b40
[  709.231195]  ffff880071589700 ffff880037b7ae00 ffff8801002543c0 000000016d70f798
[  709.231220] Call Trace:
[  709.231230]  [<ffffffff8147a5c9>] io_schedule+0x63/0x7e
[  709.231240]  [<ffffffff81217900>] get_request_wait+0x102/0x18b
[  709.231251]  [<ffffffff8106e84e>] ? remove_wait_queue+0x3a/0x3a
[  709.231260]  [<ffffffff81218641>] __make_request+0x18a/0x2b8
[  709.231270]  [<ffffffff81217338>] generic_make_request+0x2a9/0x323
[  709.231279]  [<ffffffff81217490>] submit_bio+0xde/0xfd
[  709.231290]  [<ffffffff81199bd9>] ? ext4_bio_write_page+0x30d/0x320
[  709.231300]  [<ffffffff811998a0>] ext4_io_submit+0x2c/0x58
[  709.231309]  [<ffffffff81194b65>] mpage_da_submit_io+0x371/0x389
[  709.231318]  [<ffffffff8119527d>] ? ext4_mark_iloc_dirty+0x4db/0x543
[  709.231328]  [<ffffffff8119552d>] ? ext4_mark_inode_dirty+0x1c5/0x1f0
[  709.231338]  [<ffffffff8119850c>] mpage_da_map_and_submit+0x2b7/0x2cd
[  709.231350]  [<ffffffff811ab72a>] ? ext4_journal_start_sb+0x108/0x120
[  709.231360]  [<ffffffff81198be5>] ext4_da_writepages+0x2c1/0x44d
[  709.231372]  [<ffffffff810ddcb4>] do_writepages+0x21/0x2a
[  709.231383]  [<ffffffff8113c9b7>] writeback_single_inode+0xb2/0x1bc
[  709.231393]  [<ffffffff8113cd03>] writeback_sb_inodes+0xcd/0x161
[  709.231404]  [<ffffffff8113d207>] writeback_inodes_wb+0x119/0x12b
[  709.231414]  [<ffffffff8113d407>] wb_writeback+0x1ee/0x335
[  709.231424]  [<ffffffff810736dc>] ? sched_clock_cpu+0x42/0xc6
[  709.231434]  [<ffffffff810dd59a>] ? global_dirty_limits+0x2b/0xd1
[  709.231445]  [<ffffffff8113d6cd>] wb_do_writeback+0x17f/0x19d
[  709.231455]  [<ffffffff8113d773>] bdi_writeback_thread+0x88/0x1e5
[  709.231465]  [<ffffffff8113d6eb>] ? wb_do_writeback+0x19d/0x19d
[  709.231475]  [<ffffffff8106e157>] kthread+0x84/0x8c
[  709.231486]  [<ffffffff81483564>] kernel_thread_helper+0x4/0x10
[  709.231497]  [<ffffffff8106e0d3>] ? kthread_worker_fn+0x148/0x148
[  709.231513]  [<ffffffff81483560>] ? gs_change+0x13/0x13
[  709.231521] jbd2/dm-2-8     D ffff880071617380     0   791      2 0x00000000
[  709.231534]  ffff88006cfb1cd0 0000000000000046 0000000000000000 ffff880000000001
[  709.231550]  ffff88003769ae00 ffff88006cfb1fd8 ffff88006cfb1fd8 0000000000013b40
[  709.231567]  ffff880058cdc500 ffff88003769ae00 ffff88006cfb1cd0 000000018106e7c3
[  709.231587] Call Trace:
[  709.231597]  [<ffffffff811c8b44>] jbd2_journal_commit_transaction+0x1c4/0x1194
[  709.231609]  [<ffffffff8106e84e>] ? remove_wait_queue+0x3a/0x3a
[  709.231618]  [<ffffffff8105ffef>] ? lock_timer_base+0x2c/0x52
[  709.231628]  [<ffffffff8147bc8c>] ? _raw_spin_unlock_irqrestore+0x17/0x19
[  709.231638]  [<ffffffff81060088>] ? try_to_del_timer_sync+0x73/0x81
[  709.231652]  [<ffffffff811cd1b6>] kjournald2+0xc9/0x20a
[  709.231664]  [<ffffffff8106e84e>] ? remove_wait_queue+0x3a/0x3a
[  709.231674]  [<ffffffff811cd0ed>] ? commit_timeout+0x10/0x10
[  709.231684]  [<ffffffff8106e157>] kthread+0x84/0x8c
[  709.231695]  [<ffffffff81483564>] kernel_thread_helper+0x4/0x10
[  709.231706]  [<ffffffff8106e0d3>] ? kthread_worker_fn+0x148/0x148
[  709.231716]  [<ffffffff81483560>] ? gs_change+0x13/0x13
[  709.231727] NetworkManager  D 0000000000000000     0   809      1 0x00000000
[  709.231739]  ffff88006ff23ad8 0000000000000082 ffff880100293b40 0000000000000000
[  709.231755]  ffff88006cfe2e00 ffff88006ff23fd8 ffff88006ff23fd8 0000000000013b40
[  709.231772]  ffffffff81a0b020 ffff88006cfe2e00 ffff88006ff23ad8 000000018106e7c3
[  709.231787] Call Trace:
[  709.231801]  [<ffffffff811c6dd5>] start_this_handle+0x2e8/0x465
[  709.231812]  [<ffffffff8106e84e>] ? remove_wait_queue+0x3a/0x3a
[  709.231821]  [<ffffffff811c7218>] jbd2__journal_start+0x94/0xda
[  709.231829]  [<ffffffff811c7271>] jbd2_journal_start+0x13/0x15
[  709.231839]  [<ffffffff811ab72a>] ext4_journal_start_sb+0x108/0x120
[  709.231850]  [<ffffffff81044796>] ? delayacct_blkio_end+0x21/0x41
[  709.231859]  [<ffffffff8147a5df>] ? io_schedule+0x79/0x7e
[  709.231868]  [<ffffffff81198fb6>] ext4_dirty_inode+0x1d/0x4c
[  709.231878]  [<ffffffff8113c1d6>] __mark_inode_dirty+0x2f/0x175
[  709.231887]  [<ffffffff811320c7>] touch_atime+0x10e/0x131
[  709.231899]  [<ffffffff810d7160>] generic_file_aio_read+0x5d9/0x640
[  709.231911]  [<ffffffff8111ecaa>] do_sync_read+0xbf/0xff
[  709.231919]  [<ffffffff8103fd1f>] ? should_resched+0xe/0x2d
[  709.231935]  [<ffffffff811e9afe>] ? security_file_permission+0x2e/0x33
[  709.231944]  [<ffffffff8111ef96>] ? rw_verify_area+0xb0/0xcd
[  709.231953]  [<ffffffff8111f311>] vfs_read+0xa9/0xf0
[  709.231962]  [<ffffffff8111f3a2>] sys_read+0x4a/0x6e
[  709.231972]  [<ffffffff81482442>] system_call_fastpath+0x16/0x1b
[  709.231983] rs:main Q:Reg   D 0000000000000000     0   886      1 0x00000000
[  709.231995]  ffff88006ee35a38 0000000000000082 ffff88010028fa00 ffff880100000000
[  709.232011]  ffff88006ed5dc00 ffff88006ee35fd8 ffff88006ee35fd8 0000000000013b40
[  709.232027]  ffff880071589700 ffff88006ed5dc00 ffff88006ee35a38 000000018106e7c3
[  709.232047] Call Trace:
[  709.232055]  [<ffffffff811c6dd5>] start_this_handle+0x2e8/0x465
[  709.232066]  [<ffffffff8106e84e>] ? remove_wait_queue+0x3a/0x3a
[  709.232075]  [<ffffffff811c7218>] jbd2__journal_start+0x94/0xda
[  709.232083]  [<ffffffff811c7271>] jbd2_journal_start+0x13/0x15
[  709.232093]  [<ffffffff811ab72a>] ext4_journal_start_sb+0x108/0x120
[  709.232102]  [<ffffffff81198fb6>] ext4_dirty_inode+0x1d/0x4c
[  709.232112]  [<ffffffff8113c1d6>] __mark_inode_dirty+0x2f/0x175
[  709.232121]  [<ffffffff81131f95>] file_update_time+0xef/0x113
[  709.232136]  [<ffffffff810d69b8>] __generic_file_aio_write+0x15d/0x272
[  709.232148]  [<ffffffff8107cd0e>] ? futex_wait_queue_me+0xc4/0xe0
[  709.232159]  [<ffffffff810d6b2e>] generic_file_aio_write+0x61/0xba
[  709.232171]  [<ffffffff8118fc00>] ext4_file_write+0x1dc/0x234
[  709.232181]  [<ffffffff8111ebab>] do_sync_write+0xbf/0xff
[  709.232189]  [<ffffffff8114b810>] ? fsnotify+0x1ff/0x217
[  709.232200]  [<ffffffff811f1666>] ? selinux_file_permission+0x58/0xb4
[  709.232210]  [<ffffffff811e9afe>] ? security_file_permission+0x2e/0x33
[  709.232219]  [<ffffffff8111ef96>] ? rw_verify_area+0xb0/0xcd
[  709.232228]  [<ffffffff8111f221>] vfs_write+0xac/0xf3
[  709.232237]  [<ffffffff8111f410>] sys_write+0x4a/0x6e
[  709.232246]  [<ffffffff81482442>] system_call_fastpath+0x16/0x1b
[  709.232255] flush-253:2     D 0000000000000000     0   883      2 0x00000000
[  709.232267]  ffff88006ee736b0 0000000000000046 ffff88006ee73640 ffffffff00000000
[  709.232500]  ffff88006d5d9700 ffff88006ee73fd8 ffff88006ee73fd8 0000000000013b40
[  709.232516]  ffff880071589700 ffff88006d5d9700 ffff8801002543c0 000000016ee73718
[  709.232532] Call Trace:
[  709.232542]  [<ffffffff8147a5c9>] io_schedule+0x63/0x7e
[  709.232550]  [<ffffffff81217900>] get_request_wait+0x102/0x18b
[  709.232561]  [<ffffffff8106e84e>] ? remove_wait_queue+0x3a/0x3a
[  709.232570]  [<ffffffff81218641>] __make_request+0x18a/0x2b8
[  709.232579]  [<ffffffff81217338>] generic_make_request+0x2a9/0x323
[  709.232589]  [<ffffffff8147bd19>] ? _raw_read_unlock_irqrestore+0x17/0x19
[  709.232601]  [<ffffffff8138d520>] ? dm_target_exit+0x19/0x19
[  709.232609]  [<ffffffff81217490>] submit_bio+0xde/0xfd
[  709.232620]  [<ffffffff810ea4e1>] ? inc_zone_page_state+0x27/0x29
[  709.232630]  [<ffffffff810dc9fd>] ? account_page_writeback+0x25/0x29
[  709.232641]  [<ffffffff8122e200>] ? radix_tree_gang_lookup_slot+0x66/0x87
[  709.232656]  [<ffffffff811998a0>] ext4_io_submit+0x2c/0x58
[  709.232666]  [<ffffffff81199a48>] ext4_bio_write_page+0x17c/0x320
[  709.232676]  [<ffffffff810ea4a1>] ? mod_state+0x76/0x7d
[  709.232685]  [<ffffffff81194afa>] mpage_da_submit_io+0x306/0x389
[  709.232696]  [<ffffffff8119850c>] mpage_da_map_and_submit+0x2b7/0x2cd
[  709.232706]  [<ffffffff81198be5>] ext4_da_writepages+0x2c1/0x44d
[  709.232716]  [<ffffffff810ddcb4>] do_writepages+0x21/0x2a
[  709.232728]  [<ffffffff8113c9b7>] writeback_single_inode+0xb2/0x1bc
[  709.232738]  [<ffffffff8113cd03>] writeback_sb_inodes+0xcd/0x161
[  709.232748]  [<ffffffff8113d207>] writeback_inodes_wb+0x119/0x12b
[  709.232758]  [<ffffffff8113d407>] wb_writeback+0x1ee/0x335
[  709.232768]  [<ffffffff81080be3>] ? arch_local_irq_save+0x15/0x1b
[  709.232779]  [<ffffffff8147bc3a>] ? _raw_spin_lock_irqsave+0x12/0x2f
[  709.232789]  [<ffffffff810dd59a>] ? global_dirty_limits+0x2b/0xd1
[  709.232799]  [<ffffffff8113d6cd>] wb_do_writeback+0x17f/0x19d
[  709.232808]  [<ffffffff8147aac7>] ? schedule_timeout+0xb0/0xde
[  709.232819]  [<ffffffff8113d773>] bdi_writeback_thread+0x88/0x1e5
[  709.232829]  [<ffffffff8113d6eb>] ? wb_do_writeback+0x19d/0x19d
[  709.232839]  [<ffffffff8106e157>] kthread+0x84/0x8c
[  709.232850]  [<ffffffff81483564>] kernel_thread_helper+0x4/0x10
[  709.232861]  [<ffffffff8106e0d3>] ? kthread_worker_fn+0x148/0x148
[  709.232872]  [<ffffffff81483560>] ? gs_change+0x13/0x13
[  709.232878] abrt-dump-oops  D 0000000000000000     0   903    817 0x00000000
[  709.232891]  ffff88006eda1c78 0000000000000082 0000000000000005 0000000000000000
[  709.232908]  ffff880037698000 ffff88006eda1fd8 ffff88006eda1fd8 0000000000013b40
[  709.232925]  ffffffff81a0b020 ffff880037698000 ffff88006eda1c78 000000018106e7c3
[  709.232942] Call Trace:
[  709.232951]  [<ffffffff811c6dd5>] start_this_handle+0x2e8/0x465
[  709.232962]  [<ffffffff8106e84e>] ? remove_wait_queue+0x3a/0x3a
[  709.232971]  [<ffffffff811c7218>] jbd2__journal_start+0x94/0xda
[  709.232979]  [<ffffffff811c7271>] jbd2_journal_start+0x13/0x15
[  709.232989]  [<ffffffff811ab72a>] ext4_journal_start_sb+0x108/0x120
[  709.233000]  [<ffffffff8119ccaa>] ext4_mkdir+0xc9/0x33e
[  709.233010]  [<ffffffff811297a7>] vfs_mkdir+0x5f/0x9b
[  709.233021]  [<ffffffff8112b0ae>] sys_mkdirat+0x97/0xe8
[  709.233032]  [<ffffffff81122b89>] ? sys_newstat+0x2a/0x33
[  709.233042]  [<ffffffff8112b117>] sys_mkdir+0x18/0x1a
[  709.233051]  [<ffffffff81482442>] system_call_fastpath+0x16/0x1b
[  709.233066] Xorg            D 0000000000000000     0  1187   1183 0x00400084
[  709.233080]  ffff88007171ba38 0000000000000082 ffff8800177db2d8 ffff880000000000
[  709.233097]  ffff88006d581700 ffff88007171bfd8 ffff88007171bfd8 0000000000013b40
[  709.233114]  ffffffff81a0b020 ffff88006d581700[  709.235257]  [<ffffffff8111ef96>] ? rw_verify_area+0xb0/0xcd
[  709.235532]   .MIN_vruntime                  : 0.000001
[  709.235656] 
[  709.236129]   .se->load.weight               : 2
[  709.236374]   .se->load.weight               : 2
[  709.236431] 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
