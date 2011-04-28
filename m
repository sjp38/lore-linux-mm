Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C1EC9900001
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 18:44:02 -0400 (EDT)
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback
 related.
From: James Bottomley <James.Bottomley@suse.de>
In-Reply-To: <1304025145.2598.24.camel@mulgrave.site>
References: <1303990590.2081.9.camel@lenovo>
	 <20110428135228.GC1696@quack.suse.cz> <20110428140725.GX4658@suse.de>
	 <1304000714.2598.0.camel@mulgrave.site> <20110428150827.GY4658@suse.de>
	 <1304006499.2598.5.camel@mulgrave.site>
	 <1304009438.2598.9.camel@mulgrave.site>
	 <1304009778.2598.10.camel@mulgrave.site> <20110428171826.GZ4658@suse.de>
	 <1304015436.2598.19.camel@mulgrave.site>  <20110428192104.GA4658@suse.de>
	 <1304020767.2598.21.camel@mulgrave.site>
	 <1304025145.2598.24.camel@mulgrave.site>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 28 Apr 2011 17:43:48 -0500
Message-ID: <1304030629.2598.42.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Jan Kara <jack@suse.cz>, colin.king@canonical.com, Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, mgorman@novell.com

On Thu, 2011-04-28 at 16:12 -0500, James Bottomley wrote:
> On Thu, 2011-04-28 at 14:59 -0500, James Bottomley wrote:
> > Actually, talking to Chris, I think I can get the system up using
> > init=/bin/bash without systemd, so I can try the no cgroup config.
> 
> OK, so a non-PREEMPT non-CGROUP kernel has survived three back to back
> runs of untar without locking or getting kswapd pegged, so I'm pretty
> certain this is cgroups related.  The next steps are to turn cgroups
> back on but try disabling the memory and IO controllers.

I tried non-PREEMPT CGROUP but disabled GROUP_MEM_RES_CTLR.

The results are curious:  the tar does complete (I've done three back to
back).  However, I did get one soft lockup in kswapd (below).  But the
system recovers instead of halting I/O and hanging like it did
previously.

The soft lockup is in shrink_slab, so perhaps it's a combination of slab
shrinker and cgroup memory controller issues?

James

---
[  670.823843] BUG: soft lockup - CPU#2 stuck for 67s! [kswapd0:46]
[  670.825472] Modules linked in: netconsole configfs cpufreq_ondemand acpi_cpufreq freq_table mperf snd_hda_codec_hdmi snd_hda_codec_conexant arc4 snd_hda_intel btusb snd_hda_codec snd_hwdep iwlagn snd_seq mac80211 bluetooth snd_seq_device uvcvideo snd_pcm cfg80211 wmi microcode e1000e videodev xhci_hcd rfkill snd_timer iTCO_wdt v4l2_compat_ioctl32 iTCO_vendor_support pcspkr i2c_i801 snd soundcore snd_page_alloc joydev uinput ipv6 sdhci_pci sdhci mmc_core i915 drm_kms_helper drm i2c_algo_bit i2c_core video [last unloaded: scsi_wait_scan]
[  670.830864] CPU 2 
[  670.830881] Modules linked in: netconsole configfs cpufreq_ondemand acpi_cpufreq freq_table mperf snd_hda_codec_hdmi snd_hda_codec_conexant arc4 snd_hda_intel btusb snd_hda_codec snd_hwdep iwlagn snd_seq mac80211 bluetooth snd_seq_device uvcvideo snd_pcm cfg80211 wmi microcode e1000e videodev xhci_hcd rfkill snd_timer iTCO_wdt v4l2_compat_ioctl32 iTCO_vendor_support pcspkr i2c_i801 snd soundcore snd_page_alloc joydev uinput ipv6 sdhci_pci sdhci mmc_core i915 drm_kms_helper drm i2c_algo_bit i2c_core video [last unloaded: scsi_wait_scan]
[  670.838385] 
[  670.840289] Pid: 46, comm: kswapd0 Not tainted 2.6.39-rc4+ #3 LENOVO 4170CTO/4170CTO
[  670.842193] RIP: 0010:[<ffffffff810e07cb>]  [<ffffffff810e07cb>] shrink_slab+0x86/0x166
[  670.844063] RSP: 0018:ffff88006eea5da0  EFLAGS: 00000206
[  670.845881] RAX: 0000000000000000 RBX: ffff88006eea5de0 RCX: 0000000000000002
[  670.847652] RDX: 0000000000000000 RSI: ffff88006eea5d60 RDI: ffff88006eea5d60
[  670.849394] RBP: ffff88006eea5de0 R08: 000000000000000c R09: 0000000000000000
[  670.851091] R10: 0000000000000001 R11: 000000000000005f R12: ffffffff8147b50e
[  670.852733] R13: ffff8801005e6e00 R14: 0000000000000010 R15: 0000000000017fb6
[  670.854351] FS:  0000000000000000(0000) GS:ffff880100280000(0000) knlGS:0000000000000000
[  670.855968] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  670.857555] CR2: 00000037d90ae040 CR3: 0000000001a03000 CR4: 00000000000406e0
[  670.859138] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  670.860720] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  670.862320] Process kswapd0 (pid: 46, threadinfo ffff88006eea4000, task ffff88006eeb0000)
[  670.863932] Stack:
[  670.865477]  0000000000000001 0000000000000080 ffff880000000002 ffff8801005e6e00
[  670.867023]  ffff8801005e6000 0000000000000002 0000000000000000 000000000000000c
[  670.868558]  ffff88006eea5ee0 ffffffff810e308c 0000000000000003 ffff88006eeb0000
[  670.870120] Call Trace:
[  670.871652]  [<ffffffff810e308c>] kswapd+0x4f0/0x774
[  670.873218]  [<ffffffff810e2b9c>] ? try_to_free_pages+0xe5/0xe5
[  670.874786]  [<ffffffff8106ce57>] kthread+0x84/0x8c
[  670.876327]  [<ffffffff8147bc64>] kernel_thread_helper+0x4/0x10
[  670.877871]  [<ffffffff8106cdd3>] ? kthread_worker_fn+0x148/0x148
[  670.879403]  [<ffffffff8147bc60>] ? gs_change+0x13/0x13
[  670.880932] Code: 83 eb 10 e9 ce 00 00 00 44 89 f2 31 f6 48 89 df ff 13 48 63 4b 08 4c 63 e8 48 8b 45 c8 31 d2 48 f7 f1 31 d2 49 0f af c5 49 f7 f7 
[  670.881086]  03 43 20 48 85 c0 48 89 43 20 79 18 48 8b 33 48 89 c2 48 c7 
[  670.884285] Call Trace:
[  670.885884]  [<ffffffff810e308c>] kswapd+0x4f0/0x774
[  670.887462]  [<ffffffff810e2b9c>] ? try_to_free_pages+0xe5/0xe5
[  670.889031]  [<ffffffff8106ce57>] kthread+0x84/0x8c
[  670.890578]  [<ffffffff8147bc64>] kernel_thread_helper+0x4/0x10
[  670.892130]  [<ffffffff8106cdd3>] ? kthread_worker_fn+0x148/0x148
[  670.893653]  [<ffffffff8147bc60>] ? gs_change+0x13/0x13


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
