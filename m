Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 0666A6B0038
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 06:58:03 -0400 (EDT)
Received: by pagj7 with SMTP id j7so25336581pag.2
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 03:58:02 -0700 (PDT)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id s17si3141685pdn.210.2015.03.25.03.58.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 25 Mar 2015 03:58:02 -0700 (PDT)
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0NLR00IIPL4N1CD0@mailout4.samsung.com> for linux-mm@kvack.org;
 Wed, 25 Mar 2015 19:57:59 +0900 (KST)
From: Heesub Shin <heesub.shin@samsung.com>
Subject: [PATCH] zsmalloc: fix fatal corruption due to wrong size class
 selection
Date: Wed, 25 Mar 2015 19:58:12 +0900
Message-id: <1427281092-10116-1-git-send-email-heesub.shin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Sunae Seo <sunae.seo@samsung.com>, Sunghwan Yun <sunghwan.yun@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sooyong Suk <s.suk@samsung.com>, Heesub Shin <heesub.shin@samsung.com>

There is no point in overriding the size class below. It causes fatal
corruption on the next chunk on the 3264-bytes size class, which is the
last size class that is not huge.

For example, if the requested size was exactly 3264 bytes, current
zsmalloc allocates and returns a chunk from the size class of 3264
bytes, not 4096. User access to this chunk may overwrite head of the
next adjacent chunk.

Here is the panic log captured when freelist was corrupted due to this:

    Kernel BUG at ffffffc00030659c [verbose debug info unavailable]
    Internal error: Oops - BUG: 96000006 [#1] PREEMPT SMP
    Modules linked in:
    exynos-snapshot: core register saved(CPU:5)
    CPUMERRSR: 0000000000000000, L2MERRSR: 0000000000000000
    exynos-snapshot: context saved(CPU:5)
    exynos-snapshot: item - log_kevents is disabled
    CPU: 5 PID: 898 Comm: kswapd0 Not tainted 3.10.61-4497415-eng #1
    task: ffffffc0b8783d80 ti: ffffffc0b71e8000 task.ti: ffffffc0b71e8000
    PC is at obj_idx_to_offset+0x0/0x1c
    LR is at obj_malloc+0x44/0xe8
    pc : [<ffffffc00030659c>] lr : [<ffffffc000306604>] pstate: a0000045
    sp : ffffffc0b71eb790
    x29: ffffffc0b71eb790 x28: ffffffc00204c000
    x27: 000000000001d96f x26: 0000000000000000
    x25: ffffffc098cc3500 x24: ffffffc0a13f2810
    x23: ffffffc098cc3501 x22: ffffffc0a13f2800
    x21: 000011e1a02006e3 x20: ffffffc0a13f2800
    x19: ffffffbc02a7e000 x18: 0000000000000000
    x17: 0000000000000000 x16: 0000000000000feb
    x15: 0000000000000000 x14: 00000000a01003e3
    x13: 0000000000000020 x12: fffffffffffffff0
    x11: ffffffc08b264000 x10: 00000000e3a01004
    x9 : ffffffc08b263fea x8 : ffffffc0b1e611c0
    x7 : ffffffc000307d24 x6 : 0000000000000000
    x5 : 0000000000000038 x4 : 000000000000011e
    x3 : ffffffbc00003e90 x2 : 0000000000000cc0
    x1 : 00000000d0100371 x0 : ffffffbc00003e90

Reported-by: Sooyong Suk <s.suk@samsung.com>
Signed-off-by: Heesub Shin <heesub.shin@samsung.com>
Tested-by: Sooyong Suk <s.suk@samsung.com>
Cc: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 6c39ae9..a2da64b 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1398,11 +1398,6 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 	/* extra space in chunk to keep the handle */
 	size += ZS_HANDLE_SIZE;
 	class = pool->size_class[get_size_class_index(size)];
-	/* In huge class size, we store the handle into first_page->private */
-	if (class->huge) {
-		size -= ZS_HANDLE_SIZE;
-		class = pool->size_class[get_size_class_index(size)];
-	}
 
 	spin_lock(&class->lock);
 	first_page = find_get_zspage(class);
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
