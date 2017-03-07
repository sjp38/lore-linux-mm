Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 45CB46B038E
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 10:48:52 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id y51so1879063wry.6
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 07:48:52 -0800 (PST)
Received: from mail-wr0-f196.google.com (mail-wr0-f196.google.com. [209.85.128.196])
        by mx.google.com with ESMTPS id z20si19373678wmc.68.2017.03.07.07.48.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 07:48:51 -0800 (PST)
Received: by mail-wr0-f196.google.com with SMTP id u48so753162wrc.1
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 07:48:50 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/4] s390: get rid of superfluous __GFP_REPEAT
Date: Tue,  7 Mar 2017 16:48:40 +0100
Message-Id: <20170307154843.32516-2-mhocko@kernel.org>
In-Reply-To: <20170307154843.32516-1-mhocko@kernel.org>
References: <20170307154843.32516-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

From: Michal Hocko <mhocko@suse.com>

__GFP_REPEAT has a rather weak semantic but since it has been introduced
around 2.6.12 it has been ignored for low order allocations.

page_table_alloc then uses the flag for a single page allocation. This
means that this flag has never been actually useful here because it has
always been used only for PAGE_ALLOC_COSTLY requests.

An earlier attempt to remove the flag 10d58bf297e2 ("s390: get rid of
superfluous __GFP_REPEAT") has missed this one but the situation is very
same here.

Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 arch/s390/mm/pgalloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/s390/mm/pgalloc.c b/arch/s390/mm/pgalloc.c
index 995f78532cc2..2776bad61094 100644
--- a/arch/s390/mm/pgalloc.c
+++ b/arch/s390/mm/pgalloc.c
@@ -144,7 +144,7 @@ struct page *page_table_alloc_pgste(struct mm_struct *mm)
 	struct page *page;
 	unsigned long *table;
 
-	page = alloc_page(GFP_KERNEL|__GFP_REPEAT);
+	page = alloc_page(GFP_KERNEL);
 	if (page) {
 		table = (unsigned long *) page_to_phys(page);
 		clear_table(table, _PAGE_INVALID, PAGE_SIZE/2);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
