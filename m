Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 5DBF6900111
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 12:09:18 -0400 (EDT)
Subject: [BUG] fatal hang untarring 90GB file, possibly writeback related.
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 27 Apr 2011 11:09:13 -0500
Message-ID: <1303920553.2583.7.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

The bug manifests as a soft lockup in kswapd:

[  155.759084] netconsole: network logging started
[  598.920430] BUG: soft lockup - CPU#1 stuck for 67s! [kswapd0:46]
[  598.920472] Modules linked in: netconsole configfs fuse sunrpc cpufreq_ondemand acpi_cpufreq freq_table mperf ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables snd_hda_codec_hdmi snd_hda_codec_conexant snd_hda_intel snd_hda_codec snd_hwdep arc4 snd_seq snd_seq_device snd_pcm iwlagn mac80211 snd_timer uvcvideo btusb bluetooth snd cfg80211 videodev soundcore v4l2_compat_ioctl32 iTCO_wdt xhci_hcd e1000e snd_page_alloc rfkill i2c_i801 wmi iTCO_vendor_support microcode pcspkr joydev uinput ipv6 sdhci_pci sdhci mmc_core i915 drm_kms_helper drm i2c_algo_bit i2c_core video [last unloaded: netconsole]
[  598.920834] CPU 1 
[  598.920843] Modules linked in: netconsole configfs fuse sunrpc cpufreq_ondemand acpi_cpufreq freq_table mperf ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables snd_hda_codec_hdmi snd_hda_codec_conexant snd_hda_intel snd_hda_codec snd_hwdep arc4 snd_seq snd_seq_device snd_pcm iwlagn mac80211 snd_timer uvcvideo btusb bluetooth snd cfg80211 videodev soundcore v4l2_compat_ioctl32 iTCO_wdt xhci_hcd e1000e snd_page_alloc rfkill i2c_i801 wmi iTCO_vendor_support microcode pcspkr joydev uinput ipv6 sdhci_pci sdhci mmc_core i915 drm_kms_helper drm i2c_algo_bit i2c_core video [last unloaded: netconsole]
[  598.926818] 
[  598.928043] Pid: 46, comm: kswapd0 Not tainted 2.6.39-rc4+ #1 LENOVO 4170CTO/4170CTO
[  598.929299] RIP: 0010:[<ffffffffa007ff9b>]  [<ffffffffa007ff9b>] i915_gem_inactive_shrink+0x78/0x194 [i915]
[  598.930603] RSP: 0018:ffff8800709ebd50  EFLAGS: 00000216
[  598.931867] RAX: ffff88006ec5c6b0 RBX: 00000000000000c0 RCX: 0000000000000000
[  598.933135] RDX: ffff880037e59638 RSI: 0000000000000000 RDI: ffff880037876020
[  598.934408] RBP: ffff8800709ebd90 R08: 0000000000000000 R09: 000000000001bd90
[  598.935680] R10: 0000000000000002 R11: ffffffff81a44e50 R12: ffffffff8148300e
[  598.936944] R13: ffff8800709ebcf0 R14: ffff8800709ebcf8 R15: ffffffff810dd64d
[  598.938221] FS:  0000000000000000(0000) GS:ffff880100240000(0000) knlGS:0000000000000000
[  598.939525] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  598.940813] CR2: 00007fe16a34d380 CR3: 0000000001a03000 CR4: 00000000000406e0
[  598.942114] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  598.943441] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  598.944744] Process kswapd0 (pid: 46, threadinfo ffff8800709ea000, task ffff88006df8ae00)
[  598.946044] Stack:
[  598.947317]  ffff8800709ebd90 ffff880037e59638 ffff8800709ebd60 ffff880037e595f0
[  598.948654]  0000000000000000 0000000000000000 00000000000000d0 000000000004c24e
[  598.949986]  ffff8800709ebde0 ffffffff810e1f89 000000000000003d 0000000000000080
[  598.951329] Call Trace:
[  598.952673]  [<ffffffff810e1f89>] shrink_slab+0x6d/0x166
[  598.954003]  [<ffffffff810e4bcc>] kswapd+0x533/0x798
[  598.955331]  [<ffffffff810e4699>] ? mem_cgroup_shrink_node_zone+0xe3/0xe3
[  598.956683]  [<ffffffff8106e157>] kthread+0x84/0x8c
[  598.958022]  [<ffffffff81483764>] kernel_thread_helper+0x4/0x10
[  598.959379]  [<ffffffff8106e0d3>] ? kthread_worker_fn+0x148/0x148
[  598.960709]  [<ffffffff81483760>] ? gs_change+0x13/0x13
[  598.962032] Code: 31 ed 48 83 c3 48 48 2d b0 00 00 00 eb 0a 48 8d 82 50 ff ff ff 41 ff c5 48 8b 90 b0 00 00 00 48 05 b0 00 00 00 48 39 d8 0f 18 0a 
[  598.962192]  e1 e9 da 00 00 00 4c 89 f7 e8 c6 fd ff ff 48 8b 43 48 4c 8b 
[  598.965009] Call Trace:
[  598.966421]  [<ffffffff810e1f89>] shrink_slab+0x6d/0x166
[  598.966423]  [<ffffffff810e4bcc>] kswapd+0x533/0x798
[  598.966426]  [<ffffffff810e4699>] ? mem_cgroup_shrink_node_zone+0xe3/0xe3
[  598.966429]  [<ffffffff8106e157>] kthread+0x84/0x8c
[  598.966432]  [<ffffffff81483764>] kernel_thread_helper+0x4/0x10
[  598.966435]  [<ffffffff8106e0d3>] ? kthread_worker_fn+0x148/0x148
[  598.966438]  [<ffffffff81483760>] ? gs_change+0x13/0x13

The traces are slightly different each reboot cycle, but it's always in
kswapd and usually in shrink_slab.  Once it happens, anything that
touches the filesystem hangs in D wait, so the machine is basically
toast.

The box is a Lenovo T420s sandybridge core i5 based laptop with 2GB of
memory.

There is a corresponding Red Hat bugzilla report here:

https://bugzilla.redhat.com/show_bug.cgi?id=694818

And I've verified that the bug also shows in the 2.6.38.3 stable kernel.
If anyone wants me to try anything, please let me know.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
