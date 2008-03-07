Date: Fri, 7 Mar 2008 17:51:48 -0300
From: "Luiz Fernando N. Capitulino" <lcapitulino@mandriva.com.br>
Subject: Re: [PATCH] [0/13] General DMA zone rework
Message-ID: <20080307175148.3a49d8d3@mandriva.com.br>
In-Reply-To: <200803071007.493903088@firstfloor.org>
References: <200803071007.493903088@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Em Fri,  7 Mar 2008 10:07:10 +0100 (CET)
Andi Kleen <andi@firstfloor.org> escreveu:

| I chose to implement a new "maskable memory" allocator to solve these
| problems. The existing page buddy allocator is not really suited for
| this because the data structures don't allow cheap allocation by physical 
| address boundary. 

 These patches are supposed to work, I think?

 I've tried to give them a try but got some problems. First, the
simple test case seems to fail miserably:

"""
testing mask alloc upto 24 bits
gpm1 3 mask 3fffff size 20440 total 62KB failed
gpm1 4 mask 3fffff size 24369 total 62KB failed
gpm1 6 mask 3fffff size 15255 total 64KB failed
gpm1 7 mask 3fffff size 12676 total 64KB failed
gpm1 8 mask 3fffff size 23917 total 64KB failed
gpm1 9 mask 3fffff size 11682 total 64KB failed
gpm1 10 mask 3fffff size 23091 total 64KB failed
gpm1 11 mask 3fffff size 16880 total 64KB failed
gpm1 12 mask 3fffff size 17257 total 64KB failed
gpm1 13 mask 3fffff size 8686 total 64KB failed
gpm1 14 mask 3fffff size 9871 total 64KB failed
gpm1 15 mask 3fffff size 19740 total 64KB failed
gpm1 16 mask 3fffff size 11557 total 64KB failed
gpm1 18 mask 3fffff size 23723 total 67KB failed
gpm1 19 mask 3fffff size 16136 total 67KB failed
gpm2 6 mask 3fffff size 4471 failed
gpm2 7 mask 3fffff size 16868 failed
gpm2 8 mask 3fffff size 22093 failed
gpm2 9 mask 3fffff size 17666 failed
gpm2 11 mask 3fffff size 14416 failed
gpm2 12 mask 3fffff size 10825 failed
gpm2 13 mask 3fffff size 3918 failed
gpm2 14 mask 3fffff size 6255 failed
gpm2 15 mask 3fffff size 2428 failed
gpm2 16 mask 3fffff size 517 failed
gpm2 18 mask 3fffff size 12890 failed
gpm2 19 mask 3fffff size 3211 failed
verify & free
mask fffff
mask 1fffff
mask 3fffff
mask 7fffff
mask ffffff
done
"""

 Then boot up goes on and while init is running I get this:

"""
Starting udev: ------------[ cut here ]------------
kernel BUG at mm/mask-alloc.c:178!
invalid opcode: 0000 [#1] 
Modules linked in: parport_pc(+) parport snd_via82xx(+) gameport snd_ac97_codec rtc_cmos ac97_bus rtc_core rtc_lib snd_pcm snd_timer snd_page_alloc snd_mpu401_uart snd_rawmidi snd_seq_device pcspkr snd soundcore evdev i2c_viapro i2c_core thermal button processor ohci1394 ide_cd_mod ieee1394 cdrom firewire_ohci shpchp via_agp firewire_core crc_itu_t agpgart pci_hotplug 8139too mii via82cxxx ide_disk ide_core ext3 jbd uhci_hcd ohci_hcd ehci_hcd usbcore

Pid: 1088, comm: modprobe Not tainted (2.6.25-0.rc4.1mdv #1)
EIP: 0060:[<c016d493>] EFLAGS: 00010206 CPU: 0
EIP is at alloc_pages_mask+0x74/0x3de
EAX: 00000000 EBX: 00001000 ECX: df8fb854 EDX: 000004e2
ESI: 00000000 EDI: 00010000 EBP: dfbf9c44 ESP: dfbf9bec
 DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
Process modprobe (pid: 1088, ti=dfbf8000 task=dfb9c1a0 task.ti=dfbf8000)
Stack: c0486858 004f1000 004f1000 dfbf9c04 00001000 000052d0 dfbf9c28 000fffff 
       00000001 000004e2 dfbf8000 00000000 c0496ea0 dfb9c1a0 00000000 dfbf9c40 
       c010ab33 00000000 c02c9250 00001000 00000000 00010000 dfbf9c54 c016d80b 
Call Trace:
 [<c010ab33>] ? save_stack_trace+0x1c/0x3a
 [<c016d80b>] ? get_pages_mask+0xe/0x23
 [<c0107b83>] ? dma_alloc_coherent+0xab/0xe5
 [<c010aab6>] ? save_stack_address+0x0/0x2c
 [<e095634f>] ? snd_dma_alloc_pages+0xef/0x1ef [snd_page_alloc]
 [<e0956a17>] ? snd_malloc_sgbuf_pages+0xdd/0x170 [snd_page_alloc]
 [<c0137e1f>] ? trace_hardirqs_on+0xe6/0x11b
 [<c02bf3ff>] ? __mutex_unlock_slowpath+0xf2/0x104
 [<e0956409>] ? snd_dma_alloc_pages+0x1a9/0x1ef [snd_page_alloc]
 [<c02bf419>] ? mutex_unlock+0x8/0xa
 [<e095689f>] ? snd_dma_get_reserved_buf+0xb4/0xbd [snd_page_alloc]
 [<e09a1d77>] ? snd_pcm_lib_preallocate_pages+0x5b/0x115 [snd_pcm]
 [<e09a1e62>] ? snd_pcm_lib_preallocate_pages_for_all+0x31/0x56 [snd_pcm]
 [<e09ae2ab>] ? snd_via82xx_probe+0xb22/0xe6d [snd_via82xx]
 [<c02bf043>] ? mutex_trylock+0xf3/0x10f
 [<e09ac083>] ? snd_via82xx_mixer_free_ac97+0x0/0x12 [snd_via82xx]
 [<c02c0785>] ? _spin_unlock+0x1d/0x20
 [<c01e02d4>] ? pci_match_device+0x9a/0xa5
 [<c01e0393>] ? pci_device_probe+0x39/0x59
 [<c0238115>] ? driver_probe_device+0x9f/0x119
 [<c0238274>] ? __driver_attach+0x4a/0x7f
 [<c02376ed>] ? bus_for_each_dev+0x39/0x5b
 [<c0237fad>] ? driver_attach+0x14/0x16
 [<c023822a>] ? __driver_attach+0x0/0x7f
 [<c0237dc7>] ? bus_add_driver+0x9d/0x1ae
 [<c0238433>] ? driver_register+0x47/0xa3
 [<c01e055f>] ? __pci_register_driver+0x40/0x6d
 [<e093f017>] ? alsa_card_via82xx_init+0x17/0x19 [snd_via82xx]
 [<c013ed7a>] ? sys_init_module+0x13b0/0x14a8
 [<c0122ae5>] ? __request_region+0x0/0x90
 [<c010496d>] ? sysenter_past_esp+0xb6/0xc9
 [<c0137e1f>] ? trace_hardirqs_on+0xe6/0x11b
 [<c0104924>] ? sysenter_past_esp+0x6d/0xc9
 =======================
Code: 00 74 1b 8b 45 b8 c7 45 d4 ff ff ff ff 48 c1 e8 0b ff 45 d4 d1 e8 75 f9 83 7d b8 0f 77 04 0f 0b eb fe f7 45 bc 05 40 00 00 74 04 <0f> 0b eb fe 8b 4d bc 80 cd 02 89 4d b0 d1 e9 89 4d ac ff 05 84 
EIP: [<c016d493>] alloc_pages_mask+0x74/0x3de SS:ESP 0068:dfbf9bec
---[ end trace c02107712b611dcb ]---
""""

 How can I help to debug this?

 Btw, I've created a package to test this for my convenience
(that's why you see 'mdv' in the kernel name), but it's a vanilla
kernel with your patches on top.

-- 
Luiz Fernando N. Capitulino

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
