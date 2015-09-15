Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id DFB8F6B025F
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 10:09:40 -0400 (EDT)
Received: by lbbvu2 with SMTP id vu2so13646832lbb.0
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 07:09:40 -0700 (PDT)
Received: from mail-la0-x230.google.com (mail-la0-x230.google.com. [2a00:1450:4010:c03::230])
        by mx.google.com with ESMTPS id r5si4878436lbp.56.2015.09.15.07.09.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 07:09:39 -0700 (PDT)
Received: by lamp12 with SMTP id p12so107200836lam.0
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 07:09:39 -0700 (PDT)
From: Alexander Kuleshov <kuleshovmail@gmail.com>
Subject: [PATCH 10/10] mm/mremap: Use offset_in_page macro
Date: Tue, 15 Sep 2015 20:08:44 +0600
Message-Id: <1442326124-7658-1-git-send-email-kuleshovmail@gmail.com>
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
 mm/mremap.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/mremap.c b/mm/mremap.c
index 5a71cce..3fea83c 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -401,7 +401,7 @@ static unsigned long mremap_to(unsigned long addr, unsigned long old_len,
 	unsigned long charged = 0;
 	unsigned long map_flags;
 
-	if (new_addr & ~PAGE_MASK)
+	if (offset_in_page(new_addr))
 		goto out;
 
 	if (new_len > TASK_SIZE || new_addr > TASK_SIZE - new_len)
@@ -435,11 +435,11 @@ static unsigned long mremap_to(unsigned long addr, unsigned long old_len,
 	ret = get_unmapped_area(vma->vm_file, new_addr, new_len, vma->vm_pgoff +
 				((addr - vma->vm_start) >> PAGE_SHIFT),
 				map_flags);
-	if (ret & ~PAGE_MASK)
+	if (offset_in_page(ret))
 		goto out1;
 
 	ret = move_vma(vma, addr, old_len, new_len, new_addr, locked);
-	if (!(ret & ~PAGE_MASK))
+	if (!(offset_in_page(ret)))
 		goto out;
 out1:
 	vm_unacct_memory(charged);
@@ -484,7 +484,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 	if (flags & MREMAP_FIXED && !(flags & MREMAP_MAYMOVE))
 		return ret;
 
-	if (addr & ~PAGE_MASK)
+	if (offset_in_page(addr))
 		return ret;
 
 	old_len = PAGE_ALIGN(old_len);
@@ -566,7 +566,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 					vma->vm_pgoff +
 					((addr - vma->vm_start) >> PAGE_SHIFT),
 					map_flags);
-		if (new_addr & ~PAGE_MASK) {
+		if (offset_in_page(new_addr)) {
 			ret = new_addr;
 			goto out;
 		}
@@ -574,7 +574,7 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 		ret = move_vma(vma, addr, old_len, new_len, new_addr, &locked);
 	}
 out:
-	if (ret & ~PAGE_MASK) {
+	if (offset_in_page(ret)) {
 		vm_unacct_memory(charged);
 		locked = 0;
 	}
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
