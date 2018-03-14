Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2E3B46B0005
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 20:39:42 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id b23so827590oib.16
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 17:39:42 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id u206si378838oie.408.2018.03.13.17.39.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Mar 2018 17:39:40 -0700 (PDT)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w2E0cNjr053751
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 00:39:40 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp2120.oracle.com with ESMTP id 2gprh4r4nx-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 00:39:40 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w2E0ddu3012664
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 00:39:39 GMT
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w2E0dcbl013050
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 00:39:39 GMT
Received: by mail-ot0-f173.google.com with SMTP id w38-v6so1561195ota.8
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 17:39:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180313234333.j3i43yxeawx5d67x@sasha-lappy>
References: <20180131210300.22963-1-pasha.tatashin@oracle.com>
 <20180131210300.22963-2-pasha.tatashin@oracle.com> <20180313234333.j3i43yxeawx5d67x@sasha-lappy>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Tue, 13 Mar 2018 20:38:57 -0400
Message-ID: <CAGM2reaPK=ZcLBOnmBiC2-u86DZC6ukOhL1xxZofB2OTW3ozoA@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] mm: uninitialized struct page poisoning sanity checking
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <Alexander.Levin@microsoft.com>
Cc: "steven.sistare@oracle.com" <steven.sistare@oracle.com>, "daniel.m.jordan@oracle.com" <daniel.m.jordan@oracle.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "mhocko@suse.com" <mhocko@suse.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "bharata@linux.vnet.ibm.com" <bharata@linux.vnet.ibm.com>

Hi Sasha,

It seems the patch is doing the right thing, and it catches bugs. Here
we access uninitialized struct page. The question is why this happens?

register_mem_sect_under_node(struct memory_block *mem_blk, int nid)
   page_nid = get_nid_for_pfn(pfn);

node id is stored in page flags, and since struct page is poisoned,
and the pattern is recognized, the panic is triggered.

Do you have config file? Also, instructions how to reproduce it?

Thank you,
Pasha


On Tue, Mar 13, 2018 at 7:43 PM, Sasha Levin
<Alexander.Levin@microsoft.com> wrote:
> On Wed, Jan 31, 2018 at 04:02:59PM -0500, Pavel Tatashin wrote:
>>During boot we poison struct page memory in order to ensure that no one is
>>accessing this memory until the struct pages are initialized in
>>__init_single_page().
>>
>>This patch adds more scrutiny to this checking, by making sure that flags
>>do not equal to poison pattern when the are accessed. The pattern is all
>>ones.
>>
>>Since, node id is also stored in struct page, and may be accessed quiet
>>early we add the enforcement into page_to_nid() function as well.
>>
>>Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
>>---
>
> Hey Pasha,
>
> This patch is causing the following on boot:
>
> [    1.253732] BUG: unable to handle kernel paging request at fffffffffffffffe
> [    1.254000] PGD 2284e19067 P4D 2284e19067 PUD 2284e1b067 PMD 0
> [    1.254000] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN PTI
> [    1.254000] Modules linked in:
> [    1.254000] CPU: 1 PID: 1 Comm: swapper/0 Not tainted 4.16.0-rc5-next-20180313 #10
> [    1.254000] Hardware name: Microsoft Corporation Virtual Machine/Virtual Machine, BIOS 090007  06/02/2017
> [    1.254000] RIP: 0010:__dump_page (??:?)
> [    1.254000] RSP: 0000:ffff881c63c17810 EFLAGS: 00010246
> [    1.254000] RAX: dffffc0000000000 RBX: ffffea0084000000 RCX: 1ffff1038c782f2b
> [    1.254000] RDX: 1fffffffffffffff RSI: ffffffff9e160640 RDI: ffffea0084000000
> [    1.254000] RBP: ffff881c63c17c00 R08: ffff8840107e8880 R09: ffffed0802167a4d
> [    1.254000] R10: 0000000000000001 R11: ffffed0802167a4c R12: 1ffff1038c782f07
> [    1.254000] R13: ffffea0084000020 R14: fffffffffffffffe R15: ffff881c63c17bd8
> [    1.254000] FS:  0000000000000000(0000) GS:ffff881c6ac00000(0000) knlGS:0000000000000000
> [    1.254000] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [    1.254000] CR2: fffffffffffffffe CR3: 0000002284e16000 CR4: 00000000003406e0
> [    1.254000] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [    1.254000] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> [    1.254000] Call Trace:
> [    1.254000] dump_page (/mm/debug.c:80)
> [    1.254000] get_nid_for_pfn (/./include/linux/mm.h:900 /drivers/base/node.c:396)
> [    1.254000] register_mem_sect_under_node (/drivers/base/node.c:438)
> [    1.254000] link_mem_sections (/drivers/base/node.c:517)
> [    1.254000] topology_init (/./include/linux/nodemask.h:271 /arch/x86/kernel/topology.c:164)
> [    1.254000] do_one_initcall (/init/main.c:835)
> [    1.254000] kernel_init_freeable (/init/main.c:901 /init/main.c:909 /init/main.c:927 /init/main.c:1076)
> [    1.254000] kernel_init (/init/main.c:1004)
> [    1.254000] ret_from_fork (/arch/x86/entry/entry_64.S:417)
> [ 1.254000] Code: ff a8 01 4c 0f 44 f3 4d 85 f6 0f 84 31 0e 00 00 4c 89 f2 48 b8 00 00 00 00 00 fc ff df 48 c1 ea 03 80 3c 02 00 0f 85 2d 11 00 00 <49> 83 3e ff 0f 84 a9 06 00 00 4d 8d b7 c0 fd ff ff 48 b8 00 00
> All code
> ========
>    0:   ff a8 01 4c 0f 44       ljmp   *0x440f4c01(%rax)
>    6:   f3 4d 85 f6             repz test %r14,%r14
>    a:   0f 84 31 0e 00 00       je     0xe41
>   10:   4c 89 f2                mov    %r14,%rdx
>   13:   48 b8 00 00 00 00 00    movabs $0xdffffc0000000000,%rax
>   1a:   fc ff df
>   1d:   48 c1 ea 03             shr    $0x3,%rdx
>   21:   80 3c 02 00             cmpb   $0x0,(%rdx,%rax,1)
>   25:   0f 85 2d 11 00 00       jne    0x1158
>   2b:*  49 83 3e ff             cmpq   $0xffffffffffffffff,(%r14)               <-- trapping instruction
>   2f:   0f 84 a9 06 00 00       je     0x6de
>   35:   4d 8d b7 c0 fd ff ff    lea    -0x240(%r15),%r14
>   3c:   48                      rex.W
>   3d:   b8                      .byte 0xb8
>         ...
>
> Code starting with the faulting instruction
> ===========================================
>    0:   49 83 3e ff             cmpq   $0xffffffffffffffff,(%r14)
>    4:   0f 84 a9 06 00 00       je     0x6b3
>    a:   4d 8d b7 c0 fd ff ff    lea    -0x240(%r15),%r14
>   11:   48                      rex.W
>   12:   b8                      .byte 0xb8
>         ...
> [    1.254000] RIP: __dump_page+0x1c8/0x13c0 RSP: ffff881c63c17810 (/./include/asm-generic/sections.h:42)
> [    1.254000] CR2: fffffffffffffffe
> [    1.254000] ---[ end trace e643dfbc44b562ca ]---
>
> --
>
> Thanks,
> Sasha
