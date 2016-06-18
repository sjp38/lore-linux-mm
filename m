Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id E61866B007E
	for <linux-mm@kvack.org>; Sat, 18 Jun 2016 11:33:02 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id b126so49406991ite.3
        for <linux-mm@kvack.org>; Sat, 18 Jun 2016 08:33:02 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id h4si5400717ite.83.2016.06.18.08.33.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 18 Jun 2016 08:33:02 -0700 (PDT)
Subject: Re: [PATCH v4] mm, kasan: switch SLUB to stackdepot, enable memory
 quarantine for SLUB
References: <1466173664-118413-1-git-send-email-glider@google.com>
From: Sasha Levin <sasha.levin@oracle.com>
Message-ID: <5765699E.6000508@oracle.com>
Date: Sat, 18 Jun 2016 11:32:46 -0400
MIME-Version: 1.0
In-Reply-To: <1466173664-118413-1-git-send-email-glider@google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>, adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, rostedt@goodmis.org, iamjoonsoo.kim@lge.com, js1304@gmail.com, kcc@google.com, aryabinin@virtuozzo.com, kuthonuzo.luruo@hpe.com
Cc: kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/17/2016 10:27 AM, Alexander Potapenko wrote:
> For KASAN builds:
>  - switch SLUB allocator to using stackdepot instead of storing the
>    allocation/deallocation stacks in the objects;
>  - define SLAB_RED_ZONE, SLAB_POISON, SLAB_STORE_USER to zero,
>    effectively disabling these debug features, as they're redundant in
>    the presence of KASAN;
>  - change the freelist hook so that parts of the freelist can be put into
>    the quarantine.
> 
> Signed-off-by: Alexander Potapenko <glider@google.com>

Hi Alexander,

I was seeing a bunch of use-after-frees detected by kasan, such as:

BUG: KASAN: use-after-free in rb_next+0x117/0x1b0 at addr ffff8800b01d4f30
Read of size 8 by task syz-executor/31594
CPU: 2 PID: 31594 Comm: syz-executor Tainted: G        W       4.7.0-rc2-sasha-00205-g2d8a14b #3117
 1ffff10015450f0f 000000007b9351fc ffff8800aa287900 ffffffffa002778b
 ffffffff00000002 fffffbfff5630d30 0000000041b58ab3 ffffffffaaad5648
 ffffffffa002761c ffffffff9e006ab6 ffffffffa8439f65 ffffffffffffffff
Call Trace:
 [<ffffffffa002778b>] dump_stack+0x16f/0x1d4
 [<ffffffff9e79e8cf>] kasan_report_error+0x59f/0x8c0
 [<ffffffff9e79ee06>] __asan_report_load8_noabort+0x66/0x90
 [<ffffffffa003ccf7>] rb_next+0x117/0x1b0
 [<ffffffff9e71627c>] validate_mm_rb+0xac/0xd0
 [<ffffffff9e718594>] __vma_link_rb+0x2e4/0x310
 [<ffffffff9e718650>] vma_link+0x90/0x1b0
 [<ffffffff9e722870>] mmap_region+0x13a0/0x13c0
 [<ffffffff9e7232b2>] do_mmap+0xa22/0xaf0
 [<ffffffff9e6c86bf>] vm_mmap_pgoff+0x14f/0x1c0
 [<ffffffff9e71ba8b>] SyS_mmap_pgoff+0x81b/0x910
 [<ffffffff9e1bf966>] SyS_mmap+0x16/0x20
 [<ffffffff9e006ab6>] do_syscall_64+0x2a6/0x490
 [<ffffffffa8439f65>] entry_SYSCALL64_slow_path+0x25/0x25
Object at ffff8800b01d4f00, in cache vm_area_struct
Object allocated with size 192 bytes.
Allocation:
PID = 8855
(stack is not available)
Memory state around the buggy address:
 ffff8800b01d4e00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff8800b01d4e80: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc
>ffff8800b01d4f00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                                     ^
 ffff8800b01d4f80: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc
 ffff8800b01d5000: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

Or:

BUG: KASAN: use-after-free in validate_mm_rb+0x73/0xd0 at addr ffff8800b01d4f38
Read of size 8 by task syz-executor/31594
CPU: 2 PID: 31594 Comm: syz-executor Tainted: G    B   W       4.7.0-rc2-sasha-00205-g2d8a14b #3117
 1ffff10015450f16 000000007b9351fc ffff8800aa287938 ffffffffa002778b
 ffffffff00000002 fffffbfff5630d30 0000000041b58ab3 ffffffffaaad5648
 ffffffffa002761c ffffffffa84399e8 0000000000000010 ffff8800b61e8000
Call Trace:
 [<ffffffffa002778b>] dump_stack+0x16f/0x1d4
 [<ffffffff9e79e8cf>] kasan_report_error+0x59f/0x8c0
 [<ffffffff9e79ee06>] __asan_report_load8_noabort+0x66/0x90
 [<ffffffff9e716243>] validate_mm_rb+0x73/0xd0
 [<ffffffff9e718594>] __vma_link_rb+0x2e4/0x310
 [<ffffffff9e718650>] vma_link+0x90/0x1b0
 [<ffffffff9e722870>] mmap_region+0x13a0/0x13c0
 [<ffffffff9e7232b2>] do_mmap+0xa22/0xaf0
 [<ffffffff9e6c86bf>] vm_mmap_pgoff+0x14f/0x1c0
 [<ffffffff9e71ba8b>] SyS_mmap_pgoff+0x81b/0x910
 [<ffffffff9e1bf966>] SyS_mmap+0x16/0x20
 [<ffffffff9e006ab6>] do_syscall_64+0x2a6/0x490
 [<ffffffffa8439f65>] entry_SYSCALL64_slow_path+0x25/0x25
Object at ffff8800b01d4f00, in cache vm_area_struct
Object allocated with size 192 bytes.
Allocation:
PID = 8855
(stack is not available)
Memory state around the buggy address:
 ffff8800b01d4e00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff8800b01d4e80: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc
>ffff8800b01d4f00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                                        ^
 ffff8800b01d4f80: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc
 ffff8800b01d5000: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

And bisection pointed me to this commit. Now, I'm not sure how to
tell if this is memory quarantine catching something, or is just a
bug with the patch?


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
