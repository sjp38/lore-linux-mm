Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 08D4B6B039F
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 04:29:32 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id u77so15661554wrb.6
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 01:29:31 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j1si10357577wrb.166.2017.04.10.01.29.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Apr 2017 01:29:30 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3A8ShLQ057503
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 04:29:28 -0400
Received: from e28smtp01.in.ibm.com (e28smtp01.in.ibm.com [125.16.236.1])
	by mx0b-001b2d01.pphosted.com with ESMTP id 29r4vt4w8p-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 04:29:28 -0400
Received: from localhost
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 10 Apr 2017 13:59:25 +0530
Received: from d28av06.in.ibm.com (d28av06.in.ibm.com [9.184.220.48])
	by d28relay10.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3A8RnKX7078110
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 13:57:49 +0530
Received: from d28av06.in.ibm.com (localhost [127.0.0.1])
	by d28av06.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3A8T9xa019462
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 13:59:09 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH] mm/madvise: Clean up MADV_SOFT_OFFLINE and MADV_HWPOISON
Date: Mon, 10 Apr 2017 13:59:03 +0530
Message-Id: <20170410082903.8828-1-khandual@linux.vnet.ibm.com>
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

[97216.813999] Soft offlining page 0x15e3e at 0x3fff8c230000
[97234.670320] Soft offlining page 0x1f3 at 0x3fffa0da0000
[97318.817426] Soft offlining page 0x744 at 0x3fff7d200000
[97319.537899] Soft offlining page 0x1634d at 0x3fff95e20000
[97319.538528] Soft offlining page 0x16349 at 0x3fff95e30000
[97326.714138] Soft offlining page 0x1d6 at 0x3fff9e8b0000
[97327.334351] Soft offlining page 0x5f3 at 0x3fff91bd0000

[97593.860913] Injecting memory failure for page 0x15c8b at 0x3fff83280000
[97593.861757] Injecting memory failure for page 0x16190 at 0x3fff83290000
[97594.430585] Injecting memory failure for page 0x740 at 0x3fff9a2e0000
[97594.431289] Injecting memory failure for page 0x741 at 0x3fff9a2f0000

After the patch:

[  707.219172] Soft offlining pfn 0x1484e at process virtual address 0x3fff883c0000
[  707.219178] Soft offlining pfn 0x1484f at process virtual address 0x3fff883d0000
[  707.219185] Soft offlining pfn 0x14850 at process virtual address 0x3fff883e0000
[  707.219192] Soft offlining pfn 0x14851 at process virtual address 0x3fff883f0000
[  707.219199] Soft offlining pfn 0x14852 at process virtual address 0x3fff88400000
[  707.219207] Soft offlining pfn 0x14853 at process virtual address 0x3fff88410000
[  707.219214] Soft offlining pfn 0x14854 at process virtual address 0x3fff88420000
[  710.231938] Soft offlining pfn 0x1521c at process virtual address 0x3fff6bc70000

[  746.630823] Injecting memory failure for pfn 0x10fcf at process virtual address 0x3fff86310000
[  746.630832] Injecting memory failure for pfn 0x10fd0 at process virtual address 0x3fff86320000
[  746.630842] Injecting memory failure for pfn 0x10fd1 at process virtual address 0x3fff86330000
[  746.630851] Injecting memory failure for pfn 0x10fd2 at process virtual address 0x3fff86340000
[  746.630861] Injecting memory failure for pfn 0x10fd3 at process virtual address 0x3fff86350000
[  746.630870] Injecting memory failure for pfn 0x10fd4 at process virtual address 0x3fff86360000
[  746.630880] Injecting memory failure for pfn 0x10fd5 at process virtual address 0x3fff86370000

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
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
