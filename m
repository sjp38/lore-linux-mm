Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id jAHMffUV007876
	for <linux-mm@kvack.org>; Thu, 17 Nov 2005 17:41:41 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jAHMfQH1053164
	for <linux-mm@kvack.org>; Thu, 17 Nov 2005 15:41:26 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id jAHMffrZ019517
	for <linux-mm@kvack.org>; Thu, 17 Nov 2005 15:41:41 -0700
Date: Thu, 17 Nov 2005 14:41:38 -0800
From: Mike Kravetz <kravetz@us.ibm.com>
Subject: [PATCH] Remove arch independent NODES_SPAN_OTHER_NODES
Message-ID: <20051117224138.GA5393@w-mikek2.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The NODES_SPAN_OTHER_NODES config option was created so that DISCONTIGMEM
could handle pSeries numa layouts.  However, support for DISCONTIGMEM has
been replaced by SPARSEMEM on powerpc.  As a result, this config option and
supporting code is no longer needed.

I have already sent a patch to Paul that removes the option from powerpc
specific code.  This removes the arch independent piece.  Doesn't really
matter which is applied first.

Signed-off-by: Mike Kravetz <kravetz@us.ibm.com>

diff -Naupr linux-2.6.15-rc1-mm1/include/linux/mmzone.h linux-2.6.15-rc1-mm1.work/include/linux/mmzone.h
--- linux-2.6.15-rc1-mm1/include/linux/mmzone.h	2005-11-17 18:22:08.000000000 +0000
+++ linux-2.6.15-rc1-mm1.work/include/linux/mmzone.h	2005-11-17 19:02:40.000000000 +0000
@@ -610,12 +610,6 @@ void sparse_init(void);
 #define sparse_index_init(_sec, _nid)  do {} while (0)
 #endif /* CONFIG_SPARSEMEM */
 
-#ifdef CONFIG_NODES_SPAN_OTHER_NODES
-#define early_pfn_in_nid(pfn, nid)	(early_pfn_to_nid(pfn) == (nid))
-#else
-#define early_pfn_in_nid(pfn, nid)	(1)
-#endif
-
 #ifndef early_pfn_valid
 #define early_pfn_valid(pfn)	(1)
 #endif
diff -Naupr linux-2.6.15-rc1-mm1/mm/page_alloc.c linux-2.6.15-rc1-mm1.work/mm/page_alloc.c
--- linux-2.6.15-rc1-mm1/mm/page_alloc.c	2005-11-17 18:22:08.000000000 +0000
+++ linux-2.6.15-rc1-mm1.work/mm/page_alloc.c	2005-11-17 19:03:24.000000000 +0000
@@ -1752,8 +1752,6 @@ void __devinit memmap_init_zone(unsigned
 	for (pfn = start_pfn; pfn < end_pfn; pfn++, page++) {
 		if (!early_pfn_valid(pfn))
 			continue;
-		if (!early_pfn_in_nid(pfn, nid))
-			continue;
 		page = pfn_to_page(pfn);
 		set_page_links(page, zone, nid, pfn);
 		set_page_count(page, 1);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
