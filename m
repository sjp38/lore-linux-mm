Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 93E566B0007
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 17:32:09 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id r24so2701430ioa.11
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 14:32:09 -0700 (PDT)
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id f185-v6si1881192ith.161.2018.03.20.14.32.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Mar 2018 14:32:08 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [RFC PATCH 2/8] mm: mmap: pass atomic parameter to do_munmap() call sites
Date: Wed, 21 Mar 2018 05:31:20 +0800
Message-Id: <1521581486-99134-3-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1521581486-99134-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1521581486-99134-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

It looks safe to release mmap_sem in the middle for vm_munmap and brk,
so passing "false" to do_munmap() call.
However it sounds not safe to mmap_region() which is called by
SyS_mmap().

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/mmap.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index ad6ae7a..374e4ec 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -225,7 +225,7 @@ static struct vm_area_struct *remove_vma(struct vm_area_struct *vma)
 
 	/* Always allow shrinking brk. */
 	if (brk <= mm->brk) {
-		if (!do_munmap(mm, newbrk, oldbrk-newbrk, &uf))
+		if (!do_munmap(mm, newbrk, oldbrk-newbrk, &uf, false))
 			goto set_brk;
 		goto out;
 	}
@@ -1643,7 +1643,7 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 	/* Clear old maps */
 	while (find_vma_links(mm, addr, addr + len, &prev, &rb_link,
 			      &rb_parent)) {
-		if (do_munmap(mm, addr, len, uf))
+		if (do_munmap(mm, addr, len, uf, true))
 			return -ENOMEM;
 	}
 
@@ -2778,7 +2778,7 @@ int vm_munmap(unsigned long start, size_t len)
 	if (down_write_killable(&mm->mmap_sem))
 		return -EINTR;
 
-	ret = do_munmap(mm, start, len, &uf);
+	ret = do_munmap(mm, start, len, &uf, false);
 	up_write(&mm->mmap_sem);
 	userfaultfd_unmap_complete(mm, &uf);
 	return ret;
@@ -2945,7 +2945,7 @@ static int do_brk_flags(unsigned long addr, unsigned long request, unsigned long
 	 */
 	while (find_vma_links(mm, addr, addr + len, &prev, &rb_link,
 			      &rb_parent)) {
-		if (do_munmap(mm, addr, len, uf))
+		if (do_munmap(mm, addr, len, uf, false))
 			return -ENOMEM;
 	}
 
-- 
1.8.3.1
