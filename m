Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id DB3B46B00EF
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 03:18:23 -0500 (EST)
Date: Thu, 2 Dec 2010 09:15:52 +0100
From: Michael Leun <lkml20101129@newton.leun.net>
Subject: Re: kernel BUG at mm/truncate.c:475!
Message-ID: <20101202091552.4a63f717@xenia.leun.net>
In-Reply-To: <20101202084159.6bff7355@xenia.leun.net>
References: <20101130194945.58962c44@xenia.leun.net>
	<alpine.LSU.2.00.1011301453090.12516@tigran.mtv.corp.google.com>
	<E1PNjsI-0005Bk-NB@pomaz-ex.szeredi.hu>
	<20101201124528.6809c539@xenia.leun.net>
	<E1PNqO1-0005px-9h@pomaz-ex.szeredi.hu>
	<20101202084159.6bff7355@xenia.leun.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: hughd@google.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2 Dec 2010 08:41:59 +0100
Michael Leun <lkml20101129@newton.leun.net> wrote:

> On Wed, 01 Dec 2010 18:22:33 +0100
> Miklos Szeredi <miklos@szeredi.hu> wrote:
> 
> > On Wed, 1 Dec 2010, Michael Leun wrote:
> > > At the moment I've downgraded to 2.6.36 - I cannot remember to
> > > have seen this there - which does not need to mean anything,
> > > because workload has changed (several unshared mount/network
> > > namespaces chrooted into unionfs-fuse mounted roots - cool
> > > stuff...).
> > > 
> > > Would you suspect to make 2.6.36 <> 2.6.36.1 a difference here?
> > 
> > No, that's unlikely.
> 
> Took until now to happen in 2.6.36 - so it is there also. I cannot
> really say if it is less frequent in 2.6.36 at the moment, but from
> that very limited number of tests (1) it looks like.
> 
> > > Later, when I've results from the test with 2.6.36 of course I'll
> > > try the quick test you suggested.
> > 
> > Okay, thanks.
> 
> Kernel compile 2.6.36.1 with that .page_mkwrite commented out running
> now, will reboot really soon now (TM).

OK - that happened very fast again in 2.6.36.1.

Sorry for that tainted kernel, but cannot afford to additionally have
graphics lockups all the time - I've shown that it happens with
untainted kernel also (long run without fault yesterday also was with
nvidia.ko driver).

Until I've another suggestion what to try I'll swich back to 2.6.36 to
see if it really happens less frequent there.


Dec  2 09:08:13 elektra kernel: [ 1376.957887] ------------[ cut here ]------------
Dec  2 09:08:13 elektra kernel: [ 1376.957894] kernel BUG at mm/truncate.c:475!
Dec  2 09:08:13 elektra kernel: [ 1376.957896] invalid opcode: 0000 [#1] PREEMPT SMP
Dec  2 09:08:13 elektra kernel: [ 1376.957899] last sysfs file: /sys/devices/pci0000:00/0000:00:1c.1/0000:03:00.0/irq
Dec  2 09:08:13 elektra kernel: [ 1376.957901] CPU 0
Dec  2 09:08:13 elektra kernel: [ 1376.957903] Modules linked in: veth ipt_MASQUERADE af_packet iwlagn bridge 8021q garp stp llc fuse vboxnetadp vboxnetflt vboxdrv nvidia(P) snd_pcm_oss snd_mixer_oss snd_seq snd_seq_device edd cpufreq_conservative cpufreq_userspace cpufreq_powersave acpi_cpufreq mperf ip6t_REJECT ipt_REJECT ip6t_LOG ipt_LOG xt_limit xt_recent nf_conntrack_ipv6 xt_state xt_tcpudp ip6table_mangle iptable_mangle iptable_nat ip6table_filter ip6_tables iptable_filter nf_nat_ftp nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack_ftp nf_conntrack ip_tables x_tables nls_utf8 loop arc4 ecb snd_hda_codec_nvhdmi iwlcore mac80211 snd_hda_codec_idt snd_hda_intel snd_hda_codec snd_hwdep snd_pcm cfg80211 ohci1394 ieee1394 sdhci_pci sdhci pcmcia snd_timer snd firewire_ohci mmc_core yenta_socket dell_laptop firewire_core soundcore rfkill snd_page_alloc pcmcia_rsrc pcmcia_core crc_itu_t dm9601 ppdev usbnet dell_wmi shpchp sr_mod e1000e parport_pc parport intel_agp iTCO_wdt !
 pci_hotplug cdrom intel_ips i2c_i801 pc
Dec  2 09:08:13 elektra kernel: spkr iTCO_vendor_support sg wmi button video battery dcdbas ac ext4 jbd2 crc16 sha256_generic aesni_intel cryptd aes_x86_64 aes_generic cbc dm_crypt usbhid linear ehci_hcd usbcore sd_mod dm_snapshot dm_mod fan processor ahci libahci libata scsi_mod thermal thermal_sys [last unloaded: iwlagn]
Dec  2 09:08:13 elektra kernel: [ 1376.957985]
Dec  2 09:08:13 elektra kernel: [ 1376.957988] Pid: 23526, comm: lteiad Tainted: P        W   2.6.36.1 #2 0N5KHN/Latitude E6510
Dec  2 09:08:13 elektra kernel: [ 1376.957991] RIP: 0010:[<ffffffff810ee5e1>]  [<ffffffff810ee5e1>] invalidate_inode_pages2_range+0x271/0x350
Dec  2 09:08:13 elektra kernel: [ 1376.958001] RSP: 0018:ffff88009baf1b58  EFLAGS: 00010246
Dec  2 09:08:13 elektra kernel: [ 1376.958003] RAX: 0000000000000000 RBX: ffffea0002010fa0 RCX: ffff8800c95c2bd0
Dec  2 09:08:13 elektra kernel: [ 1376.958005] RDX: 0000000000000000 RSI: ffff88009baf1a28 RDI: ffff8800cef0e258
Dec  2 09:08:13 elektra kernel: [ 1376.958007] RBP: ffff88009baf1c38 R08: ffff8800c95c2bd0 R09: 0000000000000000
Dec  2 09:08:13 elektra kernel: [ 1376.958009] R10: 0000000000000008 R11: 0000000000000001 R12: ffff88009baf1ba8
Dec  2 09:08:13 elektra kernel: [ 1376.958011] R13: 0000000000000002 R14: ffff8800cef0e218 R15: 0000000000000000
Dec  2 09:08:13 elektra kernel: [ 1376.958013] FS:  0000000000000000(0000) GS:ffff880001c00000(0000) knlGS:0000000000000000
Dec  2 09:08:13 elektra kernel: [ 1376.958016] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Dec  2 09:08:13 elektra kernel: [ 1376.958018] CR2: 00007f341c5cd020 CR3: 00000000af30b000 CR4: 00000000000006f0
Dec  2 09:08:13 elektra kernel: [ 1376.958021] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Dec  2 09:08:13 elektra kernel: [ 1376.958023] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Dec  2 09:08:13 elektra kernel: [ 1376.958025] Process lteiad (pid: 23526, threadinfo ffff88009baf0000, task ffff880096660000)
Dec  2 09:08:13 elektra kernel: [ 1376.958027] Stack:
Dec  2 09:08:13 elektra kernel: [ 1376.958029]  ffffffff81074300 ffff8800cef0e230 000000019baf1b60 0000000000000075
Dec  2 09:08:13 elektra kernel: [ 1376.958032] <0> ffffffffffffffff 00000000967c1148 000000000000000e 0000000000000000
Dec  2 09:08:13 elektra kernel: [ 1376.958035] <0> ffffea00021d1eb8 ffffea0002037fb8 ffffea0002010fa0 ffffea0002014dc0
Dec  2 09:08:13 elektra kernel: [ 1376.958039] Call Trace:
Dec  2 09:08:13 elektra kernel: [ 1376.958045]  [<ffffffff81074300>] ? autoremove_wake_function+0x0/0x40
Dec  2 09:08:13 elektra kernel: [ 1376.958048]  [<ffffffff810ee6d2>] invalidate_inode_pages2+0x12/0x20
Dec  2 09:08:13 elektra kernel: [ 1376.958057]  [<ffffffffa1119cb0>] fuse_finish_open+0x60/0x70 [fuse]
Dec  2 09:08:13 elektra kernel: [ 1376.958061]  [<ffffffffa1119d41>] fuse_open_common+0x81/0x90 [fuse]
Dec  2 09:08:13 elektra kernel: [ 1376.958064]  [<ffffffffa1119d50>] ? fuse_open+0x0/0x10 [fuse]
Dec  2 09:08:13 elektra kernel: [ 1376.958068]  [<ffffffffa1119d5b>] fuse_open+0xb/0x10 [fuse]
Dec  2 09:08:13 elektra kernel: [ 1376.958074]  [<ffffffff81137a1a>] __dentry_open+0x11a/0x3c0
Dec  2 09:08:13 elektra kernel: [ 1376.958079]  [<ffffffff811efbda>] ? security_inode_permission+0x1a/0x20
Dec  2 09:08:13 elektra kernel: [ 1376.958082]  [<ffffffff81138cc4>] nameidata_to_filp+0x54/0x70
Dec  2 09:08:13 elektra kernel: [ 1376.958086]  [<ffffffff81147168>] do_last+0x488/0x760
Dec  2 09:08:13 elektra kernel: [ 1376.958089]  [<ffffffff81147868>] do_filp_open+0x428/0x670
Dec  2 09:08:13 elektra kernel: [ 1376.958093]  [<ffffffffa1113a48>] ? fuse_put_request+0xb8/0xc0 [fuse]
Dec  2 09:08:13 elektra kernel: [ 1376.958095]  [<ffffffff81138d40>] do_sys_open+0x60/0x120
Dec  2 09:08:13 elektra kernel: [ 1376.958098]  [<ffffffff81138e1b>] sys_open+0x1b/0x20
Dec  2 09:08:13 elektra kernel: [ 1376.958102]  [<ffffffff81002f02>] system_call_fastpath+0x16/0x1b
Dec  2 09:08:13 elektra kernel: [ 1376.958104] Code: fe ff ff 0f 1f 80 00 00 00 00 48 89 c6 31 c9 48 c1 e6 0c ba 00 10 00 00 4c 89 f7 e8 ba 37 01 00 8b 43 0c 85 c0 0f 88 2e ff ff ff <0f> 0b 0f 1f 44 00 00 48 89 df e8 30 39 ff ff 8b 85 50 ff ff ff
Dec  2 09:08:13 elektra kernel: [ 1376.958126] RIP  [<ffffffff810ee5e1>] invalidate_inode_pages2_range+0x271/0x350
Dec  2 09:08:13 elektra kernel: [ 1376.958130]  RSP <ffff88009baf1b58>
Dec  2 09:08:13 elektra kernel: [ 1376.958133] ---[ end trace 0390f6d4e17d7807 ]---



-- 
MfG,

Michael Leun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
