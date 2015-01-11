Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 658C46B0082
	for <linux-mm@kvack.org>; Sun, 11 Jan 2015 06:32:36 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id fl12so25627438pdb.11
        for <linux-mm@kvack.org>; Sun, 11 Jan 2015 03:32:36 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id si4si20169488pab.20.2015.01.11.03.32.33
        for <linux-mm@kvack.org>;
        Sun, 11 Jan 2015 03:32:34 -0800 (PST)
Received: from localhost ([127.0.0.1] ident=amarsh04)
	by victoria with esmtp (Exim 4.84)
	(envelope-from <arthur.marsh@internode.on.net>)
	id 1YAGkl-0001eg-7j
	for linux-mm@kvack.org; Sun, 11 Jan 2015 22:02:19 +1030
Message-ID: <54B25F43.6020608@internode.on.net>
Date: Sun, 11 Jan 2015 22:02:19 +1030
From: Arthur Marsh <arthur.marsh@internode.on.net>
MIME-Version: 1.0
Subject: kernel BUG at mm/rmap.c:399! part 2
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

This happened on an AMD64 machine running current Linus' git head in 64 
bit mode straight after vlc crashed:

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Initializing cgroup subsys cpuacct
[    0.000000] Linux version 3.19.0-rc3+ (root@am64) (gcc version 4.9.2 
(Debian 4.9.2-10) ) #1452 SMP PREEMPT Sat Jan 10 17:48:48 ACDT 2015

[ 3292.010716] vlc[7254]: segfault at 7f5638087000 ip 00007f561393a232 
sp 00007f5632fb47a0 error 6 in libvdpau_r600.so.1.0.0[7f5613879000+376000]
[ 3412.519619] radeon 0000:01:00.0: ring 0 stalled for more than 10000msec
[ 3412.519626] radeon 0000:01:00.0: GPU lockup (current fence id 
0x000000000005fbde last fence id 0x000000000005fbe8 on ring 0)
[ 3412.526917] radeon 0000:01:00.0: Saved 313 dwords of commands on ring 0.
[ 3412.526932] radeon 0000:01:00.0: GPU softreset: 0x00000009
[ 3412.526935] radeon 0000:01:00.0:   R_008010_GRBM_STATUS      = 0xE7733030
[ 3412.526937] radeon 0000:01:00.0:   R_008014_GRBM_STATUS2     = 0x00FF0103
[ 3412.526939] radeon 0000:01:00.0:   R_000E50_SRBM_STATUS      = 0x200400C0
[ 3412.526941] radeon 0000:01:00.0:   R_008674_CP_STALLED_STAT1 = 0x00000000
[ 3412.526943] radeon 0000:01:00.0:   R_008678_CP_STALLED_STAT2 = 0x00008002
[ 3412.526945] radeon 0000:01:00.0:   R_00867C_CP_BUSY_STAT     = 0x00008086
[ 3412.526947] radeon 0000:01:00.0:   R_008680_CP_STAT          = 0x80018645
[ 3412.526950] radeon 0000:01:00.0:   R_00D034_DMA_STATUS_REG   = 0x44C83D57
[ 3412.590365] radeon 0000:01:00.0: R_008020_GRBM_SOFT_RESET=0x00007FEF
[ 3412.590418] radeon 0000:01:00.0: SRBM_SOFT_RESET=0x00000100
[ 3412.592503] radeon 0000:01:00.0:   R_008010_GRBM_STATUS      = 0xA0003030
[ 3412.592506] radeon 0000:01:00.0:   R_008014_GRBM_STATUS2     = 0x00000003
[ 3412.592508] radeon 0000:01:00.0:   R_000E50_SRBM_STATUS      = 0x200480C0
[ 3412.592510] radeon 0000:01:00.0:   R_008674_CP_STALLED_STAT1 = 0x00000000
[ 3412.592512] radeon 0000:01:00.0:   R_008678_CP_STALLED_STAT2 = 0x00000000
[ 3412.592514] radeon 0000:01:00.0:   R_00867C_CP_BUSY_STAT     = 0x00000000
[ 3412.592516] radeon 0000:01:00.0:   R_008680_CP_STAT          = 0x80100000
[ 3412.592518] radeon 0000:01:00.0:   R_00D034_DMA_STATUS_REG   = 0x44C83D57
[ 3412.592524] radeon 0000:01:00.0: GPU reset succeeded, trying to resume
[ 3412.608224] [drm] PCIE gen 2 link speeds already enabled
[ 3412.609356] [drm] PCIE GART of 512M enabled (table at 
0x0000000000254000).
[ 3412.609380] radeon 0000:01:00.0: WB enabled
[ 3412.609384] radeon 0000:01:00.0: fence driver on ring 0 use gpu addr 
0x0000000020000c00 and cpu addr 0xffff880224008c00
[ 3412.609753] radeon 0000:01:00.0: fence driver on ring 5 use gpu addr 
0x00000000000521d0 and cpu addr 0xffffc900101921d0
[ 3412.640570] [drm] ring test on 0 succeeded in 0 usecs
[ 3412.814984] [drm] ring test on 5 succeeded in 1 usecs
[ 3412.814990] [drm] UVD initialized successfully.
[ 3423.000575] radeon 0000:01:00.0: ring 0 stalled for more than 10204msec
[ 3423.000583] radeon 0000:01:00.0: GPU lockup (current fence id 
0x000000000005fbe0 last fence id 0x000000000005fbe8 on ring 0)
[ 3423.000735] [drm:r600_ib_test [radeon]] *ERROR* radeon: fence wait 
failed (-35).
[ 3423.000771] [drm:radeon_ib_ring_tests [radeon]] *ERROR* radeon: 
failed testing IB on GFX ring (-35).
[ 3423.120222] vlc[7337]: segfault at 7f3bb41b6000 ip 00007f3bbd6ef232 
sp 00007f3bd8c457a0 error 6 in libvdpau_r600.so.1.0.0[7f3bbd62e000+376000]
[ 3432.509934] ------------[ cut here ]------------
[ 3432.509971] kernel BUG at mm/rmap.c:399!
[ 3432.509992] invalid opcode: 0000 [#1] PREEMPT SMP
[ 3432.510022] Modules linked in: rfcomm arc4 ecb md4 hmac nls_utf8 cifs 
dns_resolver fscache bnep bluetooth nfc cpufreq_userspace 
cpufreq_conservative rfkill cpufreq_stats cpufreq_powersave binfmt_misc 
uinput max6650 fuse parport_pc ppdev lp parport ir_lirc_codec 
ir_sharp_decoder ir_mce_kbd_decoder ir_jvc_decoder ir_sanyo_decoder 
ir_xmp_decoder lirc_dev ir_rc5_decoder ir_sony_decoder ir_rc6_decoder 
ir_nec_decoder fc0012 snd_hda_codec_hdmi dvb_usb_rtl28xxu rtl2830 
rtl2832 i2c_mux dvb_usb_v2 dvb_core rc_core snd_hda_codec_realtek 
snd_hda_codec_generic snd_hda_intel snd_hda_controller snd_hda_codec 
snd_hwdep snd_pcm_oss kvm_amd snd_mixer_oss radeon kvm snd_pcm ttm 
psmouse snd_timer pcspkr snd soundcore evdev k10temp serio_raw 
drm_kms_helper sp5100_tco acpi_cpufreq drm i2c_algo_bit i2c_piix4 wmi 
processor
[ 3432.510482]  thermal_sys asus_atk0110 button ext4 mbcache crc16 jbd2 
sg sr_mod cdrom sd_mod ata_generic uas usb_storage ohci_pci ahci libahci 
pata_atiixp libata scsi_mod ohci_hcd ehci_pci ehci_hcd usbcore 
usb_common r8169 mii
[ 3432.510620] CPU: 0 PID: 4880 Comm: JS GC Helper Not tainted 
3.19.0-rc3+ #1452
[ 3432.510655] Hardware name: System manufacturer System Product 
Name/M3A78 PRO, BIOS 1701    01/27/2011
[ 3432.510698] task: ffff8800acc80790 ti: ffff8800b8478000 task.ti: 
ffff8800b8478000
[ 3432.510734] RIP: 0010:[<ffffffff81172f35>]  [<ffffffff81172f35>] 
unlink_anon_vmas+0x195/0x210
[ 3432.510780] RSP: 0000:ffff8800b847bb68  EFLAGS: 00010286
[ 3432.510806] RAX: ffff880075fdfd10 RBX: ffff880206098760 RCX: 
00000000ffffffff
[ 3432.510839] RDX: ffffffff00000001 RSI: ffff880075fdfd00 RDI: 
ffff8802249e8160
[ 3432.510873] RBP: ffff8800b847bba8 R08: 0000000000000000 R09: 
0000000000000001
[ 3432.510907] R10: 0000000000000000 R11: ffff880075fdfd20 R12: 
ffff8802249e8160
[ 3432.510940] R13: ffff880206098760 R14: ffff880206098770 R15: 
ffff8802249e8160
[ 3432.510974] FS:  00007f2f77eeb700(0000) GS:ffff88022fc00000(0000) 
knlGS:0000000000000000
[ 3432.511012] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 3432.511040] CR2: 00000000004d8800 CR3: 0000000001a0e000 CR4: 
00000000000007f0
[ 3432.511073] Stack:
[ 3432.511085]  ffff8800b847bb78 ffff8802060986f8 ffff8800b847bba8 
ffff88004c16f858
[ 3432.511127]  00007f2ed3000000 0000000000000000 ffff8800b847bc18 
ffff8802060986f8
[ 3432.511169]  ffff8800b847bbf8 ffffffff81164760 ffff8800b847bbf8 
0000000000000000
[ 3432.511210] Call Trace:
[ 3432.511228]  [<ffffffff81164760>] free_pgtables+0xa0/0x120
[ 3432.511256]  [<ffffffff8116f1be>] exit_mmap+0xae/0x170
[ 3432.511283]  [<ffffffff8104f70d>] mmput+0x4d/0x110
[ 3432.511308]  [<ffffffff8105530f>] do_exit+0x2af/0xb30
[ 3432.511334]  [<ffffffff8153e38b>] ? _raw_spin_unlock_irq+0x2b/0x60
[ 3432.511365]  [<ffffffff81055c1f>] do_group_exit+0x4f/0xe0
[ 3432.511393]  [<ffffffff81061af6>] get_signal+0x2c6/0x7f0
[ 3432.511421]  [<ffffffff8100251e>] do_signal+0x2e/0x760
[ 3432.511447]  [<ffffffff810935be>] ? up_read+0x1e/0x40
[ 3432.511473]  [<ffffffff8153e39c>] ? _raw_spin_unlock_irq+0x3c/0x60
[ 3432.511504]  [<ffffffff8107610f>] ? finish_task_switch+0x8f/0x140
[ 3432.511535]  [<ffffffff8153efb1>] ? sysret_signal+0x5/0x4a
[ 3432.511562]  [<ffffffff81002cc8>] do_notify_resume+0x78/0xa0
[ 3432.511591]  [<ffffffff8153f247>] int_signal+0x12/0x17
[ 3432.511616] Code: 48 89 46 18 e8 ed 54 01 00 48 8b 43 10 48 8d 53 10 
48 83 e8 10 49 39 d6 74 3c 48 8b 7b 08 48 89 de 8b 97 8c 00 00 00 85 d2 
74 9b <0f> 0b 90 48 89 75 c8 e8 bf fd ff ff 48 8b 75 c8 eb 95 48 8b 45
[ 3432.511831] RIP  [<ffffffff81172f35>] unlink_anon_vmas+0x195/0x210
[ 3432.511863]  RSP <ffff8800b847bb68>
[ 3432.511927] ---[ end trace ec049a8f8b1d1018 ]---
[ 3432.511954] Fixing recursive fault but reboot is needed!

As before, I'm happy to supply further information or run tests to help 
isolate the problem.

Arthur.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
