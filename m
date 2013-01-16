Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id ABDD86B005D
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 19:52:50 -0500 (EST)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Tue, 15 Jan 2013 17:52:50 -0700
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id A3FD63E4005E
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 17:25:32 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0G0PcVs326976
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 17:25:38 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0G0PanY020348
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 17:25:38 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 03/17] mm/page_alloc: add a VM_BUG in __free_one_page() if the zone is uninitialized.
Date: Tue, 15 Jan 2013 16:24:40 -0800
Message-Id: <1358295894-24167-4-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1358295894-24167-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1358295894-24167-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Cody P Schafer <jmesmon@gmail.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

From: Cody P Schafer <jmesmon@gmail.com>

Freeing pages to uninitialized zones is not handled by
__free_one_page(), and should never happen when the code is correct.

Ran into this while writing some code that dynamically onlines extra
zones.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/page_alloc.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index df2022f..da5a5ec 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -532,6 +532,8 @@ static inline void __free_one_page(struct page *page,
 	unsigned long uninitialized_var(buddy_idx);
 	struct page *buddy;
 
+	VM_BUG_ON(!zone_is_initialized(zone));
+
 	if (unlikely(PageCompound(page)))
 		if (unlikely(destroy_compound_page(page, order)))
 			return;
-- 
1.8.0.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
