Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id F04786B006E
	for <linux-mm@kvack.org>; Thu,  2 Apr 2015 21:07:18 -0400 (EDT)
Received: by igbqf9 with SMTP id qf9so86808481igb.1
        for <linux-mm@kvack.org>; Thu, 02 Apr 2015 18:07:18 -0700 (PDT)
Received: from mail-ie0-x229.google.com (mail-ie0-x229.google.com. [2607:f8b0:4001:c03::229])
        by mx.google.com with ESMTPS id v29si5853554iov.99.2015.04.02.18.07.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Apr 2015 18:07:18 -0700 (PDT)
Received: by ierf6 with SMTP id f6so81842105ier.2
        for <linux-mm@kvack.org>; Thu, 02 Apr 2015 18:07:18 -0700 (PDT)
Date: Thu, 2 Apr 2015 18:07:16 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm] mm, mempool: poison elements backed by page allocator
 fix fix
In-Reply-To: <alpine.DEB.2.10.1504021803170.20229@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1504021804060.20229@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1503241607240.21805@chino.kir.corp.google.com> <alpine.DEB.2.10.1503241609370.21805@chino.kir.corp.google.com> <CAPAsAGwipUr7NBWjQ_xjA0CfeiZ0NuYAg13M4jYmWVe4V8Jjmg@mail.gmail.com> <alpine.DEB.2.10.1503261542060.16259@chino.kir.corp.google.com>
 <551A861B.7020701@samsung.com> <alpine.DEB.2.10.1504021803170.20229@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Dave Kleikamp <shaggy@kernel.org>, Christoph Hellwig <hch@lst.de>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Mikulas Patocka <mpatocka@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, jfs-discussion@lists.sourceforge.net

Elements backed by the page allocator might not be directly mapped into 
lowmem, so do k{,un}map_atomic() before poisoning and verifying contents 
to map into lowmem and return the virtual adddress.

Reported-by: Andrey Ryabinin <a.ryabinin@samsung.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/mempool.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/mempool.c b/mm/mempool.c
--- a/mm/mempool.c
+++ b/mm/mempool.c
@@ -61,9 +61,10 @@ static void check_element(mempool_t *pool, void *element)
 	/* Mempools backed by page allocator */
 	if (pool->free == mempool_free_pages) {
 		int order = (int)(long)pool->pool_data;
-		void *addr = page_address(element);
+		void *addr = kmap_atomic((struct page *)element);
 
 		__check_element(pool, addr, 1UL << (PAGE_SHIFT + order));
+		kunmap_atomic(addr);
 	}
 }
 
@@ -84,9 +85,10 @@ static void poison_element(mempool_t *pool, void *element)
 	/* Mempools backed by page allocator */
 	if (pool->alloc == mempool_alloc_pages) {
 		int order = (int)(long)pool->pool_data;
-		void *addr = page_address(element);
+		void *addr = kmap_atomic((struct page *)element);
 
 		__poison_element(addr, 1UL << (PAGE_SHIFT + order));
+		kunmap_atomic(addr);
 	}
 }
 #else /* CONFIG_DEBUG_SLAB || CONFIG_SLUB_DEBUG_ON */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
