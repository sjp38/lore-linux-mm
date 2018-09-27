Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 45C228E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 12:59:56 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id s1-v6so3366324pfm.22
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 09:59:56 -0700 (PDT)
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id r73-v6si2674788pfk.83.2018.09.27.09.59.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Sep 2018 09:59:54 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [v3 PATCH 2/2 -mm] mm: brk: downgrade mmap_sem to read when shrinking
Date: Fri, 28 Sep 2018 00:59:42 +0800
Message-Id: <1538067582-60038-2-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1538067582-60038-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1538067582-60038-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, kirill@shutemov.name, willy@infradead.org, ldufour@linux.vnet.ibm.com, vbabka@suse.cz, akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

brk might be used to shrink memory mapping too other than munmap().
So, it may hold write mmap_sem for long time when shrinking large
mapping, as what commit ("mm: mmap: zap pages with read mmap_sem in
munmap") described.

The brk() will not manipulate vmas anymore after __do_munmap() call for
the mapping shrink use case. But, it may set mm->brk after
__do_munmap(), which needs hold write mmap_sem.

However, a simple trick can workaround this by setting mm->brk before
__do_munmap(). Then restore the original value if __do_munmap() fails.
With this trick, it is safe to downgrade to read mmap_sem.

So, the same optimization, which downgrades mmap_sem to read for
zapping pages, is also feasible and reasonable to this case.

The period of holding exclusive mmap_sem for shrinking large mapping
would be reduced significantly with this optimization.

Acked-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
v3: Fixed the comments from Vlastimil and Kirill. And, added their
    Acked-by. Thanks.
v2: Rephrase the commit log per Michal

 mm/mmap.c | 43 ++++++++++++++++++++++++++++++++-----------
 1 file changed, 32 insertions(+), 11 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 017bcfa..68dc4fb 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -191,16 +191,19 @@ static int do_brk_flags(unsigned long addr, unsigned long request, unsigned long
 SYSCALL_DEFINE1(brk, unsigned long, brk)
 {
 	unsigned long retval;
-	unsigned long newbrk, oldbrk;
+	unsigned long newbrk, oldbrk, origbrk;
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *next;
 	unsigned long min_brk;
 	bool populate;
+	bool downgraded = false;
 	LIST_HEAD(uf);
 
 	if (down_write_killable(&mm->mmap_sem))
 		return -EINTR;
 
+	origbrk = mm->brk;
+
 #ifdef CONFIG_COMPAT_BRK
 	/*
 	 * CONFIG_COMPAT_BRK can still be overridden by setting
@@ -229,14 +232,29 @@ static int do_brk_flags(unsigned long addr, unsigned long request, unsigned long
 
 	newbrk = PAGE_ALIGN(brk);
 	oldbrk = PAGE_ALIGN(mm->brk);
-	if (oldbrk == newbrk)
-		goto set_brk;
+	if (oldbrk == newbrk) {
+		mm->brk = brk;
+		goto success;
+	}
 
-	/* Always allow shrinking brk. */
+	/*
+	 * Always allow shrinking brk.
+	 * __do_munmap() may downgrade mmap_sem to read.
+	 */
 	if (brk <= mm->brk) {
-		if (!do_munmap(mm, newbrk, oldbrk-newbrk, &uf))
-			goto set_brk;
-		goto out;
+		/*
+		 * mm->brk need to be protected by write mmap_sem, update it
+		 * before downgrading mmap_sem.
+		 * When __do_munmap fail, it will be restored from origbrk.
+		 */
+		mm->brk = brk;
+		retval = __do_munmap(mm, newbrk, oldbrk-newbrk, &uf, true);
+		if (retval < 0) {
+			mm->brk = origbrk;
+			goto out;
+		} else if (retval == 1)
+			downgraded = true;
+		goto success;
 	}
 
 	/* Check against existing mmap mappings. */
@@ -247,18 +265,21 @@ static int do_brk_flags(unsigned long addr, unsigned long request, unsigned long
 	/* Ok, looks good - let it rip. */
 	if (do_brk_flags(oldbrk, newbrk-oldbrk, 0, &uf) < 0)
 		goto out;
-
-set_brk:
 	mm->brk = brk;
+
+success:
 	populate = newbrk > oldbrk && (mm->def_flags & VM_LOCKED) != 0;
-	up_write(&mm->mmap_sem);
+	if (downgraded)
+		up_read(&mm->mmap_sem);
+	else
+		up_write(&mm->mmap_sem);
 	userfaultfd_unmap_complete(mm, &uf);
 	if (populate)
 		mm_populate(oldbrk, newbrk - oldbrk);
 	return brk;
 
 out:
-	retval = mm->brk;
+	retval = origbrk;
 	up_write(&mm->mmap_sem);
 	return retval;
 }
-- 
1.8.3.1
