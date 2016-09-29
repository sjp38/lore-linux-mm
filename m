Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 028036B0038
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 10:42:15 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b130so75968178wmc.2
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 07:42:14 -0700 (PDT)
Received: from 13.mo5.mail-out.ovh.net (13.mo5.mail-out.ovh.net. [87.98.182.191])
        by mx.google.com with ESMTPS id jm8si15058191wjb.20.2016.09.29.07.41.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Sep 2016 07:41:53 -0700 (PDT)
Received: from player774.ha.ovh.net (b7.ovh.net [213.186.33.57])
	by mo5.mail-out.ovh.net (Postfix) with ESMTP id 79D5F88AB
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 16:41:53 +0200 (CEST)
From: Nicolas Morey-Chaisemartin <devel@morey-chaisemartin.com>
Subject: put_page vs release_pages
Message-ID: <26904abd-7a8d-076c-3ce5-f0631572ab5e@morey-chaisemartin.com>
Date: Thu, 29 Sep 2016 16:41:49 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi,

Can someone explain to me what is the difference between put_page and release_pages and which one should be used when ?

To explain my case:
We have a PCIe driver than transfers data between user process (read/write scalls) to a PCI device, using DMA.
We followed the DMA guide so the code basically does this:

----
get_user_pages()
pci_map_sg()

// All DMA setup/wait for completion

pci_unmap_sg
if (mode == PCIE_DMA_FROMDEVICE)
    foreach(page) { set_page_dirty_lock(page) }
release_pages(pages, count, 0)
----
It works nicely on centos 7 and few other kernels we tried.

However we switch to the latest kernel from el-repo (4.7.5-1.el7.elrepo.x86_64), and one of our tests fails with the following kernel bug. The bug happens systematically.
---------------------
[ 1905.322093] ------------[ cut here ]------------
[ 1905.322119] kernel BUG at mm/huge_memory.c:242!
[ 1905.322129] invalid opcode: 0000 [#1] SMP
[ 1905.322137] Modules linked in: mppapcie_tty(O) mppapcie(O) fuse netconsole xt_CHECKSUM iptable_mangle ipt_MASQUERADE nf_nat_masquerade_ipv4 iptable_nat nf_nat_ipv4 nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ipt_REJECT nf_reject_ipv4 tun ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter cts nfsv3 rpcsec_gss_krb5 nfsv4 dns_resolver nfs fscache dm_mirror dm_region_hash dm_log dm_mod edac_core x86_pkg_temp_thermal intel_powerclamp coretemp kvm_intel snd_hda_codec_realtek snd_hda_codec_generic snd_hda_intel kvm snd_hda_codec snd_hda_core irqbypass snd_hwdep crct10dif_pclmul crc32_pclmul snd_seq ghash_clmulni_intel snd_seq_device aesni_intel lrw gf128mul glue_helper snd_pcm snd_timer snd ftdi_sio ablk_helper cryptd eeepc_wmi intel_cstate intel_rapl_perf soundcore asus_wmi sparse_keymap rfkill mei_me video iTCO_wdt mei i2c_algo_bit iTCO_vendor_support mxm_wmi sg lpc_ich mfd_core i2c_i801 shpchp wmi nfsd nfs_acl lockd grace auth_rpcgss sunrpc
ip_tables ext4 jbd2 mbcache sr_mod sd_mod cdrom crc32c_intel serio_raw ahci libahci libata e1000e ptp pps_core fjes i2c_dev
[ 1905.322441] CPU: 0 PID: 15051 Comm: simultaneous_wr Tainted: G           O    4.7.5-1.el7.elrepo.x86_64 #1
[ 1905.322455] Hardware name: KALRAY DEVELOPER/RAMPAGE IV GENE, BIOS 3204-1 11/19/2012
[ 1905.322468] task: ffff88042c179680 ti: ffff8803dab30000 task.ti: ffff8803dab30000
[ 1905.322480] RIP: 0010:[<ffffffff811f5de4>]  [<ffffffff811f5de4>] put_huge_zero_page+0x14/0x20
[ 1905.322504] RSP: 0018:ffff8803dab33ce8  EFLAGS: 00010046
[ 1905.322512] RAX: ffffea000f690000 RBX: 0000000000000001 RCX: ffffea000f690000
[ 1905.322521] RDX: ffff8803dab33d18 RSI: ffff8803dab33d18 RDI: ffffea000fe424e0
[ 1905.322529] RBP: ffff8803dab33ce8 R08: ffff8803dab33d18 R09: 0000000000000000
[ 1905.322537] R10: ffffea000fe424e0 R11: 0000000000000000 R12: ffff8803dab33e68
[ 1905.322546] R13: ffffea000fe424c0 R14: ffff8803dab33e38 R15: ffff88043ffdbd80
[ 1905.322555] FS:  00007f07c76f6740(0000) GS:ffff88043fc00000(0000) knlGS:0000000000000000
[ 1905.322568] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1905.322576] CR2: 00007f07c70600d0 CR3: 00000003dab39000 CR4: 00000000000406f0
[ 1905.322585] Stack:
[ 1905.322592]  ffff8803dab33d58 ffffffff811990b9 ffff88042f01c350 0000000000000001
[ 1905.322611]  ffffea000fe424e0 0000000000000246 ffffea000fe424e0 ffffea000fe424e0
[ 1905.322629]  000000009b255e4f ffff8803dab33e68 ffffea000f690000 ffff8803dab33e68
[ 1905.322649] Call Trace:
[ 1905.322664]  [<ffffffff811990b9>] release_pages+0x2a9/0x340
[ 1905.322676]  [<ffffffff811d199a>] free_pages_and_swap_cache+0x8a/0xa0
[ 1905.322686]  [<ffffffff811b8ba6>] tlb_flush_mmu_free+0x36/0x60
[ 1905.322695]  [<ffffffff811b9e6c>] tlb_finish_mmu+0x1c/0x50
[ 1905.322705]  [<ffffffff811c20d4>] unmap_region+0xf4/0x130
[ 1905.322716]  [<ffffffff811c4707>] do_munmap+0x217/0x370
[ 1905.322726]  [<ffffffff811c4e21>] SyS_munmap+0x51/0x70
[ 1905.322738]  [<ffffffff81003b12>] do_syscall_64+0x62/0x110
[ 1905.322749]  [<ffffffff817227e1>] entry_SYSCALL64_slow_path+0x25/0x25
[ 1905.322758] Code: 02 00 00 00 48 8b 3d 3c c9 b6 00 eb 8a 65 48 ff 05 02 d5 e1 7e eb 80 66 66 66 66 90 55 48 89 e5 f0 ff 0d 20 1b fb 00 74 02 5d c3 <0f> 0b 66 2e 0f 1f 84 00 00 00 00 00 66 66 66 66 90 f6 46 50 02
[ 1905.322896] RIP  [<ffffffff811f5de4>] put_huge_zero_page+0x14/0x20
[ 1905.322908]  RSP <ffff8803dab33ce8>
[ 1905.322923] ---[ end trace 9b58553cd98c0019 ]---
[ 1905.322932] Kernel panic - not syncing: Fatal exception
[ 1905.322990] Kernel Offset: disabled
[ 1905.323000] ---[ end Kernel panic - not syncing: Fatal exception
-----------------

I tried replacing the release_pages by a call to put_page for each page and it works. Also disabling thp works with both version of the driver.

Is it just pure luck if the crash disappeared ?
Should we not use release_pages in this case?

Thanks in advance

Nicolas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
