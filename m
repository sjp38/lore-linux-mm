Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com [209.85.217.170])
	by kanga.kvack.org (Postfix) with ESMTP id 7F0236B025F
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 10:09:34 -0400 (EDT)
Received: by lbbmp1 with SMTP id mp1so85837974lbb.1
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 07:09:33 -0700 (PDT)
Received: from mail-la0-x229.google.com (mail-la0-x229.google.com. [2a00:1450:4010:c03::229])
        by mx.google.com with ESMTPS id rj9si13884466lbb.26.2015.09.15.07.09.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 07:09:32 -0700 (PDT)
Received: by lanb10 with SMTP id b10so107807836lan.3
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 07:09:32 -0700 (PDT)
From: Alexander Kuleshov <kuleshovmail@gmail.com>
Subject: [PATCH 09/10] mm/mmap: Use offset_in_page macro
Date: Tue, 15 Sep 2015 20:08:37 +0600
Message-Id: <1442326117-7603-1-git-send-email-kuleshovmail@gmail.com>
In-Reply-To: <1442326012-7034-1-git-send-email-kuleshovmail@gmail.com>
References: <1442326012-7034-1-git-send-email-kuleshovmail@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Kuleshov <kuleshovmail@gmail.com>

The <linux/mm.h> provides offset_in_page() macro. Let's use already
predefined macro instead of (addr & ~PAGE_MASK).

Signed-off-by: Alexander Kuleshov <kuleshovmail@gmail.com>
---
 mm/mmap.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 971dd2c..a313a9c 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1304,7 +1304,7 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 	 * that it represents a valid section of the address space.
 	 */
 	addr = get_unmapped_area(file, addr, len, pgoff, flags);
-	if (addr & ~PAGE_MASK)
+	if (offset_in_page(addr))
 		return addr;
 
 	/* Do simple checking here so the lower-level routines won't have
@@ -1475,7 +1475,7 @@ SYSCALL_DEFINE1(old_mmap, struct mmap_arg_struct __user *, arg)
 
 	if (copy_from_user(&a, arg, sizeof(a)))
 		return -EFAULT;
-	if (a.offset & ~PAGE_MASK)
+	if (offset_in_page(a.offset))
 		return -EINVAL;
 
 	return sys_mmap_pgoff(a.addr, a.len, a.prot, a.flags, a.fd,
@@ -1996,7 +1996,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	 * can happen with large stack limits and large mmap()
 	 * allocations.
 	 */
-	if (addr & ~PAGE_MASK) {
+	if (offset_in_page(addr)) {
 		VM_BUG_ON(addr != -ENOMEM);
 		info.flags = 0;
 		info.low_limit = TASK_UNMAPPED_BASE;
@@ -2032,7 +2032,7 @@ get_unmapped_area(struct file *file, unsigned long addr, unsigned long len,
 
 	if (addr > TASK_SIZE - len)
 		return -ENOMEM;
-	if (addr & ~PAGE_MASK)
+	if (offset_in_page(addr))
 		return -EINVAL;
 
 	addr = arch_rebalance_pgtables(addr, len);
@@ -2543,7 +2543,7 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
 	unsigned long end;
 	struct vm_area_struct *vma, *prev, *last;
 
-	if ((start & ~PAGE_MASK) || start > TASK_SIZE || len > TASK_SIZE-start)
+	if ((offset_in_page(start)) || start > TASK_SIZE || len > TASK_SIZE-start)
 		return -EINVAL;
 
 	len = PAGE_ALIGN(len);
@@ -2741,7 +2741,7 @@ static unsigned long do_brk(unsigned long addr, unsigned long len)
 	flags = VM_DATA_DEFAULT_FLAGS | VM_ACCOUNT | mm->def_flags;
 
 	error = get_unmapped_area(NULL, addr, len, 0, MAP_FIXED);
-	if (error & ~PAGE_MASK)
+	if (offset_in_page(error))
 		return error;
 
 	error = mlock_future_check(mm, mm->def_flags, len);
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
