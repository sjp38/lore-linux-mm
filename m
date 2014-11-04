From: Borislav Petkov <bp@alien8.de>
Subject: 18-rc3+: ODEBUG: assert_init not available (active state 0) object
 type: timer_list hint: stub_timer
Date: Tue, 4 Nov 2014 22:43:27 +0100
Message-ID: <20141104214327.GE14296@pd.tnic>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: linux-mm@kvack.org
Cc: lkml <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Hi,

I see the following splat on rc3+ of today when doing a suspend/resume
cycle. My suspend script does

echo 3 > /proc/sys/vm/drop_caches

and this maybe is related, judging by the code the splat points to:
page-writeback.c

>From looking at this a bit, there's some already freed timer we're
touching in laptop_sync_completion(), probably already freed in
blk_cleanup_queue(). Hmm...

[  106.615059] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[  113.317145] ------------[ cut here ]------------
[  113.319022] WARNING: CPU: 1 PID: 4006 at lib/debugobjects.c:263 debug_print_object+0x8b/0xa0()
[  113.320970] ODEBUG: assert_init not available (active state 0) object type: timer_list hint: stub_timer+0x0/
0x20
[  113.322866] Modules linked in: cpufreq_stats cpufreq_conservative cpufreq_powersave cpufreq_userspace binfmt
_misc uinput ipv6 vfat fat snd_hda_codec_conexant snd_hda_codec_generic snd_hda_codec_hdmi arc4 rtl8192ce rtl_p
ci rtl8192c_common rtlwifi pcspkr evdev mac80211 k10temp cfg80211 snd_hda_intel snd_hda_controller snd_hda_code
c snd_hwdep thinkpad_acpi nvram snd_pcm snd_seq snd_seq_device snd_timer radeon snd video soundcore battery drm
_kms_helper ac ttm button rtsx_pci_sdmmc mmc_core rtsx_pci mfd_core ehci_pci ohci_pci ohci_hcd ehci_hcd thermal
[  113.327292] CPU: 1 PID: 4006 Comm: sync Not tainted 3.18.0-rc3+ #1
[  113.327294] Hardware name: LENOVO 30515QG/30515QG, BIOS 8RET30WW (1.12 ) 09/15/2011
[  113.327297]  0000000000000009 ffff8800ba2f3d98 ffffffff8155dbc4 ffffffff810b3d56
[  113.327303]  ffff8800ba2f3de8 ffff8800ba2f3dd8 ffffffff810721ac ffff8800ba2f3e08
[  113.327308]  ffff8800ba2f3e88 ffffffff81a3bf60 ffffffff817fb9e5 ffffffff82b46508
[  113.327314] Call Trace:
[  113.327317]  [<ffffffff8155dbc4>] dump_stack+0x4f/0x7c
[  113.327326]  [<ffffffff810b3d56>] ? down_trylock+0x36/0x50
[  113.327331]  [<ffffffff810721ac>] warn_slowpath_common+0x8c/0xc0
[  113.327337]  [<ffffffff81072226>] warn_slowpath_fmt+0x46/0x50
[  113.327341]  [<ffffffff810d8b3c>] ? do_init_timer+0x5c/0x60
[  113.327345]  [<ffffffff812b992b>] debug_print_object+0x8b/0xa0
[  113.327349]  [<ffffffff810d8aa0>] ? ftrace_raw_event_tick_stop+0xe0/0xe0
[  113.327353]  [<ffffffff812ba621>] debug_object_assert_init+0x101/0x140
[  113.327358]  [<ffffffff811529d5>] ? laptop_sync_completion+0x5/0xa0
[  113.327364]  [<ffffffff810d9a4f>] del_timer+0x1f/0x70
[  113.327367]  [<ffffffff81152a2c>] laptop_sync_completion+0x5c/0xa0
[  113.327371]  [<ffffffff811529d5>] ? laptop_sync_completion+0x5/0xa0
[  113.327375]  [<ffffffff811d82d5>] sys_sync+0x85/0x90
[  113.327379]  [<ffffffff815672d2>] system_call_fastpath+0x12/0x17
[  113.327386] ---[ end trace 97d71e72cfb411a7 ]---
[  113.576302] hib.sh (4003): drop_caches: 3
[  115.126304] PM: Syncing filesystems ... done.

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--
