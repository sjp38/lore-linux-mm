Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 049A36B000E
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 17:32:42 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 60-v6so1867326plf.19
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 14:32:41 -0700 (PDT)
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id r20si1903964pfj.245.2018.03.20.14.32.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Mar 2018 14:32:40 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [RFC PATCH 3/8] mm: mremap: pass atomic parameter to do_munmap()
Date: Wed, 21 Mar 2018 05:31:21 +0800
Message-Id: <1521581486-99134-4-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1521581486-99134-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1521581486-99134-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

It sounds safe to do unlock/relock to mmap_sem in mremap, so passing
"false" here.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/mremap.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/mm/mremap.c b/mm/mremap.c
index 049470a..5f8fca4 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -353,7 +353,7 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 	if (unlikely(vma->vm_flags & VM_PFNMAP))
 		untrack_pfn_moved(vma);
 
-	if (do_munmap(mm, old_addr, old_len, uf_unmap) < 0) {
+	if (do_munmap(mm, old_addr, old_len, uf_unmap, false) < 0) {
 		/* OOM: unable to split vma, just get accounts right */
 		vm_unacct_memory(excess >> PAGE_SHIFT);
 		excess = 0;
@@ -462,12 +462,13 @@ static unsigned long mremap_to(unsigned long addr, unsigned long old_len,
 	if (addr + old_len > new_addr && new_addr + new_len > addr)
 		goto out;
 
-	ret = do_munmap(mm, new_addr, new_len, uf_unmap_early);
+	ret = do_munmap(mm, new_addr, new_len, uf_unmap_early, false);
 	if (ret)
 		goto out;
 
 	if (old_len >= new_len) {
-		ret = do_munmap(mm, addr+new_len, old_len - new_len, uf_unmap);
+		ret = do_munmap(mm, addr+new_len, old_len - new_len,
+				uf_unmap, false);
 		if (ret && old_len != new_len)
 			goto out;
 		old_len = new_len;
@@ -568,7 +569,8 @@ static int vma_expandable(struct vm_area_struct *vma, unsigned long delta)
 	 * do_munmap does all the needed commit accounting
 	 */
 	if (old_len >= new_len) {
-		ret = do_munmap(mm, addr+new_len, old_len - new_len, &uf_unmap);
+		ret = do_munmap(mm, addr+new_len, old_len - new_len,
+				&uf_unmap, false);
 		if (ret && old_len != new_len)
 			goto out;
 		ret = addr;
-- 
1.8.3.1
