Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4FB0B8E0001
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 20:47:24 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id x19-v6so13666723pfh.15
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 17:47:24 -0700 (PDT)
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id b124-v6si3770044pgc.45.2018.09.25.17.47.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Sep 2018 17:47:22 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [PATCH 2/2 -mm] mm: brk: dwongrade mmap_sem to read when shrinking
Date: Wed, 26 Sep 2018 08:46:56 +0800
Message-Id: <1537922816-108051-2-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1537922816-108051-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1537922816-108051-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, kirill@shutemov.name, willy@infradead.org, ldufour@linux.vnet.ibm.com, vbabka@suse.cz, akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

brk might be used to shinrk memory mapping too. Use __do_munmap() to
shrink mapping with downgrading mmap_sem to read.

Cc: Michal Hocko <mhocko@kernel.org>
Cc: Kirill A. Shutemov <kirill@shutemov.name>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/mmap.c | 35 ++++++++++++++++++++++++++---------
 1 file changed, 26 insertions(+), 9 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 017bcfa..3da14a1 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -193,9 +193,11 @@ static int do_brk_flags(unsigned long addr, unsigned long request, unsigned long
 	unsigned long retval;
 	unsigned long newbrk, oldbrk;
 	struct mm_struct *mm = current->mm;
+	unsigned long origbrk = mm->brk;
 	struct vm_area_struct *next;
 	unsigned long min_brk;
 	bool populate;
+	bool downgrade = false;
 	LIST_HEAD(uf);
 
 	if (down_write_killable(&mm->mmap_sem))
@@ -229,14 +231,26 @@ static int do_brk_flags(unsigned long addr, unsigned long request, unsigned long
 
 	newbrk = PAGE_ALIGN(brk);
 	oldbrk = PAGE_ALIGN(mm->brk);
-	if (oldbrk == newbrk)
-		goto set_brk;
+	if (oldbrk == newbrk) {
+		mm->brk = brk;
+		goto success;
+	}
 
 	/* Always allow shrinking brk. */
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
+			downgrade = true;
+		goto success;
 	}
 
 	/* Check against existing mmap mappings. */
@@ -247,18 +261,21 @@ static int do_brk_flags(unsigned long addr, unsigned long request, unsigned long
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
+	if (downgrade)
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
