Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6468C800D8
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 04:05:35 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id 31so4118841wri.9
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 01:05:35 -0800 (PST)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id t16si3479077wrb.163.2018.01.25.01.05.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jan 2018 01:05:33 -0800 (PST)
Date: Thu, 25 Jan 2018 10:05:16 +0100
From: Petr Tesarik <ptesarik@suse.com>
Subject: [PATCH v2] Fix explanation of lower bits in the SPARSEMEM mem_map
 pointer
Message-ID: <20180125100516.589ea6af@ezekiel.suse.cz>
In-Reply-To: <20180124145711.4f3f219d@ezekiel.suse.cz>
References: <20180119080908.3a662e6f@ezekiel.suse.cz>
	<20180119123956.GZ6584@dhcp22.suse.cz>
	<20180119142133.379d5145@ezekiel.suse.cz>
	<20180124124353.GE28465@dhcp22.suse.cz>
	<20180124145711.4f3f219d@ezekiel.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>

The comment is confusing. On the one hand, it refers to 32-bit
alignment (struct page alignment on 32-bit platforms), but this
would only guarantee that the 2 lowest bits must be zero. On the
other hand, it claims that at least 3 bits are available, and 3 bits
are actually used.

This is not broken, because there is a stronger alignment guarantee,
just less obvious. Let's fix the comment to make it clear how many
bits are available and why.

Although memmap arrays are allocated in various places, the
resulting pointer is encoded eventually, so I am adding a BUG_ON()
here to enforce at runtime that all expected bits are indeed
available.

I have also added a BUILD_BUG_ON to check that PFN_SECTION_SHIFT is
sufficient, because this part of the calculation can be easily
checked at build time.

Signed-off-by: Petr Tesarik <ptesarik@suse.com>
---
 include/linux/mmzone.h | 12 ++++++++++--
 mm/sparse.c            |  6 +++++-
 2 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 67f2e3c38939..7522a6987595 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1166,8 +1166,16 @@ extern unsigned long usemap_size(void);
 
 /*
  * We use the lower bits of the mem_map pointer to store
- * a little bit of information.  There should be at least
- * 3 bits here due to 32-bit alignment.
+ * a little bit of information.  The pointer is calculated
+ * as mem_map - section_nr_to_pfn(pnum).  The result is
+ * aligned to the minimum alignment of the two values:
+ *   1. All mem_map arrays are page-aligned.
+ *   2. section_nr_to_pfn() always clears PFN_SECTION_SHIFT
+ *      lowest bits.  PFN_SECTION_SHIFT is arch-specific
+ *      (equal SECTION_SIZE_BITS - PAGE_SHIFT), and the
+ *      worst combination is powerpc with 256k pages,
+ *      which results in PFN_SECTION_SHIFT equal 6.
+ * To sum it up, at least 6 bits are available.
  */
 #define	SECTION_MARKED_PRESENT	(1UL<<0)
 #define SECTION_HAS_MEM_MAP	(1UL<<1)
diff --git a/mm/sparse.c b/mm/sparse.c
index 2609aba121e8..6b8b5e91ceef 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -264,7 +264,11 @@ unsigned long __init node_memmap_size_bytes(int nid, unsigned long start_pfn,
  */
 static unsigned long sparse_encode_mem_map(struct page *mem_map, unsigned long pnum)
 {
-	return (unsigned long)(mem_map - (section_nr_to_pfn(pnum)));
+	unsigned long coded_mem_map =
+		(unsigned long)(mem_map - (section_nr_to_pfn(pnum)));
+	BUILD_BUG_ON(SECTION_MAP_LAST_BIT > (1UL<<PFN_SECTION_SHIFT));
+	BUG_ON(coded_mem_map & ~SECTION_MAP_MASK);
+	return coded_mem_map;
 }
 
 /*
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
