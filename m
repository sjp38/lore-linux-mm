Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BF34C6B0279
	for <linux-mm@kvack.org>; Tue, 30 May 2017 15:44:10 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id h76so110117453pfh.15
        for <linux-mm@kvack.org>; Tue, 30 May 2017 12:44:10 -0700 (PDT)
Received: from mail-pf0-x235.google.com (mail-pf0-x235.google.com. [2607:f8b0:400e:c00::235])
        by mx.google.com with ESMTPS id u13si45284768plm.229.2017.05.30.12.44.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 May 2017 12:44:09 -0700 (PDT)
Received: by mail-pf0-x235.google.com with SMTP id e193so81351668pfh.0
        for <linux-mm@kvack.org>; Tue, 30 May 2017 12:44:09 -0700 (PDT)
Date: Tue, 30 May 2017 12:43:59 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: 4.12-rc ppc64 4k-page needs costly allocations
Message-ID: <alpine.LSU.2.11.1705301151090.2133@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Christoph Lameter <cl@linux.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Since f6eedbba7a26 ("powerpc/mm/hash: Increase VA range to 128TB")
I find that swapping loads on ppc64 on G5 with 4k pages are failing:

SLUB: Unable to allocate memory on node -1, gfp=0x14000c0(GFP_KERNEL)
  cache: pgtable-2^12, object size: 32768, buffer size: 65536, default order: 4, min order: 4
  pgtable-2^12 debugging increased min order, use slub_debug=O to disable.
  node 0: slabs: 209, objs: 209, free: 8
gcc: page allocation failure: order:4, mode:0x16040c0(GFP_KERNEL|__GFP_COMP|__GFP_NOTRACK), nodemask=(null)
CPU: 1 PID: 6225 Comm: gcc Not tainted 4.12.0-rc2 #1
Call Trace:
[c00000000090b5c0] [c0000000004f8478] .dump_stack+0xa0/0xcc (unreliable)
[c00000000090b650] [c0000000000eb194] .warn_alloc+0xf0/0x178
[c00000000090b710] [c0000000000ebc9c] .__alloc_pages_nodemask+0xa04/0xb00
[c00000000090b8b0] [c00000000013921c] .new_slab+0x234/0x608
[c00000000090b980] [c00000000013b59c] .___slab_alloc.constprop.64+0x3dc/0x564
[c00000000090bad0] [c0000000004f5a84] .__slab_alloc.isra.61.constprop.63+0x54/0x70
[c00000000090bb70] [c00000000013b864] .kmem_cache_alloc+0x140/0x288
[c00000000090bc30] [c00000000004d934] .mm_init.isra.65+0x128/0x1c0
[c00000000090bcc0] [c000000000157810] .do_execveat_common.isra.39+0x294/0x690
[c00000000090bdb0] [c000000000157e70] .SyS_execve+0x28/0x38
[c00000000090be30] [c00000000000a118] system_call+0x38/0xfc

I did try booting with slub_debug=O as the message suggested, but that
made no difference: it still hoped for but failed on order:4 allocations.

I wanted to try removing CONFIG_SLUB_DEBUG, but didn't succeed in that:
it seemed to be a hard requirement for something, but I didn't find what.

I did try CONFIG_SLAB=y instead of SLUB: that lowers these allocations to
the expected order:3, which then results in OOM-killing rather than direct
allocation failure, because of the PAGE_ALLOC_COSTLY_ORDER 3 cutoff.  But
makes no real difference to the outcome: swapping loads still abort early.

Relying on order:3 or order:4 allocations is just too optimistic: ppc64
with 4k pages would do better not to expect to support a 128TB userspace.

I tried the obvious partial revert below, but it's not good enough:
the system did not boot beyond

Starting init: /sbin/init exists but couldn't execute it (error -7)
Starting init: /bin/sh exists but couldn't execute it (error -7)
Kernel panic - not syncing: No working init found. ...

--- 4.12-rc2/arch/powerpc/include/asm/book3s/64/hash-4k.h
+++ linux/arch/powerpc/include/asm/book3s/64/hash-4k.h
@@ -8,7 +8,7 @@
 #define H_PTE_INDEX_SIZE  9
 #define H_PMD_INDEX_SIZE  7
 #define H_PUD_INDEX_SIZE  9
-#define H_PGD_INDEX_SIZE  12
+#define H_PGD_INDEX_SIZE  9
 
 #ifndef __ASSEMBLY__
 #define H_PTE_TABLE_SIZE	(sizeof(pte_t) << H_PTE_INDEX_SIZE)
--- 4.12-rc2/arch/powerpc/include/asm/processor.h
+++ linux/arch/powerpc/include/asm/processor.h
@@ -110,7 +110,7 @@ void release_thread(struct task_struct *
 #define TASK_SIZE_128TB (0x0000800000000000UL)
 #define TASK_SIZE_512TB (0x0002000000000000UL)
 
-#ifdef CONFIG_PPC_BOOK3S_64
+#if defined(CONFIG_PPC_BOOK3S_64) && defined(CONFIG_PPC_64K_PAGES)
 /*
  * Max value currently used:
  */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
