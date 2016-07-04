Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id BC46F6B0005
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 19:42:33 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id g4so116301331ith.3
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 16:42:33 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id v186si643484iod.113.2016.07.04.16.42.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jul 2016 16:42:32 -0700 (PDT)
Subject: Re: [PATCH v5] mm, kasan: switch SLUB to stackdepot, enable memory
 quarantine for SLUB
References: <1466617421-58518-1-git-send-email-glider@google.com>
From: Sasha Levin <sasha.levin@oracle.com>
Message-ID: <577AF45A.5080503@oracle.com>
Date: Mon, 4 Jul 2016 19:42:18 -0400
MIME-Version: 1.0
In-Reply-To: <1466617421-58518-1-git-send-email-glider@google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>, adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, rostedt@goodmis.org, iamjoonsoo.kim@lge.com, js1304@gmail.com, kcc@google.com, aryabinin@virtuozzo.com, kuthonuzo.luruo@hpe.com
Cc: kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/22/2016 01:43 PM, Alexander Potapenko wrote:
> For KASAN builds:
>  - switch SLUB allocator to using stackdepot instead of storing the
>    allocation/deallocation stacks in the objects;
>  - change the freelist hook so that parts of the freelist can be put
>    into the quarantine.

This commit seems to be causing the following on boot (bisected):

[    0.000000] =============================================================================

[    0.000000] BUG radix_tree_node (Not tainted): Object padding overwritten

[    0.000000] -----------------------------------------------------------------------------

[    0.000000]

[    0.000000] Disabling lock debugging due to kernel taint

[    0.000000] INFO: 0xffff88004fc01600-0xffff88004fc01600. First byte 0x58 instead of 0x5a

[    0.000000] INFO: Slab 0xffffea00013f0000 objects=34 used=34 fp=0x          (null) flags=0x1fffff80004080

[    0.000000] INFO: Object 0xffff88004fc01278 @offset=4728 fp=0xffff88004fc033a8

[    0.000000]

[    0.000000] Redzone ffff88004fc01270: bb bb bb bb bb bb bb bb                          ........

[    0.000000] Object ffff88004fc01278: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[    0.000000] Object ffff88004fc01288: 00 00 00 00 00 00 00 00 90 12 c0 4f 00 88 ff ff  ...........O....

[    0.000000] Object ffff88004fc01298: 90 12 c0 4f 00 88 ff ff 00 00 00 00 00 00 00 00  ...O............

[    0.000000] Object ffff88004fc012a8: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[    0.000000] Object ffff88004fc012b8: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[    0.000000] Object ffff88004fc012c8: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[    0.000000] Object ffff88004fc012d8: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[    0.000000] Object ffff88004fc012e8: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[    0.000000] Object ffff88004fc012f8: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[    0.000000] Object ffff88004fc01308: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[    0.000000] Object ffff88004fc01318: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[    0.000000] Object ffff88004fc01328: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[    0.000000] Object ffff88004fc01338: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[    0.000000] Object ffff88004fc01348: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[    0.000000] Object ffff88004fc01358: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[    0.000000] Object ffff88004fc01368: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[    0.000000] Object ffff88004fc01378: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[    0.000000] Object ffff88004fc01388: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[    0.000000] Object ffff88004fc01398: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[    0.000000] Object ffff88004fc013a8: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[    0.000000] Object ffff88004fc013b8: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[    0.000000] Object ffff88004fc013c8: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[    0.000000] Object ffff88004fc013d8: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[    0.000000] Object ffff88004fc013e8: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[    0.000000] Object ffff88004fc013f8: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[    0.000000] Object ffff88004fc01408: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[    0.000000] Object ffff88004fc01418: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[    0.000000] Object ffff88004fc01428: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[    0.000000] Object ffff88004fc01438: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[    0.000000] Object ffff88004fc01448: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[    0.000000] Object ffff88004fc01458: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[    0.000000] Object ffff88004fc01468: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[    0.000000] Object ffff88004fc01478: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[    0.000000] Object ffff88004fc01488: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[    0.000000] Object ffff88004fc01498: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[    0.000000] Object ffff88004fc014a8: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[    0.000000] Redzone ffff88004fc014b8: bb bb bb bb bb bb bb bb                          ........

[    0.000000] Padding ffff88004fc015f8: 5a 5a 5a 5a 5a 5a 5a 5a 58 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZXZZZZZZZ

[    0.000000] Padding ffff88004fc01608: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ

[    0.000000] Padding ffff88004fc01618: 5a 5a 5a 5a 5a 5a 5a 5a                          ZZZZZZZZ

[    0.000000] CPU: 0 PID: 0 Comm: swapper/0 Tainted: G    B           4.7.0-rc5-next-20160704-sasha-00024-ge77e3f3 #3135

[    0.000000]  1ffffffff4c40f12 9d094fbe896d693a ffffffffa6207918 ffffffff9b06d567

[    0.000000]  ffffffff00000000 fffffbfff4cb1f60 0000000041b58ab3 ffffffffa5d082b8

[    0.000000]  ffffffff9b06d3f8 9d094fbe896d693a ffffffffa6238040 ffffffffa5d26f04

[    0.000000] Call Trace:

[    0.000000] dump_stack (lib/dump_stack.c:53)
[    0.000000] ? arch_local_irq_restore (./arch/x86/include/asm/paravirt.h:134)
[    0.000000] ? print_section (./arch/x86/include/asm/current.h:14 include/linux/kasan.h:35 mm/slub.c:481 mm/slub.c:512)
[    0.000000] print_trailer (mm/slub.c:670)
[    0.000000] check_bytes_and_report (mm/slub.c:712 mm/slub.c:738)
[    0.000000] check_object (mm/slub.c:868)
[    0.000000] ? radix_tree_node_alloc (lib/radix-tree.c:306)
[    0.000000] alloc_debug_processing (mm/slub.c:1068 mm/slub.c:1079)
[    0.000000] ___slab_alloc (mm/slub.c:2571 (discriminator 1))
[    0.000000] ? radix_tree_node_alloc (lib/radix-tree.c:306)
[    0.000000] ? radix_tree_node_alloc (lib/radix-tree.c:306)
[    0.000000] ? check_preemption_disabled (lib/smp_processor_id.c:52)
[    0.000000] ? radix_tree_node_alloc (lib/radix-tree.c:306)
[    0.000000] __slab_alloc.isra.23 (./arch/x86/include/asm/paravirt.h:789 mm/slub.c:2602)
[    0.000000] ? radix_tree_node_alloc (lib/radix-tree.c:306)
[    0.000000] kmem_cache_alloc (mm/slub.c:2664 mm/slub.c:2706 mm/slub.c:2711)
[    0.000000] ? deactivate_slab (mm/slub.c:2129)
[    0.000000] radix_tree_node_alloc (lib/radix-tree.c:306)
[    0.000000] __radix_tree_create (lib/radix-tree.c:505 lib/radix-tree.c:561)
[    0.000000] ? radix_tree_maybe_preload_order (lib/radix-tree.c:550)
[    0.000000] ? alloc_cpumask_var_node (lib/cpumask.c:64)
[    0.000000] ? kasan_unpoison_shadow (mm/kasan/kasan.c:59)
[    0.000000] ? kasan_kmalloc (mm/kasan/kasan.c:498 mm/kasan/kasan.c:592)
[    0.000000] __radix_tree_insert (lib/radix-tree.c:637)
[    0.000000] ? __radix_tree_create (lib/radix-tree.c:629)
[    0.000000] ? _find_next_bit (lib/find_bit.c:54)
[    0.000000] ? alloc_desc (kernel/irq/irqdesc.c:190)
[    0.000000] early_irq_init (kernel/irq/irqdesc.c:279 (discriminator 1))
[    0.000000] start_kernel (init/main.c:563)
[    0.000000] ? thread_stack_cache_init (??:?)
[    0.000000] ? memblock_reserve (mm/memblock.c:737)
[    0.000000] ? early_idt_handler_array (arch/x86/kernel/head_64.S:361)
[    0.000000] x86_64_start_reservations (arch/x86/kernel/head64.c:196)
[    0.000000] x86_64_start_kernel (arch/x86/kernel/head64.c:176)
[    0.000000] FIX radix_tree_node: Restoring 0xffff88004fc01600-0xffff88004fc01600=0x5a


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
