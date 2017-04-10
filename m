Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B40C06B03A5
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 04:48:12 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id r129so119718663pgr.18
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 01:48:12 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 67si309291pgj.210.2017.04.10.01.48.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Apr 2017 01:48:11 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3A8iKLd108719
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 04:48:03 -0400
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com [202.81.31.146])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29qym9hwhf-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 04:48:02 -0400
Received: from localhost
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 10 Apr 2017 18:48:00 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3A8lmEv38666294
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 18:47:56 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3A8lKYW011324
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 18:47:20 +1000
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH RESEND] mm/madvise: Clean up MADV_SOFT_OFFLINE and MADV_HWPOISON
Date: Mon, 10 Apr 2017 14:17:01 +0530
In-Reply-To: <20170410082903.8828-1-khandual@linux.vnet.ibm.com>
References: <20170410082903.8828-1-khandual@linux.vnet.ibm.com>
Message-Id: <20170410084701.11248-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org

This cleans up handling MADV_SOFT_OFFLINE and MADV_HWPOISON called
through madvise() system call.

* madvise_memory_failure() was misleading to accommodate handling of
  both memory_failure() as well as soft_offline_page() functions.
  Basically it handles memory error injection from user space which
  can go either way as memory failure or soft offline. Renamed as
  madvise_inject_error() instead.

* Renamed struct page pointer 'p' to 'page'.

* pr_info() was essentially printing PFN value but it said 'page'
  which was misleading. Made the process virtual address explicit.

Before the patch:

Soft offlining page 0x15e3e at 0x3fff8c230000
Soft offlining page 0x1f3 at 0x3fffa0da0000
Soft offlining page 0x744 at 0x3fff7d200000
Soft offlining page 0x1634d at 0x3fff95e20000
Soft offlining page 0x16349 at 0x3fff95e30000
Soft offlining page 0x1d6 at 0x3fff9e8b0000
Soft offlining page 0x5f3 at 0x3fff91bd0000

Injecting memory failure for page 0x15c8b at 0x3fff83280000
Injecting memory failure for page 0x16190 at 0x3fff83290000
Injecting memory failure for page 0x740 at 0x3fff9a2e0000
Injecting memory failure for page 0x741 at 0x3fff9a2f0000

After the patch:

Soft offlining pfn 0x1484e at process virtual address 0x3fff883c0000
Soft offlining pfn 0x1484f at process virtual address 0x3fff883d0000
Soft offlining pfn 0x14850 at process virtual address 0x3fff883e0000
Soft offlining pfn 0x14851 at process virtual address 0x3fff883f0000
Soft offlining pfn 0x14852 at process virtual address 0x3fff88400000
Soft offlining pfn 0x14853 at process virtual address 0x3fff88410000
Soft offlining pfn 0x14854 at process virtual address 0x3fff88420000
Soft offlining pfn 0x1521c at process virtual address 0x3fff6bc70000

Injecting memory failure for pfn 0x10fcf at process virtual address 0x3fff86310000
Injecting memory failure for pfn 0x10fd0 at process virtual address 0x3fff86320000
Injecting memory failure for pfn 0x10fd1 at process virtual address 0x3fff86330000
Injecting memory failure for pfn 0x10fd2 at process virtual address 0x3fff86340000
Injecting memory failure for pfn 0x10fd3 at process virtual address 0x3fff86350000
Injecting memory failure for pfn 0x10fd4 at process virtual address 0x3fff86360000
Injecting memory failure for pfn 0x10fd5 at process virtual address 0x3fff86370000

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
Removed timestamp from the kernel log to reduce the width of the
commit message. No changes in the code.

 mm/madvise.c | 34 ++++++++++++++++++++--------------
 1 file changed, 20 insertions(+), 14 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 7a2abf0..efd4721 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -606,34 +606,40 @@ static long madvise_remove(struct vm_area_struct *vma,
 /*
  * Error injection support for memory error handling.
  */
-static int madvise_hwpoison(int bhv, unsigned long start, unsigned long end)
+static int madvise_inject_error(int behavior,
+		unsigned long start, unsigned long end)
 {
-	struct page *p;
+	struct page *page;
+
 	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
+
 	for (; start < end; start += PAGE_SIZE <<
-				compound_order(compound_head(p))) {
+				compound_order(compound_head(page))) {
 		int ret;
 
-		ret = get_user_pages_fast(start, 1, 0, &p);
+		ret = get_user_pages_fast(start, 1, 0, &page);
 		if (ret != 1)
 			return ret;
 
-		if (PageHWPoison(p)) {
-			put_page(p);
+		if (PageHWPoison(page)) {
+			put_page(page);
 			continue;
 		}
-		if (bhv == MADV_SOFT_OFFLINE) {
-			pr_info("Soft offlining page %#lx at %#lx\n",
-				page_to_pfn(p), start);
-			ret = soft_offline_page(p, MF_COUNT_INCREASED);
+
+		if (behavior == MADV_SOFT_OFFLINE) {
+			pr_info("Soft offlining pfn %#lx at process virtual address %#lx\n",
+						page_to_pfn(page), start);
+
+			ret = soft_offline_page(page, MF_COUNT_INCREASED);
 			if (ret)
 				return ret;
 			continue;
 		}
-		pr_info("Injecting memory failure for page %#lx at %#lx\n",
-		       page_to_pfn(p), start);
-		ret = memory_failure(page_to_pfn(p), 0, MF_COUNT_INCREASED);
+		pr_info("Injecting memory failure for pfn %#lx at process virtual address %#lx\n",
+						page_to_pfn(page), start);
+
+		ret = memory_failure(page_to_pfn(page), 0, MF_COUNT_INCREASED);
 		if (ret)
 			return ret;
 	}
@@ -763,7 +769,7 @@ static int madvise_hwpoison(int bhv, unsigned long start, unsigned long end)
 
 #ifdef CONFIG_MEMORY_FAILURE
 	if (behavior == MADV_HWPOISON || behavior == MADV_SOFT_OFFLINE)
-		return madvise_hwpoison(behavior, start, start+len_in);
+		return madvise_inject_error(behavior, start, start + len_in);
 #endif
 	if (!madvise_behavior_valid(behavior))
 		return error;
-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
