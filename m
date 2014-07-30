Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 50C2C6B0036
	for <linux-mm@kvack.org>; Tue, 29 Jul 2014 21:09:12 -0400 (EDT)
Received: by mail-ig0-f179.google.com with SMTP id h18so1991981igc.0
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 18:09:12 -0700 (PDT)
Received: from mail-ie0-x234.google.com (mail-ie0-x234.google.com [2607:f8b0:4001:c03::234])
        by mx.google.com with ESMTPS id q10si1961357icg.31.2014.07.29.18.09.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 29 Jul 2014 18:09:11 -0700 (PDT)
Received: by mail-ie0-f180.google.com with SMTP id at20so547780iec.39
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 18:09:11 -0700 (PDT)
Date: Tue, 29 Jul 2014 18:09:01 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm: fix potential infinite loop in dissolve_free_huge_pages()
 fix
In-Reply-To: <1406514043.2941.6.camel@TP-T420>
Message-ID: <alpine.DEB.2.02.1407291806530.6967@chino.kir.corp.google.com>
References: <1406194585.2586.15.camel@TP-T420> <20140724124511.GA14379@nhori> <1406514043.2941.6.camel@TP-T420>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zhong <zhong@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Nadia Yvette Chambers <nadia.yvette.chambers@gmail.com>

No legitimate reason to call dissolve_free_huge_pages() when 
!hugepages_supported().

Signed-off-by: David Rientjes <rientjes@google.com>
---
 To be folded into 
 mm-fix-potential-infinite-loop-in-dissolve_free_huge_pages.patch.

 mm/hugetlb.c        | 3 +++
 mm/memory_hotplug.c | 3 +--
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1088,6 +1088,9 @@ void dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
 	unsigned long pfn;
 	struct hstate *h;
 
+	if (!hugepages_supported())
+		return;
+
 	/* Set scan step to minimum hugepage size */
 	for_each_hstate(h)
 		if (order > huge_page_order(h))
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1726,8 +1726,7 @@ repeat:
 	 * dissolve free hugepages in the memory block before doing offlining
 	 * actually in order to make hugetlbfs's object counting consistent.
 	 */
-	if (hugepages_supported())
-		dissolve_free_huge_pages(start_pfn, end_pfn);
+	dissolve_free_huge_pages(start_pfn, end_pfn);
 	/* check again */
 	offlined_pages = check_pages_isolated(start_pfn, end_pfn);
 	if (offlined_pages < 0) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
