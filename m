Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 8C9E16B0038
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 05:16:25 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id r10so9295262pdi.10
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 02:16:25 -0800 (PST)
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com. [202.81.31.143])
        by mx.google.com with ESMTPS id kn3si13097879pbc.214.2013.12.11.02.16.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 11 Dec 2013 02:16:24 -0800 (PST)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 11 Dec 2013 20:16:21 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 9829F2CE8040
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 21:16:18 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBBAG5Ir64028700
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 21:16:05 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBBAGHBY015709
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 21:16:17 +1100
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v6 4/6] sched/numa: fix set cpupid on page migration twice against normal page
Date: Wed, 11 Dec 2013 18:15:59 +0800
Message-Id: <1386756961-3887-5-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1386756961-3887-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1386756961-3887-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

commit 7851a45cd3 (mm: numa: Copy cpupid on page migration) copy over
the cpupid at page migration time, there is unnecessary to set it again
in function alloc_misplaced_dst_page, this patch fix it.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Acked-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/migrate.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index fdb70f7..d4228c6 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1557,8 +1557,6 @@ static struct page *alloc_misplaced_dst_page(struct page *page,
 					  __GFP_NOMEMALLOC | __GFP_NORETRY |
 					  __GFP_NOWARN) &
 					 ~GFP_IOFS, 0);
-	if (newpage)
-		page_cpupid_xchg_last(newpage, page_cpupid_last(page));
 
 	return newpage;
 }
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
