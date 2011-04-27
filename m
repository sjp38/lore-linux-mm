Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 474636B0011
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 14:26:09 -0400 (EDT)
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback
 related.
From: Colin Ian King <colin.king@ubuntu.com>
In-Reply-To: <1303926637.2583.17.camel@mulgrave.site>
References: <1303920553.2583.7.camel@mulgrave.site>
	 <1303921583-sup-4021@think> <1303923000.2583.8.camel@mulgrave.site>
	 <1303923177-sup-2603@think> <1303924902.2583.13.camel@mulgrave.site>
	 <1303925374-sup-7968@think>  <1303926637.2583.17.camel@mulgrave.site>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 27 Apr 2011 19:25:52 +0100
Message-ID: <1303928753.2417.6.camel@lenovo>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

Hi,

Just like to add that I've seen almost identical issues with 2.6.38
copying large amounts of data to an ext4 filesystem with systems with
small amounts of memory.

I found that increasing /sys/fs/ext4/sdaX/max_writeback_mb_bump worked
around the issue.

Colin


On Wed, 2011-04-27 at 12:50 -0500, James Bottomley wrote:
> On Wed, 2011-04-27 at 13:34 -0400, Chris Mason wrote:
> > [ cc'd linux-ext4 ]
> > 
> > James is hitting softlockups in kswapd while doing writes to a large
> > ext4 file.
> > 
> > Excerpts from James Bottomley's message of 2011-04-27 13:21:42 -0400:
> > > On Wed, 2011-04-27 at 12:54 -0400, Chris Mason wrote:
> > > > Ok, I'd try turning it on so we catch the sleeping with a spinlock held
> > > > case better.
> > > 
> > > Will do, that's CONFIG_PREEMPT (rather than CONFIG_PREEMPT_VOLUNTARY)?
> > > 
> > > This is the trace with sysrq-l and sysrq-w
> > 
> > > 
> > > The repro this time doesn't have a soft lockup, just the tar is hung and
> > > one of my CPUs is in 99% system.
> > > [  454.742935] flush-253:2     D 0000000000000000     0   793      2 0x00000000
> > > [  454.745425]  ffff88006355b710 0000000000000046 ffff88006355b6b0 ffffffff00000000
> > > [  454.747955]  ffff880037ee9700 ffff88006355bfd8 ffff88006355bfd8 0000000000013b40
> > > [  454.750506]  ffffffff81a0b020 ffff880037ee9700 ffff88006355b710 000000018106e7c3
> > > [  454.753048] Call Trace:
> > > [  454.755537]  [<ffffffff811c82b8>] do_get_write_access+0x1c6/0x38d
> > > [  454.758071]  [<ffffffff8106e88b>] ? autoremove_wake_function+0x3d/0x3d
> > > [  454.760644]  [<ffffffff811c8588>] jbd2_journal_get_write_access+0x2b/0x42
> > > [  454.763206]  [<ffffffff8118ea4f>] ? ext4_read_block_bitmap+0x54/0x2d0
> > > [  454.765770]  [<ffffffff811b5888>] __ext4_journal_get_write_access+0x58/0x66
> > > [  454.768353]  [<ffffffff811b8dbe>] ext4_mb_mark_diskspace_used+0x70/0x2ae
> > > [  454.770942]  [<ffffffff811bb10e>] ext4_mb_new_blocks+0x1c8/0x3c2
> > > [  454.773501]  [<ffffffff811b4628>] ext4_ext_map_blocks+0x1961/0x1c04
> > > [  454.776082]  [<ffffffff8122ed78>] ? radix_tree_gang_lookup_tag_slot+0x81/0xa2
> > > [  454.778711]  [<ffffffff810d55f9>] ? find_get_pages_tag+0x3b/0xd6
> > > [  454.781323]  [<ffffffff811967fa>] ext4_map_blocks+0x112/0x1e7
> > > [  454.783894]  [<ffffffff811984e8>] mpage_da_map_and_submit+0x93/0x2cd
> > > [  454.786491]  [<ffffffff81198de5>] ext4_da_writepages+0x2c1/0x44d
> > > [  454.789090]  [<ffffffff810ddeb4>] do_writepages+0x21/0x2a
> > 
> > So our flusher threads are stuck waiting in
> > jbd2_journal_get_write_access, which means they aren't cleaning dirty
> > pages.
> > 
> > In order to get write access, they probably need the transaction to
> > commit:
> > 
> > > [  454.828711] jbd2/dm-2-8     D 0000000000000000     0   799      2 0x00000000
> > > [  454.831390]  ffff88006d59db10 0000000000000046 ffff88006d59daa0 ffffffff00000000
> > > [  454.834094]  ffff88006deb4500 ffff88006d59dfd8 ffff88006d59dfd8 0000000000013b40
> > > [  454.836788]  ffffffff81a0b020 ffff88006deb4500 ffff88006d59dad0 000000016d59dad0
> > > [  454.839453] Call Trace:
> > > [  454.842098]  [<ffffffff810d5904>] ? lock_page+0x3e/0x3e
> > > [  454.844738]  [<ffffffff810d5904>] ? lock_page+0x3e/0x3e
> > > [  454.847303]  [<ffffffff8147a7c9>] io_schedule+0x63/0x7e
> > > [  454.849877]  [<ffffffff810d5912>] sleep_on_page+0xe/0x12
> > > [  454.852469]  [<ffffffff8147aea9>] __wait_on_bit+0x48/0x7b
> > > [  454.855021]  [<ffffffff810d5a8c>] wait_on_page_bit+0x72/0x74
> > > [  454.857583]  [<ffffffff8106e88b>] ? autoremove_wake_function+0x3d/0x3d
> > > [  454.860171]  [<ffffffff810d5b6b>] filemap_fdatawait_range+0x84/0x163
> > > [  454.862744]  [<ffffffff810d5c6e>] filemap_fdatawait+0x24/0x26
> > > [  454.865299]  [<ffffffff811c94a2>] jbd2_journal_commit_transaction+0x922/0x1194
> > 
> > But that seems to be waiting for a page lock.  Probably the same page
> > lock held by the flusher thread?  Looks like tar is stuck in the same
> > boat down below.
> 
> To test the theory, Chris asked me to try with data=ordered.
> Unfortunately, the deadlock still shows up.  This is what I get.
> 
> James
> 
> ---
> 
> [  263.749738] BUG: soft lockup - CPU#2 stuck for 67s! [kswapd0:46]
> [  263.751207] Modules linked in: netconsole configfs cpufreq_ondemand acpi_cpufreq freq_table mperf snd_hda_codec_hdmi snd_hda_codec_conexant arc4 snd_hda_intel snd_hda_codec snd_hwdep iwlagn snd_seq snd_seq_device uvcvideo mac80211 e1000e btusb videodev snd_pcm v4l2_compat_ioctl32 snd_timer bluetooth i2c_i801 snd cfg80211 microcode iTCO_wdt xhci_hcd iTCO_vendor_support wmi pcspkr joydev soundcore snd_page_alloc rfkill uinput ipv6 sdhci_pci sdhci mmc_core i915 drm_kms_helper drm i2c_algo_bit i2c_core video [last unloaded: scsi_wait_scan]
> [  263.756081] CPU 2 
> [  263.756091] Modules linked in: netconsole configfs cpufreq_ondemand acpi_cpufreq freq_table mperf snd_hda_codec_hdmi snd_hda_codec_conexant arc4 snd_hda_intel snd_hda_codec snd_hwdep iwlagn snd_seq snd_seq_device uvcvideo mac80211 e1000e btusb videodev snd_pcm v4l2_compat_ioctl32 snd_timer bluetooth i2c_i801 snd cfg80211 microcode iTCO_wdt xhci_hcd iTCO_vendor_support wmi pcspkr joydev soundcore snd_page_alloc rfkill uinput ipv6 sdhci_pci sdhci mmc_core i915 drm_kms_helper drm i2c_algo_bit i2c_core video [last unloaded: scsi_wait_scan]
> [  263.763033] 
> [  263.764761] Pid: 46, comm: kswapd0 Not tainted 2.6.39-rc4+ #1 LENOVO 4170CTO/4170CTO
> [  263.766509] RIP: 0010:[<ffffffff810e1fa2>]  [<ffffffff810e1fa2>] shrink_slab+0x86/0x166
> [  263.768256] RSP: 0018:ffff8800709ebda0  EFLAGS: 00000206
> [  263.769976] RAX: 0000000000000000 RBX: ffff8800709ebde0 RCX: 0000000000000002
> [  263.771683] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffffffff81a44e50
> [  263.773378] RBP: ffff8800709ebde0 R08: 0000000000000000 R09: 000000000000a2b2
> [  263.775053] R10: 0000000000000002 R11: ffffffff81a44e50 R12: ffffffff8148300e
> [  263.776728] R13: ffff8800709ebe58 R14: 0000000000000004 R15: 00000000000178f9
> [  263.778408] FS:  0000000000000000(0000) GS:ffff880100280000(0000) knlGS:0000000000000000
> [  263.780098] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  263.781777] CR2: 0000000001091018 CR3: 0000000001a03000 CR4: 00000000000406e0
> [  263.783458] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [  263.785140] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [  263.786811] Process kswapd0 (pid: 46, threadinfo ffff8800709ea000, task ffff88006dfa8000)
> [  263.788491] Stack:
> [  263.790153]  000000000000003d 0000000000000080 ffff880000000000 ffff8801005e6700
> [  263.791810]  ffff8801005e6000 0000000000000002 0000000000000000 000000000000000c
> [  263.793426]  ffff8800709ebee0 ffffffff810e4bcc 0000000000000003 ffff88006dfa8000
> [  263.795038] Call Trace:
> [  263.796614]  [<ffffffff810e4bcc>] kswapd+0x533/0x798
> [  263.798183]  [<ffffffff810e4699>] ? mem_cgroup_shrink_node_zone+0xe3/0xe3
> [  263.799755]  [<ffffffff8106e157>] kthread+0x84/0x8c
> [  263.801328]  [<ffffffff81483764>] kernel_thread_helper+0x4/0x10
> [  263.802904]  [<ffffffff8106e0d3>] ? kthread_worker_fn+0x148/0x148
> [  263.804434]  [<ffffffff81483760>] ? gs_change+0x13/0x13
> [  263.805914] Code: 83 eb 10 e9 ce 00 00 00 44 89 f2 31 f6 48 89 df ff 13 48 63 4b 08 4c 63 e8 48 8b 45 c8 31 d2 48 f7 f1 31 d2 49 0f af c5 49 f7 f7 
> [  263.806080]  03 43 20 48 85 c0 48 89 43 20 79 18 48 8b 33 48 89 c2 48 c7 
> [  263.809185] Call Trace:
> [  263.810748]  [<ffffffff810e4bcc>] kswapd+0x533/0x798
> [  263.812327]  [<ffffffff810e4699>] ? mem_cgroup_shrink_node_zone+0xe3/0xe3
> [  263.813913]  [<ffffffff8106e157>] kthread+0x84/0x8c
> [  263.815486]  [<ffffffff81483764>] kernel_thread_helper+0x4/0x10
> [  263.817053]  [<ffffffff8106e0d3>] ? kthread_worker_fn+0x148/0x148
> [  263.818621]  [<ffffffff81483760>] ? gs_change+0x13/0x13
> [  272.421176] SysRq : Show backtrace of all active CPUs
> [  272.422748] sending NMI to all CPUs:
> [  272.424304] NMI backtrace for cpu 2
> [  272.426364] CPU 2 
> [  272.426380] Modules linked in: netconsole configfs cpufreq_ondemand acpi_cpufreq freq_table mperf snd_hda_codec_hdmi snd_hda_codec_conexant arc4 snd_hda_intel snd_hda_codec snd_hwdep iwlagn snd_seq snd_seq_device uvcvideo mac80211 e1000e btusb videodev snd_pcm v4l2_compat_ioctl32 snd_timer bluetooth i2c_i801 snd cfg80211 microcode iTCO_wdt xhci_hcd iTCO_vendor_support wmi pcspkr joydev soundcore snd_page_alloc rfkill uinput ipv6 sdhci_pci sdhci mmc_core i915 drm_kms_helper drm i2c_algo_bit i2c_core video [last unloaded: scsi_wait_scan]
> [  272.435128] 
> [  272.437299] Pid: 46, comm: kswapd0 Not tainted 2.6.39-rc4+ #1 LENOVO 4170CTO/4170CTO
> [  272.439506] RIP: 0010:[<ffffffff810d9b6e>]  [<ffffffff810d9b6e>] zone_watermark_ok_safe+0xa8/0xae
> [  272.441728] RSP: 0018:ffff8800709ebd80  EFLAGS: 00000282
> [  272.443916] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000000
> [  272.446101] RDX: 0000000000000813 RSI: 0000000000000000 RDI: ffff8801005e6000
> [  272.448258] RBP: ffff8800709ebd90 R08: 0000000000000000 R09: 00000000000007f0
> [  272.450362] R10: 0000000000000002 R11: 00000000000000cd R12: ffff8801005e6000
> [  272.452399] R13: 0000000000000000 R14: 0000000000000000 R15: ffff8801005e6000
> [  272.454367] FS:  0000000000000000(0000) GS:ffff880100280000(0000) knlGS:0000000000000000
> [  272.456306] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  272.458188] CR2: 0000000001091018 CR3: 0000000001a03000 CR4: 00000000000406e0
> [  272.460021] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [  272.461789] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [  272.463503] Process kswapd0 (pid: 46, threadinfo ffff8800709ea000, task ffff88006dfa8000)
> [  272.465234] Stack:
> [  272.466929]  0000000000000000 0000000000000000 ffff8800709ebde0 ffffffff810e1e8a
> [  272.468675]  ffff880000000002 ffffffff8106e701 ffff880000000002 ffff8801005e6000
> [  272.470406]  ffff8801005f9e68 0000000000000002 0000000000000000 0000000000000000
> [  272.472144] Call Trace:
> [  272.473850]  [<ffffffff810e1e8a>] sleeping_prematurely.part.11+0x6e/0xd2
> [  272.475582]  [<ffffffff8106e701>] ? prepare_to_wait_exclusive+0x67/0x77
> [  272.477304]  [<ffffffff810e47fe>] kswapd+0x165/0x798
> [  272.479015]  [<ffffffff8106e84e>] ? remove_wait_queue+0x3a/0x3a
> [  272.480712]  [<ffffffff810e4699>] ? mem_cgroup_shrink_node_zone+0xe3/0xe3
> [  272.482414]  [<ffffffff8106e157>] kthread+0x84/0x8c
> [  272.484106]  [<ffffffff81483764>] kernel_thread_helper+0x4/0x10
> [  272.485809]  [<ffffffff8106e0d3>] ? kthread_worker_fn+0x148/0x148
> [  272.487507]  [<ffffffff81483760>] ? gs_change+0x13/0x13
> [  272.489175] Code: a6 00 48 8b 55 d8 8b 4d d0 44 8b 45 c8 7c c0 45 31 c9 4d 85 ed 4d 0f 49 cd 44 89 e6 48 89 df e8 5e f4 ff ff 48 83 c4 20 5b 41 5c 
> [  272.489409]  5d 41 5e 5d c3 55 48 89 e5 0f 1f 44 00 00 bf da 00 02 00 e8 
> [  272.492911] Call Trace:
> [  272.494651]  [<ffffffff810e1e8a>] sleeping_prematurely.part.11+0x6e/0xd2
> [  272.496408]  [<ffffffff8106e701>] ? prepare_to_wait_exclusive+0x67/0x77
> [  272.498173]  [<ffffffff810e47fe>] kswapd+0x165/0x798
> [  272.499926]  [<ffffffff8106e84e>] ? remove_wait_queue+0x3a/0x3a
> [  272.501678]  [<ffffffff810e4699>] ? mem_cgroup_shrink_node_zone+0xe3/0xe3
> [  272.503444]  [<ffffffff8106e157>] kthread+0x84/0x8c
> [  272.505198]  [<ffffffff81483764>] kernel_thread_helper+0x4/0x10
> [  272.506968]  [<ffffffff8106e0d3>] ? kthread_worker_fn+0x148/0x148
> [  272.508691]  [<ffffffff81483760>] ? gs_change+0x13/0x13
> [  272.510355] NMI backtrace for cpu 1
> [  272.511996] CPU 1 
> [  272.512011] Modules linked in: netconsole configfs cpufreq_ondemand acpi_cpufreq freq_table mperf snd_hda_codec_hdmi snd_hda_codec_conexant arc4 snd_hda_intel snd_hda_codec snd_hwdep iwlagn snd_seq snd_seq_device uvcvideo mac80211 e1000e btusb videodev snd_pcm v4l2_compat_ioctl32 snd_timer bluetooth i2c_i801 snd cfg80211 microcode iTCO_wdt xhci_hcd iTCO_vendor_support wmi pcspkr joydev soundcore snd_page_alloc rfkill uinput ipv6 sdhci_pci sdhci mmc_core i915 drm_kms_helper drm i2c_algo_bit i2c_core video [last unloaded: scsi_wait_scan]
> [  272.519303] 
> [  272.521156] Pid: 0, comm: kworker/0:0 Not tainted 2.6.39-rc4+ #1 LENOVO 4170CTO/4170CTO
> [  272.523190] RIP: 0010:[<ffffffff81275d36>]  [<ffffffff81275d36>] intel_idle+0xaa/0x100
> [  272.525110] RSP: 0018:ffff880071587e68  EFLAGS: 00000046
> [  272.527018] RAX: 0000000000000010 RBX: 0000000000000004 RCX: 0000000000000001
> [  272.528960] RDX: 0000000000000000 RSI: ffff880071587fd8 RDI: ffffffff81a0e640
> [  272.530906] RBP: ffff880071587eb8 R08: 00000000000004af R09: 00000000000003e5
> [  272.532800] R10: ffffffff00000001 R11: ffff880100253b40 R12: 0000000000000010
> [  272.534634] R13: 12187a34a107f726 R14: 0000000000000002 R15: 0000000000000001
> [  272.536399] FS:  0000000000000000(0000) GS:ffff880100240000(0000) knlGS:0000000000000000
> [  272.538145] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  272.539879] CR2: 00000037da2830e4 CR3: 0000000001a03000 CR4: 00000000000406e0
> [  272.541614] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [  272.543329] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [  272.545026] Process kworker/0:0 (pid: 0, threadinfo ffff880071586000, task ffff880071589700)
> [  272.546756] Stack:
> [  272.548457]  ffff880071587e88 ffffffff810731c0 ffff880100251290 0000000000011290
> [  272.550225]  ffff880071587eb8 000000018139c97a ffffe8ffffc40170 ffffe8ffffc40170
> [  272.552009]  ffffe8ffffc40240 0000000000000000 ffff880071587ef8 ffffffff8139b868
> [  272.553780] Call Trace:
> [  272.555514]  [<ffffffff810731c0>] ? pm_qos_request+0x3e/0x45
> [  272.557259]  [<ffffffff8139b868>] cpuidle_idle_call+0xe7/0x166
> [  272.559005]  [<ffffffff81008321>] cpu_idle+0xa5/0xdf
> [  272.560755]  [<ffffffff8146ae57>] start_secondary+0x223/0x225
> [  272.562485] Code: 28 e0 ff ff 80 e2 08 75 22 31 d2 48 83 c0 10 48 89 d1 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e0 0f 01 c9 <e8> 23 09 e0 ff 4c 29 e8 48 89 c7 e8 ab 29 de ff 4c 69 e0 40 42 
> [  272.566380] Call Trace:
> [  272.568193]  [<ffffffff810731c0>] ? pm_qos_request+0x3e/0x45
> [  272.570031]  [<ffffffff8139b868>] cpuidle_idle_call+0xe7/0x166
> [  272.571855]  [<ffffffff81008321>] cpu_idle+0xa5/0xdf
> [  272.573658]  [<ffffffff8146ae57>] start_secondary+0x223/0x225
> [  272.575463] NMI backtrace for cpu 0
> [  272.576865] CPU 0 
> [  272.576875] Modules linked in: netconsole configfs cpufreq_ondemand acpi_cpufreq freq_table mperf snd_hda_codec_hdmi snd_hda_codec_conexant arc4 snd_hda_intel snd_hda_codec snd_hwdep iwlagn snd_seq snd_seq_device uvcvideo mac80211 e1000e btusb videodev snd_pcm v4l2_compat_ioctl32 snd_timer bluetooth i2c_i801 snd cfg80211 microcode iTCO_wdt xhci_hcd iTCO_vendor_support wmi pcspkr joydev soundcore snd_page_alloc rfkill uinput ipv6 sdhci_pci sdhci mmc_core i915 drm_kms_helper drm i2c_algo_bit i2c_core video [last unloaded: scsi_wait_scan]
> [  272.582932] 
> [  272.584474] Pid: 0, comm: swapper Not tainted 2.6.39-rc4+ #1 LENOVO 4170CTO/4170CTO
> [  272.586057] RIP: 0010:[<ffffffff81232e6e>]  [<ffffffff81232e6e>] __const_udelay+0x23/0x2e
> [  272.587604] RSP: 0018:ffff880100203bf8  EFLAGS: 00000887
> [  272.589120] RAX: 00000000fa1c3100 RBX: 0000000000002710 RCX: 0000000000000040
> [  272.590635] RDX: 000000000026074e RSI: 0000000000000100 RDI: 0000000000418958
> [  272.592139] RBP: ffff880100203bf8 R08: 000000008b000052 R09: 0000000000000000
> [  272.593644] R10: 0000000000000000 R11: 0000000000000003 R12: 0000000000000008
> [  272.595143] R13: 000000000000006c R14: 0000000000000002 R15: 0000000000000001
> [  272.596635] FS:  0000000000000000(0000) GS:ffff880100200000(0000) knlGS:0000000000000000
> [  272.598139] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  272.599637] CR2: 00000037d909e270 CR3: 000000006f2d7000 CR4: 00000000000406f0
> [  272.601151] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [  272.602669] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [  272.604187] Process swapper (pid: 0, threadinfo ffffffff81a00000, task ffffffff81a0b020)
> [  272.605715] Stack:
> [  272.607238]  ffff880100203c18 ffffffff8102166e 0000000000000000 ffffffff81a5e690
> [  272.608756]  ffff880100203c28 ffffffff812be0ad ffff880100203c68 ffffffff812be310
> [  272.610226]  ffff880037d01900 0000000000000026 ffff880037d01900 0000000000000001
> [  272.611653] Call Trace:
> [  272.613026]  <IRQ> 
> [  272.614388]  [<ffffffff8102166e>] arch_trigger_all_cpu_backtrace+0x76/0x88
> [  272.615761]  [<ffffffff812be0ad>] sysrq_handle_showallcpus+0xe/0x10
> [  272.617118]  [<ffffffff812be310>] __handle_sysrq+0xa2/0x13c
> [  272.618465]  [<ffffffff812be514>] sysrq_filter+0x112/0x16e
> [  272.619814]  [<ffffffff81365764>] input_pass_event+0x94/0xcc
> [  272.621158]  [<ffffffff81366bf1>] input_handle_event+0x480/0x48f
> [  272.622497]  [<ffffffff810483af>] ? walk_tg_tree.constprop.71+0x28/0x94
> [  272.623844]  [<ffffffff81366cf2>] input_event+0x69/0x87
> [  272.625172]  [<ffffffff8136c17b>] atkbd_interrupt+0x4c1/0x58e
> [  272.626489]  [<ffffffff81361b2e>] serio_interrupt+0x45/0x7f
> [  272.627791]  [<ffffffff81362870>] i8042_interrupt+0x299/0x2ab
> [  272.629085]  [<ffffffff8100eb79>] ? native_sched_clock+0x34/0x36
> [  272.630383]  [<ffffffff810a95d5>] handle_irq_event_percpu+0x5f/0x198
> [  272.631675]  [<ffffffff810a9746>] handle_irq_event+0x38/0x56
> [  272.632946]  [<ffffffff81022e0e>] ? ack_apic_edge+0x25/0x29
> [  272.634205]  [<ffffffff810ab71a>] handle_edge_irq+0x9d/0xc0
> [  272.635455]  [<ffffffff8100ab9d>] handle_irq+0x88/0x8e
> [  272.636699]  [<ffffffff8148409d>] do_IRQ+0x4d/0xa5
> [  272.637927]  [<ffffffff8147c253>] common_interrupt+0x13/0x13
> [  272.639155]  <EOI> 
> [  272.640374]  [<ffffffff8100e6cd>] ? paravirt_read_tsc+0x9/0xd
> [  272.641612]  [<ffffffff81275d67>] ? intel_idle+0xdb/0x100
> [  272.642840]  [<ffffffff81275d46>] ? intel_idle+0xba/0x100
> [  272.644012]  [<ffffffff8139b868>] cpuidle_idle_call+0xe7/0x166
> [  272.645115]  [<ffffffff81008321>] cpu_idle+0xa5/0xdf
> [  272.646215]  [<ffffffff8145a91e>] rest_init+0x72/0x74
> [  272.647313]  [<ffffffff81b59b9f>] start_kernel+0x3de/0x3e9
> [  272.648411]  [<ffffffff81b592c4>] x86_64_start_reservations+0xaf/0xb3
> [  272.649514]  [<ffffffff81b59140>] ? early_idt_handlers+0x140/0x140
> [  272.650624]  [<ffffffff81b593ca>] x86_64_start_kernel+0x102/0x111
> [  272.651725] Code: ff 15 37 2b 82 00 5d c3 55 48 89 e5 0f 1f 44 00 00 65 48 8b 14 25 98 3a 01 00 48 8d 04 bd 00 00 00 00 48 69 d2 fa 00 00 00 f7 e2 
> [  272.651891]  8d 7a 01 e8 c3 ff ff ff 5d c3 55 48 89 e5 0f 1f 44 00 00 48 
> [  272.654210] Call Trace:
> [  272.655298]  <IRQ>  [<ffffffff8102166e>] arch_trigger_all_cpu_backtrace+0x76/0x88
> [  272.656372]  [<ffffffff812be0ad>] sysrq_handle_showallcpus+0xe/0x10
> [  272.657421]  [<ffffffff812be310>] __handle_sysrq+0xa2/0x13c
> [  272.658456]  [<ffffffff812be514>] sysrq_filter+0x112/0x16e
> [  272.659480]  [<ffffffff81365764>] input_pass_event+0x94/0xcc
> [  272.660486]  [<ffffffff81366bf1>] input_handle_event+0x480/0x48f
> [  272.661487]  [<ffffffff810483af>] ? walk_tg_tree.constprop.71+0x28/0x94
> [  272.662497]  [<ffffffff81366cf2>] input_event+0x69/0x87
> [  272.663502]  [<ffffffff8136c17b>] atkbd_interrupt+0x4c1/0x58e
> [  272.664519]  [<ffffffff81361b2e>] serio_interrupt+0x45/0x7f
> [  272.665525]  [<ffffffff81362870>] i8042_interrupt+0x299/0x2ab
> [  272.666522]  [<ffffffff8100eb79>] ? native_sched_clock+0x34/0x36
> [  272.667509]  [<ffffffff810a95d5>] handle_irq_event_percpu+0x5f/0x198
> [  272.668492]  [<ffffffff810a9746>] handle_irq_event+0x38/0x56
> [  272.669467]  [<ffffffff81022e0e>] ? ack_apic_edge+0x25/0x29
> [  272.670445]  [<ffffffff810ab71a>] handle_edge_irq+0x9d/0xc0
> [  272.671408]  [<ffffffff8100ab9d>] handle_irq+0x88/0x8e
> [  272.672357]  [<ffffffff8148409d>] do_IRQ+0x4d/0xa5
> [  272.673284]  [<ffffffff8147c253>] common_interrupt+0x13/0x13
> [  272.674225]  <EOI>  [<ffffffff8100e6cd>] ? paravirt_read_tsc+0x9/0xd
> [  272.675166]  [<ffffffff81275d67>] ? intel_idle+0xdb/0x100
> [  272.676098]  [<ffffffff81275d46>] ? intel_idle+0xba/0x100
> [  272.677032]  [<ffffffff8139b868>] cpuidle_idle_call+0xe7/0x166
> [  272.677951]  [<ffffffff81008321>] cpu_idle+0xa5/0xdf
> [  272.678865]  [<ffffffff8145a91e>] rest_init+0x72/0x74
> [  272.679770]  [<ffffffff81b59b9f>] start_kernel+0x3de/0x3e9
> [  272.680685]  [<ffffffff81b592c4>] x86_64_start_reservations+0xaf/0xb3
> [  272.681603]  [<ffffffff81b59140>] ? early_idt_handlers+0x140/0x140
> [  272.682526]  [<ffffffff81b593ca>] x86_64_start_kernel+0x102/0x111
> [  272.683442] NMI backtrace for cpu 3
> [  272.684688] CPU 3 
> [  272.684705] Modules linked in: netconsole configfs cpufreq_ondemand acpi_cpufreq freq_table mperf snd_hda_codec_hdmi snd_hda_codec_conexant arc4 snd_hda_intel snd_hda_codec snd_hwdep iwlagn snd_seq snd_seq_device uvcvideo mac80211 e1000e btusb videodev snd_pcm v4l2_compat_ioctl32 snd_timer bluetooth i2c_i801 snd cfg80211 microcode iTCO_wdt xhci_hcd iTCO_vendor_support wmi pcspkr joydev soundcore snd_page_alloc rfkill uinput ipv6 sdhci_pci sdhci mmc_core i915 drm_kms_helper drm i2c_algo_bit i2c_core video [last unloaded: scsi_wait_scan]
> [  272.690650] 
> [  272.692143] Pid: 0, comm: kworker/0:1 Not tainted 2.6.39-rc4+ #1 LENOVO 4170CTO/4170CTO
> [  272.693726] RIP: 0010:[<ffffffff81275d36>]  [<ffffffff81275d36>] intel_idle+0xaa/0x100
> [  272.695312] RSP: 0018:ffff8800715dfe68  EFLAGS: 00000046
> [  272.696892] RAX: 0000000000000030 RBX: 0000000000000010 RCX: 0000000000000001
> [  272.698508] RDX: 0000000000000000 RSI: ffff8800715dffd8 RDI: ffffffff81a0e640
> [  272.700117] RBP: ffff8800715dfeb8 R08: 000000000000006d R09: 00000000000003e4
> [  272.701740] R10: ffffffff00000003 R11: ffff8801002d3b40 R12: 0000000000000030
> [  272.703369] R13: 12187a34a107edc5 R14: 0000000000000004 R15: 0000000000000003
> [  272.704985] FS:  0000000000000000(0000) GS:ffff8801002c0000(0000) knlGS:0000000000000000
> [  272.706626] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  272.708277] CR2: 00000037d904c480 CR3: 0000000001a03000 CR4: 00000000000406e0
> [  272.709952] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [  272.711633] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [  272.713299] Process kworker/0:1 (pid: 0, threadinfo ffff8800715de000, task ffff8800715e1700)
> [  272.715001] Stack:
> [  272.716681]  ffff8800715dfe88 ffffffff810731c0 ffff8801002d1290 0000000000011290
> [  272.718411]  ffff8800715dfeb8 000000038139c97a ffffe8ffffcc0170 ffffe8ffffcc0170
> [  272.720153]  ffffe8ffffcc0300 0000000000000000 ffff8800715dfef8 ffffffff8139b868
> [  272.721848] Call Trace:
> [  272.723465]  [<ffffffff810731c0>] ? pm_qos_request+0x3e/0x45
> [  272.725095]  [<ffffffff8139b868>] cpuidle_idle_call+0xe7/0x166
> [  272.726712]  [<ffffffff81008321>] cpu_idle+0xa5/0xdf
> [  272.728304]  [<ffffffff8146ae57>] start_secondary+0x223/0x225
> [  272.729891] Code: 28 e0 ff ff 80 e2 08 75 22 31 d2 48 83 c0 10 48 89 d1 0f 01 c8 0f ae f0 48 8b 86 38 e0 ff ff a8 08 75 08 b1 01 4c 89 e0 0f 01 c9 <e8> 23 09 e0 ff 4c 29 e8 48 89 c7 e8 ab 29 de ff 4c 69 e0 40 42 
> [  272.733594] Call Trace:
> [  272.735317]  [<ffffffff810731c0>] ? pm_qos_request+0x3e/0x45
> [  272.737068]  [<ffffffff8139b868>] cpuidle_idle_call+0xe7/0x166
> [  272.738815]  [<ffffffff81008321>] cpu_idle+0xa5/0xdf
> [  272.740554]  [<ffffffff8146ae57>] start_secondary+0x223/0x225
> [  274.865072] SysRq : Show Blocked State
> [  274.866350]   task                        PC stack   pid father
> [  274.867634] jbd2/dm-1-8     D 0000000000000000     0   363      2 0x00000000
> [  274.868930]  ffff880037d05ba0 0000000000000046 ffff880037d05b30 ffffffff00000000
> [  274.870242]  ffff880037acc500 ffff880037d05fd8 ffff880037d05fd8 0000000000013b40
> [  274.871555]  ffffffff81a0b020 ffff880037acc500 ffff8801002143c0 00000001005bd1d0
> [  274.872869] Call Trace:
> [  274.874168]  [<ffffffff81142202>] ? wait_on_buffer+0x3a/0x3a
> [  274.875485]  [<ffffffff81142202>] ? wait_on_buffer+0x3a/0x3a
> [  274.876791]  [<ffffffff8147a7c9>] io_schedule+0x63/0x7e
> [  274.878089]  [<ffffffff81142210>] sleep_on_buffer+0xe/0x12
> [  274.879382]  [<ffffffff8147aea9>] __wait_on_bit+0x48/0x7b
> [  274.880684]  [<ffffffff8147af4e>] out_of_line_wait_on_bit+0x72/0x7d
> [  274.881986]  [<ffffffff81142202>] ? wait_on_buffer+0x3a/0x3a
> [  274.883290]  [<ffffffff8106e88b>] ? autoremove_wake_function+0x3d/0x3d
> [  274.884601]  [<ffffffff811421c6>] __wait_on_buffer+0x26/0x28
> [  274.885912]  [<ffffffff811c8a3c>] wait_on_buffer+0x35/0x39
> [  274.887221]  [<ffffffff811c9633>] jbd2_journal_commit_transaction+0xab3/0x1194
> [  274.888547]  [<ffffffff81008714>] ? __switch_to+0xc6/0x220
> [  274.889864]  [<ffffffff81080be3>] ? arch_local_irq_save+0x15/0x1b
> [  274.891178]  [<ffffffff8147be3a>] ? _raw_spin_lock_irqsave+0x12/0x2f
> [  274.892500]  [<ffffffff8105ffef>] ? lock_timer_base+0x2c/0x52
> [  274.893776]  [<ffffffff811cd3b6>] kjournald2+0xc9/0x20a
> [  274.895001]  [<ffffffff8106e84e>] ? remove_wait_queue+0x3a/0x3a
> [  274.896179]  [<ffffffff811cd2ed>] ? commit_timeout+0x10/0x10
> [  274.897328]  [<ffffffff8106e157>] kthread+0x84/0x8c
> [  274.898465]  [<ffffffff81483764>] kernel_thread_helper+0x4/0x10
> [  274.899591]  [<ffffffff8106e0d3>] ? kthread_worker_fn+0x148/0x148
> [  274.900708]  [<ffffffff81483760>] ? gs_change+0x13/0x13
> [  274.901813] flush-253:1     D 0000000000000000     0   419      2 0x00000000
> [  274.902938]  ffff8800706bf760 0000000000000046 ffff8800706bf6f0 ffffffff00000000
> [  274.904067]  ffff880037afc500 ffff8800706bffd8 ffff8800706bffd8 0000000000013b40
> [  274.905198]  ffffffff81a0b020 ffff880037afc500 ffff8800706bf720 00000001706bf720
> [  274.906327] Call Trace:
> [  274.907430]  [<ffffffff8147a7c9>] io_schedule+0x63/0x7e
> [  274.908536]  [<ffffffff81217b00>] get_request_wait+0x102/0x18b
> [  274.909633]  [<ffffffff8106e84e>] ? remove_wait_queue+0x3a/0x3a
> [  274.910729]  [<ffffffff81218841>] __make_request+0x18a/0x2b8
> [  274.911826]  [<ffffffff81217538>] generic_make_request+0x2a9/0x323
> [  274.912908]  [<ffffffff810d79c9>] ? mempool_alloc_slab+0x15/0x17
> [  274.913979]  [<ffffffff81217690>] submit_bio+0xde/0xfd
> [  274.915040]  [<ffffffff81145fc0>] ? bio_alloc_bioset+0x4c/0xc3
> [  274.916104]  [<ffffffff810ea6e1>] ? inc_zone_page_state+0x27/0x29
> [  274.917161]  [<ffffffff81141c42>] submit_bh+0xe6/0x105
> [  274.918208]  [<ffffffff8114317e>] __block_write_full_page+0x1e7/0x2d7
> [  274.919261]  [<ffffffff81147540>] ? thaw_bdev+0x79/0x79
> [  274.920306]  [<ffffffff81144967>] ? bit_spin_lock.constprop.20+0x2c/0x2c
> [  274.921361]  [<ffffffff81144967>] ? bit_spin_lock.constprop.20+0x2c/0x2c
> [  274.922411]  [<ffffffff81147540>] ? thaw_bdev+0x79/0x79
> [  274.923396]  [<ffffffff81144851>] block_write_full_page_endio+0x8a/0x97
> [  274.924324]  [<ffffffff81144873>] block_write_full_page+0x15/0x17
> [  274.925248]  [<ffffffff81147297>] blkdev_writepage+0x18/0x1a
> [  274.926168]  [<ffffffff810dd3c1>] __writepage+0x15/0x2e
> [  274.927083]  [<ffffffff810dd1fc>] write_cache_pages+0x209/0x330
> [  274.928001]  [<ffffffff810dd3ac>] ? set_page_dirty_lock+0x33/0x33
> [  274.928923]  [<ffffffff8104e4c1>] ? find_busiest_group+0x253/0x8b9
> [  274.929834]  [<ffffffff81198ba9>] ? ext4_da_writepages+0x85/0x44d
> [  274.930744]  [<ffffffff810dd363>] generic_writepages+0x40/0x56
> [  274.931646]  [<ffffffff810ddeb4>] do_writepages+0x21/0x2a
> [  274.932536]  [<ffffffff8113cbb7>] writeback_single_inode+0xb2/0x1bc
> [  274.933430]  [<ffffffff8113cf03>] writeback_sb_inodes+0xcd/0x161
> [  274.934317]  [<ffffffff8113d407>] writeback_inodes_wb+0x119/0x12b
> [  274.935194]  [<ffffffff8113d607>] wb_writeback+0x1ee/0x335
> [  274.936061]  [<ffffffff81045c65>] ? hrtick_update+0x32/0x34
> [  274.936941]  [<ffffffff810dd79a>] ? global_dirty_limits+0x2b/0xd1
> [  274.936943]  [<ffffffff8113d8cd>] wb_do_writeback+0x17f/0x19d
> [  274.936945]  [<ffffffff8113d973>] bdi_writeback_thread+0x88/0x1e5
> [  274.936947]  [<ffffffff8113d8eb>] ? wb_do_writeback+0x19d/0x19d
> [  274.936949]  [<ffffffff8106e157>] kthread+0x84/0x8c
> [  274.936951]  [<ffffffff81483764>] kernel_thread_helper+0x4/0x10
> [  274.936953]  [<ffffffff8106e0d3>] ? kthread_worker_fn+0x148/0x148
> [  274.936956]  [<ffffffff81483760>] ? gs_change+0x13/0x13
> [  274.936958] jbd2/dm-2-8     D ffff88006e17c700     0   787      2 0x00000000
> [  274.936960]  ffff88006ffe5cd0 0000000000000046 0000000000000000 0000000000000000
> [  274.936962]  ffff88006f0e0000 ffff88006ffe5fd8 ffff88006ffe5fd8 0000000000013b40
> [  274.936964]  ffff8800715fc500 ffff88006f0e0000 ffff88006ffe5cd0 ffffffff8106e7c3
> [  274.936966] Call Trace:
> [  274.936968]  [<ffffffff8106e7c3>] ? prepare_to_wait+0x6c/0x78
> [  274.936970]  [<ffffffff811c8d44>] jbd2_journal_commit_transaction+0x1c4/0x1194
> [  274.936972]  [<ffffffff8104480b>] ? perf_event_task_sched_out+0x55/0x61
> [  274.936974]  [<ffffffff8100eb84>] ? sched_clock+0x9/0xd
> [  274.936977]  [<ffffffff810736dc>] ? sched_clock_cpu+0x42/0xc6
> [  274.936979]  [<ffffffff8100804e>] ? load_TLS+0x10/0x14
> [  274.936981]  [<ffffffff81008714>] ? __switch_to+0xc6/0x220
> [  274.936983]  [<ffffffff8106e84e>] ? remove_wait_queue+0x3a/0x3a
> [  274.936985]  [<ffffffff8105ffef>] ? lock_timer_base+0x2c/0x52
> [  274.936987]  [<ffffffff8147be8c>] ? _raw_spin_unlock_irqrestore+0x17/0x19
> [  274.936989]  [<ffffffff81060088>] ? try_to_del_timer_sync+0x73/0x81
> [  274.936991]  [<ffffffff811cd3b6>] kjournald2+0xc9/0x20a
> [  274.936993]  [<ffffffff8106e84e>] ? remove_wait_queue+0x3a/0x3a
> [  274.936995]  [<ffffffff811cd2ed>] ? commit_timeout+0x10/0x10
> [  274.936997]  [<ffffffff8106e157>] kthread+0x84/0x8c
> [  274.936998]  [<ffffffff81483764>] kernel_thread_helper+0x4/0x10
> [  274.937001]  [<ffffffff8106e0d3>] ? kthread_worker_fn+0x148/0x148
> [  274.937003]  [<ffffffff81483760>] ? gs_change+0x13/0x13
> [  274.937004] flush-253:2     D ffff88006d5a0000     0   851      2 0x00000000
> [  274.937006]  ffff88006e45d760 0000000000000046 ffff880037a30000 0000000000000246
> [  274.937008]  ffff88006d5a0000 ffff88006e45dfd8 ffff88006e45dfd8 0000000000013b40
> [  274.937010]  ffff880071588000 ffff88006d5a0000 ffff88006e45d720 ffff88006e45d720
> [  274.937011] Call Trace:
> [  274.937013]  [<ffffffff8147a7c9>] io_schedule+0x63/0x7e
> [  274.937015]  [<ffffffff81217b00>] get_request_wait+0x102/0x18b
> [  274.937017]  [<ffffffff8106e84e>] ? remove_wait_queue+0x3a/0x3a
> [  274.937019]  [<ffffffff81218841>] __make_request+0x18a/0x2b8
> [  274.937020]  [<ffffffff81217538>] generic_make_request+0x2a9/0x323
> [  274.937022]  [<ffffffff810d79c9>] ? mempool_alloc_slab+0x15/0x17
> [  274.937024]  [<ffffffff81217690>] submit_bio+0xde/0xfd
> [  274.937026]  [<ffffffff81145fc0>] ? bio_alloc_bioset+0x4c/0xc3
> [  274.937028]  [<ffffffff810ea6e1>] ? inc_zone_page_state+0x27/0x29
> [  274.937030]  [<ffffffff81141c42>] submit_bh+0xe6/0x105
> [  274.937031]  [<ffffffff8114317e>] __block_write_full_page+0x1e7/0x2d7
> [  274.937033]  [<ffffffff81147540>] ? thaw_bdev+0x79/0x79
> [  274.937035]  [<ffffffff81144967>] ? bit_spin_lock.constprop.20+0x2c/0x2c
> [  274.937037]  [<ffffffff81144967>] ? bit_spin_lock.constprop.20+0x2c/0x2c
> [  274.937039]  [<ffffffff81147540>] ? thaw_bdev+0x79/0x79
> [  274.937040]  [<ffffffff81144851>] block_write_full_page_endio+0x8a/0x97
> [  274.937042]  [<ffffffff81144873>] block_write_full_page+0x15/0x17
> [  274.937044]  [<ffffffff81147297>] blkdev_writepage+0x18/0x1a
> [  274.937046]  [<ffffffff810dd3c1>] __writepage+0x15/0x2e
> [  274.937048]  [<ffffffff810dd1fc>] write_cache_pages+0x209/0x330
> [  274.937049]  [<ffffffff810dd3ac>] ? set_page_dirty_lock+0x33/0x33
> [  274.937052]  [<ffffffff810dd363>] generic_writepages+0x40/0x56
> [  274.937054]  [<ffffffff810ddeb4>] do_writepages+0x21/0x2a
> [  274.937055]  [<ffffffff8113cbb7>] writeback_single_inode+0xb2/0x1bc
> [  274.937057]  [<ffffffff8113cf03>] writeback_sb_inodes+0xcd/0x161
> [  274.937059]  [<ffffffff8113d407>] writeback_inodes_wb+0x119/0x12b
> [  274.937061]  [<ffffffff8113d607>] wb_writeback+0x1ee/0x335
> [  274.937063]  [<ffffffff81080be3>] ? arch_local_irq_save+0x15/0x1b
> [  274.937065]  [<ffffffff8147be3a>] ? _raw_spin_lock_irqsave+0x12/0x2f
> [  274.937067]  [<ffffffff8113d891>] wb_do_writeback+0x143/0x19d
> [  274.937069]  [<ffffffff8147acc7>] ? schedule_timeout+0xb0/0xde
> [  274.937071]  [<ffffffff8113d973>] bdi_writeback_thread+0x88/0x1e5
> [  274.937073]  [<ffffffff8113d8eb>] ? wb_do_writeback+0x19d/0x19d
> [  274.937075]  [<ffffffff8106e157>] kthread+0x84/0x8c
> [  274.937077]  [<ffffffff81483764>] kernel_thread_helper+0x4/0x10
> [  274.937079]  [<ffffffff8106e0d3>] ? kthread_worker_fn+0x148/0x148
> [  274.937081]  [<ffffffff81483760>] ? gs_change+0x13/0x13
> [  274.937082] tar             D 0000000000000000     0   980    826 0x00000000
> [  274.937084]  ffff88006f19f9e8 0000000000000086 00000000ffff9fd7 0000000000000000
> [  274.937086]  ffff88006d670000 ffff88006f19ffd8 ffff88006f19ffd8 0000000000013b40
> [  274.937088]  ffffffff81a0b020 ffff88006d670000 ffff88006f19f9b8 0000000100000282
> [  274.937090] Call Trace:
> [  274.937091]  [<ffffffff8147acbe>] schedule_timeout+0xa7/0xde
> [  274.937093]  [<ffffffff8106015c>] ? del_timer+0x7a/0x7a
> [  274.937095]  [<ffffffff8147abc2>] io_schedule_timeout+0x6f/0x98
> [  274.937097]  [<ffffffff810ddc26>] balance_dirty_pages_ratelimited_nr+0x341/0x3b6
> [  274.937100]  [<ffffffff810d5efb>] generic_file_buffered_write+0x1dc/0x23a
> [  274.937102]  [<ffffffff810d6c9d>] __generic_file_aio_write+0x242/0x272
> [  274.937105]  [<ffffffff810d6d2e>] generic_file_aio_write+0x61/0xba
> [  274.937108]  [<ffffffff8118fe00>] ext4_file_write+0x1dc/0x234
> [  274.937111]  [<ffffffff8111edab>] do_sync_write+0xbf/0xff
> [  274.937112]  [<ffffffff8114b9fc>] ? fsnotify+0x1eb/0x217
> [  274.937115]  [<ffffffff811f1866>] ? selinux_file_permission+0x58/0xb4
> [  274.937118]  [<ffffffff811e9cfe>] ? security_file_permission+0x2e/0x33
> [  274.937120]  [<ffffffff8111f196>] ? rw_verify_area+0xb0/0xcd
> [  274.937122]  [<ffffffff8111f421>] vfs_write+0xac/0xf3
> [  274.937123]  [<ffffffff8111f610>] sys_write+0x4a/0x6e
> [  274.937126]  [<ffffffff81482642>] system_call_fastpath+0x16/0x1b
> [  274.937128] make            D 0000000000000000     0  2252   2143 0x00000004
> [  274.937130]  ffff88006d631948 0000000000000082 ffff88006d6318d8 ffffffff00000000
> [  274.937132]  ffff880037d9dc00 ffff88006d631fd8 ffff88006d631fd8 0000000000013b40
> [  274.937133]  ffffffff81a0b020 ffff880037d9dc00 ffff88006d631908 000000016d631908
> [  274.937135] Call Trace:
> [  274.937137]  [<ffffffff81142202>] ? wait_on_buffer+0x3a/0x3a
> [  274.937139]  [<ffffffff8147a7c9>] io_schedule+0x63/0x7e
> [  274.937140]  [<ffffffff81142210>] sleep_on_buffer+0xe/0x12
> [  274.937142]  [<ffffffff8147ad9b>] __wait_on_bit_lock+0x46/0x8f
> [  274.937144]  [<ffffffff8147ae56>] out_of_line_wait_on_bit_lock+0x72/0x7d
> [  274.937146]  [<ffffffff81142202>] ? wait_on_buffer+0x3a/0x3a
> [  274.937148]  [<ffffffff8106e88b>] ? autoremove_wake_function+0x3d/0x3d
> [  274.937149]  [<ffffffff8114240b>] __lock_buffer+0x38/0x3c
> [  274.937151]  [<ffffffff811c6ce9>] lock_buffer+0x39/0x3d
> [  274.937153]  [<ffffffff811c8162>] do_get_write_access+0x70/0x38d
> [  274.937155]  [<ffffffff811927b4>] ? __ext4_get_inode_loc+0x118/0x36d
> [  274.937156]  [<ffffffff811991cc>] ? ext4_dirty_inode+0x33/0x4c
> [  274.937158]  [<ffffffff811c8588>] jbd2_journal_get_write_access+0x2b/0x42
> [  274.937161]  [<ffffffff811b5888>] __ext4_journal_get_write_access+0x58/0x66
> [  274.937163]  [<ffffffff81195526>] ext4_reserve_inode_write+0x41/0x83
> [  274.937165]  [<ffffffff811955e4>] ext4_mark_inode_dirty+0x7c/0x1f0
> [  274.937167]  [<ffffffff8147c515>] ? page_fault+0x25/0x30
> [  274.937169]  [<ffffffff811991cc>] ext4_dirty_inode+0x33/0x4c
> [  274.937171]  [<ffffffff8113c3d6>] __mark_inode_dirty+0x2f/0x175
> [  274.937173]  [<ffffffff811322c7>] touch_atime+0x10e/0x131
> [  274.937176]  [<ffffffff810d7360>] generic_file_aio_read+0x5d9/0x640
> [  274.937178]  [<ffffffff8111eeaa>] do_sync_read+0xbf/0xff
> [  274.937180]  [<ffffffff811e9cfe>] ? security_file_permission+0x2e/0x33
> [  274.937181]  [<ffffffff8111f196>] ? rw_verify_area+0xb0/0xcd
> [  274.937183]  [<ffffffff8111f511>] vfs_read+0xa9/0xf0
> [  274.937185]  [<ffffffff8111f5a2>] sys_read+0x4a/0x6e
> [  274.937187]  [<ffffffff81482642>] system_call_fastpath+0x16/0x1b
> [  274.937188] make            D 0000000000000000     0  2262   2254 0x00000004
> [  274.937190]  ffff880070b2b948 0000000000000082 ffff880070b2b8d8 ffffffff00000000
> [  274.937192]  ffff88006d428000 ffff880070b2bfd8 ffff880070b2bfd8 0000000000013b40
> [  274.937194]  ffffffff81a0b020 ffff88006d428000 ffff880070b2b908 0000000170b2b908
> [  274.937195] Call Trace:
> [  274.937197]  [<ffffffff81142202>] ? wait_on_buffer+0x3a/0x3a
> [  274.937199]  [<ffffffff8147a7c9>] io_schedule+0x63/0x7e
> [  274.937200]  [<ffffffff81142210>] sleep_on_buffer+0xe/0x12
> [  274.937202]  [<ffffffff8147ad9b>] __wait_on_bit_lock+0x46/0x8f
> [  274.937204]  [<ffffffff8147ae56>] out_of_line_wait_on_bit_lock+0x72/0x7d
> [  274.937205]  [<ffffffff81142202>] ? wait_on_buffer+0x3a/0x3a
> [  274.937208]  [<ffffffff8106e88b>] ? autoremove_wake_function+0x3d/0x3d
> [  274.937209]  [<ffffffff8114240b>] __lock_buffer+0x38/0x3c
> [  274.937211]  [<ffffffff811c6ce9>] lock_buffer+0x39/0x3d
> [  274.937212]  [<ffffffff811c8162>] do_get_write_access+0x70/0x38d
> [  274.937214]  [<ffffffff811927b4>] ? __ext4_get_inode_loc+0x118/0x36d
> [  274.937216]  [<ffffffff811991cc>] ? ext4_dirty_inode+0x33/0x4c
> [  274.937217]  [<ffffffff811c8588>] jbd2_journal_get_write_access+0x2b/0x42
> [  274.937219]  [<ffffffff811b5888>] __ext4_journal_get_write_access+0x58/0x66
> [  274.937221]  [<ffffffff81195526>] ext4_reserve_inode_write+0x41/0x83
> [  274.937223]  [<ffffffff811955e4>] ext4_mark_inode_dirty+0x7c/0x1f0
> [  274.937225]  [<ffffffff8147c515>] ? page_fault+0x25/0x30
> [  274.937227]  [<ffffffff811991cc>] ext4_dirty_inode+0x33/0x4c
> [  274.937228]  [<ffffffff8113c3d6>] __mark_inode_dirty+0x2f/0x175
> [  274.937230]  [<ffffffff811322c7>] touch_atime+0x10e/0x131
> [  274.937232]  [<ffffffff810d7360>] generic_file_aio_read+0x5d9/0x640
> [  274.937234]  [<ffffffff8111eeaa>] do_sync_read+0xbf/0xff
> [  274.937236]  [<ffffffff811e9cfe>] ? security_file_permission+0x2e/0x33
> [  274.937238]  [<ffffffff8111f196>] ? rw_verify_area+0xb0/0xcd
> [  274.937240]  [<ffffffff8111f511>] vfs_read+0xa9/0xf0
> [  274.937241]  [<ffffffff8111f5a2>] sys_read+0x4a/0x6e
> [  274.937243]  [<ffffffff81482642>] system_call_fastpath+0x16/0x1b
> [  274.937244] sh              D 0000000000000000     0  2270   2253 0x00000004
> [  274.937246]  ffff8800709fd918 0000000000000086 ffff8800709fd8a8 ffffffff00000000
> [  274.937248]  ffff880037f60000 ffff8800709fdfd8 ffff8800709fdfd8 0000000000013b40
> [  274.937250]  ffff880071589700 ffff880037f60000 ffff8801002543c0 00000001005b89d0
> [  274.937252] Call Trace:
> [  274.937253]  [<ffffffff81142202>] ? wait_on_buffer+0x3a/0x3a
> [  274.937255]  [<ffffffff8147a7c9>] io_schedule+0x63/0x7e
> [  274.937256]  [<ffffffff81142210>] sleep_on_buffer+0xe/0x12
> [  274.937258]  [<ffffffff8147ad9b>] __wait_on_bit_lock+0x46/0x8f
> [  274.937260]  [<ffffffff8147ae56>] out_of_line_wait_on_bit_lock+0x72/0x7d
> [  274.937261]  [<ffffffff81142202>] ? wait_on_buffer+0x3a/0x3a
> [  274.937264]  [<ffffffff8106e88b>] ? autoremove_wake_function+0x3d/0x3d
> [  274.937265]  [<ffffffff8114240b>] __lock_buffer+0x38/0x3c
> [  274.937267]  [<ffffffff811c6ce9>] lock_buffer+0x39/0x3d
> [  274.937268]  [<ffffffff811c8162>] do_get_write_access+0x70/0x38d
> [  274.937270]  [<ffffffff81196fe4>] ? ext4_getblk+0x8e/0x153
> [  274.937272]  [<ffffffff811c8588>] jbd2_journal_get_write_access+0x2b/0x42
> [  274.937274]  [<ffffffff811b5888>] __ext4_journal_get_write_access+0x58/0x66
> [  274.937276]  [<ffffffff8119c0ce>] ext4_add_entry+0x11f/0x8cf
> [  274.937277]  [<ffffffff811429f3>] ? __brelse+0x15/0x33
> [  274.937280]  [<ffffffff81191bac>] ? ext4_new_inode+0xc63/0xd0a
> [  274.937282]  [<ffffffff8119c89c>] ext4_add_nondir+0x1e/0x67
> [  274.937283]  [<ffffffff8119cb1b>] ext4_create+0xf5/0x13e
> [  274.937286]  [<ffffffff81129b12>] vfs_create+0x6c/0x8e
> [  274.937288]  [<ffffffff81129dad>] do_last+0x279/0x5ab
> [  274.937289]  [<ffffffff8112ac73>] path_openat+0xc8/0x31c
> [  274.937291]  [<ffffffff810f2332>] ? handle_mm_fault+0x1ac/0x1bf
> [  274.937293]  [<ffffffff8112aeff>] do_filp_open+0x38/0x86
> [  274.937295]  [<ffffffff81233de1>] ? might_fault+0x21/0x23
> [  274.937298]  [<ffffffff8113477b>] ? alloc_fd+0x72/0x11d
> [  274.937299]  [<ffffffff8111e995>] do_sys_open+0x6e/0x100
> [  274.937301]  [<ffffffff8111ea47>] sys_open+0x20/0x22
> [  274.937303]  [<ffffffff81482642>] system_call_fastpath+0x16/0x1b
> [  274.937304] gcc             D 0000000000000000     0  2272   2271 0x00000004
> [  274.937306]  ffff88006f197c58 0000000000000086 ffff88006f197d14 0000000000000000
> [  274.937307]  ffff880037f64500 ffff88006f197fd8 ffff88006f197fd8 0000000000013b40
> [  274.937309]  ffffffff81a0b020 ffff880037f64500 ffff88006f197c58 000000018106e7c3
> [  274.937311] Call Trace:
> [  274.937313]  [<ffffffff811c6fd5>] start_this_handle+0x2e8/0x465
> [  274.937315]  [<ffffffff8106e84e>] ? remove_wait_queue+0x3a/0x3a
> [  274.937317]  [<ffffffff811c7418>] jbd2__journal_start+0x94/0xda
> [  274.937318]  [<ffffffff811c7471>] jbd2_journal_start+0x13/0x15
> [  274.937320]  [<ffffffff811ab92a>] ext4_journal_start_sb+0x108/0x120
> [  274.937323]  [<ffffffff8119cc24>] ext4_symlink+0xc0/0x212
> [  274.937325]  [<ffffffff81129928>] vfs_symlink+0x54/0x74
> [  274.937326]  [<ffffffff8112b40a>] sys_symlinkat+0x96/0xef
> [  274.937329]  [<ffffffff81122d89>] ? sys_newstat+0x2a/0x33
> [  274.937330]  [<ffffffff8112b479>] sys_symlink+0x16/0x18
> [  274.937332]  [<ffffffff81482642>] system_call_fastpath+0x16/0x1b
> [  274.937335] Sched Debug Version: v0.10, 2.6.39-rc4+ #1
> [  274.937336] ktime                                   : 275382.978028
> [  274.937337] sched_clk                               : 274937.334155
> [  274.937338] cpu_clk                                 : 274937.334189
> [  274.937339] jiffies                                 : 4294942678
> [  274.937340] sched_clock_stable                      : 1
> [  274.937341] 
> [  274.937342] sysctl_sched
> [  274.937342]   .sysctl_sched_latency                    : 18.000000
> [  274.937344]   .sysctl_sched_min_granularity            : 2.250000
> [  274.937345]   .sysctl_sched_wakeup_granularity         : 3.000000
> [  274.937346]   .sysctl_sched_child_runs_first           : 0
> [  274.937347]   .sysctl_sched_features                   : 7279
> [  274.937348]   .sysctl_sched_tunable_scaling            : 1 (logaritmic)
> [  274.937349] 
> [  274.937350] cpu#0, 2492.220 MHz
> [  274.937350]   .nr_running                    : 0
> [  274.937351]   .load                          : 0
> [  274.937352]   .nr_switches                   : 105039
> [  274.937353]   .nr_load_updates               : 121182
> [  274.937354]   .nr_uninterruptible            : 8
> [  274.937355]   .next_balance                  : 4294.942607
> [  274.937356]   .curr->pid                     : 0
> [  274.937357]   .clock                         : 274864.523786
> [  274.937359]   .cpu_load[0]                   : 0
> [  274.937360]   .cpu_load[1]                   : 0
> [  274.937361]   .cpu_load[2]                   : 0
> [  274.937362]   .cpu_load[3]                   : 0
> [  274.937363]   .cpu_load[4]                   : 0
> [  274.937364]   .yld_count                     : 0
> [  274.937364]   .sched_switch                  : 0
> [  274.937365]   .sched_count                   : 107487
> [  274.937366]   .sched_goidle                  : 43368
> [  274.937367]   .avg_idle                      : 1000000
> [  274.937368]   .ttwu_count                    : 56534
> [  274.937369]   .ttwu_local                    : 53925
> [  274.937370]   .bkl_count                     : 0
> [  274.937371] 
> [  274.937372] cfs_rq[0]:/system
> [  274.937372]   .exec_clock                    : 5906.036519
> [  274.937374]   .MIN_vruntime                  : 0.000001
> [  274.937375]   .min_vruntime                  : 7138.254657
> [  274.937376]   .max_vruntime                  : 0.000001
> [  274.937377]   .spread                        : 0.000000
> [  274.937378]   .spread0                       : -14302.149798
> [  274.937379]   .nr_spread_over                : 0
> [  274.937379]   .nr_running                    : 0
> [  274.937380]   .load                          : 0
> [  274.937381]   .load_avg                      : 159.999997
> [  274.937382]   .load_period                   : 5.496191
> [  274.937383]   .load_contrib                  : 29
> [  274.937384]   .load_tg                       : 29
> [  274.937385]   .se->exec_start                : 272446.423795
> [  274.937386]   .se->vruntime                  : 21431.398168
> [  274.937387]   .se->sum_exec_runtime          : 5906.111805
> [  274.937388]   .se->statistics.wait_start     : 0.000000
> [  274.937389]   .se->statistics.sleep_start    : 0.000000
> [  274.937390]   .se->statistics.block_start    : 0.000000
> [  274.937391]   .se->statistics.sleep_max      : 0.000000
> [  274.937392]   .se->statistics.block_max      : 0.000000
> [  274.937393]   .se->statistics.exec_max       : 15.266617
> [  274.937394]   .se->statistics.slice_max      : 5.258344
> [  274.937395]   .se->statistics.wait_max       : 7.305679
> [  274.937396]   .se->statistics.wait_sum       : 190.506686
> [  274.937397]   .se->statistics.wait_count     : 18946
> [  274.937398]   .se->load.weight               : 2
> [  274.937399] 
> [  274.937399] cfs_rq[0]:/
> [  274.937400]   .exec_clock                    : 17409.691339
> [  274.937401]   .MIN_vruntime                  : 0.000001
> [  274.937402]   .min_vruntime                  : 21440.404455
> [  274.937403]   .max_vruntime                  : 0.000001
> [  274.937403]   .spread                        : 0.000000
> [  274.937404]   .spread0                       : 0.000000
> [  274.937405]   .nr_spread_over                : 58
> [  274.937406]   .nr_running                    : 0
> [  274.937407]   .load                          : 0
> [  274.937408]   .load_avg                      : 0.000000
> [  274.937409]   .load_period                   : 0.000000
> [  274.937409]   .load_contrib                  : 0
> [  274.937410]   .load_tg                       : 0
> [  274.937411] 
> [  274.937412] cfs_rq[0]:/system/rescue.service
> [  274.937413]   .exec_clock                    : 4319.868509
> [  274.937414]   .MIN_vruntime                  : 0.000001
> [  274.937414]   .min_vruntime                  : 4255.887524
> [  274.937415]   .max_vruntime                  : 0.000001
> [  274.937416]   .spread                        : 0.000000
> [  274.937417]   .spread0                       : -17184.516931
> [  274.937418]   .nr_spread_over                : 24
> [  274.937419]   .nr_running                    : 0
> [  274.937420]   .load                          : 0
> [  274.937421]   .load_avg                      : 160.004112
> [  274.937421]   .load_period                   : 5.496149
> [  274.937422]   .load_contrib                  : 29
> [  274.937423]   .load_tg                       : 29
> [  274.937424]   .se->exec_start                : 272446.423795
> [  274.937425]   .se->vruntime                  : 7138.254657
> [  274.937426]   .se->sum_exec_runtime          : 4319.796162
> [  274.937427]   .se->statistics.wait_start     : 0.000000
> [  274.937428]   .se->statistics.sleep_start    : 0.000000
> [  274.937429]   .se->statistics.block_start    : 0.000000
> [  274.937430]   .se->statistics.sleep_max      : 0.000000
> [  274.937431]   .se->statistics.block_max      : 0.000000
> [  274.937432]   .se->statistics.exec_max       : 6.213083
> [  274.937432]   .se->statistics.slice_max      : 7.894226
> [  274.937433]   .se->statistics.wait_max       : 4.870567
> [  274.937434]   .se->statistics.wait_sum       : 91.737803
> [  274.937435]   .se->statistics.wait_count     : 15504
> [  274.937436]   .se->load.weight               : 2
> [  274.937437] 
> [  274.937438] runnable tasks:
> [  274.937438]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
> [  274.937439] ----------------------------------------------------------------------------------------------------------
> [  274.937444] 
> [  274.937445] cpu#1, 2492.220 MHz
> [  274.937445]   .nr_running                    : 0
> [  274.937446]   .load                          : 0
> [  274.937447]   .nr_switches                   : 35274
> [  274.937448]   .nr_load_updates               : 105259
> [  274.937449]   .nr_uninterruptible            : 1
> [  274.937449]   .next_balance                  : 4294.942681
> [  274.937450]   .curr->pid                     : 0
> [  274.937451]   .clock                         : 274937.357922
> [  274.937452]   .cpu_load[0]                   : 0
> [  274.937453]   .cpu_load[1]                   : 0
> [  274.937454]   .cpu_load[2]                   : 0
> [  274.937454]   .cpu_load[3]                   : 0
> [  274.937455]   .cpu_load[4]                   : 0
> [  274.937456]   .yld_count                     : 0
> [  274.937457]   .sched_switch                  : 0
> [  274.937458]   .sched_count                   : 35560
> [  274.937458]   .sched_goidle                  : 14561
> [  274.937459]   .avg_idle                      : 1000000
> [  274.937460]   .ttwu_count                    : 16938
> [  274.937461]   .ttwu_local                    : 14491
> [  274.937462]   .bkl_count                     : 0
> [  274.937463] 
> [  274.937463] cfs_rq[1]:/
> [  274.937464]   .exec_clock                    : 5221.725565
> [  274.937465]   .MIN_vruntime                  : 0.000001
> [  274.937466]   .min_vruntime                  : 9077.562937
> [  274.937466]   .max_vruntime                  : 0.000001
> [  274.937467]   .spread                        : 0.000000
> [  274.937468]   .spread0                       : -12362.841518
> [  274.937469]   .nr_spread_over                : 69
> [  274.937470]   .nr_running                    : 0
> [  274.937471]   .load                          : 0
> [  274.937472]   .load_avg                      : 0.000000
> [  274.937473]   .load_period                   : 0.000000
> [  274.937473]   .load_contrib                  : 0
> [  274.937474]   .load_tg                       : 0
> [  274.937475] 
> [  274.937476] runnable tasks:
> [  274.937476]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
> [  274.937477] ----------------------------------------------------------------------------------------------------------
> [  274.937481] 
> [  274.937482] cpu#2, 2492.220 MHz
> [  274.937482]   .nr_running                    : 4
> [  274.937483]   .load                          : 2048
> [  274.937484]   .nr_switches                   : 7092
> [  274.937485]   .nr_load_updates               : 100502
> [  274.937486]   .nr_uninterruptible            : 0
> [  274.937487]   .next_balance                  : 4294.942806
> [  274.937487]   .curr->pid                     : 46
> [  274.937488]   .clock                         : 183206.600407
> [  274.937489]   .cpu_load[0]                   : 2048
> [  274.937490]   .cpu_load[1]                   : 2048
> [  274.937491]   .cpu_load[2]                   : 2048
> [  274.937492]   .cpu_load[3]                   : 2048
> [  274.937492]   .cpu_load[4]                   : 2048
> [  274.937493]   .yld_count                     : 0
> [  274.937494]   .sched_switch                  : 0
> [  274.937495]   .sched_count                   : 7323
> [  274.937496]   .sched_goidle                  : 2831
> [  274.937496]   .avg_idle                      : 1000000
> [  274.937497]   .ttwu_count                    : 3275
> [  274.937498]   .ttwu_local                    : 2028
> [  274.937499]   .bkl_count                     : 0
> [  274.937500] 
> [  274.937500] cfs_rq[2]:/
> [  274.937501]   .exec_clock                    : 2187.192139
> [  274.937502]   .MIN_vruntime                  : 5109.505143
> [  274.937503]   .min_vruntime                  : 5118.505143
> [  274.937504]   .max_vruntime                  : 5109.505143
> [  274.937505]   .spread                        : 0.000000
> [  274.937506]   .spread0                       : -16321.899312
> [  274.937506]   .nr_spread_over                : 31
> [  274.937507]   .nr_running                    : 2
> [  274.937508]   .load                          : 2048
> [  274.937509]   .load_avg                      : 0.000000
> [  274.937510]   .load_period                   : 0.000000
> [  274.937511]   .load_contrib                  : 0
> [  274.937511]   .load_tg                       : 0
> [  274.937512] 
> [  274.937513] rt_rq[2]:/
> [  274.937513]   .rt_nr_running                 : 1
> [  274.937514]   .rt_throttled                  : 0
> [  274.937515]   .rt_time                       : 0.000000
> [  274.937516]   .rt_runtime                    : 950.000000
> [  274.937517] 
> [  274.937517] runnable tasks:
> [  274.937518]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
> [  274.937519] ----------------------------------------------------------------------------------------------------------
> [  274.937520]      migration/2    13         0.000000       113     0         0.000000         0.000815         0.000000 /
> [  274.937524]       watchdog/2    16         0.000000        17     0         0.000000         1.785026         0.002124 /
> [  274.937527] R        kswapd0    46      5118.505143       370   120      5118.505143       415.766870    181943.841718 /
> [  274.937531]      kworker/2:1    76      5109.505143      1083   120      5109.505143        25.615305    181183.059001 /
> [  274.937535] 
> [  274.937536] cpu#3, 2492.220 MHz
> [  274.937536]   .nr_running                    : 1
> [  274.937537]   .load                          : 1024
> [  274.937538]   .nr_switches                   : 22324
> [  274.937539]   .nr_load_updates               : 59855
> [  274.937540]   .nr_uninterruptible            : 0
> [  274.937541]   .next_balance                  : 4294.942679
> [  274.937542]   .curr->pid                     : 73
> [  274.937543]   .clock                         : 274936.938702
> [  274.937543]   .cpu_load[0]                   : 0
> [  274.937544]   .cpu_load[1]                   : 0
> [  274.937545]   .cpu_load[2]                   : 0
> [  274.937546]   .cpu_load[3]                   : 0
> [  274.937546]   .cpu_load[4]                   : 0
> [  274.937547]   .yld_count                     : 123
> [  274.937548]   .sched_switch                  : 0
> [  274.937549]   .sched_count                   : 22774
> [  274.937550]   .sched_goidle                  : 9952
> [  274.937551]   .avg_idle                      : 946660
> [  274.937551]   .ttwu_count                    : 10075
> [  274.937552]   .ttwu_local                    : 8964
> [  274.937553]   .bkl_count                     : 0
> [  274.937554] 
> [  274.937554] cfs_rq[3]:/
> [  274.937555]   .exec_clock                    : 3244.912177
> [  274.937556]   .MIN_vruntime                  : 0.000001
> [  274.937557]   .min_vruntime                  : 7517.482154
> [  274.937558]   .max_vruntime                  : 0.000001
> [  274.937559]   .spread                        : 0.000000
> [  274.937559]   .spread0                       : -13922.922301
> [  274.937560]   .nr_spread_over                : 128
> [  274.937561]   .nr_running                    : 1
> [  274.937562]   .load                          : 1024
> [  274.937563]   .load_avg                      : 0.000000
> [  274.937564]   .load_period                   : 0.000000
> [  274.937565]   .load_contrib                  : 0
> [  274.937565]   .load_tg                       : 0
> [  274.937567] 
> [  274.937567] runnable tasks:
> [  274.937567]             task   PID         tree-key  switches  prio     exec-runtime         sum-exec        sum-sleep
> [  274.937568] ----------------------------------------------------------------------------------------------------------
> [  274.937571] R    kworker/3:1    73      7517.482154      7294   120      7517.482154       264.876541    272702.297840 /
> [  274.937575] 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
