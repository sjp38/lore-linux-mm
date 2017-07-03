Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id AFFE26B0292
	for <linux-mm@kvack.org>; Mon,  3 Jul 2017 10:18:05 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 130so14792045wmq.4
        for <linux-mm@kvack.org>; Mon, 03 Jul 2017 07:18:05 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r41si11998747wrb.298.2017.07.03.07.18.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 03 Jul 2017 07:18:03 -0700 (PDT)
Subject: Re: "mm: use early_pfn_to_nid in page_ext_init" broken on some
 configurations?
From: Vlastimil Babka <vbabka@suse.cz>
References: <20170630141847.GN22917@dhcp22.suse.cz>
 <54336b9a-6dc7-890f-1900-c4188fb6cf1a@suse.cz>
Message-ID: <bfec3bba-8e15-8156-9ae2-01b1c6319a16@suse.cz>
Date: Mon, 3 Jul 2017 16:18:01 +0200
MIME-Version: 1.0
In-Reply-To: <54336b9a-6dc7-890f-1900-c4188fb6cf1a@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Yang Shi <yang.shi@linaro.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 07/03/2017 01:48 PM, Vlastimil Babka wrote:
> On 06/30/2017 04:18 PM, Michal Hocko wrote:
>> fe53ca54270a ("mm: use early_pfn_to_nid in page_ext_init") seem
>> to silently depend on CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID resp.
>> CONFIG_HAVE_MEMBLOCK_NODE_MAP. early_pfn_to_nid is returning zero with
>> !defined(CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID) && !defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP)
>> I am not sure how widely is this used but such a code is tricky. I see
>> how catching early allocations during defered initialization might be
>> useful but a subtly broken code sounds like a problem to me.  So is
>> fe53ca54270a worth this or we should revert it?
> 
> There might be more issues with fe53ca54270a, I think. This I've
> observed on our 4.4-based kernel, which has deferred page struct init,
> but doesn't have b8f1a75d61d8 ("mm: call page_ext_init() after all
> struct pages are initialized") nor aforementioned fe53ca54270a:
> 
> [    0.000000] allocated 421003264 bytes of page_ext
> [    0.000000] Node 0, zone      DMA: page owner found early allocated 0 pages
> [    0.000000] Node 0, zone    DMA32: page owner found early allocated 33 pages
> [    0.000000] Node 0, zone   Normal: page owner found early allocated 2842622 pages
> [    0.000000] BUG: unable to handle kernel NULL pointer dereference at           (null)
> [    0.000000] IP: [<ffffffff811f090a>] init_page_owner+0x12a/0x240
> [    0.000000] PGD 0 
> [    0.000000] Oops: 0000 [#1] SMP 
> [    0.000000] Modules linked in:
> [    0.000000] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.4.74+ #7
> [    0.000000] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.0.0-prebuilt.qemu-project.org 04/01/2014
> [    0.000000] task: ffffffff81e104c0 ti: ffffffff81e00000 task.ti: ffffffff81e00000
> [    0.000000] RIP: 0010:[<ffffffff811f090a>]  [<ffffffff811f090a>] init_page_owner+0x12a/0x240
> [    0.000000] RSP: 0000:ffffffff81e03ed0  EFLAGS: 00010046
> [    0.000000] RAX: 0000000000000000 RBX: ffff88083ffe0210 RCX: ffffea0013000000
> [    0.000000] RDX: 0000000000000300 RSI: ffffffff81f57437 RDI: 00000000004c0000
> [    0.000000] RBP: ffffffff81e03f20 R08: ffffffff81e03e90 R09: 0000000000000000
> [    0.000000] R10: 00000000004c0200 R11: 0000000000000000 R12: ffffea0000000000
> [    0.000000] R13: 00000000004c0200 R14: 00000000004c0000 R15: 0000000000840000
> [    0.000000] FS:  0000000000000000(0000) GS:ffff88042fc00000(0000) knlGS:0000000000000000
> [    0.000000] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [    0.000000] CR2: 0000000000000000 CR3: 0000000001e0b000 CR4: 00000000000406b0
> [    0.000000] Stack:
> [    0.000000]  0000000000000206 ffff88083ffe0f90 ffff88083ffdf000 0000000000003181
> [    0.000000]  ffffea0013000000 0000000000000040 ffffea0000000000 0000000000840000
> [    0.000000]  0000000000840000 000000008e000010 ffffffff81e03f50 ffffffff81f84145
> [    0.000000] Call Trace:
> [    0.000000]  [<ffffffff81f84145>] page_ext_init+0x15e/0x167
> [    0.000000]  [<ffffffff81f57e6a>] start_kernel+0x351/0x418
> [    0.000000]  [<ffffffff81f57120>] ? early_idt_handler_array+0x120/0x120
> [    0.000000]  [<ffffffff81f57309>] x86_64_start_reservations+0x2a/0x2c
> [    0.000000]  [<ffffffff81f57437>] x86_64_start_kernel+0x12c/0x13b
> [    0.000000] Code: 81 e2 00 fe ff ff 4d 39 fa 4d 0f 47 d7 4d 39 f2 4d 89 d5 77 34 eb 5e 48 8b 01 f6 c4 04 75 21 48 89 cf 48 89 4d d0 e8 b6 35 00 00 <48> 8b 00 a8 04 75 0e 48 8b 4d d0 e9 c2 00 00 00 48 83 45 c8 01 
> [    0.000000] RIP  [<ffffffff811f090a>] init_page_owner+0x12a/0x240
> [    0.000000]  RSP <ffffffff81e03ed0>
> [    0.000000] CR2: 0000000000000000
> [    0.000000] ---[ end trace 19e05592f03a690f ]---
> 
> Note that this is different backtrace than in b8f1a75d61d8 log.
> 
> Still, backporting b8f1a75d61d8 fixes this:
> 
> [    1.538379] allocated 738197504 bytes of page_ext
> [    1.539340] Node 0, zone      DMA: page owner found early allocated 0 pages
> [    1.540179] Node 0, zone    DMA32: page owner found early allocated 33 pages
> [    1.611173] Node 0, zone   Normal: page owner found early allocated 96755 pages
> [    1.683167] Node 1, zone   Normal: page owner found early allocated 96575 pages
> 
> No panic, notice how it allocated more for page_ext, and found smaller number of
> early allocated pages.
> 
> Now backporting fe53ca54270a on top:
> 
> [    0.000000] allocated 738197504 bytes of page_ext
> [    0.000000] Node 0, zone      DMA: page owner found early allocated 0 pages
> [    0.000000] Node 0, zone    DMA32: page owner found early allocated 33 pages
> [    0.000000] Node 0, zone   Normal: page owner found early allocated 2842622 pages
> [    0.000000] Node 1, zone   Normal: page owner found early allocated 3694362 pages
> 
> Again no panic, and same amount of page_ext usage. But the "early allocated" numbers
> seem bogus to me. I think it's because init_pages_in_zone() is running and inspecting
> struct pages that have not been yet initialized. It doesn't end up crashing, but
> still doesn't seem correct?

Hmm, and for the record, this is recent mainline. Wonder why the "early
allocated" looks much more sane there. But there's a warning nevertheless.

[    0.001000] allocated 201326592 bytes of page_ext
[    0.001000] ------------[ cut here ]------------
[    0.001000] WARNING: CPU: 0 PID: 0 at mm/page_alloc.c:2467 drain_all_pages+0x1a9/0x1d0
[    0.001000] Modules linked in:
[    0.001000] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.12.0-rc7+ #179
[    0.001000] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.0.0-prebuilt.qemu-project.org 04/01/2014
[    0.001000] task: ffffffff8200f4c0 task.stack: ffffffff82000000
[    0.001000] RIP: 0010:drain_all_pages+0x1a9/0x1d0
[    0.001000] RSP: 0000:ffffffff82003e18 EFLAGS: 00010246
[    0.001000] RAX: ffffffff8200f4c0 RBX: 0000000000000040 RCX: 0000000000000000
[    0.001000] RDX: ffffffff8200f4c0 RSI: 0000000000000000 RDI: 0000000000000000
[    0.001000] RBP: ffffffff82003e80 R08: 0000000000000040 R09: 0000000000000001
[    0.001000] R10: 0000000000000080 R11: ffffffff81086356 R12: 0000000000840000
[    0.001000] R13: 0000000000000040 R14: 0000000000840000 R15: 000000008e000010
[    0.001000] FS:  0000000000000000(0000) GS:ffff88042fc00000(0000) knlGS:0000000000000000
[    0.001000] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    0.001000] CR2: 00000000ffffffff CR3: 000000000200a000 CR4: 00000000000406b0
[    0.001000] Call Trace:
[    0.001000]  ? init_page_owner+0x39/0x250
[    0.001000]  ? printk+0x3e/0x46
[    0.001000]  page_ext_init+0x195/0x19e
[    0.001000]  start_kernel+0x31a/0x3dc
[    0.001000]  ? early_idt_handler_array+0x120/0x120
[    0.001000]  x86_64_start_reservations+0x2a/0x2c
[    0.001000]  x86_64_start_kernel+0x12d/0x13c
[    0.001000]  secondary_startup_64+0x9f/0x9f
[    0.001000] Code: 52 82 48 63 d2 e8 a8 09 26 00 3b 05 d6 fb fa 00 89 c3 7c cd 48 c7 c7 c0 02 06 82 e8 b2 05 87 00 5b 41 5c 41 5d 41 5e 41 5f 5d c3 <0f> ff c3 4d 85 e4 74 ed 48 c7 c7 c0 02 06 82 e8 83 0b 87 00 e9 
[    0.001000] ---[ end trace 392dd6a55122ccf6 ]---
[    0.001000] Node 0, zone      DMA: page owner found early allocated 0 pages
[    0.001000] Node 0, zone    DMA32: page owner found early allocated 33 pages
[    0.001000] Node 0, zone   Normal: page owner found early allocated 24732 pages
[    0.001000] Node 1, zone   Normal: page owner found early allocated 24577 pages



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
