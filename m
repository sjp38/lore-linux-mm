Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9ECA36B0271
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 16:18:14 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id i14so5139969qke.6
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 13:18:14 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id f68si2394282qkc.474.2017.09.20.13.18.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Sep 2017 13:18:13 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v9 06/12] mm: zero struct pages during initialization
Date: Wed, 20 Sep 2017 16:17:08 -0400
Message-Id: <20170920201714.19817-7-pasha.tatashin@oracle.com>
In-Reply-To: <20170920201714.19817-1-pasha.tatashin@oracle.com>
References: <20170920201714.19817-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

Add struct page zeroing as a part of initialization of other fields in
__init_single_page().

This single thread performance collected on: Intel(R) Xeon(R) CPU E7-8895
v3 @ 2.60GHz with 1T of memory (268400646 pages in 8 nodes):

                        BASE            FIX
sparse_init     11.244671836s   0.007199623s
zone_sizes_init  4.879775891s   8.355182299s
                  --------------------------
Total           16.124447727s   8.362381922s

sparse_init is where memory for struct pages is zeroed, and the zeroing
part is moved later in this patch into __init_single_page(), which is
called from zone_sizes_init().

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Reviewed-by: Bob Picco <bob.picco@oracle.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/mm.h | 9 +++++++++
 mm/page_alloc.c    | 1 +
 2 files changed, 10 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index f8c10d336e42..50b74d628243 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -94,6 +94,15 @@ extern int mmap_rnd_compat_bits __read_mostly;
 #define mm_forbids_zeropage(X)	(0)
 #endif
 
+/*
+ * On some architectures it is expensive to call memset() for small sizes.
+ * Those architectures should provide their own implementation of "struct page"
+ * zeroing by defining this macro in <asm/pgtable.h>.
+ */
+#ifndef mm_zero_struct_page
+#define mm_zero_struct_page(pp)  ((void)memset((pp), 0, sizeof(struct page)))
+#endif
+
 /*
  * Default maximum number of active map areas, this limits the number of vmas
  * per mm struct. Users can overwrite this number by sysctl but there is a
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a8dbd405ed94..4b630ee91430 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1170,6 +1170,7 @@ static void free_one_page(struct zone *zone,
 static void __meminit __init_single_page(struct page *page, unsigned long pfn,
 				unsigned long zone, int nid)
 {
+	mm_zero_struct_page(page);
 	set_page_links(page, zone, nid, pfn);
 	init_page_count(page);
 	page_mapcount_reset(page);
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
