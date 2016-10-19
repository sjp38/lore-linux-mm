Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 135646B0253
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 04:04:19 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f193so10752795wmg.4
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 01:04:19 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ir6si43968109wjb.2.2016.10.19.01.04.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Oct 2016 01:04:17 -0700 (PDT)
Subject: Re: [4.9-rc1] Unable to handle kernel paging request
References: <CAC1QiQHeviJA_bCDSgOqpX03nvMJE8J3h+=1vSj9BJDExTKz+A@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <231e548a-2940-4c1c-338d-e1cbc41d59b7@suse.cz>
Date: Wed, 19 Oct 2016 10:04:10 +0200
MIME-Version: 1.0
In-Reply-To: <CAC1QiQHeviJA_bCDSgOqpX03nvMJE8J3h+=1vSj9BJDExTKz+A@mail.gmail.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ryan Chan <ryan.chan105@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 10/18/2016 06:28 PM, Ryan Chan wrote:
> Hi all,
> The following  message appeared during bootup. May I know if this a known issue?
> I did not meet this problem in 4.8-rcx,
> My desktop becomes unstable after bootup now.
> thanks.

Hi,

is the backtrace always the same, especially the apparmor part, or are there 
differences? It looks like it just does a kzalloc(), but perhaps there's e.g. 
some double freeing that corrupts SL*B structures.

Can you provide your .config? Now we don't even know if it's SLAB or SLUB.

Also could you run the oopses through this script?
https://github.com/google/sanitizers/blob/master/address-sanitizer/tools/kasan_symbolize.py

Vlastimil

> [   22.594649] BUG: unable to handle kernel paging request at 0000000180040100
> [   22.601639] IP: [<ffffffff8f205a1b>] kmem_cache_alloc_trace+0x7b/0x1c0
> [   22.608183] PGD 0
>
> [   22.611519] Oops: 0000 [#1] SMP
> [   22.614659] Modules linked in: snd_hda_codec_hdmi nls_iso8859_1
> snd_hda_codec_realtek snd_hda_codec_generic snd_hda_intel snd_hda_codec
> snd_hda_core intel_rapl x86_pkg_temp_thermal snd_pcm intel_powerclamp snd_hwdep
> snd_seq_midi coretemp snd_seq_midi_event crct10dif_pclmul snd_rawmidi
> crc32_pclmul snd_seq ghash_clmulni_intel snd_timer snd_seq_device cryptd joydev
> input_leds serio_raw lpc_ich snd mei_me soundcore mei mac_hid shpchp parport_pc
> ppdev lp parport autofs4 hid_generic usbhid psmouse r8169 hid mii pata_acpi fjes
> video
> [   22.662064] CPU: 0 PID: 2687 Comm: systemd-udevd Not tainted 4.9.0-rc1+ #3
> [   22.668935] Hardware name: Gigabyte Technology Co., Ltd. To be filled by
> O.E.M./H61M-S2PH, BIOS F1 03/11/2013
> [   22.678844] task: ffff9a397d043900 task.stack: ffffa95b81f3c000
> [   22.684758] RIP: 0010:[<ffffffff8f205a1b>]  [<ffffffff8f205a1b>]
> kmem_cache_alloc_trace+0x7b/0x1c0
> [   22.693730] RSP: 0018:ffffa95b81f3fdf0  EFLAGS: 00010206
> [   22.699044] RAX: 0000000000000000 RBX: 00000000024080c0 RCX: 000000000000e748
> [   22.706175] RDX: 000000000000e747 RSI: 00000000024080c0 RDI: 000000000001c520
> [   22.713306] RBP: ffffa95b81f3fe30 R08: ffff9a399ec1c520 R09: ffff9a3996003cc0
> [   22.720429] R10: 0000000180040100 R11: ffff9a397d043900 R12: 00000000024080c0
> [   22.727553] R13: ffffffff8f3a1453 R14: ffffffff8fc9982a R15: ffff9a3996003cc0
> [   22.734678] FS:  00007f778f5ca8c0(0000) GS:ffff9a399ec00000(0000)
> knlGS:0000000000000000
> [   22.742753] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [   22.748491] CR2: 0000000180040100 CR3: 00000001fd1ed000 CR4: 00000000000406f0
> [   22.755615] Stack:
> [   22.757625]  ffffffff8fea7f60 ffffa95b81f3fe18 0000000000000002 ffff9a397fb61200
> [   22.765078]  ffff9a397fb61200 ffffffff8fa35c20 ffffffff8fc9982a 000055e4b443d028
> [   22.772531]  ffffa95b81f3fe48 ffffffff8f3a1453 ffffffff8fea7f60 ffffa95b81f3fe68
> [   22.779983] Call Trace:
> [   22.782433]  [<ffffffff8f3a1453>] apparmor_file_alloc_security+0x23/0x40
> [   22.789130]  [<ffffffff8f362713>] security_file_alloc+0x33/0x50
> [   22.795049]  [<ffffffff8f22f0fa>] get_empty_filp+0x9a/0x1c0
> [   22.800621]  [<ffffffff8f22f23b>] alloc_file+0x1b/0xc0
> [   22.805759]  [<ffffffff8f2797c9>] anon_inode_getfile+0xd9/0x150
> [   22.811669]  [<ffffffff8f278259>] SyS_epoll_create1+0x79/0xe0
> [   22.817407]  [<ffffffff8f8309fb>] entry_SYSCALL_64_fastpath+0x1e/0xad
> [   22.823836] Code: 08 65 4c 03 05 97 47 e0 70 49 83 78 10 00 4d 8b 10 0f 84 f0
> 00 00 00 4d 85 d2 0f 84 e7 00 00 00 49 63 41 20 48 8d 4a 01 49 8b 39 <49> 8b 1c
> 02 4c 89 d0 65 48 0f c7 0f 0f 94 c0 84 c0 74 bb 49 63
> [   22.843785] RIP  [<ffffffff8f205a1b>] kmem_cache_alloc_trace+0x7b/0x1c0
> [   22.850407]  RSP <ffffa95b81f3fdf0>
> [   22.853890] CR2: 0000000180040100
> [   22.857272] ---[ end trace aa2a9696006788ce ]---
> [   22.868212] BUG: unable to handle kernel NULL pointer dereference at
> 0000000000000805
> [   22.876069] IP: [<ffffffff8f205a1b>] kmem_cache_alloc_trace+0x7b/0x1c0
> [   22.882612] PGD 1fd1f3067
> [   22.885142] PUD 2145e2067
> [   22.887855] PMD 0
>
> [   22.889892] Oops: 0000 [#2] SMP
> [   22.893029] Modules linked in: snd_hda_codec_hdmi nls_iso8859_1
> snd_hda_codec_realtek snd_hda_codec_generic snd_hda_intel snd_hda_codec
> snd_hda_core intel_rapl x86_pkg_temp_thermal snd_pcm intel_powerclamp snd_hwdep
> snd_seq_midi coretemp snd_seq_midi_event crct10dif_pclmul snd_rawmidi
> crc32_pclmul snd_seq ghash_clmulni_intel snd_timer snd_seq_device cryptd joydev
> input_leds serio_raw lpc_ich snd mei_me soundcore mei mac_hid shpchp parport_pc
> ppdev lp parport autofs4 hid_generic usbhid psmouse r8169 hid mii pata_acpi fjes
> video
> [   22.940418] CPU: 0 PID: 2702 Comm: cp Tainted: G      D         4.9.0-rc1+ #3
> [   22.947548] Hardware name: Gigabyte Technology Co., Ltd. To be filled by
> O.E.M./H61M-S2PH, BIOS F1 03/11/2013
> [   22.957445] task: ffff9a397d23b900 task.stack: ffffa95b81f5c000
> [   22.963355] RIP: 0010:[<ffffffff8f205a1b>]  [<ffffffff8f205a1b>]
> kmem_cache_alloc_trace+0x7b/0x1c0
> [   22.972325] RSP: 0018:ffffa95b81f5fc50  EFLAGS: 00010206
> [   22.977628] RAX: 0000000000000000 RBX: 00000000024080c0 RCX: 000000000000e798
> [   22.984753] RDX: 000000000000e797 RSI: 00000000024080c0 RDI: 000000000001c520
> [   22.991875] RBP: ffffa95b81f5fc90 R08: ffff9a399ec1c520 R09: ffff9a3996003cc0
> [   22.999001] R10: 0000000000000805 R11: fefefefefefefeff R12: 00000000024080c0
> [   23.006125] R13: ffffffff8f3a1453 R14: 00007f1c701fc040 R15: ffff9a3996003cc0
> [   23.013249] FS:  0000000000000000(0000) GS:ffff9a399ec00000(0000)
> knlGS:0000000000000000
> [   23.021324] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [   23.027063] CR2: 0000000000000805 CR3: 00000001fd261000 CR4: 00000000000406f0
> [   23.034186] Stack:
> [   23.036196]  ffffa95b81f5fc50 ffffa95b81f5fc50 0000000000000002 ffff9a397d21a400
> [   23.043649]  ffff9a397d21a400 ffffa95b81f5fef4 00007f1c701fc040 00007f1c701fd510
> [   23.051101]  ffffa95b81f5fca8 ffffffff8f3a1453 ffffffff8fea7f60 ffffa95b81f5fcc8
> [   23.058556] Call Trace:
> [   23.061001]  [<ffffffff8f3a1453>] apparmor_file_alloc_security+0x23/0x40
> [   23.067692]  [<ffffffff8f362713>] security_file_alloc+0x33/0x50
> [   23.073602]  [<ffffffff8f22f0fa>] get_empty_filp+0x9a/0x1c0
> [   23.079164]  [<ffffffff8f23be00>] path_openat+0x40/0x1440
> [   23.084555]  [<ffffffff8f1a7917>] ? __alloc_pages_nodemask+0x137/0x300
> [   23.091073]  [<ffffffff8f23e4c1>] do_filp_open+0x91/0x100
> [   23.096464]  [<ffffffff8f1afd16>] ? lru_cache_add_active_or_unevictable+0x36/0xb0
> [   23.103935]  [<ffffffff8f1d6e5b>] ? handle_mm_fault+0xffb/0x14a0
> [   23.109941]  [<ffffffff8f23d3d6>] ? getname_flags+0x56/0x1f0
> [   23.115598]  [<ffffffff8f205d46>] ? kmem_cache_alloc+0x156/0x1b0
> [   23.121595]  [<ffffffff8f24cd66>] ? __alloc_fd+0x46/0x170
> [   23.126985]  [<ffffffff8f22b874>] do_sys_open+0x124/0x210
> [   23.132375]  [<ffffffff8f22b97e>] SyS_open+0x1e/0x20
> [   23.137335]  [<ffffffff8f8309fb>] entry_SYSCALL_64_fastpath+0x1e/0xad
> [   23.143773] Code: 08 65 4c 03 05 97 47 e0 70 49 83 78 10 00 4d 8b 10 0f 84 f0
> 00 00 00 4d 85 d2 0f 84 e7 00 00 00 49 63 41 20 48 8d 4a 01 49 8b 39 <49> 8b 1c
> 02 4c 89 d0 65 48 0f c7 0f 0f 94 c0 84 c0 74 bb 49 63
> [   23.163720] RIP  [<ffffffff8f205a1b>] kmem_cache_alloc_trace+0x7b/0x1c0
> [   23.170342]  RSP <ffffa95b81f5fc50>
> [   23.173827] CR2: 0000000000000805
> [   23.177198] ---[ end trace aa2a9696006788cf ]---
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
