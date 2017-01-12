Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3C39B6B026C
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 11:17:24 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id d140so5940737wmd.4
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 08:17:24 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 10si7711498wry.3.2017.01.12.08.17.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 08:17:23 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id v0CGEKFT061194
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 11:17:21 -0500
Received: from e06smtp06.uk.ibm.com (e06smtp06.uk.ibm.com [195.75.94.102])
	by mx0a-001b2d01.pphosted.com with ESMTP id 27xag5fepy-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 11:17:21 -0500
Received: from localhost
	by e06smtp06.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <imbrenda@linux.vnet.ibm.com>;
	Thu, 12 Jan 2017 16:17:19 -0000
From: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
Subject: [PATCH v1 1/1] mm/ksm: improve deduplication of zero pages with colouring
Date: Thu, 12 Jan 2017 17:17:14 +0100
Message-Id: <1484237834-15803-1-git-send-email-imbrenda@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: borntraeger@de.ibm.com, hughd@google.com, izik.eidus@ravellosystems.com, aarcange@redhat.com, chrisw@sous-sol.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Some architectures have a set of zero pages (coloured zero pages)
instead of only one zero page, in order to improve the cache
performance. In those cases, the kernel samepage merger (KSM) would
merge all the allocated pages that happen to be filled with zeroes to
the same deduplicated page, thus losing all the advantages of coloured
zero pages.

This patch fixes this behaviour. When coloured zero pages are present,
the checksum of a zero page is calculated during initialisation, and
compared with the checksum of the current canditate during merging. In
case of a match, the normal merging routine is used to merge the page
with the correct coloured zero page, which ensures the candidate page
is checked to be equal to the target zero page.

This behaviour is noticeable when a process accesses large arrays of
allocated pages containing zeroes. A test I conducted on s390 shows
that there is a speed penalty when KSM merges such pages, compared to
not merging them or using actual zero pages from the start without
breaking the COW.

With this patch, the performance with KSM is the same as with non
COW-broken actual zero pages, which is also the same as without KSM.

Signed-off-by: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
---
 mm/ksm.c | 29 +++++++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

diff --git a/mm/ksm.c b/mm/ksm.c
index 9ae6011..b0cfc30 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -223,6 +223,11 @@ struct rmap_item {
 /* Milliseconds ksmd should sleep between batches */
 static unsigned int ksm_thread_sleep_millisecs = 20;
 
+#ifdef __HAVE_COLOR_ZERO_PAGE
+/* Checksum of an empty (zeroed) page */
+static unsigned int zero_checksum;
+#endif
+
 #ifdef CONFIG_NUMA
 /* Zeroed when merging across nodes is not allowed */
 static unsigned int ksm_merge_across_nodes = 1;
@@ -1467,6 +1472,25 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
 		return;
 	}
 
+#ifdef __HAVE_COLOR_ZERO_PAGE
+	/*
+	 * Same checksum as an empty page. We attempt to merge it with the
+	 * appropriate zero page.
+	 */
+	if (checksum == zero_checksum) {
+		struct vm_area_struct *vma;
+
+		vma = find_mergeable_vma(rmap_item->mm, rmap_item->address);
+		err = try_to_merge_one_page(vma, page,
+					    ZERO_PAGE(rmap_item->address));
+		/*
+		 * In case of failure, the page was not really empty, so we
+		 * need to continue. Otherwise we're done.
+		 */
+		if (!err)
+			return;
+	}
+#endif
 	tree_rmap_item =
 		unstable_tree_search_insert(rmap_item, page, &tree_page);
 	if (tree_rmap_item) {
@@ -2304,6 +2328,11 @@ static int __init ksm_init(void)
 	struct task_struct *ksm_thread;
 	int err;
 
+#ifdef __HAVE_COLOR_ZERO_PAGE
+	/* The correct value depends on page size and endianness */
+	zero_checksum = calc_checksum(ZERO_PAGE(0));
+#endif
+
 	err = ksm_slab_init();
 	if (err)
 		goto out;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
