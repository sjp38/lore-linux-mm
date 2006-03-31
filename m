Message-Id: <200603310013.k2V0Dng26534@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: [patch] don't allow free hugetlb count fall below reserved count
Date: Thu, 30 Mar 2006 16:14:34 -0800
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: 'David Gibson' <david@gibson.dropbear.id.au>, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

With strict page reservation, I think kernel should enforce number of
free hugetlb page don't fall below reserved count. Currently it is
possible in the sysctl path.  Add proper check in sysctl to disallow
that.


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>

--- ./mm/hugetlb.c.orig	2006-03-30 15:32:20.000000000 -0800
+++ ./mm/hugetlb.c	2006-03-30 15:48:22.000000000 -0800
@@ -334,6 +334,7 @@
 		return nr_huge_pages;
 
 	spin_lock(&hugetlb_lock);
+	count = max(count, reserved_huge_pages);
 	try_to_free_low(count);
 	while (count < nr_huge_pages) {
 		struct page *page = dequeue_huge_page(NULL, 0);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
