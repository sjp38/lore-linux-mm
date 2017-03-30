Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B7D5E6B0397
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 02:44:28 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id b10so35035388pgn.8
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 23:44:28 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0108.outbound.protection.outlook.com. [104.47.0.108])
        by mx.google.com with ESMTPS id w9si1221160plk.296.2017.03.29.23.44.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 29 Mar 2017 23:44:27 -0700 (PDT)
From: Tommi Rantala <tommi.t.rantala@nokia.com>
Subject: sudo x86info -a => kernel BUG at mm/usercopy.c:78!
Message-ID: <d928849c-e7c3-6b81-e551-a39fa976f341@nokia.com>
Date: Thu, 30 Mar 2017 09:44:20 +0300
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@redhat.com>, Ingo Molnar <mingo@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Mark Rutland <mark.rutland@arm.com>, Eric Biggers <ebiggers@google.com>, davej@codemonkey.org.uk

Hi,

Running:

   $ sudo x86info -a

On this HP ZBook 15 G3 laptop kills the x86info process with segfault 
and produces the following kernel BUG.

   $ git describe
   v4.11-rc4-40-gfe82203

It is also reproducible with the fedora kernel: 4.9.14-200.fc25.x86_64

Full dmesg output here: https://pastebin.com/raw/Kur2mpZq

[   51.418954] usercopy: kernel memory exposure attempt detected from 
ffff880000090000 (dma-kmalloc-256) (4096 bytes)
[   51.418959] ------------[ cut here ]------------
[   51.418968] kernel BUG at /home/tomranta/git/linux/mm/usercopy.c:78!
[   51.418970] invalid opcode: 0000 [#1] SMP
[   51.418972] Modules linked in: fuse ccm ipt_REJECT nf_reject_ipv4 
xt_tcpudp tun af_packet xt_conntrack nf_conntrack libcrc32c ebtable_nat 
ebtable_broute bridge ip6table_mangle ip6table_raw iptable_mangle 
iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables 
iptable_filter ip_tables x_tables nls_iso8859_1 nls_cp437 vfat fat 
dm_mirror dm_region_hash dm_log arc4 hp_wmi sparse_keymap coretemp 
kvm_intel snd_hda_codec_hdmi kvm irqbypass pcbc aesni_intel aes_x86_64 
crypto_simd cryptd glue_helper intel_cstate intel_uncore intel_rapl_perf 
iwlmvm mac80211 snd_usb_audio mousedev snd_usbmidi_lib snd_rawmidi 
input_leds snd_hda_codec_conexant snd_hda_codec_generic efivars iwlwifi 
uvcvideo videobuf2_vmalloc videobuf2_memops snd_hda_intel videobuf2_v4l2 
cfg80211 videobuf2_core snd_hda_codec snd_seq snd_hwdep
[   51.419010]  snd_seq_device snd_hda_core snd_pcm thermal hp_accel 
lis3lv02d input_polldev ac acpi_pad battery led_class evdev hp_wireless 
nfsd lockd grace sunrpc tg3 libphy crc32_pclmul crc32c_intel e1000e 
sd_mod 8021q garp stp llc mrp unix autofs4
[   51.419025] CPU: 7 PID: 2406 Comm: x86info Not tainted 
4.11.0-rc4-tommi+ #14
[   51.419027] Hardware name: HP HP ZBook 15 G3/80D5, BIOS N81 Ver. 
01.12 11/01/2016
[   51.419030] task: ffff88026ce84100 task.stack: ffffc90003b94000
[   51.419035] RIP: 0010:__check_object_size+0xfd/0x195
[   51.419037] RSP: 0018:ffffc90003b97de0 EFLAGS: 00010282
[   51.419039] RAX: 0000000000000066 RBX: ffff880000090000 RCX: 
0000000000000000
[   51.419042] RDX: ffff8802bddd33e8 RSI: ffff8802bddcc9e8 RDI: 
ffff8802bddcc9e8
[   51.419044] RBP: ffffc90003b97e00 R08: 000000000006648a R09: 
000000000000048b
[   51.419046] R10: 0000000000000100 R11: ffffffff81e9a86d R12: 
0000000000001000
[   51.419049] R13: 0000000000000001 R14: ffff880000091000 R15: 
ffff880000090000
[   51.419051] FS:  00007f8323436b40(0000) GS:ffff8802bddc0000(0000) 
knlGS:0000000000000000
[   51.419054] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   51.419056] CR2: 00007ffcbec21000 CR3: 000000026c8e8000 CR4: 
00000000003406a0
[   51.419058] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
0000000000000000
[   51.419061] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 
0000000000000400
[   51.419063] Call Trace:
[   51.419066]  read_mem+0x70/0x120
[   51.419069]  __vfs_read+0x28/0x130
[   51.419072]  ? security_file_permission+0x9b/0xb0
[   51.419075]  ? rw_verify_area+0x4e/0xb0
[   51.419077]  vfs_read+0x96/0x130
[   51.419079]  SyS_read+0x46/0xb0
[   51.419082]  ? SyS_lseek+0x87/0xb0
[   51.419085]  entry_SYSCALL_64_fastpath+0x1a/0xa9
[   51.419087] RIP: 0033:0x7f8322d56bd0
[   51.419089] RSP: 002b:00007ffcbec11c68 EFLAGS: 00000246 ORIG_RAX: 
0000000000000000
[   51.419091] RAX: ffffffffffffffda RBX: 0000000000000006 RCX: 
00007f8322d56bd0
[   51.419094] RDX: 0000000000010000 RSI: 00007ffcbec11ca0 RDI: 
0000000000000003
[   51.419096] RBP: 0000000000000008 R08: 0000000000000005 R09: 
0000000000000050
[   51.419098] R10: 0000000000000000 R11: 0000000000000246 R12: 
0000000002231c00
[   51.419100] R13: 00007ffcbec11c9e R14: 00007ffcbec51cf8 R15: 
0000000000000000
[   51.419103] Code: a8 81 48 c7 c2 29 69 a4 81 48 c7 c6 82 89 a5 81 48 
0f 45 d0 48 c7 c0 1a 1e a6 81 48 c7 c7 d0 ed a5 81 48 0f 45 f0 e8 7f 74 
f8 ff <0f> 0b 48 89 df e8 29 98 e8 ff 84 c0 0f 84 3a ff ff ff b8 00 00
[   51.419123] RIP: __check_object_size+0xfd/0x195 RSP: ffffc90003b97de0
[   51.421565] ---[ end trace 441f7992ca25e39d ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
