Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id D81876B0088
	for <linux-mm@kvack.org>; Sun, 29 Mar 2015 20:43:29 -0400 (EDT)
Received: by pacwe9 with SMTP id we9so150677737pac.1
        for <linux-mm@kvack.org>; Sun, 29 Mar 2015 17:43:29 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id jp11si9591275pbb.255.2015.03.29.17.43.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Mar 2015 17:43:28 -0700 (PDT)
Received: by pacgg7 with SMTP id gg7so21593968pac.0
        for <linux-mm@kvack.org>; Sun, 29 Mar 2015 17:43:28 -0700 (PDT)
Date: Sun, 29 Mar 2015 17:43:19 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: arm/ksm: Unable to handle kernel paging request in get_ksm_page()
 and ksm_scan_thread()
In-Reply-To: <55161D0E.9070604@huawei.com>
Message-ID: <alpine.LSU.2.11.1503291701580.1052@eggly.anvils>
References: <55140869.7060507@huawei.com> <55161D0E.9070604@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, neilb@suse.de, heiko.carstens@de.ibm.com, dhowells@redhat.com, hughd@google.com, izik.eidus@ravellosystems.com, aarcange@redhat.com, chrisw@sous-sol.org, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sat, 28 Mar 2015, Xishi Qiu wrote:
> On 2015/3/26 21:23, Xishi Qiu wrote:
> 
> > Here are two panic logs from smart phone test, and the kernel version is v3.10.
> > 
> > log1 is "Unable to handle kernel paging request at virtual address c0704da020", it should be ffffffc0704da020, right?

That one was an oops at get_ksm_page+0x34/0x150: I'm pretty sure that
comes from the "kpfn = ACCESS_ONCE(stable_node->kpfn)" line, that the
stable_node pointer (in x21 or x22) has upper bits cleared; which
suggests corruption of the rmap_item supposed to point to it.

get_ksm_page() is tricky with ACCESS_ONCEs against page migration,
and the structures tricky with unions; but pointers overlay pointers
in those unions, I don't see any way we might pick up an address with
the upper 24 or 32 bits cleared due to that.

> > and log2 is "Unable to handle kernel paging request at virtual address 1e000796", it should be ffffffc01e000796, right?

And this one was an oops at ksm_scan_thread+0x4ac/0xce0; as is the oops
you posted below.  Which contains lots of hex numbers, but very little
info I can work from.

Please make a CONFIG_DEBUG_INFO=y build of one of the kernels you're
hitting this with, then use the disassembler (objdump -ld perhaps) to
identify precisely which line of ksm.c that is oopsing on: the compiler
will have inlined more interesting functions into ksm_scan_thread, so
I haven't a clue where it's actually oopsing.

Maybe we'll find that it's also oopsing on a kernel virtual address
from an rmap_item, maybe we won't.

And I don't read arm64 assembler at all, so I shall be rather limited
in what I can tell you, I'm afraid.

> > 
> > I cann't repeat the panic by test, so could anyone tell me this is the 
> > bug of ksm or other reason?

I've not heard of any problem like this with KSM on other architectures.
Maybe it is making some assumption which is invalid on arm64, but I'd
have thought we'd have heard about that before now.  My guess is that
something in your kernel is stamping on KSM's structures.

A relevant experiment (after identifying the oops line in your current
kernel) might be to switch from CONFIG_SLAB=y to CONFIG_SLUB=y or vice
versa.  I doubt SLAB or SLUB is to blame, but changing allocator might
shake things up in a way that either hides the problem, or shifts it
elsewhere.

Hugh

> > 
> > Thanks,
> > Xishi Qiu
> > 
> 
> Here is another one.
> 
> [145556.775726s][2015:03:24 20:07:00][pid:864,cpu0,ksmd]Unable to handle kernel paging request at virtual address ff00000000000018
> [145556.775817s][2015:03:24 20:07:00][pid:864,cpu0,ksmd]pgd = ffffffc07f5e4000
> [145556.775817s][2015:03:24 20:07:00][pid:864,cpu0,ksmd][ff00000000000018] *pgd=0000000080808003, *pmd=0000000000000000
> [145556.775878s][2015:03:24 20:07:00][pid:864,cpu0,ksmd]Internal error: Oops: 96000006 [#1] PREEMPT SMP
> [145556.775909s][2015:03:24 20:07:00][pid:864,cpu0,ksmd]Modules linked in:
> [145556.776000s][2015:03:24 20:07:00][pid:864,cpu0,ksmd]CPU: 0 PID: 864 Comm: ksmd Tainted: G        W    3.10.61-g2aca0a6-dirty #2
> [145556.776031s][2015:03:24 20:07:00][pid:864,cpu0,ksmd]task: ffffffc0bc06ee00 ti: ffffffc0baae4000 task.ti: ffffffc0baae4000
> [145556.776092s][2015:03:24 20:07:00][pid:864,cpu0,ksmd]PC is at ksm_scan_thread+0x4ac/0xce0
> [145556.776123s][2015:03:24 20:07:00][pid:864,cpu0,ksmd]LR is at ksm_scan_thread+0x49c/0xce0
> [145556.776153s][2015:03:24 20:07:00][pid:864,cpu0,ksmd]pc : [<ffffffc00077a3e4>] lr : [<ffffffc00077a3d4>] pstate: 80000145
> [145556.776153s][2015:03:24 20:07:00][pid:864,cpu0,ksmd]sp : ffffffc0baae7d50
> [145556.776184s][2015:03:24 20:07:00][pid:864,cpu0,ksmd]x29: ffffffc0baae7d50 x28: 0000000075a40000 
> [145556.776214s][2015:03:24 20:07:00][pid:864,cpu0,ksmd]x27: ffffffbc02308260 x26: ffffffc0010ab000 
> [145556.776245s][2015:03:24 20:07:00][pid:864,cpu0,ksmd]x25: ffffffc0599392a0 x24: ffffffc0baae4000 
> [145556.776306s][2015:03:24 20:07:00][pid:864,cpu0,ksmd]x23: ffffffc001a0aa90 x22: ffffffc0baae7df8 
> [145556.776336s][2015:03:24 20:07:00][pid:864,cpu0,ksmd]x21: ffffffc084150080 x20: ff00000000000000 
> [145556.776367s][2015:03:24 20:07:00][pid:864,cpu0,ksmd]x19: ffffffc0018ddb88 x18: 0000000000000000 
> [145556.776397s][2015:03:24 20:07:00][pid:864,cpu0,ksmd]x17: 0000007f7f28a974 x16: ffffffc0007ca16c 
> [145556.776428s][2015:03:24 20:07:00][pid:864,cpu0,ksmd]x15: 0000000000000873 x14: 0000000000000001 
> [145556.776458s][2015:03:24 20:07:00][pid:864,cpu0,ksmd]x13: 0000000000000001 x12: 0000000000000848 
> [145556.776489s][2015:03:24 20:07:00][pid:864,cpu0,ksmd]x11: 0000000000000848 x10: 000000006995fcb1 
> [145556.776519s][2015:03:24 20:07:00][pid:864,cpu0,ksmd]x9 : 00000000c72311f7 x8 : 0000000009050501 
> [145556.776550s][2015:03:24 20:07:00][pid:864,cpu0,ksmd]x7 : 0000000005aeda8e x6 : 00000000fa9a48df 
> [145556.776611s][2015:03:24 20:07:00][pid:864,cpu0,ksmd]x5 : ffffffc095e7abb0 x4 : 00000000000bffff 
> [145556.776641s][2015:03:24 20:07:00][pid:864,cpu0,ksmd]x3 : 0000000000000001 x2 : 0000000000000001 
> [145556.776672s][2015:03:24 20:07:00][pid:864,cpu0,ksmd]x1 : 0000000000100051 x0 : ffffffbc02308260 
[ remainder snipped ]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
