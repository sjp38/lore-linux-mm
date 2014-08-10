Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 9A4B56B0036
	for <linux-mm@kvack.org>; Sun, 10 Aug 2014 02:32:07 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id rd3so9409522pab.12
        for <linux-mm@kvack.org>; Sat, 09 Aug 2014 23:32:07 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id nj8si6313751pdb.70.2014.08.09.23.32.05
        for <linux-mm@kvack.org>;
        Sat, 09 Aug 2014 23:32:06 -0700 (PDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 1/1] memblock, memhotplug: Fix wrong type in memblock_find_in_range_node().
Date: Sun, 10 Aug 2014 14:12:03 +0800
Message-ID: <1407651123-10994-1-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, santosh.shilimkar@ti.com, grygorii.strashko@ti.com, phacht@linux.vnet.ibm.com, yinghai@kernel.org, fabf@skynet.be, Emilian.Medve@freescale.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, tangchen@cn.fujitsu.com

In memblock_find_in_range_node(), we defeind ret as int. But it shoule
be phys_addr_t because it is used to store the return value from
__memblock_find_range_bottom_up().

The bug has not been triggered because when allocating low memory near
the kernel end, the "int ret" won't turn out to be minus. When we started
to allocate memory on other nodes, and the "int ret" could be minus.
Then the kernel will panic.

A simple way to reproduce this: comment out the following code in numa_init(),

        memblock_set_bottom_up(false);

and the kernel won't boot.

Reported-by: Xishi Qiu <qiuxishi@huawei.com>
Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 mm/memblock.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 6d2f219..70fad0c 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -192,8 +192,7 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t size,
 					phys_addr_t align, phys_addr_t start,
 					phys_addr_t end, int nid)
 {
-	int ret;
-	phys_addr_t kernel_end;
+	phys_addr_t kernel_end, ret;
 
 	/* pump up @end */
 	if (end == MEMBLOCK_ALLOC_ACCESSIBLE)
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
