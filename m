Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id E8AD86B006C
	for <linux-mm@kvack.org>; Tue,  1 Jan 2013 10:56:41 -0500 (EST)
Received: from mailout-de.gmx.net ([10.1.76.19]) by mrigmx.server.lan
 (mrigmx001) with ESMTP (Nemesis) id 0MdIS5-1TXi0Z1huF-00IT9O for
 <linux-mm@kvack.org>; Tue, 01 Jan 2013 16:56:40 +0100
Message-ID: <50E30736.9050207@gmx.de>
Date: Tue, 01 Jan 2013 16:56:38 +0100
From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
Subject: Re: kernel bug at mm/huge_memory.c:1789 for v3.8-rc1-91-g4a490b7
References: <50E2C87A.3090000@gmx.de>
In-Reply-To: <50E2C87A.3090000@gmx.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Linux Kernel <linux-kernel@vger.kernel.org>

I found this in the syslog (sry for the big unnecessary JPEG in the previous message,
I wasn't aware, that the syslogd was still working):

2013-01-01T12:15:28.000+01:00 n22 ntpd[3095]: Listen normally on 5 ppp0 80.171.221.184 UDP 123
2013-01-01T12:15:28.000+01:00 n22 ntpd[3095]: peers refreshed
2013-01-01T12:18:32.394+01:00 n22 kernel: mapcount 0 page_mapcount 1
2013-01-01T12:18:32.394+01:00 n22 kernel: ------------[ cut here ]------------
2013-01-01T12:18:32.394+01:00 n22 kernel: kernel BUG at mm/huge_memory.c:1798!
2013-01-01T12:18:32.394+01:00 n22 kernel: invalid opcode: 0000 [#1] SMP
2013-01-01T12:18:32.394+01:00 n22 kernel: Modules linked in: loop ipt_MASQUERADE xt_owner xt_multiport ipt_REJECT xt_tcpudp xt_recent xt_conntrack nf_conntrack_ftp xt_limit xt_LOG iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_filter ip_tables x_tables af_packet pppoe pppox ppp_generic slhc bridge stp llc tun fuse dm_mod msr i915 fbcon font bitblit softcursor drm_kms_helper snd_hda_codec_conexant drm fb snd_hda_intel fbdev snd_hda_codec intel_agp cfbcopyarea i2c_algo_bit snd_pcm thinkpad_acpi intel_gtt coretemp snd_timer hwmon snd agpgart snd_page_alloc kvm_intel soundcore arc4 sg cfbimgblt iwldvm mac80211 iwlwifi cfg80211 uvcvideo videobuf2_core videodev 8250_pci sdhci_pci e1000e 8250_core sdhci mmc_core videobuf2_vmalloc cfbfillrect wmi videobuf2_memops sr_mod rfkill usblp serial_core acpi_cpufreq hid_cherry mperf hid_generic processor usbhid tpm_tis hid tpm video ac thermal battery cdrom tpm_bios nvram kvm aesni_intel ablk_helper cryptd lrw i2c
_i801 aes_i586 xts i2c_core gf128mul evdev psmouse button [last unloaded: microcode]
2013-01-01T12:18:32.394+01:00 n22 kernel: Pid: 20477, comm: firefox Not tainted 3.8.0-rc1+ #3 LENOVO 4180F65/4180F65
2013-01-01T12:18:32.394+01:00 n22 kernel: EIP: 0060:[<c11149f4>] EFLAGS: 00010297 CPU: 2
2013-01-01T12:18:32.394+01:00 n22 kernel: EIP is at split_huge_page+0x5d4/0x670
2013-01-01T12:18:32.394+01:00 n22 kernel: EAX: 00000001 EBX: f194b640 ECX: 000003d6 EDX: f516d000
2013-01-01T12:18:32.394+01:00 n22 kernel: ESI: 00000000 EDI: 00000000 EBP: e9a2fe2c ESP: e9a2fdc4
2013-01-01T12:18:32.395+01:00 n22 kernel: DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
2013-01-01T12:18:32.395+01:00 n22 kernel: CR0: 80050033 CR2: ac9550e0 CR3: 2b0bc000 CR4: 000407f0
2013-01-01T12:18:32.395+01:00 n22 kernel: DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
2013-01-01T12:18:32.395+01:00 n22 kernel: DR6: ffff0ff0 DR7: 00000400
2013-01-01T12:18:32.395+01:00 n22 kernel: Process firefox (pid: 20477, ti=e9a2e000 task=e978f620 task.ti=e9a2e000)
2013-01-01T12:18:32.395+01:00 n22 kernel: Stack:
2013-01-01T12:18:32.395+01:00 n22 kernel: c148e3a0 00000000 00000001 e9a2fe2c ef980e80 00000001 f3d5e000 98c00000
2013-01-01T12:18:32.395+01:00 n22 kernel: 00000202 f194b640 00000000 00098a00 f516d000 e9a2fe3c f4e74e60 0005dfc0
2013-01-01T12:18:32.395+01:00 n22 kernel: 00000000 ef980e98 98c00000 00000000 98a00000 00000282 f37d4148 f516d000
2013-01-01T12:18:32.395+01:00 n22 kernel: Call Trace:
2013-01-01T12:18:32.395+01:00 n22 kernel: [<c1115c2e>] __split_huge_page_pmd+0xce/0x280
2013-01-01T12:18:32.395+01:00 n22 kernel: [<c10f65be>] unmap_single_vma+0x14e/0x5b0
2013-01-01T12:18:32.395+01:00 n22 kernel: [<c106861b>] ? update_curr+0x1ab/0x310
2013-01-01T12:18:32.395+01:00 n22 kernel: [<c10f78e7>] ? handle_pte_fault+0x297/0x940
2013-01-01T12:18:32.395+01:00 n22 kernel: [<c106613f>] ? __enqueue_entity+0x6f/0x80
2013-01-01T12:18:32.395+01:00 n22 kernel: [<c10f71e4>] zap_page_range+0x84/0xd0
2013-01-01T12:18:32.395+01:00 n22 kernel: [<c102af00>] ? vmalloc_sync_all+0x10/0x10
2013-01-01T12:18:32.395+01:00 n22 kernel: [<c102acb3>] ? __do_page_fault+0x1c3/0x400
2013-01-01T12:18:32.395+01:00 n22 kernel: [<c10f4813>] sys_madvise+0x1f3/0x580
2013-01-01T12:18:32.395+01:00 n22 kernel: [<c103be0c>] ? irq_exit+0x5c/0xa0
2013-01-01T12:18:32.395+01:00 n22 kernel: [<c13d5941>] sysenter_do_call+0x12/0x22
2013-01-01T12:18:32.395+01:00 n22 kernel: [<c13d007b>] ? bdi_stat_error.isra.13+0xc/0x1d
2013-01-01T12:18:32.395+01:00 n22 kernel: [<c13d0000>] ? __alloc_pages_direct_compact+0x15d/0x18e
2013-01-01T12:18:32.395+01:00 n22 kernel: Code: 0f 0b 83 c4 5c b8 01 00 00 00 5b 5e 5f 5d c3 0f 0b 8b 43 1c e9 5b fd ff ff 0f 0b 0f 0b 0f 0b 0f 0b 0f 0b 0f 0b 0f 0b 0f 0b 0f 0b <0f> 0b 8b 42 0c c7 04 24 a0 e3 48 c1 8b 75 c0 83 c0 01 89 74 24
2013-01-01T12:18:32.395+01:00 n22 kernel: EIP: [<c11149f4>] split_huge_page+0x5d4/0x670 SS:ESP 0068:e9a2fdc4
2013-01-01T12:18:32.586+01:00 n22 kernel: ---[ end trace efddc03bd6b617e5 ]---


-- 
MfG/Sincerely
Toralf FA?rster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
