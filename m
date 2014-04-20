Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 09B7A6B0039
	for <linux-mm@kvack.org>; Sat, 19 Apr 2014 22:26:49 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id fp1so2583397pdb.14
        for <linux-mm@kvack.org>; Sat, 19 Apr 2014 19:26:49 -0700 (PDT)
Received: from g2t2354.austin.hp.com (g2t2354.austin.hp.com. [15.217.128.53])
        by mx.google.com with ESMTPS id fn10si17741621pad.156.2014.04.19.19.26.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 19 Apr 2014 19:26:49 -0700 (PDT)
From: Davidlohr Bueso <davidlohr@hp.com>
Subject: [PATCH 2/6] m68k: call find_vma with the mmap_sem held in sys_cacheflush()
Date: Sat, 19 Apr 2014 19:26:27 -0700
Message-Id: <1397960791-16320-3-git-send-email-davidlohr@hp.com>
In-Reply-To: <1397960791-16320-1-git-send-email-davidlohr@hp.com>
References: <1397960791-16320-1-git-send-email-davidlohr@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: zeus@gnu.org, aswin@hp.com, davidlohr@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, linux-m68k@lists.linux-m68k.org

Performing vma lookups without taking the mm->mmap_sem is asking
for trouble. While doing the search, the vma in question can be
modified or even removed before returning to the caller. Take the
lock (shared) in order to avoid races while iterating through
the vmacache and/or rbtree.

This patch is completely *untested*.

Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: linux-m68k@lists.linux-m68k.org
---
 arch/m68k/kernel/sys_m68k.c | 18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/arch/m68k/kernel/sys_m68k.c b/arch/m68k/kernel/sys_m68k.c
index 3a480b3..d2263a0 100644
--- a/arch/m68k/kernel/sys_m68k.c
+++ b/arch/m68k/kernel/sys_m68k.c
@@ -376,7 +376,6 @@ cache_flush_060 (unsigned long addr, int scope, int cache, unsigned long len)
 asmlinkage int
 sys_cacheflush (unsigned long addr, int scope, int cache, unsigned long len)
 {
-	struct vm_area_struct *vma;
 	int ret = -EINVAL;
 
 	if (scope < FLUSH_SCOPE_LINE || scope > FLUSH_SCOPE_ALL ||
@@ -389,16 +388,23 @@ sys_cacheflush (unsigned long addr, int scope, int cache, unsigned long len)
 		if (!capable(CAP_SYS_ADMIN))
 			goto out;
 	} else {
+		struct vm_area_struct *vma;
+		bool invalid;
+
+		/* Check for overflow.  */
+		if (addr + len < addr)
+			goto out;
+
 		/*
 		 * Verify that the specified address region actually belongs
 		 * to this process.
 		 */
-		vma = find_vma (current->mm, addr);
 		ret = -EINVAL;
-		/* Check for overflow.  */
-		if (addr + len < addr)
-			goto out;
-		if (vma == NULL || addr < vma->vm_start || addr + len > vma->vm_end)
+		down_read(&current->mm->mmap_sem);
+		vma = find_vma(current->mm, addr);
+		invalid = !vma || addr < vma->vm_start || addr + len > vma->vm_end;
+		up_read(&current->mm->mmap_sem);
+		if (invalid)
 			goto out;
 	}
 
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
