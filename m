Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0DCB96B7437
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 12:02:09 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id b8-v6so9217914oib.4
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 09:02:09 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c18-v6si1436824oiy.298.2018.09.05.09.02.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 09:02:08 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w85FuBFp033765
	for <linux-mm@kvack.org>; Wed, 5 Sep 2018 12:02:07 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mafkfgmsf-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 05 Sep 2018 12:01:37 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 5 Sep 2018 17:01:05 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [RFC PATCH 26/29] memblock: rename __free_pages_bootmem to memblock_free_pages
Date: Wed,  5 Sep 2018 18:59:41 +0300
In-Reply-To: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1536163184-26356-27-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Paul Burton <paul.burton@mips.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

The conversion is done using

sed -i 's@__free_pages_bootmem@memblock_free_pages@' \
    $(git grep -l __free_pages_bootmem)

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 mm/internal.h   | 2 +-
 mm/memblock.c   | 2 +-
 mm/nobootmem.c  | 2 +-
 mm/page_alloc.c | 2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 87256ae..291eb2b 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -161,7 +161,7 @@ static inline struct page *pageblock_pfn_to_page(unsigned long start_pfn,
 }
 
 extern int __isolate_free_page(struct page *page, unsigned int order);
-extern void __free_pages_bootmem(struct page *page, unsigned long pfn,
+extern void memblock_free_pages(struct page *page, unsigned long pfn,
 					unsigned int order);
 extern void prep_compound_page(struct page *page, unsigned int order);
 extern void post_alloc_hook(struct page *page, unsigned int order,
diff --git a/mm/memblock.c b/mm/memblock.c
index 63df68b..55d7d50 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1639,7 +1639,7 @@ void __init __memblock_free_late(phys_addr_t base, phys_addr_t size)
 	end = PFN_DOWN(base + size);
 
 	for (; cursor < end; cursor++) {
-		__free_pages_bootmem(pfn_to_page(cursor), cursor, 0);
+		memblock_free_pages(pfn_to_page(cursor), cursor, 0);
 		totalram_pages++;
 	}
 }
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index bb64b09..9608bc5 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -43,7 +43,7 @@ static void __init __free_pages_memory(unsigned long start, unsigned long end)
 		while (start + (1UL << order) > end)
 			order--;
 
-		__free_pages_bootmem(pfn_to_page(start), start, order);
+		memblock_free_pages(pfn_to_page(start), start, order);
 
 		start += (1UL << order);
 	}
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 33c9e27..e143fae 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1333,7 +1333,7 @@ meminit_pfn_in_nid(unsigned long pfn, int node,
 #endif
 
 
-void __init __free_pages_bootmem(struct page *page, unsigned long pfn,
+void __init memblock_free_pages(struct page *page, unsigned long pfn,
 							unsigned int order)
 {
 	if (early_page_uninitialised(pfn))
-- 
2.7.4
