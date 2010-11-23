Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id EF8286B0087
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 09:55:33 -0500 (EST)
Received: by gwaa18 with SMTP id a18so2111gwa.14
        for <linux-mm@kvack.org>; Tue, 23 Nov 2010 06:55:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101122154754.e022d935.akpm@linux-foundation.org>
References: <AANLkTinbqG7sXxf82wc516snLoae1DtCWjo+VtsPx2P3@mail.gmail.com>
	<20101122154754.e022d935.akpm@linux-foundation.org>
Date: Tue, 23 Nov 2010 15:55:31 +0100
Message-ID: <AANLkTi=AiJ1MekBXZbVj3f2pBtFe52BtCxtbRq=u-YOR@mail.gmail.com>
Subject: Re: kernel BUG at /build/buildd/linux-2.6.35/mm/filemap.c:128!
From: =?UTF-8?B?Um9iZXJ0IMWad2nEmWNraQ==?= <robert@swiecki.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> Hi,
>>
>> I was doing some fuzzing with http://code.google.com/p/iknowthis/ and
>> my system pretty quickly crashes with the BUG() below.
>
> So it is a repeatable crash?

Not in a sense that I can provide you with a sequence of syscalls that
led to this state. Generally it repeats after some time (<12 hours on
2 intel-core) of running the
http://code.google.com/p/iknowthis/source/browse/#svn/trunk

>> - Even if it's just BUG() it renders my system unusable (I'm able to
>> type a few characters on the virtual terminal at most)
>> - Judging from the stacktrace it's sys_madvise(..., ..., MADV_REMOVE)
>> - I'm testing with ubuntu's 2.6.35-22-server#35 but I got similar
>> results with 2.6.32 some time ago
>
> It is.
>
>> - I'm posting this cause diving into linux mm spaghetti code might be
>> not a trivial task, but if nobody can see anything obvious in a day or
>> so, I'll try to debug it mysel
>> - I'm unable to provide a testcase by now, nor any usable state of the
>> crashing process, cause the system becomes unusable
>> - It crashes both linux-kernel working on a physical machine as well
>> as on the VirtualBox emulator
>> - I'm usually waiting from 0.5h to 12h for this crash to appear, I
>> think it could be speed up greatly by disabling any irrelevant
>> syscalls in the fuzzer
>>
>> [25142.286531] kernel BUG at /build/buildd/linux-2.6.35/mm/filemap.c:128=
!
>
> That's
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0BUG_ON(page_mapped(page));
>
> in __remove_from_page_cache(). =C2=A0That state is worth a BUG().
>
>> [25142.290627] invalid opcode: 0000 [#2] SMP
>> [25142.290627] last sysfs file: /sys/fs/ext4/sda1/lifetime_write_kbytes
>> [25142.301039] CPU 1
>> [25142.301039] Modules linked in: dccp_ipv6 decnet llc2 x25 pppoe
>> pppox irda crc_ccitt dccp_ipv4 dccp ipx p8023 rds af_key netrom econet
>> can atm l2cap bluetooth appletalk rose ax25 nouveau snd_hda_codec_idt
>> ttm snd_hda_intel drm_kms_helper snd_hda_codec led_class drm psmouse
>> snd_hwdep ppdev snd_pcm snd_timer i2c_algo_bit serio_raw i82975x_edac
>> snd parport_pc lp soundcore edac_core snd_page_alloc parport dcdbas
>> floppy ahci firewire_ohci firewire_core crc_itu_t tg3 libahci
>> [25142.301039]
>> [25142.301039] Pid: 22612, comm: iknowthis Tainted: G =C2=A0 =C2=A0 =C2=
=A0D W
>> 2.6.35-22-server #35-Ubuntu 0GH911/Precision WorkStation 390
>> [25142.301039] RIP: 0010:[<ffffffff81101645>] =C2=A0[<ffffffff81101645>]
>> __remove_from_page_cache+0xd5/0xe0
>> [25142.367617] RSP: 0000:ffff8800cb8a3cf8 =C2=A0EFLAGS: 00010002
>> [25142.367617] RAX: 0100000000100029 RBX: ffffea0002159670 RCX: 00000000=
00000000
>> [25142.367617] RDX: 0000000000000001 RSI: 0000000000000016 RDI: ffff8801=
00000700
>> [25142.367617] RBP: ffff8800cb8a3d08 R08: 0000000000000018 R09: 00000000=
00000000
>> [25142.367617] R10: ffffea0002159678 R11: 0000000000000000 R12: ffff8800=
cb865188
>> [25142.367617] R13: ffff8800cb865188 R14: ffff8800cb8a3d88 R15: 00000000=
00000000
>> [25142.367617] FS: =C2=A00000000000000000(0000) GS:ffff880001e40000(0063=
)
>> knlGS:00000000f75276c0
>> [25142.367617] CS: =C2=A00010 DS: 002b ES: 002b CR0: 000000008005003b
>> [25142.367617] CR2: 00000000080ba1fc CR3: 000000012091d000 CR4: 00000000=
000006e0
>> [25142.367617] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000000=
00000000
>> [25142.367617] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 00000000=
00000400
>> [25142.367617] Process iknowthis (pid: 22612, threadinfo
>> ffff8800cb8a2000, task ffff8800cb9516e0)
>> [25142.367617] Stack:
>> [25142.367617] =C2=A0ffffea0002159670 ffff8800cb8651a0 ffff8800cb8a3d28
>> ffffffff81101686
>> [25142.367617] <0> ffffea0002159670 ffff8800cb865188 ffff8800cb8a3d48
>> ffffffff8110c6d9
>> [25142.367617] <0> 0000000000000001 0000000000000008 ffff8800cb8a3e38
>> ffffffff8110cce0
>> [25142.367617] Call Trace:
>> [25142.367617] =C2=A0[<ffffffff81101686>] remove_from_page_cache+0x36/0x=
60
>> [25142.367617] =C2=A0[<ffffffff8110c6d9>] truncate_inode_page+0x79/0xb0
>> [25142.367617] =C2=A0[<ffffffff8110cce0>] truncate_inode_pages_range+0x1=
60/0x460
>> [25142.367617] =C2=A0[<ffffffff81121250>] ? unmap_mapping_range+0xb0/0x1=
60
>> [25142.367617] =C2=A0[<ffffffff81121398>] vmtruncate_range+0x98/0x100
>> [25142.367617] =C2=A0[<ffffffff8111ae5a>] madvise_vma+0x17a/0x210
>> [25142.367617] =C2=A0[<ffffffff8111b055>] sys_madvise+0x165/0x290
>> [25142.367617] =C2=A0[<ffffffff810467c3>] ia32_sysret+0x0/0x5
>> [25142.367617] Code: 00 00 e8 1f 8a 1c 00 48 89 df 57 9d 0f 1f 44 00
>> 00 5b 41 5c c9 c3 be 16 00 00 00 48 89 df e8 a3 68 01 00 48 8b 03 e9
>> 71 ff ff ff <0f> 0b eb fe eb 05 90 90 90 90 90 55 48 89 e5 48 83 ec 10
>> 48 89
>> [25142.367617] RIP =C2=A0[<ffffffff81101645>] __remove_from_page_cache+0=
xd5/0xe0
>> [25142.367617] =C2=A0RSP <ffff8800cb8a3cf8>
>> [25142.367617] ---[ end trace a262aa785b417723 ]---
>
>



--=20
Robert =C5=9Awi=C4=99cki

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
