Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 28A9D8D003B
	for <linux-mm@kvack.org>; Tue,  5 Apr 2011 02:24:49 -0400 (EDT)
Message-Id: <c4f5166f98cb703742191eb74f583bb8011f9cdf.1301984663.git.michael@ellerman.id.au>
From: Michael Ellerman <michael@ellerman.id.au>
Subject: [PATCH] mm: Check we have the right vma in access_process_vm()
Date: Tue,  5 Apr 2011 16:24:31 +1000 (EST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, hughd@google.com, walken@google.com, aarcange@redhat.com, riel@redhat.com, Andrew Morton <akpm@osdl.org>, linuxppc-dev@ozlabs.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>

In access_process_vm() we need to check that we have found the right
vma, not the following vma, before we try to access it. Otherwise
we might call the vma's access routine with an address which does
not fall inside the vma.

Signed-off-by: Michael Ellerman <michael@ellerman.id.au>
---
 mm/memory.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 5823698..7e6f17b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3619,7 +3619,7 @@ int access_process_vm(struct task_struct *tsk, unsigned long addr, void *buf, in
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
