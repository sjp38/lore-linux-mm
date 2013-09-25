Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 1484D6B007D
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 19:23:40 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id lf10so473923pab.17
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 16:23:39 -0700 (PDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 26 Sep 2013 04:53:26 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 16326394004D
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:53:09 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8PNNLnW41680946
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:53:21 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8PNNMoD023173
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:53:23 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v4 24/40] mm: Drop some very expensive sorted-buddy
 related checks under DEBUG_PAGEALLOC
Date: Thu, 26 Sep 2013 04:49:17 +0530
Message-ID: <20130925231915.26184.87083.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, dave@sr71.net, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Under CONFIG_DEBUG_PAGEALLOC, we have numerous checks and balances to verify
the correctness of various sorted-buddy operations. But some of them are very
expensive and hence can't be enabled while benchmarking the code.
(They should be used only to verify that the code is working correctly, as a
precursor to benchmarking the performance).

The check to see if a page given as input to del_from_freelist() indeed
belongs to that freelist, is one such very expensive check. Drop it.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 mm/page_alloc.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d5acea7..178f210 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -812,6 +812,7 @@ static void del_from_freelist(struct page *page, struct free_list *free_list,
 #ifdef CONFIG_DEBUG_PAGEALLOC
 	WARN(region->nr_free < 0, "%s: nr_free is negative\n", __func__);
 
+#if 0
 	/* Verify whether this page indeed belongs to this free list! */
 
 	list_for_each(p, &free_list->list) {
@@ -820,6 +821,7 @@ static void del_from_freelist(struct page *page, struct free_list *free_list,
 	}
 
 	WARN(1, "%s: page doesn't belong to the given freelist!\n", __func__);
+#endif
 
 page_found:
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
