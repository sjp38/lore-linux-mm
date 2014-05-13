Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1BF676B0083
	for <linux-mm@kvack.org>; Tue, 13 May 2014 01:25:49 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id kq14so9748256pab.38
        for <linux-mm@kvack.org>; Mon, 12 May 2014 22:25:48 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id ap2si7412369pbc.89.2014.05.12.22.25.47
        for <linux-mm@kvack.org>;
        Mon, 12 May 2014 22:25:48 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 1/2] mm: export unmap_kernel_range
Date: Tue, 13 May 2014 14:28:06 +0900
Message-Id: <1399958887-8432-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-mm@kvack.org, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>

Now zsmalloc needs exported unmap_kernel_range for building it
as module. In detail, here it is. https://lkml.org/lkml/2013/1/18/487

I didn't send a patch to make unmap_kernel_range exportable at that time
because zram was staging stuff and I thought VM function exporting
for staging stuff makes no sense.

Now zsmalloc was promoted. If we can't build zsmalloc as module,
it means we can't build zram as module, either.
Additionally, buddy map_vm_area is already exported so let's export
unmap_kernel_range to help his buddy.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/vmalloc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 2ed75fb89fc1..f64632b67196 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1268,6 +1268,7 @@ void unmap_kernel_range(unsigned long addr, unsigned long size)
 	vunmap_page_range(addr, end);
 	flush_tlb_kernel_range(addr, end);
 }
+EXPORT_SYMBOL_GPL(unmap_kernel_range);
 
 int map_vm_area(struct vm_struct *area, pgprot_t prot, struct page ***pages)
 {
-- 
1.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
