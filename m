Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 30EBE6B004F
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 06:46:43 -0500 (EST)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Fri, 13 Jan 2012 11:40:02 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0DBddbw3584140
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 22:39:41 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0DBi6eM022982
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 22:44:06 +1100
Message-ID: <4F101904.8090405@linux.vnet.ibm.com>
Date: Fri, 13 Jan 2012 19:44:04 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 1/5] hugetlbfs: fix hugetlb_get_unmapped_area
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: William Irwin <wli@holomorphy.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Using/updating cached_hole_size and free_area_cache properly to speedup
find free region

Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
---
 fs/hugetlbfs/inode.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index e425ad9..9e0794a 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -154,10 +154,12 @@ hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
 			return addr;
 	}

-	start_addr = mm->free_area_cache;
-
-	if (len <= mm->cached_hole_size)
+	if (len > mm->cached_hole_size)
+		start_addr = mm->free_area_cache;
+	else {
 		start_addr = TASK_UNMAPPED_BASE;
+		mm->cached_hole_size = 0;
+	}

 full_search:
 	addr = ALIGN(start_addr, huge_page_size(h));
@@ -171,13 +173,18 @@ full_search:
 			 */
 			if (start_addr != TASK_UNMAPPED_BASE) {
 				start_addr = TASK_UNMAPPED_BASE;
+				mm->cached_hole_size = 0;
 				goto full_search;
 			}
 			return -ENOMEM;
 		}

-		if (!vma || addr + len <= vma->vm_start)
+		if (!vma || addr + len <= vma->vm_start) {
+			mm->free_area_cache = addr + len;
 			return addr;
+		}
+		if (addr + mm->cached_hole_size < vma->vm_start)
+			mm->cached_hole_size = vma->vm_start - addr;
 		addr = ALIGN(vma->vm_end, huge_page_size(h));
 	}
 }
-- 
1.7.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
