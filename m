Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4B9066B0005
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 10:33:44 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id w8so40675405ybe.1
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 07:33:44 -0700 (PDT)
Received: from mail-qt0-f181.google.com (mail-qt0-f181.google.com. [209.85.216.181])
        by mx.google.com with ESMTPS id u184si24322450qkh.319.2016.08.10.07.33.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Aug 2016 07:33:43 -0700 (PDT)
Received: by mail-qt0-f181.google.com with SMTP id u25so21631641qtb.1
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 07:33:43 -0700 (PDT)
From: Laura Abbott <labbott@redhat.com>
Subject: [REGRESSION] !PageLocked(page) assertion with tcpdump
Message-ID: <c711e067-0bff-a6cb-3c37-04dfe77d2db1@redhat.com>
Date: Wed, 10 Aug 2016 07:33:38 -0700
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Hi,

There have been several reports[1] of assertions tripping when using
tcpdump on the latest master:

[ 1013.718212] device wlp2s0 entered promiscuous mode
[ 1013.736003] page:ffffea0004380000 count:2 mapcount:0 mapping:
(null) index:0x0 compound_mapcount: 0
[ 1013.736013] flags: 0x17ffffc0004000(head)
[ 1013.736017] page dumped because: VM_BUG_ON_PAGE(!PageLocked(page))
[ 1013.736044] ------------[ cut here ]------------
[ 1013.736091] kernel BUG at mm/rmap.c:1288!
[ 1013.736113] invalid opcode: 0000 [#1] SMP
[ 1013.736145] Modules linked in: nfnetlink_queue nfnetlink_log nfnetlink
rfcomm fuse target_core_mod ccm bnep arc4 uvcvideo iwldvm videobuf2_vmalloc
mac80211 snd_hda_codec_hdmi videobuf2_memops snd_hda_codec_realtek intel_rapl
videobuf2_v4l2 x86_pkg_temp_thermal intel_powerclamp coretemp kvm_intel
iTCO_wdt videobuf2_core snd_hda_codec_generic btusb kvm iTCO_vendor_support
iwlwifi snd_hda_intel irqbypass snd_hda_codec btrtl crct10dif_pclmul
crc32_pclmul ghash_clmulni_intel snd_hda_core videodev cfg80211 intel_cstate
btbcm rtsx_pci_ms intel_uncore btintel joydev media snd_hwdep memstick
bluetooth intel_rapl_perf snd_seq snd_seq_device snd_pcm acpi_als mei_me
kfifo_buf industrialio sony_laptop snd_timer rfkill i2c_i801 mei lpc_ich fjes
tpm_tis tpm_tis_core tpm snd soundcore shpchp i2c_smbus btrfs xor
[ 1013.736793]  raid6_pq amdkfd amd_iommu_v2 rtsx_pci_sdmmc i915 mmc_core
radeon crc32c_intel i2c_algo_bit serio_raw ttm drm_kms_helper drm r8169
rtsx_pci mii video
[ 1013.736925] CPU: 2 PID: 5013 Comm: tcpdump Not tainted
4.8.0-0.rc0.git5.1.fc26.x86_64 #1
[ 1013.736982] Hardware name: Sony Corporation VPCSB2M9E/VAIO, BIOS R2087H4
06/15/2012
[ 1013.737039] task: ffffa25a4dc48000 task.stack: ffffa25910b3c000
[ 1013.737080] RIP: 0010:[<ffffffffaa249157>]  [<ffffffffaa249157>]
page_add_file_rmap+0x1d7/0x200
[ 1013.737139] RSP: 0018:ffffa25910b3fc70  EFLAGS: 00010246
[ 1013.737169] RAX: 0000000000000000 RBX: ffffea0004380000 RCX:
0000000000000006
[ 1013.737217] RDX: 0000000000000007 RSI: 0000000000000000 RDI:
ffffa25a569ce2a0
[ 1013.737265] RBP: ffffa25910b3fc80 R08: 0000000000000001 R09:
0000000000000001
[ 1013.737308] R10: ffffa25a4dc48000 R11: 000000000000081a R12:
ffffea0004380000
[ 1013.737354] R13: ffffa259e7ed8000 R14: ffffa2590f090700 R15:
8000000000000027
[ 1013.737392] FS:  00007f7fe9ce9480(0000) GS:ffffa25a56800000(0000)
knlGS:0000000000000000
[ 1013.737444] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1013.737487] CR2: 00007fc53c7f7b20 CR3: 000000010ecbc000 CR4:
00000000000406e0
[ 1013.737526] Stack:
[ 1013.737539]  ffffea0004380000 00007f7fe88e0000 ffffa25910b3fcc8
ffffffffaa23dab6
[ 1013.737602]  ffffa259184a0168 00000000c61f7435 0000000000000000
ffffa2590ecca4e8
[ 1013.737658]  ffffa2590e000000 00007f7fe88e0000 ffffffff80000000
ffffa25910b3fd28
[ 1013.737724] Call Trace:
[ 1013.737750]  [<ffffffffaa23dab6>] vm_insert_page+0x126/0x230
[ 1013.737795]  [<ffffffffaa8cc6be>] packet_mmap+0x18e/0x1f0
[ 1013.737841]  [<ffffffffaa77518d>] sock_mmap+0x1d/0x20
[ 1013.737883]  [<ffffffffaa2443e5>] mmap_region+0x3a5/0x640
[ 1013.737928]  [<ffffffffaa244a9b>] do_mmap+0x41b/0x4d0
[ 1013.737969]  [<ffffffffaa2222fc>] ? vm_mmap_pgoff+0x8c/0x100
[ 1013.738013]  [<ffffffffaa22232d>] vm_mmap_pgoff+0xbd/0x100
[ 1013.738061]  [<ffffffffaa242551>] SyS_mmap_pgoff+0x1c1/0x290
[ 1013.738107]  [<ffffffffaa1830ab>] ? __audit_syscall_exit+0x1db/0x260
[ 1013.738155]  [<ffffffffaa033bab>] SyS_mmap+0x1b/0x30
[ 1013.738183]  [<ffffffffaa003efc>] do_syscall_64+0x6c/0x1e0
[ 1013.738221]  [<ffffffffaa8f823f>] entry_SYSCALL64_slow_path+0x25/0x25
[ 1013.738268] Code: c4 48 8b 00 a8 01 0f 85 fb fe ff ff 0f 0b 48 c7 c6 e8 40
c7 aa e8 2a ab fe ff 0f 0b 48 c7 c6 60 38 c7 aa 4c 89 e7 e8 19 ab fe ff <0f> 0b
48 c7 c6 60 50 c7 aa 4c 89 e7 e8 08 ab fe ff 0f 0b 48 c7
[ 1013.738627] RIP  [<ffffffffaa249157>] page_add_file_rmap+0x1d7/0x200
[ 1013.738681]  RSP <ffffa25910b3fc70>
[ 1013.746241] ---[ end trace 61301dcad33a4a75 ]---
[ 1013.746250] BUG: sleeping function called from invalid context at
./include/linux/sched.h:3049
[ 1013.746254] in_atomic(): 1, irqs_disabled(): 0, pid: 5013, name: tcpdump
[ 1013.746256] INFO: lockdep is turned off.
[ 1013.746261] CPU: 2 PID: 5013 Comm: tcpdump Tainted: G      D
4.8.0-0.rc0.git5.1.fc26.x86_64 #1
[ 1013.746264] Hardware name: Sony Corporation VPCSB2M9E/VAIO, BIOS R2087H4
06/15/2012
[ 1013.746267]  0000000000000286 00000000c61f7435 ffffa25910b3fe50
ffffffffaa465b63
[ 1013.746275]  ffffa25a4dc48000 ffffffffaac670f8 ffffa25910b3fe78
ffffffffaa0de759
[ 1013.746281]  ffffffffaac670f8 0000000000000be9 0000000000000000
ffffa25910b3fea0
[ 1013.746287] Call Trace:
[ 1013.746297]  [<ffffffffaa465b63>] dump_stack+0x86/0xc3
[ 1013.746303]  [<ffffffffaa0de759>] ___might_sleep+0x179/0x230
[ 1013.746307]  [<ffffffffaa0de859>] __might_sleep+0x49/0x80
[ 1013.746312]  [<ffffffffaa0c27b3>] exit_signals+0x33/0x160
[ 1013.746316]  [<ffffffffaa0b34d3>] do_exit+0xc3/0xd40
[ 1013.746322]  [<ffffffffaa8fa8b7>] rewind_stack_do_exit+0x17/0x20

This looks like the assertions added in 9a73f61bdb8a (thp, mlock: do
not mlock PTE-mapped file huge pages). I can confirm that just running
tcpdump is enough to trigger this. I saw there was another fix[2] to
one of the assertions but I don't think this the same situation since
CONFIG_TRANSPARENT_HUGEPAGE=y in my config.

Thanks,
Laura

[1] https://bugzilla.redhat.com/show_bug.cgi?id=1365686
[2] http://marc.info/?l=linux-mm&m=147083824730035

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
