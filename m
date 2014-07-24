Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 92DFF6B0035
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 05:36:38 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id z12so2434698wgg.12
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 02:36:37 -0700 (PDT)
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com. [195.75.94.109])
        by mx.google.com with ESMTPS id fg5si10656968wic.21.2014.07.24.02.36.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 24 Jul 2014 02:36:34 -0700 (PDT)
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zhong@linux.vnet.ibm.com>;
	Thu, 24 Jul 2014 10:36:31 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id A8003219005E
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 10:36:14 +0100 (BST)
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s6O9aT8V16253152
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 09:36:29 GMT
Received: from d06av02.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s6O9aS6t009040
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 03:36:29 -0600
Message-ID: <1406194585.2586.15.camel@TP-T420>
Subject: [RFC PATCH]mm: fix potential infinite loop in
 dissolve_free_huge_pages()
From: Li Zhong <zhong@linux.vnet.ibm.com>
Date: Thu, 24 Jul 2014 17:36:25 +0800
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: n-horiguchi@ah.jp.nec.com, Andrew Morton <akpm@linux-foundation.org>

It is possible for some platforms, such as powerpc to set HPAGE_SHIFT to
0 to indicate huge pages not supported. 

When this is the case, hugetlbfs could be disabled during boot time:
hugetlbfs: disabling because there are no supported hugepage sizes

Then in dissolve_free_huge_pages(), order is kept maximum (64 for
64bits), and the for loop below won't end:
for (pfn = start_pfn; pfn < end_pfn; pfn += 1 << order)

The fix below returns directly if the order isn't set to a correct
value.

Signed-off-by: Li Zhong <zhong@linux.vnet.ibm.com>
---
 mm/hugetlb.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 2024bbd..a950817 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1093,6 +1093,10 @@ void dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
 	for_each_hstate(h)
 		if (order > huge_page_order(h))
 			order = huge_page_order(h);
+
+	if (order == 8 * sizeof(void *))
+		return;
+
 	VM_BUG_ON(!IS_ALIGNED(start_pfn, 1 << order));
 	for (pfn = start_pfn; pfn < end_pfn; pfn += 1 << order)
 		dissolve_free_huge_page(pfn_to_page(pfn));


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
