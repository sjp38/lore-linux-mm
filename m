Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5C5B66B0279
	for <linux-mm@kvack.org>; Tue,  4 Jul 2017 01:23:13 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g27so219772608pfj.6
        for <linux-mm@kvack.org>; Mon, 03 Jul 2017 22:23:13 -0700 (PDT)
Received: from mail-pg0-x236.google.com (mail-pg0-x236.google.com. [2607:f8b0:400e:c05::236])
        by mx.google.com with ESMTPS id c1si14456299pld.330.2017.07.03.22.23.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jul 2017 22:23:12 -0700 (PDT)
Received: by mail-pg0-x236.google.com with SMTP id u62so104538693pgb.3
        for <linux-mm@kvack.org>; Mon, 03 Jul 2017 22:23:12 -0700 (PDT)
Date: Tue, 4 Jul 2017 14:23:06 +0900
From: Joonsoo Kim <js1304@gmail.com>
Subject: Re: "mm: use early_pfn_to_nid in page_ext_init" broken on some
 configurations?
Message-ID: <20170704052304.GC28589@js1304-desktop>
References: <20170630141847.GN22917@dhcp22.suse.cz>
 <54336b9a-6dc7-890f-1900-c4188fb6cf1a@suse.cz>
 <bfec3bba-8e15-8156-9ae2-01b1c6319a16@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bfec3bba-8e15-8156-9ae2-01b1c6319a16@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, Yang Shi <yang.shi@linaro.org>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 03, 2017 at 04:18:01PM +0200, Vlastimil Babka wrote:
> On 07/03/2017 01:48 PM, Vlastimil Babka wrote:
> > On 06/30/2017 04:18 PM, Michal Hocko wrote:
> >> fe53ca54270a ("mm: use early_pfn_to_nid in page_ext_init") seem
> >> to silently depend on CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID resp.
> >> CONFIG_HAVE_MEMBLOCK_NODE_MAP. early_pfn_to_nid is returning zero with
> >> !defined(CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID) && !defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP)
> >> I am not sure how widely is this used but such a code is tricky. I see
> >> how catching early allocations during defered initialization might be
> >> useful but a subtly broken code sounds like a problem to me.  So is
> >> fe53ca54270a worth this or we should revert it?
> > 
> > There might be more issues with fe53ca54270a, I think. This I've
> > observed on our 4.4-based kernel, which has deferred page struct init,
> > but doesn't have b8f1a75d61d8 ("mm: call page_ext_init() after all
> > struct pages are initialized") nor aforementioned fe53ca54270a:
> > 
> > [    0.000000] allocated 421003264 bytes of page_ext
> > [    0.000000] Node 0, zone      DMA: page owner found early allocated 0 pages
> > [    0.000000] Node 0, zone    DMA32: page owner found early allocated 33 pages
> > [    0.000000] Node 0, zone   Normal: page owner found early allocated 2842622 pages
> > [    0.000000] BUG: unable to handle kernel NULL pointer dereference at           (null)
> > [    0.000000] IP: [<ffffffff811f090a>] init_page_owner+0x12a/0x240
> > [    0.000000] PGD 0 
> > [    0.000000] Oops: 0000 [#1] SMP 
> > [    0.000000] Modules linked in:
> > [    0.000000] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.4.74+ #7
> > [    0.000000] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.0.0-prebuilt.qemu-project.org 04/01/2014
> > [    0.000000] task: ffffffff81e104c0 ti: ffffffff81e00000 task.ti: ffffffff81e00000
> > [    0.000000] RIP: 0010:[<ffffffff811f090a>]  [<ffffffff811f090a>] init_page_owner+0x12a/0x240
> > [    0.000000] RSP: 0000:ffffffff81e03ed0  EFLAGS: 00010046
> > [    0.000000] RAX: 0000000000000000 RBX: ffff88083ffe0210 RCX: ffffea0013000000
> > [    0.000000] RDX: 0000000000000300 RSI: ffffffff81f57437 RDI: 00000000004c0000
> > [    0.000000] RBP: ffffffff81e03f20 R08: ffffffff81e03e90 R09: 0000000000000000
> > [    0.000000] R10: 00000000004c0200 R11: 0000000000000000 R12: ffffea0000000000
> > [    0.000000] R13: 00000000004c0200 R14: 00000000004c0000 R15: 0000000000840000
> > [    0.000000] FS:  0000000000000000(0000) GS:ffff88042fc00000(0000) knlGS:0000000000000000
> > [    0.000000] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > [    0.000000] CR2: 0000000000000000 CR3: 0000000001e0b000 CR4: 00000000000406b0
> > [    0.000000] Stack:
> > [    0.000000]  0000000000000206 ffff88083ffe0f90 ffff88083ffdf000 0000000000003181
> > [    0.000000]  ffffea0013000000 0000000000000040 ffffea0000000000 0000000000840000
> > [    0.000000]  0000000000840000 000000008e000010 ffffffff81e03f50 ffffffff81f84145
> > [    0.000000] Call Trace:
> > [    0.000000]  [<ffffffff81f84145>] page_ext_init+0x15e/0x167
> > [    0.000000]  [<ffffffff81f57e6a>] start_kernel+0x351/0x418
> > [    0.000000]  [<ffffffff81f57120>] ? early_idt_handler_array+0x120/0x120
> > [    0.000000]  [<ffffffff81f57309>] x86_64_start_reservations+0x2a/0x2c
> > [    0.000000]  [<ffffffff81f57437>] x86_64_start_kernel+0x12c/0x13b
> > [    0.000000] Code: 81 e2 00 fe ff ff 4d 39 fa 4d 0f 47 d7 4d 39 f2 4d 89 d5 77 34 eb 5e 48 8b 01 f6 c4 04 75 21 48 89 cf 48 89 4d d0 e8 b6 35 00 00 <48> 8b 00 a8 04 75 0e 48 8b 4d d0 e9 c2 00 00 00 48 83 45 c8 01 
> > [    0.000000] RIP  [<ffffffff811f090a>] init_page_owner+0x12a/0x240
> > [    0.000000]  RSP <ffffffff81e03ed0>
> > [    0.000000] CR2: 0000000000000000
> > [    0.000000] ---[ end trace 19e05592f03a690f ]---
> > 
> > Note that this is different backtrace than in b8f1a75d61d8 log.
> > 
> > Still, backporting b8f1a75d61d8 fixes this:
> > 
> > [    1.538379] allocated 738197504 bytes of page_ext
> > [    1.539340] Node 0, zone      DMA: page owner found early allocated 0 pages
> > [    1.540179] Node 0, zone    DMA32: page owner found early allocated 33 pages
> > [    1.611173] Node 0, zone   Normal: page owner found early allocated 96755 pages
> > [    1.683167] Node 1, zone   Normal: page owner found early allocated 96575 pages
> > 
> > No panic, notice how it allocated more for page_ext, and found smaller number of
> > early allocated pages.
> > 
> > Now backporting fe53ca54270a on top:
> > 
> > [    0.000000] allocated 738197504 bytes of page_ext
> > [    0.000000] Node 0, zone      DMA: page owner found early allocated 0 pages
> > [    0.000000] Node 0, zone    DMA32: page owner found early allocated 33 pages
> > [    0.000000] Node 0, zone   Normal: page owner found early allocated 2842622 pages
> > [    0.000000] Node 1, zone   Normal: page owner found early allocated 3694362 pages
> > 
> > Again no panic, and same amount of page_ext usage. But the "early allocated" numbers
> > seem bogus to me. I think it's because init_pages_in_zone() is running and inspecting
> > struct pages that have not been yet initialized. It doesn't end up crashing, but
> > still doesn't seem correct?
> 
> Hmm, and for the record, this is recent mainline. Wonder why the "early

Hmm... I don't know the reason.

> allocated" looks much more sane there. But there's a warning nevertheless.

Warning would comes from the fact that drain_all_pages() is called
before mm_percpu_wq is initialised. We could remove WARN_ON_ONCE() and add
drain_local_page(zone) to fix the problem.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
