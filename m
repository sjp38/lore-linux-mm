Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id AACA26B0037
	for <linux-mm@kvack.org>; Sat, 19 Apr 2014 22:26:44 -0400 (EDT)
Received: by mail-ob0-f179.google.com with SMTP id vb8so674912obc.24
        for <linux-mm@kvack.org>; Sat, 19 Apr 2014 19:26:44 -0700 (PDT)
Received: from g2t2353.austin.hp.com (g2t2353.austin.hp.com. [15.217.128.52])
        by mx.google.com with ESMTPS id n6si26095503oeo.79.2014.04.19.19.26.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 19 Apr 2014 19:26:44 -0700 (PDT)
From: Davidlohr Bueso <davidlohr@hp.com>
Subject: [PATCH 1/6] blackfin/ptrace: call find_vma with the mmap_sem held
Date: Sat, 19 Apr 2014 19:26:26 -0700
Message-Id: <1397960791-16320-2-git-send-email-davidlohr@hp.com>
In-Reply-To: <1397960791-16320-1-git-send-email-davidlohr@hp.com>
References: <1397960791-16320-1-git-send-email-davidlohr@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: zeus@gnu.org, aswin@hp.com, davidlohr@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Steven Miao <realmz6@gmail.com>, adi-buildroot-devel@lists.sourceforge.net

Performing vma lookups without taking the mm->mmap_sem is asking
for trouble. While doing the search, the vma in question can be
modified or even removed before returning to the caller. Take the
lock (shared) in order to avoid races while iterating through the
vmacache and/or rbtree.

This patch is completely *untested*.

Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
Cc: Steven Miao <realmz6@gmail.com>
Cc: adi-buildroot-devel@lists.sourceforge.net
---
 arch/blackfin/kernel/ptrace.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/arch/blackfin/kernel/ptrace.c b/arch/blackfin/kernel/ptrace.c
index e1f88e0..8b8fe67 100644
--- a/arch/blackfin/kernel/ptrace.c
+++ b/arch/blackfin/kernel/ptrace.c
@@ -117,6 +117,7 @@ put_reg(struct task_struct *task, unsigned long regno, unsigned long data)
 int
 is_user_addr_valid(struct task_struct *child, unsigned long start, unsigned long len)
 {
+	bool valid;
 	struct vm_area_struct *vma;
 	struct sram_list_struct *sraml;
 
@@ -124,9 +125,12 @@ is_user_addr_valid(struct task_struct *child, unsigned long start, unsigned long
 	if (start + len < start)
 		return -EIO;
 
+	down_read(&child->mm->mmap_sem);
 	vma = find_vma(child->mm, start);
-	if (vma && start >= vma->vm_start && start + len <= vma->vm_end)
-			return 0;
+	valid = vma && start >= vma->vm_start && start + len <= vma->vm_end;
+	up_read(&child->mm->mmap_sem);
+	if (valid)
+		return 0;
 
 	for (sraml = child->mm->context.sram_list; sraml; sraml = sraml->next)
 		if (start >= (unsigned long)sraml->addr
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
