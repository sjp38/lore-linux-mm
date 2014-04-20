Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id 492206B003C
	for <linux-mm@kvack.org>; Sat, 19 Apr 2014 22:26:57 -0400 (EDT)
Received: by mail-ob0-f171.google.com with SMTP id uy5so3148914obc.30
        for <linux-mm@kvack.org>; Sat, 19 Apr 2014 19:26:52 -0700 (PDT)
Received: from g2t2353.austin.hp.com (g2t2353.austin.hp.com. [15.217.128.52])
        by mx.google.com with ESMTPS id yu9si26105254oeb.89.2014.04.19.19.26.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 19 Apr 2014 19:26:51 -0700 (PDT)
From: Davidlohr Bueso <davidlohr@hp.com>
Subject: [PATCH 4/6] arc: call find_vma with the mmap_sem held
Date: Sat, 19 Apr 2014 19:26:29 -0700
Message-Id: <1397960791-16320-5-git-send-email-davidlohr@hp.com>
In-Reply-To: <1397960791-16320-1-git-send-email-davidlohr@hp.com>
References: <1397960791-16320-1-git-send-email-davidlohr@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: zeus@gnu.org, aswin@hp.com, davidlohr@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vineet Gupta <vgupta@synopsys.com>

Performing vma lookups without taking the mm->mmap_sem is asking
for trouble. While doing the search, the vma in question can be
modified or even removed before returning to the caller. Take the
lock (shared) in order to avoid races while iterating through
the vmacache and/or rbtree.

This patch is completely *untested*.

Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
Cc: Vineet Gupta <vgupta@synopsys.com>
---
 arch/arc/kernel/troubleshoot.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/arch/arc/kernel/troubleshoot.c b/arch/arc/kernel/troubleshoot.c
index 73a7450..3a5a5c1 100644
--- a/arch/arc/kernel/troubleshoot.c
+++ b/arch/arc/kernel/troubleshoot.c
@@ -90,7 +90,7 @@ static void show_faulting_vma(unsigned long address, char *buf)
 	/* can't use print_vma_addr() yet as it doesn't check for
 	 * non-inclusive vma
 	 */
-
+	down_read(&current->active_mm->mmap_sem);
 	vma = find_vma(current->active_mm, address);
 
 	/* check against the find_vma( ) behaviour which returns the next VMA
@@ -110,9 +110,10 @@ static void show_faulting_vma(unsigned long address, char *buf)
 			vma->vm_start < TASK_UNMAPPED_BASE ?
 				address : address - vma->vm_start,
 			nm, vma->vm_start, vma->vm_end);
-	} else {
+	} else
 		pr_info("    @No matching VMA found\n");
-	}
+
+	up_read(&current->active_mm->mmap_sem);
 }
 
 static void show_ecr_verbose(struct pt_regs *regs)
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
