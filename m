Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3C48E6B0033
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 04:33:25 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id m189so8087321qke.21
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 01:33:25 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id e8si6695953qtk.427.2017.10.19.01.33.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Oct 2017 01:33:24 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9J8T2lX013598
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 04:33:23 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2dppye4vpx-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 04:33:23 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 19 Oct 2017 09:33:20 +0100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v9J8XGnZ21758000
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 08:33:18 GMT
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v9J8XAFe001848
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 19:33:10 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [RFC] mm/swap: Rename pagevec_lru_move_fn() as pagevec_lruvec_move_fn()
Date: Thu, 19 Oct 2017 14:03:14 +0530
Message-Id: <20171019083314.12614-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org

The function pagevec_lru_move_fn() actually moves pages from various
per cpu pagevecs into per node lruvecs with a custom function which
knows how to handle individual pages present in any given pagevec.
Because it does movement between pagevecs and lruvecs as whole not
to an individual list element, the name should reflect it.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 mm/swap.c | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index a77d68f..fcd82bc 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -185,7 +185,7 @@ int get_kernel_page(unsigned long start, int write, struct page **pages)
 }
 EXPORT_SYMBOL_GPL(get_kernel_page);
 
-static void pagevec_lru_move_fn(struct pagevec *pvec,
+static void pagevec_lruvec_move_fn(struct pagevec *pvec,
 	void (*move_fn)(struct page *page, struct lruvec *lruvec, void *arg),
 	void *arg)
 {
@@ -235,7 +235,7 @@ static void pagevec_move_tail(struct pagevec *pvec)
 {
 	int pgmoved = 0;
 
-	pagevec_lru_move_fn(pvec, pagevec_move_tail_fn, &pgmoved);
+	pagevec_lruvec_move_fn(pvec, pagevec_move_tail_fn, &pgmoved);
 	__count_vm_events(PGROTATED, pgmoved);
 }
 
@@ -294,7 +294,7 @@ static void activate_page_drain(int cpu)
 	struct pagevec *pvec = &per_cpu(activate_page_pvecs, cpu);
 
 	if (pagevec_count(pvec))
-		pagevec_lru_move_fn(pvec, __activate_page, NULL);
+		pagevec_lruvec_move_fn(pvec, __activate_page, NULL);
 }
 
 static bool need_activate_page_drain(int cpu)
@@ -310,7 +310,7 @@ void activate_page(struct page *page)
 
 		get_page(page);
 		if (!pagevec_add(pvec, page) || PageCompound(page))
-			pagevec_lru_move_fn(pvec, __activate_page, NULL);
+			pagevec_lruvec_move_fn(pvec, __activate_page, NULL);
 		put_cpu_var(activate_page_pvecs);
 	}
 }
@@ -620,11 +620,11 @@ void lru_add_drain_cpu(int cpu)
 
 	pvec = &per_cpu(lru_deactivate_file_pvecs, cpu);
 	if (pagevec_count(pvec))
-		pagevec_lru_move_fn(pvec, lru_deactivate_file_fn, NULL);
+		pagevec_lruvec_move_fn(pvec, lru_deactivate_file_fn, NULL);
 
 	pvec = &per_cpu(lru_lazyfree_pvecs, cpu);
 	if (pagevec_count(pvec))
-		pagevec_lru_move_fn(pvec, lru_lazyfree_fn, NULL);
+		pagevec_lruvec_move_fn(pvec, lru_lazyfree_fn, NULL);
 
 	activate_page_drain(cpu);
 }
@@ -650,7 +650,8 @@ void deactivate_file_page(struct page *page)
 		struct pagevec *pvec = &get_cpu_var(lru_deactivate_file_pvecs);
 
 		if (!pagevec_add(pvec, page) || PageCompound(page))
-			pagevec_lru_move_fn(pvec, lru_deactivate_file_fn, NULL);
+			pagevec_lruvec_move_fn(pvec,
+					lru_deactivate_file_fn, NULL);
 		put_cpu_var(lru_deactivate_file_pvecs);
 	}
 }
@@ -670,7 +671,7 @@ void mark_page_lazyfree(struct page *page)
 
 		get_page(page);
 		if (!pagevec_add(pvec, page) || PageCompound(page))
-			pagevec_lru_move_fn(pvec, lru_lazyfree_fn, NULL);
+			pagevec_lruvec_move_fn(pvec, lru_lazyfree_fn, NULL);
 		put_cpu_var(lru_lazyfree_pvecs);
 	}
 }
@@ -901,7 +902,7 @@ static void __pagevec_lru_add_fn(struct page *page, struct lruvec *lruvec,
  */
 void __pagevec_lru_add(struct pagevec *pvec)
 {
-	pagevec_lru_move_fn(pvec, __pagevec_lru_add_fn, NULL);
+	pagevec_lruvec_move_fn(pvec, __pagevec_lru_add_fn, NULL);
 }
 EXPORT_SYMBOL(__pagevec_lru_add);
 
-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
