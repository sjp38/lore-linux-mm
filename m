Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 182A26B026D
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 09:21:42 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id a66so27918735wme.1
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 06:21:42 -0700 (PDT)
Received: from mail-lf0-x22d.google.com (mail-lf0-x22d.google.com. [2a00:1450:4010:c07::22d])
        by mx.google.com with ESMTPS id dz1si16026916lbc.125.2016.06.20.06.21.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jun 2016 06:21:40 -0700 (PDT)
Received: by mail-lf0-x22d.google.com with SMTP id f6so37610637lfg.0
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 06:21:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5766D902.7080007@oracle.com>
References: <1466173664-118413-1-git-send-email-glider@google.com>
 <5765699E.6000508@oracle.com> <CAG_fn=WP3HBLBarYz6u8UfEKwS3Cw58+2VcrzV_asiuQid_oxw@mail.gmail.com>
 <5766D902.7080007@oracle.com>
From: Alexander Potapenko <glider@google.com>
Date: Mon, 20 Jun 2016 15:21:39 +0200
Message-ID: <CAG_fn=Xs88WZKhf1CLc7kZ1VE-1oKkpCFCX5VpuO_4aTZv8ruw@mail.gmail.com>
Subject: Re: [PATCH v4] mm, kasan: switch SLUB to stackdepot, enable memory
 quarantine for SLUB
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Dmitriy Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Joonsoo Kim <js1304@gmail.com>, Kostya Serebryany <kcc@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sun, Jun 19, 2016 at 7:40 PM, Sasha Levin <sasha.levin@oracle.com> wrote=
:
> On 06/19/2016 03:24 AM, Alexander Potapenko wrote:
>> Hi Sasha,
>>
>> This commit delays the reuse of memory after it has been freed, so
>> it's intended to help people find more use-after-free errors.
>
> Is there a way to tell if the use-after-free access was to a memory
> that is quarantined?
Sorry, missed this question.
In theory, these can be distinguished by looking at alloc_info->state
(see kasan_object_err() in mm/kasan/report.c): the quarantined chunk
should have the KASAN_STATE_QUARANTINE state.
But your report contains the line "Object allocated with size 192
bytes.", which means the chunk had the KASAN_STATE_ALLOC state.
Therefore, we're dealing with an inconsistency between the shadow
memory value (0xFB, i.e. freed memory) and the chunk header
(KASAN_STATE_ALLOC) here.
Can you apply "mm, kasan: improve double-free detection" by Kuthonuzo
Luruo and see if the report changes?
>> But I'm puzzled why the stacks are missing.
>
> I looked at the logs, it looks like stackdepot ran out of room pretty
> early during boot. I've increased the max count and that solved the
> problem. Here's a trace with all the stacks:
>
> [ 1157.040216] BUG: KASAN: use-after-free in print_bad_pte+0x5c7/0x6e0 at=
 addr ffff8801b82286a0
> [ 1157.040222] Read of size 8 by task syz-executor/20583
> [ 1157.040236] CPU: 0 PID: 20583 Comm: syz-executor Tainted: G    B      =
     4.7.0-rc2-next-20160609-sasha-00032-g779e0df-dirty #3123
> [ 1157.040249]  1ffff10016b26e97 000000001af4d42c ffff8800b5937540 ffffff=
ffa103380b
> [ 1157.040262]  ffffffff00000000 fffffbfff5830bf4 0000000041b58ab3 ffffff=
ffabaf1240
> [ 1157.040274]  ffffffffa103369c 0000000000000006 0000000000000000 ffff88=
00b5937550
> [ 1157.040276] Call Trace:
> [ 1157.040290]  [<ffffffffa103380b>] dump_stack+0x16f/0x1d4
> [ 1157.040319]  [<ffffffff9f7a148f>] kasan_report_error+0x59f/0x8c0
> [ 1157.040382]  [<ffffffff9f7a19c6>] __asan_report_load8_noabort+0x66/0x9=
0
> [ 1157.040409]  [<ffffffff9f6fa5e7>] print_bad_pte+0x5c7/0x6e0
> [ 1157.040418]  [<ffffffff9f702e02>] unmap_page_range+0x12f2/0x1e20
> [ 1157.040445]  [<ffffffff9f703b69>] unmap_single_vma+0x239/0x250
> [ 1157.040452]  [<ffffffff9f7045e9>] unmap_vmas+0x119/0x1d0
> [ 1157.040461]  [<ffffffff9f720a73>] exit_mmap+0x2a3/0x410
> [ 1157.040485]  [<ffffffff9f3769e2>] mmput+0x192/0x350
> [ 1157.040524]  [<ffffffff9f38d745>] do_exit+0xea5/0x19e0
> [ 1157.040566]  [<ffffffff9f38e5d3>] do_group_exit+0x2e3/0x2f0
> [ 1157.040580]  [<ffffffff9f3b1928>] get_signal+0x1128/0x1370
> [ 1157.040593]  [<ffffffff9f1afca6>] do_signal+0x86/0x1da0
> [ 1157.040700]  [<ffffffff9f00539c>] exit_to_usermode_loop+0xac/0x200
> [ 1157.040712]  [<ffffffff9f006c20>] do_syscall_64+0x410/0x490
> [ 1157.040725]  [<ffffffffa94d0ca5>] entry_SYSCALL64_slow_path+0x25/0x25
> [ 1157.040733] Object at ffff8801b8228600, in cache vm_area_struct
> [ 1157.040737] Object allocated with size 192 bytes.
> [ 1157.040738] Allocation:
> [ 1157.040741] PID =3D 20521
> [ 1157.040757]  [<ffffffff9f1dfae6>] save_stack_trace+0x26/0x70
> [ 1157.040770]  [<ffffffff9f7a01e6>] save_stack+0x46/0xd0
> [ 1157.040784]  [<ffffffff9f7a0470>] kasan_kmalloc+0x110/0x130
> [ 1157.040797]  [<ffffffff9f7a09a2>] kasan_slab_alloc+0x12/0x20
> [ 1157.040811]  [<ffffffff9f79a546>] kmem_cache_alloc+0x1e6/0x230
> [ 1157.040826]  [<ffffffff9f7245ad>] mmap_region+0x56d/0x13c0
> [ 1157.040840]  [<ffffffff9f725e22>] do_mmap+0xa22/0xaf0
> [ 1157.040853]  [<ffffffff9f6cb1af>] vm_mmap_pgoff+0x14f/0x1c0
> [ 1157.040889]  [<ffffffff9f71e5fb>] SyS_mmap_pgoff+0x81b/0x910
> [ 1157.040901]  [<ffffffff9f1bf966>] SyS_mmap+0x16/0x20
> [ 1157.040910]  [<ffffffff9f006ab6>] do_syscall_64+0x2a6/0x490
> [ 1157.040919]  [<ffffffffa94d0ca5>] return_from_SYSCALL_64+0x0/0x6a
> [ 1157.040920] Memory state around the buggy address:
> [ 1157.040927]  ffff8801b8228580: fb fb fb fb fb fb fb fb fc fc fc fc fc =
fc fc fc
> [ 1157.040933]  ffff8801b8228600: fb fb fb fb fb fb fb fb fb fb fb fb fb =
fb fb fb
> [ 1157.040938] >ffff8801b8228680: fb fb fb fb fb fb fb fb fc fc fc fc fc =
fc fc fc
> [ 1157.040940]                                ^
> [ 1157.040946]  ffff8801b8228700: fb fb fb fb fb fb fb fb fb fb fb fb fb =
fb fb fb
> [ 1157.040951]  ffff8801b8228780: fb fb fb fb fb fb fb fb fc fc fc fc fc =
fc fc fc
>
>> Can you please share the reproduction steps for this bug?
>
> Just running syzkaller inside a kvmtool guest.
>
>> I also wonder whether it's reproducible when you:
>>  - revert this commit?
>
> Not reproducible.
>
>>  - build with SLAB instead of SLUB?
>
> Not reproducible.
>
>
> Thanks,
> Sasha



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
