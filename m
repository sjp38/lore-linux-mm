Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7B3576B0011
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 13:21:49 -0400 (EDT)
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback
 related.
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <1303923177-sup-2603@think>
References: <1303920553.2583.7.camel@mulgrave.site>
	 <1303921583-sup-4021@think> <1303923000.2583.8.camel@mulgrave.site>
	 <1303923177-sup-2603@think>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 27 Apr 2011 12:21:42 -0500
Message-ID: <1303924902.2583.13.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Mason <chris.mason@oracle.com>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Wed, 2011-04-27 at 12:54 -0400, Chris Mason wrote:
> Ok, I'd try turning it on so we catch the sleeping with a spinlock held
> case better.

Will do, that's CONFIG_PREEMPT (rather than CONFIG_PREEMPT_VOLUNTARY)?

This is the trace with sysrq-l and sysrq-w

The repro this time doesn't have a soft lockup, just the tar is hung and
one of my CPUs is in 99% system.

James 

---


[  453.351255] SysRq : Show backtrace of all active CPUs
[  453.352601] sending NMI to all CPUs:
[  453.353849] NMI backtrace for cpu 3
[  453.355545] CPU 3 
[  453.355560] Modules linked in: netconsole configfs cpufreq_ondemand acpi_cpufreq freq_table mperf snd_hda_codec_hdmi snd_hda_codec_conexant arc4 snd_hda_intel snd_hda_codec iwlagn snd_hwdep snd_seq mac80211 snd_seq_device uvcvideo btusb cfg80211 bluetooth wmi e1000e snd_pcm videodev rfkill i2c_i801 microcode iTCO_wdt iTCO_vendor_support xhci_hcd snd_timer v4l2_compat_ioctl32 joydev pcspkr snd soundcore snd_page_alloc uinput ipv6 sdhci_pci sdhci mmc_core i915 drm_kms_helper drm i2c_algo_bit i2c_core video [last unloaded: scsi_wait_scan]
[  453.363188] 
[  453.365162] Pid: 46, comm: kswapd0 Not tainted 2.6.39-rc4+ #1 LENOVO 4170CTO/4170CTO
[  453.367133] RIP: 0010:[<ffffffff8147af8c>]  [<ffffffff8147af8c>] mutex_trylock+0x16/0x38
[  453.369122] RSP: 0018:ffff88006dfc1d40  EFLAGS: 00000246
[  453.371098] RAX: 0000000000000001 RBX: ffff880037de15f0 RCX: 0000000000000001
[  453.373099] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff880037875820
[  453.375097] RBP: ffff88006dfc1d40 R08: 0000000000000000 R09: 00000000000074ad
[  453.377079] R10: 0000000000000002 R11: ffffffff81a44e50 R12: 0000000000000000
[  453.379052] R13: 0000000000000000 R14: ffff880037875800 R15: ffff880037875820
[  453.381015] FS:  0000000000000000(0000) GS:ffff8801002c0000(0000) knlGS:0000000000000000
[  453.382985] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  453.384944] CR2: 00007fbf8ea8d090 CR3: 0000000001a03000 CR4: 00000000000406e0
[  453.386920] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  453.388887] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  453.390789] Process kswapd0 (pid: 46, threadinfo ffff88006dfc0000, task ffff88006dfb8000)
[  453.392649] Stack:
[  453.394473]  ffff88006dfc1d90 ffffffffa007ff52 ffff88006dfc1d90 ffffffff811613b5
[  453.396337]  ffff88006dfc1d60 ffff880037de15f0 0000000000000000 0000000000000000
[  453.398174]  00000000000000d0 000000000006366c ffff88006dfc1de0 ffffffff810e1f89
[  453.400015] Call Trace:
[  453.401845]  [<ffffffffa007ff52>] i915_gem_inactive_shrink+0x2f/0x194 [i915]
[  453.403702]  [<ffffffff811613b5>] ? mb_cache_shrink_fn+0x32/0xd0
[  453.405499]  [<ffffffff810e1f89>] shrink_slab+0x6d/0x166
[  453.407234]  [<ffffffff810e4bcc>] kswapd+0x533/0x798
[  453.408952]  [<ffffffff810e4699>] ? mem_cgroup_shrink_node_zone+0xe3/0xe3
[  453.410690]  [<ffffffff8106e157>] kthread+0x84/0x8c
[  453.412432]  [<ffffffff81483764>] kernel_thread_helper+0x4/0x10
[  453.414187]  [<ffffffff8106e0d3>] ? kthread_worker_fn+0x148/0x148
[  453.415945]  [<ffffffff81483760>] ? gs_change+0x13/0x13
[  453.417671] Code: 00 48 c7 47 18 00 00 00 00 f0 ff 07 7f 05 e8 ed 02 00 00 5d c3 55 48 89 e5 0f 1f 44 00 00 b9 01 00 00 00 31 d2 89 c8 f0 0f b1 17 
[  453.417905]  c1 31 c0 ff c9 75 18 65 48 8b 04 25 c8 cc 00 00 48 2d d8 1f 
[  453.421534] Call Trace:
[  453.423337]  [<ffffffffa007ff52>] i915_gem_inactive_shrink+0x2f/0x194 [i915]
[  453.425172]  [<ffffffff811613b5>] ? mb_cache_shrink_fn+0x32/0xd0
[  453.426997]  [<ffffffff810e1f89>] shrink_slab+0x6d/0x166
[  453.428818]  [<ffffffff810e4bcc>] kswapd+0x533/0x798
[  453.430639]  [<ffffffff810e4699>] ? mem_cgroup_shrink_node_zone+0xe3/0xe3
[  453.432485]  [<ffffffff8106e157>] kthread+0x84/0x8c
[  453.434298]  [<ffffffff81483764>] kernel_thread_helper+0x4/0x10
[  453.436112]  [<ffffffff8106e0d3>] ? kthread_worker_fn+0x148/0x148
[  453.437894]  [<ffffffff81483760>] ? gs_change+0x13/0x13
[  453.439654] NMI backtrace for cpu 2
[  453.441508] CPU 2 
[  453.441525] Modules linked in: netconsole configfs cpufreq_ondemand acpi_cpufreq freq_table mperf snd_hda_codec_hdmi snd_hda_codec_conexant arc4 snd_hda_intel snd_hda_codec iwlagn snd_hwdep snd_seq mac80211 snd_seq_device uvcvideo btusb cfg80211 bluetooth wmi e1000e snd_pcm videodev rfkill i2c_i801 microcode iTCO_wdt iTCO_vendor_support xhci_hcd snd_timer v4l2_compat_ioctl32 joydev pcspkr snd soundcore snd_page_alloc uinput ipv6 sdhci_pci sdhci mmc_core i915 drm_kms_helper drm i2c_algo_bit i2c_core video [last unloaded: scsi_wait_scan]
[  453.449517] 
[  453.451516] Pid: 0, comm: kworker/0:1 Not tainted 2.6.39-rc4+ #1 LENOVO 4170CTO/4170CTO
[  453.453704] RIP: 0010:[<ffffffff81275d36>]  [<ffffffff81275d36>] intel_idle+0xaa/0x100
[  453.455772] RSP: 0018:ffff8800715c9e68  EFLAGS: 00000046
[  453.457827] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
[  453.459903] RDX: 0000000000000000 RSI: ffff8800715c9fd8 RDI: ffffffff81a0e640
[  453.461999] RBP: ffff8800715c9eb8 R08: 000000000000006d R09: 00000000000003e5
[  453.464039] R10: ffffffff00000002 R11: ffff880100293b40 R12: 0000000000000030
[  453.466013] R13: 12187898d4512537 R14: 0000000000000004 R15: 0000000000000002
[  453.467918] FS:  0000000000000000(0000) GS:ffff880100280000(0000) knlGS:0000000000000000
[  453.469797] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  453.471644] CR2: 0000000000452630 CR3: 0000000001a03000 CR4: 00000000000406e0
[  453.473512] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  453.475356] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  453.477185] Process kworker/0:1 (pid: 0, threadinfo ffff8800715c8000, task ffff8800715a1700)
[  453.479024] Stack:
[  453.480855]  ffff8800715c9e88 ffffffff810731c0 ffff880100291290 0000000000011290
[  453.482739]  ffff8800715c9eb8 000000028139c97a ffffe8ffffc80170 ffffe8ffffc80170
[  453.484631]  ffffe8ffffc80300 0000000000000000 ffff8800715c9ef8 ffffffff8139b868
[  453.486518] Call Trace:
[  453.488365]  [<ffffffff810731c0>] ? pm_qos_request+0x3e/0x45
[  453.490226]  [<ffffffff8139b868>] cpuidle_idle_call+0xe7/0x166
[  453.492096]  [<ffffffff81008321>] cpu_idle+0xa5/0xdf
[  453.493947]  [<ffffffff8146ae57>] start_secondary+0x223/0x225
[  453.495791] Code: 28 e0 ff ff 80 e2 08 75 22 31 d2 48 83 c0 10 48 89 d1 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e0 0f 01 c9 <e8> 23 09 e0 ff 4c 29 e8 48 89 c7 e8 ab 29 de ff 4c 69 e0 40 42 
[  453.499958] Call Trace:
[  453.501895]  [<ffffffff810731c0>] ? pm_qos_request+0x3e/0x45
[  453.503837]  [<ffffffff8139b868>] cpuidle_idle_call+0xe7/0x166
[  453.505775]  [<ffffffff81008321>] cpu_idle+0xa5/0xdf
[  453.507687]  [<ffffffff8146ae57>] start_secondary+0x223/0x225
[  453.509598] NMI backtrace for cpu 1
[  453.511390] CPU 1 
[  453.511405] Modules linked in: netconsole configfs cpufreq_ondemand acpi_cpufreq freq_table mperf snd_hda_codec_hdmi snd_hda_codec_conexant arc4 snd_hda_intel snd_hda_codec iwlagn snd_hwdep snd_seq mac80211 snd_seq_device uvcvideo btusb cfg80211 bluetooth wmi e1000e snd_pcm videodev rfkill i2c_i801 microcode iTCO_wdt iTCO_vendor_support xhci_hcd snd_timer v4l2_compat_ioctl32 joydev pcspkr snd soundcore snd_page_alloc uinput ipv6 sdhci_pci sdhci mmc_core i915 drm_kms_helper drm i2c_algo_bit i2c_core video [last unloaded: scsi_wait_scan]
[  453.519288] 
[  453.521289] Pid: 0, comm: kworker/0:0 Not tainted 2.6.39-rc4+ #1 LENOVO 4170CTO/4170CTO
[  453.523353] RIP: 0010:[<ffffffff81275d36>]  [<ffffffff81275d36>] intel_idle+0xaa/0x100
[  453.525377] RSP: 0018:ffff880071587e68  EFLAGS: 00000046
[  453.527353] RAX: 0000000000000010 RBX: 0000000000000004 RCX: 0000000000000001
[  453.529332] RDX: 0000000000000000 RSI: ffff880071587fd8 RDI: ffffffff81a0e640
[  453.531303] RBP: ffff880071587eb8 R08: 00000000000004af R09: 00000000000003e5
[  453.533276] R10: ffffffff00000001 R11: ffff880100253b40 R12: 0000000000000010
[  453.535249] R13: 12187898d4512ee3 R14: 0000000000000002 R15: 0000000000000001
[  453.537229] FS:  0000000000000000(0000) GS:ffff880100240000(0000) knlGS:0000000000000000
[  453.539224] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  453.541210] CR2: 00000037d9071fa0 CR3: 0000000001a03000 CR4: 00000000000406e0
[  453.543220] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  453.545233] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  453.547239] Process kworker/0:0 (pid: 0, threadinfo ffff880071586000, task ffff880071589700)
[  453.549274] Stack:
[  453.551289]  ffff880071587e88 ffffffff810731c0 ffff880100251290 0000000000011290
[  453.553301]  ffff880071587eb8 000000018139c97a ffffe8ffffc40170 ffffe8ffffc40170
[  453.555257]  ffffe8ffffc40240 0000000000000000 ffff880071587ef8 ffffffff8139b868
[  453.557156] Call Trace:
[  453.558980]  [<ffffffff810731c0>] ? pm_qos_request+0x3e/0x45
[  453.560817]  [<ffffffff8139b868>] cpuidle_idle_call+0xe7/0x166
[  453.562635]  [<ffffffff81008321>] cpu_idle+0xa5/0xdf
[  453.564438]  [<ffffffff8146ae57>] start_secondary+0x223/0x225
[  453.566227] Code: 28 e0 ff ff 80 e2 08 75 22 31 d2 48 83 c0 10 48 89 d1 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e0 0f 01 c9 <e8> 23 09 e0 ff 4c 29 e8 48 89 c7 e8 ab 29 de ff 4c 69 e0 40 42 
[  453.570292] Call Trace:
[  453.572196]  [<ffffffff810731c0>] ? pm_qos_request+0x3e/0x45
[  453.574117]  [<ffffffff8139b868>] cpuidle_idle_call+0xe7/0x166
[  453.576031]  [<ffffffff81008321>] cpu_idle+0xa5/0xdf
[  453.577924]  [<ffffffff8146ae57>] start_secondary+0x223/0x225
[  453.579811] NMI backtrace for cpu 0
[  453.581279] CPU 0 
[  453.581289] Modules linked in: netconsole configfs cpufreq_ondemand acpi_cpufreq freq_table mperf snd_hda_codec_hdmi snd_hda_codec_conexant arc4 snd_hda_intel snd_hda_codec iwlagn snd_hwdep snd_seq mac80211 snd_seq_device uvcvideo btusb cfg80211 bluetooth wmi e1000e snd_pcm videodev rfkill i2c_i801 microcode iTCO_wdt iTCO_vendor_support xhci_hcd snd_timer v4l2_compat_ioctl32 joydev pcspkr snd soundcore snd_page_alloc uinput ipv6 sdhci_pci sdhci mmc_core i915 drm_kms_helper drm i2c_algo_bit i2c_core video [last unloaded: scsi_wait_scan]
[  453.587576] 
[  453.589160] Pid: 0, comm: swapper Not tainted 2.6.39-rc4+ #1 LENOVO 4170CTO/4170CTO
[  453.590777] RIP: 0010:[<ffffffff8100f0fa>]  [<ffffffff8100f0fa>] native_read_tsc+0x1/0x14
[  453.592390] RSP: 0018:ffff880100203b98  EFLAGS: 00000883
[  453.594001] RAX: 00000000f9ab6980 RBX: 0000000000002710 RCX: 0000000000000040
[  453.595624] RDX: 000000000026066c RSI: 0000000000000100 RDI: 000000000026066d
[  453.597250] RBP: ffff880100203ba8 R08: 000000008b000052 R09: 0000000000000000
[  453.598872] R10: 0000000000000000 R11: 0000000000000003 R12: 000000000026066d
[  453.600437] R13: 0000000000000000 R14: 0000000000000002 R15: 0000000000000001
[  453.601924] FS:  0000000000000000(0000) GS:ffff880100200000(0000) knlGS:0000000000000000
[  453.603434] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  453.604942] CR2: 0000000000440360 CR3: 0000000001a03000 CR4: 00000000000406f0
[  453.606460] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  453.607981] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  453.609597] Process swapper (pid: 0, threadinfo ffffffff81a00000, task ffffffff81a0b020)
[  453.611134] Stack:
[  453.612655]  ffff880100203ba8 ffffffff81232dfe ffff880100203bd8 ffffffff81232ecb
[  453.614176]  0000000000002710 0000000000000008 000000000000006c 0000000000000002
[  453.615656]  ffff880100203be8 ffffffff81232e49 ffff880100203bf8 ffffffff81232e77
[  453.617101] Call Trace:
[  453.618492]  <IRQ> 
[  453.619874]  [<ffffffff81232dfe>] ? paravirt_read_tsc+0xe/0x12
[  453.621251]  [<ffffffff81232ecb>] delay_tsc+0x27/0x74
[  453.622613]  [<ffffffff81232e49>] __delay+0xf/0x11
[  453.623973]  [<ffffffff81232e77>] __const_udelay+0x2c/0x2e
[  453.625322]  [<ffffffff8102166e>] arch_trigger_all_cpu_backtrace+0x76/0x88
[  453.626673]  [<ffffffff812be0ad>] sysrq_handle_showallcpus+0xe/0x10
[  453.628027]  [<ffffffff812be310>] __handle_sysrq+0xa2/0x13c
[  453.629372]  [<ffffffff812be514>] sysrq_filter+0x112/0x16e
[  453.630706]  [<ffffffff81365764>] input_pass_event+0x94/0xcc
[  453.632028]  [<ffffffff81366bf1>] input_handle_event+0x480/0x48f
[  453.633342]  [<ffffffff810483af>] ? walk_tg_tree.constprop.71+0x28/0x94
[  453.634655]  [<ffffffff81366cf2>] input_event+0x69/0x87
[  453.635978]  [<ffffffff8136c17b>] atkbd_interrupt+0x4c1/0x58e
[  453.637283]  [<ffffffff81361b2e>] serio_interrupt+0x45/0x7f
[  453.638563]  [<ffffffff81362870>] i8042_interrupt+0x299/0x2ab
[  453.639830]  [<ffffffff8100eb79>] ? native_sched_clock+0x34/0x36
[  453.641092]  [<ffffffff810a95d5>] handle_irq_event_percpu+0x5f/0x198
[  453.642354]  [<ffffffff810a9746>] handle_irq_event+0x38/0x56
[  453.643598]  [<ffffffff81022e0e>] ? ack_apic_edge+0x25/0x29
[  453.644832]  [<ffffffff810ab71a>] handle_edge_irq+0x9d/0xc0
[  453.646069]  [<ffffffff8100ab9d>] handle_irq+0x88/0x8e
[  453.647299]  [<ffffffff8148409d>] do_IRQ+0x4d/0xa5
[  453.648527]  [<ffffffff8147c253>] common_interrupt+0x13/0x13
[  453.649695]  <EOI> 
[  453.650794]  [<ffffffff8100e6cd>] ? paravirt_read_tsc+0x9/0xd
[  453.651911]  [<ffffffff81275d67>] ? intel_idle+0xdb/0x100
[  453.653025]  [<ffffffff81275d46>] ? intel_idle+0xba/0x100
[  453.654129]  [<ffffffff8139b868>] cpuidle_idle_call+0xe7/0x166
[  453.655231]  [<ffffffff81008321>] cpu_idle+0xa5/0xdf
[  453.656329]  [<ffffffff8145a91e>] rest_init+0x72/0x74
[  453.657417]  [<ffffffff81b59b9f>] start_kernel+0x3de/0x3e9
[  453.658514]  [<ffffffff81b592c4>] x86_64_start_reservations+0xaf/0xb3
[  453.659576]  [<ffffffff81b59140>] ? early_idt_handlers+0x140/0x140
[  453.660589]  [<ffffffff81b593ca>] x86_64_start_kernel+0x102/0x111
[  453.661559] Code: 21 00 00 e8 74 3d 22 00 5d c3 90 90 90 55 40 88 f8 48 89 e5 e6 70 e4 71 5d c3 55 40 88 f0 48 89 e5 e6 70 40 88 f8 e6 71 5d c3 55 
[  453.661721]  89 e5 0f 31 89 c1 48 89 d0 48 c1 e0 20 48 09 c8 5d c3 55 b2 
[  453.663728] Call Trace:
[  453.664713]  <IRQ>  [<ffffffff81232dfe>] ? paravirt_read_tsc+0xe/0x12
[  453.665710]  [<ffffffff81232ecb>] delay_tsc+0x27/0x74
[  453.666698]  [<ffffffff81232e49>] __delay+0xf/0x11
[  453.667686]  [<ffffffff81232e77>] __const_udelay+0x2c/0x2e
[  453.668675]  [<ffffffff8102166e>] arch_trigger_all_cpu_backtrace+0x76/0x88
[  453.669676]  [<ffffffff812be0ad>] sysrq_handle_showallcpus+0xe/0x10
[  453.670681]  [<ffffffff812be310>] __handle_sysrq+0xa2/0x13c
[  453.671676]  [<ffffffff812be514>] sysrq_filter+0x112/0x16e
[  453.672662]  [<ffffffff81365764>] input_pass_event+0x94/0xcc
[  453.673646]  [<ffffffff81366bf1>] input_handle_event+0x480/0x48f
[  453.674627]  [<ffffffff810483af>] ? walk_tg_tree.constprop.71+0x28/0x94
[  453.675614]  [<ffffffff81366cf2>] input_event+0x69/0x87
[  453.676587]  [<ffffffff8136c17b>] atkbd_interrupt+0x4c1/0x58e
[  453.677550]  [<ffffffff81361b2e>] serio_interrupt+0x45/0x7f
[  453.678498]  [<ffffffff81362870>] i8042_interrupt+0x299/0x2ab
[  453.679431]  [<ffffffff8100eb79>] ? native_sched_clock+0x34/0x36
[  453.680351]  [<ffffffff810a95d5>] handle_irq_event_percpu+0x5f/0x198
[  453.681270]  [<ffffffff810a9746>] handle_irq_event+0x38/0x56
[  453.682186]  [<ffffffff81022e0e>] ? ack_apic_edge+0x25/0x29
[  453.683100]  [<ffffffff810ab71a>] handle_edge_irq+0x9d/0xc0
[  453.684014]  [<ffffffff8100ab9d>] handle_irq+0x88/0x8e
[  453.684924]  [<ffffffff8148409d>] do_IRQ+0x4d/0xa5
[  453.685831]  [<ffffffff8147c253>] common_interrupt+0x13/0x13
[  453.686740]  <EOI>  [<ffffffff8100e6cd>] ? paravirt_read_tsc+0x9/0xd
[  453.687655]  [<ffffffff81275d67>] ? intel_idle+0xdb/0x100
[  453.688573]  [<ffffffff81275d46>] ? intel_idle+0xba/0x100
[  453.689480]  [<ffffffff8139b868>] cpuidle_idle_call+0xe7/0x166
[  453.690387]  [<ffffffff81008321>] cpu_idle+0xa5/0xdf
[  453.691293]  [<ffffffff8145a91e>] rest_init+0x72/0x74
[  453.692195]  [<ffffffff81b59b9f>] start_kernel+0x3de/0x3e9
[  453.693095]  [<ffffffff81b592c4>] x86_64_start_reservations+0xaf/0xb3
[  453.693996]  [<ffffffff81b59140>] ? early_idt_handlers+0x140/0x140
[  453.694905]  [<ffffffff81b593ca>] x86_64_start_kernel+0x102/0x111
[  454.680802] SysRq : Show Blocked State
[  454.683427]   task                        PC stack   pid father
[  454.686058] systemd         D 0000000000000000     0     1      0 0x00000000
[  454.688752]  ffff8801003bdcd8 0000000000000082 ffff8801003bdc88 ffffffff00000000
[  454.691491]  ffff880100370000 ffff8801003bdfd8 ffff8801003bdfd8 0000000000013b40
[  454.694228]  ffff8800715e1700 ffff880100370000 ffff8801003bdcb8 00000001811329db
[  454.696969] Call Trace:
[  454.699683]  [<ffffffff8147ac4b>] schedule_timeout+0x34/0xde
[  454.702447]  [<ffffffff810ad618>] ? __call_rcu+0x123/0x12c
[  454.705184]  [<ffffffff810ad64d>] ? call_rcu_sched+0x15/0x17
[  454.707906]  [<ffffffff8147aa14>] wait_for_common+0xac/0x101
[  454.710656]  [<ffffffff8104c7af>] ? try_to_wake_up+0x226/0x226
[  454.713445]  [<ffffffff8147ab1d>] wait_for_completion+0x1d/0x1f
[  454.716199]  [<ffffffff810ada5a>] synchronize_sched+0x5a/0x5c
[  454.718972]  [<ffffffff8106bdb8>] ? find_ge_pid+0x43/0x43
[  454.721766]  [<ffffffff81090d05>] cgroup_diput+0x37/0xe3
[  454.724562]  [<ffffffff81090cce>] ? parse_cgroupfs_options+0x353/0x353
[  454.727328]  [<ffffffff8112fc79>] dentry_kill+0xfa/0x121
[  454.730103]  [<ffffffff81130189>] dput+0xdd/0xea
[  454.732866]  [<ffffffff8112aa68>] do_rmdir+0xc6/0xfe
[  454.735481]  [<ffffffff8111dc78>] ? filp_close+0x6e/0x7a
[  454.737990]  [<ffffffff8112b32f>] sys_rmdir+0x16/0x18
[  454.740469]  [<ffffffff81482642>] system_call_fastpath+0x16/0x1b
[  454.742935] flush-253:2     D 0000000000000000     0   793      2 0x00000000
[  454.745425]  ffff88006355b710 0000000000000046 ffff88006355b6b0 ffffffff00000000
[  454.747955]  ffff880037ee9700 ffff88006355bfd8 ffff88006355bfd8 0000000000013b40
[  454.750506]  ffffffff81a0b020 ffff880037ee9700 ffff88006355b710 000000018106e7c3
[  454.753048] Call Trace:
[  454.755537]  [<ffffffff811c82b8>] do_get_write_access+0x1c6/0x38d
[  454.758071]  [<ffffffff8106e88b>] ? autoremove_wake_function+0x3d/0x3d
[  454.760644]  [<ffffffff811c8588>] jbd2_journal_get_write_access+0x2b/0x42
[  454.763206]  [<ffffffff8118ea4f>] ? ext4_read_block_bitmap+0x54/0x2d0
[  454.765770]  [<ffffffff811b5888>] __ext4_journal_get_write_access+0x58/0x66
[  454.768353]  [<ffffffff811b8dbe>] ext4_mb_mark_diskspace_used+0x70/0x2ae
[  454.770942]  [<ffffffff811bb10e>] ext4_mb_new_blocks+0x1c8/0x3c2
[  454.773501]  [<ffffffff811b4628>] ext4_ext_map_blocks+0x1961/0x1c04
[  454.776082]  [<ffffffff8122ed78>] ? radix_tree_gang_lookup_tag_slot+0x81/0xa2
[  454.778711]  [<ffffffff810d55f9>] ? find_get_pages_tag+0x3b/0xd6
[  454.781323]  [<ffffffff811967fa>] ext4_map_blocks+0x112/0x1e7
[  454.783894]  [<ffffffff811984e8>] mpage_da_map_and_submit+0x93/0x2cd
[  454.786491]  [<ffffffff81198de5>] ext4_da_writepages+0x2c1/0x44d
[  454.789090]  [<ffffffff810ddeb4>] do_writepages+0x21/0x2a
[  454.791703]  [<ffffffff8113cbb7>] writeback_single_inode+0xb2/0x1bc
[  454.794334]  [<ffffffff8113cf03>] writeback_sb_inodes+0xcd/0x161
[  454.796962]  [<ffffffff8113d407>] writeback_inodes_wb+0x119/0x12b
[  454.799582]  [<ffffffff8113d607>] wb_writeback+0x1ee/0x335
[  454.802204]  [<ffffffff81080be3>] ? arch_local_irq_save+0x15/0x1b
[  454.804803]  [<ffffffff8147be3a>] ? _raw_spin_lock_irqsave+0x12/0x2f
[  454.807427]  [<ffffffff8113d891>] wb_do_writeback+0x143/0x19d
[  454.810077]  [<ffffffff8147acc7>] ? schedule_timeout+0xb0/0xde
[  454.812776]  [<ffffffff8113d973>] bdi_writeback_thread+0x88/0x1e5
[  454.815464]  [<ffffffff8113d8eb>] ? wb_do_writeback+0x19d/0x19d
[  454.818129]  [<ffffffff8106e157>] kthread+0x84/0x8c
[  454.820808]  [<ffffffff81483764>] kernel_thread_helper+0x4/0x10
[  454.823452]  [<ffffffff8106e0d3>] ? kthread_worker_fn+0x148/0x148
[  454.826103]  [<ffffffff81483760>] ? gs_change+0x13/0x13
[  454.828711] jbd2/dm-2-8     D 0000000000000000     0   799      2 0x00000000
[  454.831390]  ffff88006d59db10 0000000000000046 ffff88006d59daa0 ffffffff00000000
[  454.834094]  ffff88006deb4500 ffff88006d59dfd8 ffff88006d59dfd8 0000000000013b40
[  454.836788]  ffffffff81a0b020 ffff88006deb4500 ffff88006d59dad0 000000016d59dad0
[  454.839453] Call Trace:
[  454.842098]  [<ffffffff810d5904>] ? lock_page+0x3e/0x3e
[  454.844738]  [<ffffffff810d5904>] ? lock_page+0x3e/0x3e
[  454.847303]  [<ffffffff8147a7c9>] io_schedule+0x63/0x7e
[  454.849877]  [<ffffffff810d5912>] sleep_on_page+0xe/0x12
[  454.852469]  [<ffffffff8147aea9>] __wait_on_bit+0x48/0x7b
[  454.855021]  [<ffffffff810d5a8c>] wait_on_page_bit+0x72/0x74
[  454.857583]  [<ffffffff8106e88b>] ? autoremove_wake_function+0x3d/0x3d
[  454.860171]  [<ffffffff810d5b6b>] filemap_fdatawait_range+0x84/0x163
[  454.862744]  [<ffffffff810d5c6e>] filemap_fdatawait+0x24/0x26
[  454.865299]  [<ffffffff811c94a2>] jbd2_journal_commit_transaction+0x922/0x1194
[  454.867892]  [<ffffffff81008714>] ? __switch_to+0xc6/0x220
[  454.870496]  [<ffffffff811cd3b6>] kjournald2+0xc9/0x20a
[  454.873103]  [<ffffffff8106e84e>] ? remove_wait_queue+0x3a/0x3a
[  454.875690]  [<ffffffff811cd2ed>] ? commit_timeout+0x10/0x10
[  454.878327]  [<ffffffff8106e157>] kthread+0x84/0x8c
[  454.880961]  [<ffffffff81483764>] kernel_thread_helper+0x4/0x10
[  454.883604]  [<ffffffff8106e0d3>] ? kthread_worker_fn+0x148/0x148
[  454.886262]  [<ffffffff81483760>] ? gs_change+0x13/0x13
[  454.888875] tar             D ffff88006e573af8     0   991    838 0x00000000
[  454.891546]  ffff880037f5b8a8 0000000000000086 ffff8801002a1d40 0000000000000282
[  454.894213]  ffff88006d644500 ffff880037f5bfd8 ffff880037f5bfd8 0000000000013b40
[  454.896889]  ffff8801002b4500 ffff88006d644500 ffff880037f5b8a8 ffffffff8106e7c3
[  454.899530] Call Trace:
[  454.902118]  [<ffffffff8106e7c3>] ? prepare_to_wait+0x6c/0x78
[  454.904724]  [<ffffffff811c82b8>] do_get_write_access+0x1c6/0x38d
[  454.907344]  [<ffffffff8106e88b>] ? autoremove_wake_function+0x3d/0x3d
[  454.909967]  [<ffffffff811991cc>] ? ext4_dirty_inode+0x33/0x4c
[  454.912574]  [<ffffffff811c8588>] jbd2_journal_get_write_access+0x2b/0x42
[  454.915192]  [<ffffffff811b5888>] __ext4_journal_get_write_access+0x58/0x66
[  454.917819]  [<ffffffff81195526>] ext4_reserve_inode_write+0x41/0x83
[  454.920459]  [<ffffffff811955e4>] ext4_mark_inode_dirty+0x7c/0x1f0
[  454.923070]  [<ffffffff811991cc>] ext4_dirty_inode+0x33/0x4c
[  454.925660]  [<ffffffff8113c3d6>] __mark_inode_dirty+0x2f/0x175
[  454.928247]  [<ffffffff81143a0d>] generic_write_end+0x6c/0x7e
[  454.930865]  [<ffffffff811983f6>] ext4_da_write_end+0x1a5/0x204
[  454.933454]  [<ffffffff810d5e9d>] generic_file_buffered_write+0x17e/0x23a
[  454.936062]  [<ffffffff810d6c9d>] __generic_file_aio_write+0x242/0x272
[  454.938648]  [<ffffffff810d6d2e>] generic_file_aio_write+0x61/0xba
[  454.941288]  [<ffffffff8118fe00>] ext4_file_write+0x1dc/0x234
[  454.943909]  [<ffffffff8111edab>] do_sync_write+0xbf/0xff
[  454.946501]  [<ffffffff8114b9fc>] ? fsnotify+0x1eb/0x217
[  454.949114]  [<ffffffff811f1866>] ? selinux_file_permission+0x58/0xb4
[  454.951736]  [<ffffffff811e9cfe>] ? security_file_permission+0x2e/0x33
[  454.954349]  [<ffffffff8111f196>] ? rw_verify_area+0xb0/0xcd
[  454.956943]  [<ffffffff8111f421>] vfs_write+0xac/0xf3
[  454.959530]  [<ffffffff8111f610>] sys_write+0x4a/0x6e
[  454.962129]  [<ffffffff81482642>] system_call_fastpath+0x16/0x1b
[  454.964732] dhclient-script D 0000000000000000     0  2856   2855 0x00000000
[  454.967360]  ffff88006e1f5b18 0000000000000082 ffff8800378da880 0000000000000000
[  454.970056]  ffff88006deb1700 ffff88006e1f5fd8 ffff88006e1f5fd8 0000000000013b40
[  454.972706]  ffff880071589700 ffff88006deb1700 ffff88006e1f5ad8 000000016e1f5ad8
[  454.975323] Call Trace:
[  454.977882]  [<ffffffff810d5916>] ? sleep_on_page+0x12/0x12
[  454.980477]  [<ffffffff8147a7c9>] io_schedule+0x63/0x7e
[  454.983063]  [<ffffffff810d5924>] sleep_on_page_killable+0xe/0x3b
[  454.985622]  [<ffffffff8147ad9b>] __wait_on_bit_lock+0x46/0x8f
[  454.988182]  [<ffffffff810d5819>] __lock_page_killable+0x66/0x68
[  454.990785]  [<ffffffff8106e88b>] ? autoremove_wake_function+0x3d/0x3d
[  454.993436]  [<ffffffff810d5859>] lock_page_killable+0x3e/0x43
[  454.996099]  [<ffffffff810d71ea>] generic_file_aio_read+0x463/0x640
[  454.998730]  [<ffffffff8111eeaa>] do_sync_read+0xbf/0xff
[  455.001383]  [<ffffffff811ebc34>] ? avc_has_perm+0x51/0x63
[  455.004012]  [<ffffffff811e9cfe>] ? security_file_permission+0x2e/0x33
[  455.006644]  [<ffffffff8111f196>] ? rw_verify_area+0xb0/0xcd
[  455.009289]  [<ffffffff8111f511>] vfs_read+0xa9/0xf0
[  455.011917]  [<ffffffff811233eb>] kernel_read+0x41/0x4f
[  455.014511]  [<ffffffff811234dd>] prepare_binprm+0xe4/0xe8
[  455.017094]  [<ffffffff81124d40>] do_execve+0x114/0x277
[  455.019678]  [<ffffffff8100ff91>] sys_execve+0x43/0x5a
[  455.022281]  [<ffffffff81482a9c>] stub_execve+0x6c/0xc0
[  455.024888] Sched Debug Version: v0.10, 2.6.39-rc4+ #1
[  455.027487] ktime                                   : 455879.226285
[  455.030142] sched_clk                               : 455024.886257
[  455.032786] cpu_clk                                 : 455024.886397
[  455.035352] jiffies                                 : 4295123185
[  455.037904] sched_clock_stable                      : 1
[  455.040413] 
[  455.042892] sysctl_sched
[  455.045306]   .sysctl_sched_latency                    : 18.000000
[  455.047775]   .sysctl_sched_min_granularity            : 2.250000
[  455.050206]   .sysctl_sched_wakeup_granularity         : 3.000000
[  455.052643]   .sysctl_sched_child_runs_first           : 0
[  455.055034]   .sysctl_sched_features                   : 7279
[  455.057423]   .sysctl_sched_tunable_scaling            : 1 (logaritmic)
[  455.059829] 
[  455.059830] cpu#0, 2491.994 MHz
[  455.064443]   .nr_running                    : 0
[  455.066757]   .load                          : 0
[  455.069054]   .nr_switches                   : 146510
[  455.071353]   .nr_load_updates               : 233084
[  455.073642]   .nr_uninterruptible            : 2
[  455.075894]   .next_balance                  : 4295.122831
[  455.078152]   .curr->pid                     : 0
[  455.080396]   .clock                         : 454680.481348
[  455.082634]   .cpu_load[0]                   : 0
[  455.084867]   .cpu_load[1]                   : 0
[  455.087065]   .cpu_load[2]                   : 0
[  455.089233]   .cpu_load[3]                   : 0
[  455.091390]   .cpu_load[4]                   : 0
[  455.093499]   .yld_count                     : 0
[  455.095605]   .sched_switch                  : 0
[  455.097667]   .sched_count                   : 149062
[  455.099765]   .sched_goidle                  : 62756
[  455.101781]   .avg_idle                      : 1000000
[  455.103807]   .ttwu_count                    : 77219
[  455.105958]   .ttwu_local                    : 74144
[  455.107957]   .bkl_count                     : 0
[  455.109914] 
[  455.109915] cfs_rq[0]:/
[  455.113642]   .exec_clock                    : 20017.048374
[  455.115515]   .MIN_vruntime                  : 0.000001
[  455.117353]   .min_vruntime                  : 28900.800090
[  455.119185]   .max_vruntime                  : 0.000001
[  455.121028]   .spread                        : 0.000000
[  455.122820]   .spread0                       : 0.000000
[  455.124581]   .nr_spread_over                : 54
[  455.126318]   .nr_running                    : 0
[  455.128045]   .load                          : 0
[  455.129743]   .load_avg                      : 0.000000
[  455.131414]   .load_period                   : 0.000000
[  455.133052]   .load_contrib                  : 0
[  455.134692]   .load_tg                       : 0
[  455.136305] 
[  455.136306] runnable tasks:
[  455.136307]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[  455.136310] ----------------------------------------------------------------------------------------------------------
[  455.142856] 
[  455.142857] cpu#1, 2491.994 MHz
[  455.146215]   .nr_running                    : 0
[  455.147931]   .load                          : 0
[  455.149648]   .nr_switches                   : 62175
[  455.151348]   .nr_load_updates               : 217324
[  455.153045]   .nr_uninterruptible            : 2
[  455.154747]   .next_balance                  : 4295.123306
[  455.156457]   .curr->pid                     : 0
[  455.158149]   .clock                         : 455157.364642
[  455.159867]   .cpu_load[0]                   : 0
[  455.161594]   .cpu_load[1]                   : 0
[  455.163283]   .cpu_load[2]                   : 0
[  455.164954]   .cpu_load[3]                   : 0
[  455.166575]   .cpu_load[4]                   : 0
[  455.168185]   .yld_count                     : 60
[  455.169791]   .sched_switch                  : 0
[  455.171401]   .sched_count                   : 62899
[  455.172984]   .sched_goidle                  : 27394
[  455.174580]   .avg_idle                      : 1000000
[  455.176171]   .ttwu_count                    : 30510
[  455.177739]   .ttwu_local                    : 25277
[  455.179292]   .bkl_count                     : 0
[  455.180882] 
[  455.180883] cfs_rq[1]:/
[  455.183954]   .exec_clock                    : 10655.021809
[  455.185550]   .MIN_vruntime                  : 0.000001
[  455.187141]   .min_vruntime                  : 19718.135550
[  455.188771]   .max_vruntime                  : 0.000001
[  455.190407]   .spread                        : 0.000000
[  455.192016]   .spread0                       : -9182.664540
[  455.193634]   .nr_spread_over                : 80
[  455.195242]   .nr_running                    : 0
[  455.196848]   .load                          : 0
[  455.198441]   .load_avg                      : 0.000000
[  455.200059]   .load_period                   : 0.000000
[  455.201654]   .load_contrib                  : 0
[  455.203240]   .load_tg                       : 0
[  455.204836] 
[  455.204837] runnable tasks:
[  455.204838]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[  455.204841] ----------------------------------------------------------------------------------------------------------
[  455.211403] 
[  455.211404] cpu#2, 2491.994 MHz
[  455.214958]   .nr_running                    : 0
[  455.216771]   .load                          : 0
[  455.218564]   .nr_switches                   : 37444
[  455.220394]   .nr_load_updates               : 219042
[  455.222202]   .nr_uninterruptible            : 0
[  455.224039]   .next_balance                  : 4295.123375
[  455.225897]   .curr->pid                     : 0
[  455.227769]   .clock                         : 455227.204963
[  455.229681]   .cpu_load[0]                   : 0
[  455.231548]   .cpu_load[1]                   : 0
[  455.233353]   .cpu_load[2]                   : 0
[  455.235059]   .cpu_load[3]                   : 0
[  455.236676]   .cpu_load[4]                   : 0
[  455.238280]   .yld_count                     : 0
[  455.239879]   .sched_switch                  : 0
[  455.241471]   .sched_count                   : 37815
[  455.243075]   .sched_goidle                  : 16831
[  455.244674]   .avg_idle                      : 1000000
[  455.246270]   .ttwu_count                    : 18348
[  455.247849]   .ttwu_local                    : 16899
[  455.249430]   .bkl_count                     : 0
[  455.250992] 
[  455.250993] cfs_rq[2]:/
[  455.254040]   .exec_clock                    : 6758.351942
[  455.255630]   .MIN_vruntime                  : 0.000001
[  455.257236]   .min_vruntime                  : 13719.942866
[  455.258861]   .max_vruntime                  : 0.000001
[  455.260497]   .spread                        : 0.000000
[  455.262122]   .spread0                       : -15180.857224
[  455.263753]   .nr_spread_over                : 21
[  455.265389]   .nr_running                    : 0
[  455.267018]   .load                          : 0
[  455.268637]   .load_avg                      : 0.000000
[  455.270292]   .load_period                   : 0.000000
[  455.271911]   .load_contrib                  : 0
[  455.273530]   .load_tg                       : 0
[  455.275163] 
[  455.275165] runnable tasks:
[  455.275166]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[  455.275169] ----------------------------------------------------------------------------------------------------------
[  455.281810] 
[  455.281811] cpu#3, 2491.994 MHz
[  455.285349]   .nr_running                    : 4
[  455.287149]   .load                          : 2048
[  455.288952]   .nr_switches                   : 30358
[  455.290787]   .nr_load_updates               : 223302
[  455.292599]   .nr_uninterruptible            : 1
[  455.294419]   .next_balance                  : 4295.123506
[  455.296250]   .curr->pid                     : 46
[  455.298090]   .clock                         : 431792.394314
[  455.299953]   .cpu_load[0]                   : 2048
[  455.301810]   .cpu_load[1]                   : 2048
[  455.303610]   .cpu_load[2]                   : 2048
[  455.305311]   .cpu_load[3]                   : 2048
[  455.306926]   .cpu_load[4]                   : 2048
[  455.308531]   .yld_count                     : 63
[  455.310130]   .sched_switch                  : 0
[  455.311723]   .sched_count                   : 30824
[  455.313315]   .sched_goidle                  : 13491
[  455.314904]   .avg_idle                      : 1000000
[  455.316481]   .ttwu_count                    : 13858
[  455.318057]   .ttwu_local                    : 12507
[  455.319629]   .bkl_count                     : 0
[  455.321187] 
[  455.321188] cfs_rq[3]:/
[  455.324213]   .exec_clock                    : 5334.144946
[  455.325795]   .MIN_vruntime                  : 13295.262803
[  455.327401]   .min_vruntime                  : 13302.523317
[  455.329046]   .max_vruntime                  : 13295.262803
[  455.330656]   .spread                        : 0.000000
[  455.332297]   .spread0                       : -15598.276773
[  455.333925]   .nr_spread_over                : 117
[  455.335577]   .nr_running                    : 2
[  455.337204]   .load                          : 2048
[  455.338823]   .load_avg                      : 0.000000
[  455.340476]   .load_period                   : 0.000000
[  455.342094]   .load_contrib                  : 0
[  455.343702]   .load_tg                       : 0
[  455.345302] 
[  455.345303] rt_rq[3]:/
[  455.348416]   .rt_nr_running                 : 1
[  455.350006]   .rt_throttled                  : 0
[  455.351587]   .rt_time                       : 0.000000
[  455.353173]   .rt_runtime                    : 950.000000
[  455.354759] 
[  455.354760] runnable tasks:
[  455.354761]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
[  455.354764] ----------------------------------------------------------------------------------------------------------
[  455.361357]      migration/3    17         0.000000      1084     0         0.000000         0.000933         0.000000 /
[  455.363278]       watchdog/3    20         0.000000        31     0         0.000000         0.780405         0.002351 /
[  455.365212] R        kswapd0    46     13302.523317       714   120     13302.523317      1148.767369    245855.504389 /
[  455.367220]      kworker/3:1    74     13295.262803     10488   120     13295.262803       324.924994    315669.659686 /
[  455.369317] 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
