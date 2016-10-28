Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C85776B027B
	for <linux-mm@kvack.org>; Fri, 28 Oct 2016 16:15:53 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 68so8830808wmz.5
        for <linux-mm@kvack.org>; Fri, 28 Oct 2016 13:15:53 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id o83si11855745wmb.123.2016.10.28.13.15.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Oct 2016 13:15:52 -0700 (PDT)
Date: Fri, 28 Oct 2016 21:15:48 +0100
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: Re: Crash in -next due to 'mm/vmalloc: replace opencoded 4-level
 page walkers'
Message-ID: <20161028201548.GA16450@nuc-i3427.alporthouse.com>
References: <20161028171825.GA15116@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161028171825.GA15116@roeck-us.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guenter Roeck <linux@roeck-us.net>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, sparclinux@vger.kernel.org, linux-mm@kvack.org

On Fri, Oct 28, 2016 at 10:18:25AM -0700, Guenter Roeck wrote:
> Hi,
> 
> when running sparc64 images in qemu, I see the following crash.
> This is with next-20161028.
> 
> [    2.530785] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff,max_idle_ns: 19112604462750000 ns
> [    2.532359] kernel BUG at mm/memory.c:1881!
> [    2.532798]               \|/ ____ \|/
> [    2.532798]               "@'/ .. \`@"
> [    2.532798]               /_| \__/ |_\
> [    2.532798]                  \__U_/
> [    2.533250] swapper(1): Kernel bad sw trap 5 [#1]
> [    2.533705] CPU: 0 PID: 1 Comm: swapper Not tainted 4.9.0-rc2+ #1
> [    2.534129] task: fffff8001f0af620 task.stack: fffff8001f0b0000
> [    2.534505] TSTATE: 0000004480001605 TPC: 00000000005124d8 TNPC: 00000000005124dc Y: 00000035    Not tainted
> [    2.535112] TPC: <apply_to_page_range+0x2f8/0x3a0>
> [    2.535469] g0: 00000000009b1548 g1: 0000000000a4a990 g2: 0000000000a4a990 g3: 0000000000b37694
> [    2.535857] g4: fffff8001f0af620 g5: 0000000000000000 g6: fffff8001f0b0000 g7: 0000000000000000
> [    2.536236] o0: 000000000000001f o1: 00000000009ac2c0 o2: 0000000000000759 o3: 0000000000122000
> [    2.536695] o4: 0000000000000000 o5: 00000000009ac2c0 sp: fffff8001f0b2d61 ret_pc: 00000000005124d0
> [    2.537086] RPC: <apply_to_page_range+0x2f0/0x3a0>
> [    2.537454] l0: 0000000000000000 l1: 0000000000002000 l2: fffff8001f10b000 l3: 0000000100002000
> [    2.537843] l4: 0000000000aef910 l5: 0000000000a5e7e8 l6: 0000000100001fff l7: ffffffffff800000
> [    2.538229] i0: 0000000000a5e7e8 i1: 0000000100000000 i2: 0000000100002000 i3: 000000000051e5e0
> [    2.538613] i4: fffff8001f0b3708 i5: fffff8001f10c000 i6: fffff8001f0b2e51 i7: 000000000051e8e0
> [    2.539007] I7: <vmap_page_range_noflush+0x40/0x80>
> [    2.539387] Call Trace:
> [    2.539765]  [000000000051e8e0] vmap_page_range_noflush+0x40/0x80
> [    2.540139]  [000000000051e970] map_vm_area+0x50/0x80
> [    2.540492]  [000000000051f84c] __vmalloc_node_range+0x14c/0x260
> [    2.540848]  [000000000051f98c] __vmalloc_node+0x2c/0x40
> [    2.541198]  [00000000004d39cc] bpf_prog_alloc+0x2c/0xa0
> [    2.541554]  [00000000008129bc] bpf_prog_create+0x3c/0xa0
> [    2.541916]  [0000000000adb21c] ptp_classifier_init+0x20/0x4c
> [    2.542271]  [0000000000ad9808] sock_init+0x90/0xa0
> [    2.542622]  [0000000000426cb0] do_one_initcall+0x30/0x160
> [    2.542978]  [0000000000aaeaec] kernel_init_freeable+0x10c/0x1b0
> [    2.543332]  [00000000008e3324] kernel_init+0x4/0x100
> [    2.543681]  [0000000000405f04] ret_from_fork+0x1c/0x2c
> 
> Bisect points to commit 0c79e3331f08 ("mm/vmalloc: replace opencoded 4-level
> page walkers"). Reverting this patch fixes the problem.

Hmm, apply_to_pte_range() has a BUG_ON(pmd_huge(*pmd)) but the old
vmap_pte_range() does not and neither has the code to handle that case.
Presuming that the BUG_ON() there is actually meaningful.
-Chris

-- 
Chris Wilson, Intel Open Source Technology Centre

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
