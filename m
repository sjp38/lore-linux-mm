Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7C4896B02FE
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 08:07:10 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id he10so53284366wjc.6
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 05:07:10 -0800 (PST)
Received: from mail-wj0-f193.google.com (mail-wj0-f193.google.com. [209.85.210.193])
        by mx.google.com with ESMTPS id 63si18925597wmo.42.2016.12.20.05.07.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 05:07:09 -0800 (PST)
Received: by mail-wj0-f193.google.com with SMTP id he10so27636665wjc.2
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 05:07:09 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/2] mm, slab: make sure that KMALLOC_MAX_SIZE will fit into MAX_ORDER
Date: Tue, 20 Dec 2016 14:06:58 +0100
Message-Id: <20161220130659.16461-2-mhocko@kernel.org>
In-Reply-To: <20161220130659.16461-1-mhocko@kernel.org>
References: <20161220130659.16461-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Cristopher Lameter <cl@linux.com>, Alexei Starovoitov <ast@kernel.org>, Andrey Konovalov <andreyknvl@google.com>, netdev@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Andrey Konovalov has reported the following warning triggered by
the syzkaller fuzzer.

WARNING: CPU: 1 PID: 9935 at mm/page_alloc.c:3511
__alloc_pages_nodemask+0x159c/0x1e20
Kernel panic - not syncing: panic_on_warn set ...

CPU: 1 PID: 9935 Comm: syz-executor0 Not tainted 4.9.0-rc7+ #34
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 ffff88006949f2c8 ffffffff81f96b8a ffffffff00000200 1ffff1000d293dec
 ffffed000d293de4 0000000000000a06 0000000041b58ab3 ffffffff8598b510
 ffffffff81f968f8 0000000041b58ab3 ffffffff85942a58 ffffffff81432860
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff81f96b8a>] dump_stack+0x292/0x398 lib/dump_stack.c:51
 [<ffffffff8168c88e>] panic+0x1cb/0x3a9 kernel/panic.c:179
 [<ffffffff812b80b4>] __warn+0x1c4/0x1e0 kernel/panic.c:542
 [<ffffffff812b831c>] warn_slowpath_null+0x2c/0x40 kernel/panic.c:585
 [<     inline     >] __alloc_pages_slowpath mm/page_alloc.c:3511
 [<ffffffff816c08ac>] __alloc_pages_nodemask+0x159c/0x1e20 mm/page_alloc.c:3781
 [<ffffffff817cde17>] alloc_pages_current+0x1c7/0x6b0 mm/mempolicy.c:2072
 [<     inline     >] alloc_pages include/linux/gfp.h:469
 [<ffffffff8172fd8f>] kmalloc_order+0x1f/0x70 mm/slab_common.c:1015
 [<ffffffff8172fdff>] kmalloc_order_trace+0x1f/0x160 mm/slab_common.c:1026
 [<     inline     >] kmalloc_large include/linux/slab.h:422
 [<ffffffff817e01f0>] __kmalloc+0x210/0x2d0 mm/slub.c:3723
 [<     inline     >] kmalloc include/linux/slab.h:495
 [<ffffffff832262a7>] ep_write_iter+0x167/0xb50 drivers/usb/gadget/legacy/inode.c:664
 [<     inline     >] new_sync_write fs/read_write.c:499
 [<ffffffff817fdcd3>] __vfs_write+0x483/0x760 fs/read_write.c:512
 [<ffffffff817ff720>] vfs_write+0x170/0x4e0 fs/read_write.c:560
 [<     inline     >] SYSC_write fs/read_write.c:607
 [<ffffffff81803b2b>] SyS_write+0xfb/0x230 fs/read_write.c:599
 [<ffffffff84f47ec1>] entry_SYSCALL_64_fastpath+0x1f/0xc2

The issue is caused by a lack of size check for the request size in
ep_write_iter which should be fixed. It, however, points to another
problem, that SLUB defines KMALLOC_MAX_SIZE too large because the its
KMALLOC_SHIFT_MAX is (MAX_ORDER + PAGE_SHIFT) which means that the
resulting page allocator request might be MAX_ORDER which is too large
(see __alloc_pages_slowpath). The same applies to the SLOB allocator
which allows even larger sizes. Make sure that they are capped properly
and never request more than MAX_ORDER order.

Reported-by: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
Acked-by: Christoph Lameter <cl@linux.com>
---
 include/linux/slab.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 084b12bad198..4c5363566815 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -226,7 +226,7 @@ static inline const char *__check_heap_object(const void *ptr,
  * (PAGE_SIZE*2).  Larger requests are passed to the page allocator.
  */
 #define KMALLOC_SHIFT_HIGH	(PAGE_SHIFT + 1)
-#define KMALLOC_SHIFT_MAX	(MAX_ORDER + PAGE_SHIFT)
+#define KMALLOC_SHIFT_MAX	(MAX_ORDER + PAGE_SHIFT - 1)
 #ifndef KMALLOC_SHIFT_LOW
 #define KMALLOC_SHIFT_LOW	3
 #endif
@@ -239,7 +239,7 @@ static inline const char *__check_heap_object(const void *ptr,
  * be allocated from the same page.
  */
 #define KMALLOC_SHIFT_HIGH	PAGE_SHIFT
-#define KMALLOC_SHIFT_MAX	30
+#define KMALLOC_SHIFT_MAX	(MAX_ORDER + PAGE_SHIFT - 1)
 #ifndef KMALLOC_SHIFT_LOW
 #define KMALLOC_SHIFT_LOW	3
 #endif
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
