Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5E2176B0333
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 18:03:22 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id i50so334654420otd.3
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 15:03:22 -0700 (PDT)
Received: from mail-oi0-x233.google.com (mail-oi0-x233.google.com. [2607:f8b0:4003:c06::233])
        by mx.google.com with ESMTPS id v5si4104534ote.250.2017.03.21.15.03.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Mar 2017 15:03:21 -0700 (PDT)
Received: by mail-oi0-x233.google.com with SMTP id l203so9754213oia.0
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 15:03:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CANaxB-wtxWcHyOV1gJRjWvAi88FitcTYQzDUAvwV23YyQX0X+w@mail.gmail.com>
References: <CANaxB-wtxWcHyOV1gJRjWvAi88FitcTYQzDUAvwV23YyQX0X+w@mail.gmail.com>
From: Andrei Vagin <avagin@gmail.com>
Date: Tue, 21 Mar 2017 15:03:20 -0700
Message-ID: <CANaxB-ygnT+HGy1FsEYb626209jvVzm3hr_ZXE=rOPomSbTm-g@mail.gmail.com>
Subject: Re: linux-next: something wrong with 5-level paging
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Hi,

I reproduced it locally. This kernel doesn't boot via kexec, but it
can boot if we set it via the qemu -kernel option. Then I tried to
boot the same kernel again via kexec and got a bug in dmesg:
[ 1252.014292] BUG: unable to handle kernel paging request at ffffd204f000f000
[ 1252.015093] IP: ident_pmd_init.isra.5+0x5a/0xb0
[ 1252.015636] PGD 0

[ 1252.016003] Oops: 0000 [#1] SMP
[ 1252.016003] Modules linked in:
[ 1252.016003] CPU: 1 PID: 21962 Comm: kexec Not tainted
4.11.0-rc3-next-20170321 #1
[ 1252.016003] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS 1.9.3-1.fc25 04/01/2014
[ 1252.016003] task: ffff92b19f3dc6c0 task.stack: ffffa44187194000
[ 1252.016003] RIP: 0010:ident_pmd_init.isra.5+0x5a/0xb0
[ 1252.016003] RSP: 0018:ffffa44187197da0 EFLAGS: 00010286
[ 1252.016003] RAX: ffffd204f000f000 RBX: 0000000000000000 RCX: ffffc000001fffff
[ 1252.016003] RDX: ffffd204f000f000 RSI: ffffa44187197ea0 RDI: ffffa44187197e98
[ 1252.016003] RBP: ffffa44187197dd8 R08: 0000000040000000 R09: 0000000000000003
[ 1252.016003] R10: 0000000135bf4000 R11: 0000000000000000 R12: 0000000040000000
[ 1252.016003] R13: ffffc000001fffff R14: ffffc00000000fff R15: ffffd204f000f000
[ 1252.016003] FS:  00007f9b81f3c700(0000) GS:ffff92b23fc80000(0000)
knlGS:0000000000000000
[ 1252.016003] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1252.016003] CR2: ffffd204f000f000 CR3: 0000000131984000 CR4: 00000000003406e0
[ 1252.016003] Call Trace:
[ 1252.016003]  ident_p4d_init+0xb5/0x1d0
[ 1252.016003]  kernel_ident_mapping_init+0xb5/0x130
[ 1252.016003]  machine_kexec_prepare+0xa2/0x470
[ 1252.016003]  ? trace_clock_x86_tsc+0x20/0x20
[ 1252.016003]  do_kexec_load+0x16c/0x260
[ 1252.016003]  SyS_kexec_load+0x8d/0xd0
[ 1252.016003]  entry_SYSCALL_64_fastpath+0x23/0xc2
[ 1252.016003] RIP: 0033:0x7f9b8162c239
[ 1252.016003] RSP: 002b:00007ffff29e97d8 EFLAGS: 00000206 ORIG_RAX:
00000000000000f6
[ 1252.016003] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007f9b8162c239
[ 1252.016003] RDX: 0000000000a5ddf0 RSI: 0000000000000003 RDI: 000000013fff6740
[ 1252.016003] RBP: 00000000ee683622 R08: 0000000000000000 R09: 00007fff00000002
[ 1252.016003] R10: 00000000003e0000 R11: 0000000000000206 R12: 0000000000000000
[ 1252.016003] R13: 00000000549ec713 R14: 0000000000000000 R15: 00000000468b48d1
[ 1252.016003] Code: d7 4d 89 c4 49 be ff 0f 00 00 00 c0 ff ff 49 bd
ff ff 1f 00 00 c0 ff ff 48 89 da 4c 89 e9 48 c1 ea 12 81 e2 f8 0f 00
00 4c 01 fa <48> 8b 02 a8 80 49 0f 44 ce 48 21 c8 a9 81 01 00 00 75 28
48 8b
[ 1252.016003] RIP: ident_pmd_init.isra.5+0x5a/0xb0 RSP: ffffa44187197da0
[ 1252.016003] CR2: ffffd204f000f000
[ 1252.016003] ---[ end trace a00ff9b4dd2290c1 ]---

On Tue, Mar 21, 2017 at 1:48 PM, Andrei Vagin <avagin@gmail.com> wrote:
> Hi Kirill,
>
> We use travis-ci to test linux-next. We don't have access to virtual
> machines or serial console logs there. And we found that
> linux-next-20170320 doesn't boot. It's all information what we have
> now.
>
> Here are out logs:
> https://travis-ci.org/avagin/criu/jobs/213276252
> https://s3.amazonaws.com/archive.travis-ci.org/jobs/213276252/log.txt
>
> I bisected this issue and here is the bisect log:
> [avagin@laptop linux-next]$ git bisect log
> # bad: [50eff530518ae89e25d09ec1aa41a7aea6a7d51c] Add linux-next
> specific files for 20170321
> # good: [97da3854c526d3a6ee05c849c96e48d21527606c] Linux 4.11-rc3
> git bisect start 'HEAD' '97da3854c526d3a6ee05c849c96e48d21527606c'
> # good: [445775520e021af86ee95b76eecca2df8203ce93] Merge
> remote-tracking branch 'drm/drm-next'
> git bisect good 445775520e021af86ee95b76eecca2df8203ce93
> # bad: [9f18c54f1a491ed2ff42354352fa72949ce21622] Merge
> remote-tracking branch 'usb-serial/usb-next'
> git bisect bad 9f18c54f1a491ed2ff42354352fa72949ce21622
> # good: [8a96989361a21261af9b33db7f0463e23e11af60] Merge
> remote-tracking branch 'device-mapper/for-next'
> git bisect good 8a96989361a21261af9b33db7f0463e23e11af60
> # good: [86550c0919cab6e71fe3955d764f7b8fe7f6d203] Merge
> remote-tracking branch 'spi/for-next'
> git bisect good 86550c0919cab6e71fe3955d764f7b8fe7f6d203
> # bad: [cb1341c192398fc727bdd9b2ac42c5b36d5bcb9e] Merge
> remote-tracking branch 'tip/auto-latest'
> git bisect bad cb1341c192398fc727bdd9b2ac42c5b36d5bcb9e
> # good: [ad86b2388abbf931aacac1a5d0b022ad7a7dafe9] Merge branch 'perf/core'
> git bisect good ad86b2388abbf931aacac1a5d0b022ad7a7dafe9
> # good: [091c3e29ebd9400f96e4456cc882dd6af6991b8f] Merge branch 'x86/microcode'
> git bisect good 091c3e29ebd9400f96e4456cc882dd6af6991b8f
> # bad: [e93480537fd7ecaf5ed1a662a979376f6fee50e3] mm/gup: Mark all
> pages PageReferenced in generic get_user_pages_fast()
> git bisect bad e93480537fd7ecaf5ed1a662a979376f6fee50e3
> # bad: [06c830a48346643e195801460dfe16d96ba4dff5] x86/power: Add
> 5-level paging support
> git bisect bad 06c830a48346643e195801460dfe16d96ba4dff5
> # good: [fe1e8c3e9634071ac608172e29bf997596d17c7c] x86/mm: Extend
> headers with basic definitions to support 5-level paging
> git bisect good fe1e8c3e9634071ac608172e29bf997596d17c7c
> # good: [0318e5abe1c0933b8bf6763a1a0d3caec4f0826d] x86/mm/gup: Add
> 5-level paging support
> git bisect good 0318e5abe1c0933b8bf6763a1a0d3caec4f0826d
> # bad: [b50858ce3e2a25a7f4638464e857853fbfc81823] x86/mm/vmalloc: Add
> 5-level paging support
> git bisect bad b50858ce3e2a25a7f4638464e857853fbfc81823
> # bad: [ea3b5e60ce804403ca019039d6331368521348de] x86/mm/ident_map:
> Add 5-level paging support
> git bisect bad ea3b5e60ce804403ca019039d6331368521348de
> # first bad commit: [ea3b5e60ce804403ca019039d6331368521348de]
> x86/mm/ident_map: Add 5-level paging support
>
> What we do in travis-ci:
> * clone a kernel tree
> * curl -o .config
> https://raw.githubusercontent.com/avagin/criu/linux-next/scripts/linux-next-config
> * make olddefconfig
> * make localyesconfig
> * kexec -l linux/arch/x86/boot/bzImage --command-line "root=/dev/sda1
> cgroup_enable=memory swapaccount=1 apparmor=0 console=ttyS0
> console=ttyS0 debug raid=noautodetect slub_debug=FZP"
> * kexec -e
>
> Thanks,
> Andrei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
