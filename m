Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id F3C206B005A
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 06:47:42 -0500 (EST)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Fri, 13 Jan 2012 11:45:45 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0DBfKQW3498090
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 22:41:20 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0DBjl0j024364
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 22:45:47 +1100
Message-ID: <4F101969.8050601@linux.vnet.ibm.com>
Date: Fri, 13 Jan 2012 19:45:45 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 3/5] hugetlb: try to search again if it is really needed
References: <4F101904.8090405@linux.vnet.ibm.com>
In-Reply-To: <4F101904.8090405@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, William Irwin <wli@holomorphy.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Search again only if some holes may be skipped in the first time

Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
---
 arch/x86/mm/hugetlbpage.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index e12debc..6bf5735 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -309,9 +309,8 @@ static unsigned long hugetlb_get_unmapped_area_topdown(struct file *file,
 	struct hstate *h = hstate_file(file);
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
-	unsigned long base = mm->mmap_base, addr = addr0;
+	unsigned long base = mm->mmap_base, addr = addr0, start_addr;
 	unsigned long largest_hole = mm->cached_hole_size;
-	int first_time = 1;

 	/* don't allow allocations above current base */
 	if (mm->free_area_cache > base)
@@ -322,6 +321,8 @@ static unsigned long hugetlb_get_unmapped_area_topdown(struct file *file,
 		mm->free_area_cache  = base;
 	}
 try_again:
+	start_addr = mm->free_area_cache;
+
 	/* make sure it can fit in the remaining address space */
 	if (mm->free_area_cache < len)
 		goto fail;
@@ -357,10 +358,9 @@ fail:
 	 * if hint left us with no space for the requested
 	 * mapping then try again:
 	 */
-	if (first_time) {
+	if (start_addr != base) {
 		mm->free_area_cache = base;
 		largest_hole = 0;
-		first_time = 0;
 		goto try_again;
 	}
 	/*
-- 
1.7.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
