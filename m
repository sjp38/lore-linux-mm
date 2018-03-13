Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 63C8D6B0006
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 19:43:39 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id 188so1403683iou.14
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 16:43:39 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0121.outbound.protection.outlook.com. [104.47.38.121])
        by mx.google.com with ESMTPS id 83si808622itb.168.2018.03.13.16.43.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 13 Mar 2018 16:43:37 -0700 (PDT)
From: Sasha Levin <Alexander.Levin@microsoft.com>
Subject: Re: [PATCH v2 1/2] mm: uninitialized struct page poisoning sanity
 checking
Date: Tue, 13 Mar 2018 23:43:35 +0000
Message-ID: <20180313234333.j3i43yxeawx5d67x@sasha-lappy>
References: <20180131210300.22963-1-pasha.tatashin@oracle.com>
 <20180131210300.22963-2-pasha.tatashin@oracle.com>
In-Reply-To: <20180131210300.22963-2-pasha.tatashin@oracle.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <9732134B9E963143AEC8301E7EBD6B7F@namprd21.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: "steven.sistare@oracle.com" <steven.sistare@oracle.com>, "daniel.m.jordan@oracle.com" <daniel.m.jordan@oracle.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "mhocko@suse.com" <mhocko@suse.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "bharata@linux.vnet.ibm.com" <bharata@linux.vnet.ibm.com>

On Wed, Jan 31, 2018 at 04:02:59PM -0500, Pavel Tatashin wrote:
>During boot we poison struct page memory in order to ensure that no one is
>accessing this memory until the struct pages are initialized in
>__init_single_page().
>
>This patch adds more scrutiny to this checking, by making sure that flags
>do not equal to poison pattern when the are accessed. The pattern is all
>ones.
>
>Since, node id is also stored in struct page, and may be accessed quiet
>early we add the enforcement into page_to_nid() function as well.
>
>Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
>---

Hey Pasha,

This patch is causing the following on boot:

[    1.253732] BUG: unable to handle kernel paging request at fffffffffffff=
ffe
[    1.254000] PGD 2284e19067 P4D 2284e19067 PUD 2284e1b067 PMD 0
[    1.254000] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN PTI
[    1.254000] Modules linked in:
[    1.254000] CPU: 1 PID: 1 Comm: swapper/0 Not tainted 4.16.0-rc5-next-20=
180313 #10
[    1.254000] Hardware name: Microsoft Corporation Virtual Machine/Virtual=
 Machine, BIOS 090007  06/02/2017
[    1.254000] RIP: 0010:__dump_page (??:?)
[    1.254000] RSP: 0000:ffff881c63c17810 EFLAGS: 00010246
[    1.254000] RAX: dffffc0000000000 RBX: ffffea0084000000 RCX: 1ffff1038c7=
82f2b
[    1.254000] RDX: 1fffffffffffffff RSI: ffffffff9e160640 RDI: ffffea00840=
00000
[    1.254000] RBP: ffff881c63c17c00 R08: ffff8840107e8880 R09: ffffed08021=
67a4d
[    1.254000] R10: 0000000000000001 R11: ffffed0802167a4c R12: 1ffff1038c7=
82f07
[    1.254000] R13: ffffea0084000020 R14: fffffffffffffffe R15: ffff881c63c=
17bd8
[    1.254000] FS:  0000000000000000(0000) GS:ffff881c6ac00000(0000) knlGS:=
0000000000000000
[    1.254000] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    1.254000] CR2: fffffffffffffffe CR3: 0000002284e16000 CR4: 00000000003=
406e0
[    1.254000] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000000000=
00000
[    1.254000] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 00000000000=
00400
[    1.254000] Call Trace:
[    1.254000] dump_page (/mm/debug.c:80)
[    1.254000] get_nid_for_pfn (/./include/linux/mm.h:900 /drivers/base/nod=
e.c:396)
[    1.254000] register_mem_sect_under_node (/drivers/base/node.c:438)
[    1.254000] link_mem_sections (/drivers/base/node.c:517)
[    1.254000] topology_init (/./include/linux/nodemask.h:271 /arch/x86/ker=
nel/topology.c:164)
[    1.254000] do_one_initcall (/init/main.c:835)
[    1.254000] kernel_init_freeable (/init/main.c:901 /init/main.c:909 /ini=
t/main.c:927 /init/main.c:1076)
[    1.254000] kernel_init (/init/main.c:1004)
[    1.254000] ret_from_fork (/arch/x86/entry/entry_64.S:417)
[ 1.254000] Code: ff a8 01 4c 0f 44 f3 4d 85 f6 0f 84 31 0e 00 00 4c 89 f2 =
48 b8 00 00 00 00 00 fc ff df 48 c1 ea 03 80 3c 02 00 0f 85 2d 11 00 00 <49=
> 83 3e ff 0f 84 a9 06 00 00 4d 8d b7 c0 fd ff ff 48 b8 00 00
All code
=3D=3D=3D=3D=3D=3D=3D=3D
   0:   ff a8 01 4c 0f 44       ljmp   *0x440f4c01(%rax)
   6:   f3 4d 85 f6             repz test %r14,%r14
   a:   0f 84 31 0e 00 00       je     0xe41
  10:   4c 89 f2                mov    %r14,%rdx
  13:   48 b8 00 00 00 00 00    movabs $0xdffffc0000000000,%rax
  1a:   fc ff df
  1d:   48 c1 ea 03             shr    $0x3,%rdx
  21:   80 3c 02 00             cmpb   $0x0,(%rdx,%rax,1)
  25:   0f 85 2d 11 00 00       jne    0x1158
  2b:*  49 83 3e ff             cmpq   $0xffffffffffffffff,(%r14)          =
     <-- trapping instruction
  2f:   0f 84 a9 06 00 00       je     0x6de
  35:   4d 8d b7 c0 fd ff ff    lea    -0x240(%r15),%r14
  3c:   48                      rex.W
  3d:   b8                      .byte 0xb8
        ...

Code starting with the faulting instruction
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
   0:   49 83 3e ff             cmpq   $0xffffffffffffffff,(%r14)
   4:   0f 84 a9 06 00 00       je     0x6b3
   a:   4d 8d b7 c0 fd ff ff    lea    -0x240(%r15),%r14
  11:   48                      rex.W
  12:   b8                      .byte 0xb8
        ...
[    1.254000] RIP: __dump_page+0x1c8/0x13c0 RSP: ffff881c63c17810 (/./incl=
ude/asm-generic/sections.h:42)
[    1.254000] CR2: fffffffffffffffe
[    1.254000] ---[ end trace e643dfbc44b562ca ]---

--=20

Thanks,
Sasha=
