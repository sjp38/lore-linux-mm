Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8BFAD6B02EE
	for <linux-mm@kvack.org>; Fri,  5 May 2017 13:03:31 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a66so8575700pfl.6
        for <linux-mm@kvack.org>; Fri, 05 May 2017 10:03:31 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id f4si5596255plb.175.2017.05.05.10.03.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 May 2017 10:03:30 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [v3 5/9] mm: zero struct pages during initialization
Date: Fri,  5 May 2017 13:03:12 -0400
Message-Id: <1494003796-748672-6-git-send-email-pasha.tatashin@oracle.com>
In-Reply-To: <1494003796-748672-1-git-send-email-pasha.tatashin@oracle.com>
References: <1494003796-748672-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net

When deferred struct page initialization is enabled, do not expect that
the memory that was allocated for struct pages was zeroed by the
allocator. Zero it when "struct pages" are initialized.

Also, a defined boolean VMEMMAP_ZERO is provided to tell platforms whether
they should zero memory or can deffer it.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Reviewed-by: Shannon Nelson <shannon.nelson@oracle.com>
---
 include/linux/mm.h |    9 +++++++++
 mm/page_alloc.c    |    3 +++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 4375015..1c481fc 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2419,6 +2419,15 @@ int vmemmap_populate_basepages(unsigned long start, unsigned long end,
 #ifdef CONFIG_MEMORY_HOTPLUG
 void vmemmap_free(unsigned long start, unsigned long end);
 #endif
+/*
+ * Don't zero "struct page"es during early boot, and zero only when they are
+ * initialized in parallel.
+ */
+#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
+#define VMEMMAP_ZERO	false
+#else
+#define VMEMMAP_ZERO	true
+#endif
 void register_page_bootmem_memmap(unsigned long section_nr, struct page *map,
 				  unsigned long size);
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2c25de4..e736c6a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1159,6 +1159,9 @@ static void free_one_page(struct zone *zone,
 static void __meminit __init_single_page(struct page *page, unsigned long pfn,
 				unsigned long zone, int nid)
 {
+#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
+	memset(page, 0, sizeof(struct page));
+#endif
 	set_page_links(page, zone, nid, pfn);
 	init_page_count(page);
 	page_mapcount_reset(page);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
