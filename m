Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7BE4D6B0005
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 17:21:23 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id u4so7426478iti.2
        for <linux-mm@kvack.org>; Mon, 12 Feb 2018 14:21:23 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id u35si590994ioi.278.2018.02.12.14.21.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Feb 2018 14:21:22 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 1/3] mm: make start_isolate_page_range() fail if already isolated
Date: Mon, 12 Feb 2018 14:20:54 -0800
Message-Id: <20180212222056.9735-2-mike.kravetz@oracle.com>
In-Reply-To: <20180212222056.9735-1-mike.kravetz@oracle.com>
References: <20180212222056.9735-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>, Mike Kravetz <mike.kravetz@oracle.com>

start_isolate_page_range() is used to set the migrate type of a
page block to MIGRATE_ISOLATE while attempting to start a
migration operation.  It is assumed that only one thread is
attempting such an operation, and due to the limited number of
callers this is generally the case.  However, there are no
guarantees and it is 'possible' for two threads to operate on
the same range.

Since start_isolate_page_range() is called at the beginning of
such operations, have it return -EBUSY if MIGRATE_ISOLATE is
already set.

This will allow start_isolate_page_range to serve as a
synchronization mechanism and will allow for more general use
of callers making use of these interfaces.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/page_alloc.c     |  8 ++++----
 mm/page_isolation.c | 10 +++++++++-
 2 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 76c9688b6a0a..064458f317bf 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7605,11 +7605,11 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
  * @gfp_mask:	GFP mask to use during compaction
  *
  * The PFN range does not have to be pageblock or MAX_ORDER_NR_PAGES
- * aligned, however it's the caller's responsibility to guarantee that
- * we are the only thread that changes migrate type of pageblocks the
- * pages fall in.
+ * aligned.  The PFN range must belong to a single zone.
  *
- * The PFN range must belong to a single zone.
+ * The first thing this routine does is attempt to MIGRATE_ISOLATE all
+ * pageblocks in the range.  Once isolated, the pageblocks should not
+ * be modified by others.
  *
  * Returns zero on success or negative error code.  On success all
  * pages which PFN is in [start, end) are allocated for the caller and
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 165ed8117bd1..e815879d525f 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -28,6 +28,13 @@ static int set_migratetype_isolate(struct page *page, int migratetype,
 
 	spin_lock_irqsave(&zone->lock, flags);
 
+	/*
+	 * We assume we are the only ones trying to isolate this block.
+	 * If MIGRATE_ISOLATE already set, return -EBUSY
+	 */
+	if (is_migrate_isolate_page(page))
+		goto out;
+
 	pfn = page_to_pfn(page);
 	arg.start_pfn = pfn;
 	arg.nr_pages = pageblock_nr_pages;
@@ -166,7 +173,8 @@ __first_valid_page(unsigned long pfn, unsigned long nr_pages)
  * future will not be allocated again.
  *
  * start_pfn/end_pfn must be aligned to pageblock_order.
- * Returns 0 on success and -EBUSY if any part of range cannot be isolated.
+ * Returns 0 on success and -EBUSY if any part of range cannot be isolated
+ * or any part of the range is already set to MIGRATE_ISOLATE.
  */
 int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 			     unsigned migratetype, bool skip_hwpoisoned_pages)
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
