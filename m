Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f45.google.com (mail-la0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id AB6E06B0259
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 10:08:28 -0400 (EDT)
Received: by lanb10 with SMTP id b10so107782391lan.3
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 07:08:28 -0700 (PDT)
Received: from mail-la0-x236.google.com (mail-la0-x236.google.com. [2a00:1450:4010:c03::236])
        by mx.google.com with ESMTPS id d6si13869094lab.61.2015.09.15.07.08.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 07:08:27 -0700 (PDT)
Received: by lagj9 with SMTP id j9so109907288lag.2
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 07:08:26 -0700 (PDT)
From: Alexander Kuleshov <kuleshovmail@gmail.com>
Subject: [PATCH 02/10] mm/nommu: Use offset_in_page macro
Date: Tue, 15 Sep 2015 20:07:31 +0600
Message-Id: <1442326051-7206-1-git-send-email-kuleshovmail@gmail.com>
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
 mm/nommu.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/nommu.c b/mm/nommu.c
index ab14a20..1e0f168 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1497,7 +1497,7 @@ SYSCALL_DEFINE1(old_mmap, struct mmap_arg_struct __user *, arg)
 
 	if (copy_from_user(&a, arg, sizeof(a)))
 		return -EFAULT;
-	if (a.offset & ~PAGE_MASK)
+	if (offset_in_page(a.offset))
 		return -EINVAL;
 
 	return sys_mmap_pgoff(a.addr, a.len, a.prot, a.flags, a.fd,
@@ -1653,9 +1653,9 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
 			goto erase_whole_vma;
 		if (start < vma->vm_start || end > vma->vm_end)
 			return -EINVAL;
-		if (start & ~PAGE_MASK)
+		if (offset_in_page(start))
 			return -EINVAL;
-		if (end != vma->vm_end && end & ~PAGE_MASK)
+		if (end != vma->vm_end && offset_in_page(end))
 			return -EINVAL;
 		if (start != vma->vm_start && end != vma->vm_end) {
 			ret = split_vma(mm, vma, start, 1);
@@ -1736,7 +1736,7 @@ static unsigned long do_mremap(unsigned long addr,
 	if (old_len == 0 || new_len == 0)
 		return (unsigned long) -EINVAL;
 
-	if (addr & ~PAGE_MASK)
+	if (offset_in_page(addr))
 		return -EINVAL;
 
 	if (flags & MREMAP_FIXED && new_addr != addr)
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
