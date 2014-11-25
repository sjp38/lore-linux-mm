Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id DB70F6B0038
	for <linux-mm@kvack.org>; Tue, 25 Nov 2014 01:52:23 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id ft15so11397787pdb.32
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 22:52:23 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id p5si577961pdb.8.2014.11.24.22.52.18
        for <linux-mm@kvack.org>;
        Mon, 24 Nov 2014 22:52:22 -0800 (PST)
From: Chanho Min <chanho.min@lge.com>
Subject: [PATCH] mm: add parameter to disable faultaround
Date: Tue, 25 Nov 2014 15:51:58 +0900
Message-Id: <1416898318-17409-1-git-send-email-chanho.min@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, HyoJun Im <hyojun.im@lge.com>, Gunho Lee <gunho.lee@lge.com>, Wonhong Kwon <wonhong.kwon@lge.com>, Chanho Min <chanho.min@lge.com>

The faultaround improves the file read performance, whereas pages which
can be dropped by drop_caches are reduced. On some systems, The amount of
freeable pages under memory pressure is more important than read
performance. So It prefers to be selectable.

This patch adds a new kernel cmdline parameter "nofaultaround"
for situations where users want to disable faultaround.

Signed-off-by: Chanho Min <chanho.min@lge.com>
---
 mm/memory.c |   11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index 4879b42..c36a96f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2888,6 +2888,14 @@ static int __init fault_around_debugfs(void)
 late_initcall(fault_around_debugfs);
 #endif
 
+static bool enable_fault_around = true;
+static int __init disable_fault_around(char *s)
+{
+	enable_fault_around = false;
+	return 1;
+}
+__setup("nofaultaround", disable_fault_around);
+
 /*
  * do_fault_around() tries to map few pages around the fault address. The hope
  * is that the pages will be needed soon and this will lower the number of
@@ -2965,7 +2973,8 @@ static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * if page by the offset is not ready to be mapped (cold cache or
 	 * something).
 	 */
-	if (vma->vm_ops->map_pages && !(flags & FAULT_FLAG_NONLINEAR) &&
+	if (enable_fault_around && vma->vm_ops->map_pages &&
+	    !(flags & FAULT_FLAG_NONLINEAR) &&
 	    fault_around_pages() > 1) {
 		pte = pte_offset_map_lock(mm, pmd, address, &ptl);
 		do_fault_around(vma, address, pte, pgoff, flags);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
