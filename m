Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 30C8A6B0038
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 02:09:29 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id h1so633177wre.20
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 23:09:29 -0800 (PST)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id e13si8119295wra.463.2018.01.18.23.09.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jan 2018 23:09:27 -0800 (PST)
Date: Fri, 19 Jan 2018 08:09:08 +0100
From: Petr Tesarik <ptesarik@suse.com>
Subject: [PATCH] Fix explanation of lower bits in the SPARSEMEM mem_map
 pointer
Message-ID: <20180119080908.3a662e6f@ezekiel.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>

The comment is confusing. On the one hand, it refers to 32-bit
alignment (struct page alignment on 32-bit platforms), but this
would only guarantee that the 2 lowest bits must be zero. On the
other hand, it claims that at least 3 bits are available, and 3 bits
are actually used.

This is not broken, because there is a stronger alignment guarantee,
just less obvious. Let's fix the comment to make it clear how many
bits are available and why.

Signed-off-by: Petr Tesarik <ptesarik@suse.com>
---
 include/linux/mmzone.h | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

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
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
