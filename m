Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 51B676B0032
	for <linux-mm@kvack.org>; Fri, 16 Jan 2015 10:21:57 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kq14so24769116pab.12
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 07:21:57 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id qo8si5681194pdb.246.2015.01.16.07.21.54
        for <linux-mm@kvack.org>;
        Fri, 16 Jan 2015 07:21:55 -0800 (PST)
Received: from localhost ([127.0.0.1] ident=amarsh04)
	by victoria with esmtp (Exim 4.84)
	(envelope-from <arthur.marsh@internode.on.net>)
	id 1YC8iY-0001X0-29
	for linux-mm@kvack.org; Sat, 17 Jan 2015 01:51:46 +1030
Message-ID: <54B92C89.3030400@internode.on.net>
Date: Sat, 17 Jan 2015 01:51:45 +1030
From: Arthur Marsh <arthur.marsh@internode.on.net>
MIME-Version: 1.0
Subject: BUG: Bad page state in process chromium  pfn:375a0 3.19.0-rcx on
 amd64
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Running current Linus' git head 64 bit kernel on 4-core AMD64, I've seen 
the occasional problem like the following when restarting chromium on 
Debian unstable and resuming lots of windows and tabs:

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Initializing cgroup subsys cpuacct
[    0.000000] Linux version 3.19.0-rc4+ (root@am64) (gcc version 4.9.2 
(Debian 4.9.2-10) ) #1464 SMP PREEMPT Fri Jan 16 15:38:48 ACDT 2015
...
[  645.729360] BUG: Bad page state in process chromium  pfn:375a0
[  645.729368] page:ffffea0000dd6800 count:0 mapcount:0 mapping: 
   (null) index:0x2
[  645.729371] flags: 
0x400000000000fdb0(dirty|lru|slab|owner_priv_1|reserved|private|private_2|writeback|head|tail)
[  645.729382] page dumped because: PAGE_FLAGS_CHECK_AT_PREP flag set
[  645.729383] bad because of flags:
[  645.729384] flags: 
0xfdb0(dirty|lru|slab|owner_priv_1|reserved|private|private_2|writeback|head|tail)
[  645.729392] Modules linked in: rfcomm arc4 ecb md4 hmac nls_utf8 cifs 
dns_resolver fscache cpufreq_userspace cpufreq_conservative 
cpufreq_stats nfc bnep bluetooth rfkill cpufreq_powersave binfmt_misc 
uinput max6650 fuse parport_pc ppdev lp parport ir_sharp_decoder 
ir_mce_kbd_decoder ir_lirc_codec ir_jvc_decoder ir_xmp_decoder 
ir_sanyo_decoder lirc_dev ir_rc5_decoder ir_sony_decoder ir_rc6_decoder 
ir_nec_decoder fc0012 dvb_usb_rtl28xxu rtl2830 rtl2832 i2c_mux 
dvb_usb_v2 dvb_core rc_core radeon snd_hda_codec_realtek 
snd_hda_codec_generic snd_hda_codec_hdmi snd_hda_intel kvm_amd 
snd_hda_controller kvm snd_hda_codec snd_hwdep snd_pcm_oss ttm 
snd_mixer_oss psmouse snd_pcm pcspkr drm_kms_helper edac_mce_amd 
edac_core evdev k10temp sp5100_tco drm snd_timer i2c_piix4 serio_raw 
acpi_cpufreq snd processor
[  645.729445]  i2c_algo_bit asus_atk0110 thermal_sys soundcore wmi 
button ext4 mbcache crc16 jbd2 sg sr_mod cdrom sd_mod ata_generic uas 
usb_storage ohci_pci ahci pata_atiixp libahci libata r8169 ohci_hcd 
scsi_mod mii ehci_pci ehci_hcd usbcore usb_common
[  645.729469] CPU: 1 PID: 5868 Comm: chromium Not tainted 3.19.0-rc4+ #1464
[  645.729471] Hardware name: System manufacturer System Product 
Name/M3A78 PRO, BIOS 1701    01/27/2011
[  645.729473]  ffffffff817eb9d0 ffff88018880b918 ffffffff81536de2 
0000000000000000
[  645.729477]  ffffea0000dd6800 ffff88018880b948 ffffffff8113caf0 
ffffffff81aa8700
[  645.729480]  ffffffff81aa8700 0000000000000000 0000000000000246 
ffff88018880ba18
[  645.729484] Call Trace:
[  645.729491]  [<ffffffff81536de2>] dump_stack+0x4f/0x7b
[  645.729495]  [<ffffffff8113caf0>] bad_page+0xc0/0x110
[  645.729499]  [<ffffffff8114046f>] get_page_from_freelist+0x2ff/0x780
[  645.729502]  [<ffffffff81140c11>] __alloc_pages_nodemask+0x1d1/0xbb0
[  645.729507]  [<ffffffff81151d17>] shmem_getpage_gfp+0x527/0x8e0
[  645.729510]  [<ffffffff811526d6>] shmem_fault+0x66/0x1c0
[  645.729513]  [<ffffffff8107bf61>] ? get_parent_ip+0x11/0x50
[  645.729517]  [<ffffffff81163ea4>] __do_fault+0x34/0x70
[  645.729520]  [<ffffffff81166998>] do_shared_fault.isra.67+0x38/0x1f0
[  645.729522]  [<ffffffff8116800f>] handle_mm_fault+0x2df/0xe90
[  645.729526]  [<ffffffff810465ed>] ? __do_page_fault+0x13d/0x600
[  645.729530]  [<ffffffff811e17a3>] ? fsnotify+0x63/0x4f0
[  645.729532]  [<ffffffff8104664c>] __do_page_fault+0x19c/0x600
[  645.729536]  [<ffffffff8119f28c>] ? vfs_write+0x16c/0x1f0
[  645.729540]  [<ffffffff81540160>] ? retint_swapgs+0x13/0x1b
[  645.729543]  [<ffffffff812befaa>] ? trace_hardirqs_off_thunk+0x3a/0x3f
[  645.729545]  [<ffffffff81046adb>] do_page_fault+0x2b/0x40
[  645.729548]  [<ffffffff81541358>] page_fault+0x28/0x30
[  645.729550] Disabling lock debugging due to kernel taint
[  688.320454] netlink: 128 bytes leftover after parsing attributes in 
process `kded4'.
[  688.320465] netlink: 128 bytes leftover after parsing attributes in 
process `kded4'.
[  688.320502] netlink: 128 bytes leftover after parsing attributes in 
process `kded4'.
[  718.312585] netlink: 128 bytes leftover after parsing attributes in 
process `kded4'.
[  718.312594] netlink: 128 bytes leftover after parsing attributes in 
process `kded4'.
[  718.312629] netlink: 128 bytes leftover after parsing attributes in 
process `kded4'.

It doesn't happen every time, but has happened a few times in the 
3.19.0-rcx kernels. When it does, one of the windows in chromium fails 
to be restored.

Chromium version reported is: 39.0.2171.71-2

I'm happy to supply any further details and test patches.

Arthur.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
