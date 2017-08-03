Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id C6A8C6B06BC
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 17:25:03 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id o9so23540301iod.13
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 14:25:03 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id n5si735068ite.46.2017.08.03.14.25.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Aug 2017 14:25:01 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [v5 08/15] mm: zero struct pages during initialization
Date: Thu,  3 Aug 2017 17:23:46 -0400
Message-Id: <1501795433-982645-9-git-send-email-pasha.tatashin@oracle.com>
In-Reply-To: <1501795433-982645-1-git-send-email-pasha.tatashin@oracle.com>
References: <1501795433-982645-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org

Add struct page zeroing as a part of initialization of other fields in
__init_single_page().

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Reviewed-by: Bob Picco <bob.picco@oracle.com>
---
 include/linux/mm.h | 9 +++++++++
 mm/page_alloc.c    | 1 +
 2 files changed, 10 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 46b9ac5e8569..183ac5e733db 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -94,6 +94,15 @@ extern int mmap_rnd_compat_bits __read_mostly;
 #endif
 
 /*
+ * On some architectures it is expensive to call memset() for small sizes.
+ * Those architectures should provide their own implementation of "struct page"
+ * zeroing by defining this macro in <asm/pgtable.h>.
+ */
+#ifndef mm_zero_struct_page
+#define mm_zero_struct_page(pp)  ((void)memset((pp), 0, sizeof(struct page)))
+#endif
+
+/*
  * Default maximum number of active map areas, this limits the number of vmas
  * per mm struct. Users can overwrite this number by sysctl but there is a
  * problem.
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 05110ae50aca..cbcdd53ad9f8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1168,6 +1168,7 @@ static void free_one_page(struct zone *zone,
 static void __meminit __init_single_page(struct page *page, unsigned long pfn,
 				unsigned long zone, int nid)
 {
+	mm_zero_struct_page(page);
 	set_page_links(page, zone, nid, pfn);
 	init_page_count(page);
 	page_mapcount_reset(page);
-- 
2.13.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
