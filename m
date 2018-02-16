Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4E3616B0003
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 08:47:07 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id a61so2210020pla.22
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 05:47:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b185si1557248pgc.608.2018.02.16.05.47.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Feb 2018 05:47:06 -0800 (PST)
From: Juergen Gross <jgross@suse.com>
Subject: [PATCH] mm: don't defer struct page initialization for Xen pv guests
Date: Fri, 16 Feb 2018 14:37:26 +0100
Message-Id: <20180216133726.30813-1-jgross@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, xen-devel@lists.xenproject.org
Cc: akpm@linux-foundation.org, mhocko@suse.com, Juergen Gross <jgross@suse.com>, stable@vger.kernel.org

Commit f7f99100d8d95dbcf09e0216a143211e79418b9f ("mm: stop zeroing
memory during allocation in vmemmap") broke Xen pv domains in some
configurations, as the "Pinned" information in struct page of early
page tables could get lost.

Avoid this problem by not deferring struct page initialization when
running as Xen pv guest.

Cc: <stable@vger.kernel.org> #4.15
Signed-off-by: Juergen Gross <jgross@suse.com>
---
 mm/page_alloc.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 81e18ceef579..681d504b9a40 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -347,6 +347,9 @@ static inline bool update_defer_init(pg_data_t *pgdat,
 	/* Always populate low zones for address-constrained allocations */
 	if (zone_end < pgdat_end_pfn(pgdat))
 		return true;
+	/* Xen PV domains need page structures early */
+	if (xen_pv_domain())
+		return true;
 	(*nr_initialised)++;
 	if ((*nr_initialised > pgdat->static_init_pgcnt) &&
 	    (pfn & (PAGES_PER_SECTION - 1)) == 0) {
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
