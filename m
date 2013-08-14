Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id E16F66B0038
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 01:55:33 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v6 4/5] mm: export unmap_kernel_range
Date: Wed, 14 Aug 2013 14:55:35 +0900
Message-Id: <1376459736-7384-5-git-send-email-minchan@kernel.org>
In-Reply-To: <1376459736-7384-1-git-send-email-minchan@kernel.org>
References: <1376459736-7384-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Luigi Semenzato <semenzato@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>

Now zsmalloc needs exported unmap_kernel_range for building it
as module. In detail, here it is.
https://lkml.org/lkml/2013/1/18/487

We didn't send patch to make unmap_kernel_range exportable at that time.
Because zram is staging stuff and we didn't think make VM function
exportable for staging stuff makes sense so we decided giving up build=m
for zsmalloc but zsmalloc moved under zram directory so if we can't build
zsmalloc as module, it means we can't build zram as module, either.
In addition, another reason we should export it is that buddy map_vm_area
is already exported.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/vmalloc.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 93d3182..0e9a9f8 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1254,6 +1254,7 @@ void unmap_kernel_range(unsigned long addr, unsigned long size)
 	vunmap_page_range(addr, end);
 	flush_tlb_kernel_range(addr, end);
 }
+EXPORT_SYMBOL_GPL(unmap_kernel_range);
 
 int map_vm_area(struct vm_struct *area, pgprot_t prot, struct page ***pages)
 {
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
