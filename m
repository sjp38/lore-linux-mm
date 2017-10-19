Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 81CB86B0253
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 11:10:07 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id 10so8365810qty.10
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 08:10:07 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id r48si3130781qtb.100.2017.10.19.08.10.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Oct 2017 08:10:06 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9JF9oHT041024
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 11:10:05 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2dpwvc2hrd-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 11:09:54 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 19 Oct 2017 15:57:05 +0100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v9JEv1JC22282364
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 14:57:02 GMT
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v9JEv1P6032149
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 01:57:01 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH] mm/swap: Use page flags to determine LRU list in __activate_page()
Date: Thu, 19 Oct 2017 20:26:57 +0530
Message-Id: <20171019145657.11199-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, shli@kernel.org

Its already assumed that the PageActive flag is clear on the input
page, hence page_lru(page) will pick the base LRU for the page. In
the same way page_lru(page) will pick active base LRU, once the
flag PageActive is set on the page. This change of LRU list should
happen implicitly through the page flags instead of being hard
coded.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 mm/swap.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index fcd82bc..494276b 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -275,12 +275,10 @@ static void __activate_page(struct page *page, struct lruvec *lruvec,
 {
 	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
 		int file = page_is_file_cache(page);
-		int lru = page_lru_base_type(page);
 
-		del_page_from_lru_list(page, lruvec, lru);
+		del_page_from_lru_list(page, lruvec, page_lru(page));
 		SetPageActive(page);
-		lru += LRU_ACTIVE;
-		add_page_to_lru_list(page, lruvec, lru);
+		add_page_to_lru_list(page, lruvec, page_lru(page));
 		trace_mm_lru_activate(page);
 
 		__count_vm_event(PGACTIVATE);
-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
