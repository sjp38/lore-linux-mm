Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 35FDA8D003B
	for <linux-mm@kvack.org>; Fri,  8 Apr 2011 03:24:08 -0400 (EDT)
Message-Id: <10e5cbf67c850b6ae511979bdbad1761236ad9b0.1302247435.git.michael@ellerman.id.au>
From: Michael Ellerman <michael@ellerman.id.au>
Subject: [PATCH] mm: Check we have the right vma in __access_remote_vm()
Date: Fri,  8 Apr 2011 17:24:01 +1000 (EST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, hughd@google.com, walken@google.com, aarcange@redhat.com, riel@redhat.com, Andrew Morton <akpm@osdl.org>, linuxppc-dev@ozlabs.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>

In __access_remote_vm() we need to check that we have found the right
vma, not the following vma, before we try to access it. Otherwise we
might call the vma's access routine with an address which does not
fall inside the vma.

Signed-off-by: Michael Ellerman <michael@ellerman.id.au>
---
 mm/memory.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 9da8cab..ce999ca 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3678,7 +3678,7 @@ static int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 			 */
 #ifdef CONFIG_HAVE_IOREMAP_PROT
 			vma = find_vma(mm, addr);
-			if (!vma)
+			if (!vma || vma->vm_start > addr)
 				break;
 			if (vma->vm_ops && vma->vm_ops->access)
 				ret = vma->vm_ops->access(vma, addr, buf,
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
