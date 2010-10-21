Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id AA7DD5F0040
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 08:54:06 -0400 (EDT)
Received: from localhost.localdomain by digidescorp.com (Cipher TLSv1:RC4-MD5:128) (MDaemon PRO v10.1.1)
	with ESMTP id md50001457164.msg
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 07:54:04 -0500
From: "Steven J. Magnani" <steve@digidescorp.com>
Subject: [PATCH] nommu: yield CPU periodically while disposing large VM
Date: Thu, 21 Oct 2010 07:53:55 -0500
Message-Id: <1287665635-7925-1-git-send-email-steve@digidescorp.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: dhowells@redhat.com, linux-kernel@vger.kernel.org, "Steven J. Magnani" <steve@digidescorp.com>
List-ID: <linux-mm.kvack.org>

Depending on processor speed, page size, and the amount of memory a process
is allowed to amass, cleanup of a large VM may freeze the system for many
seconds. This can result in a watchdog timeout.

Make sure other tasks receive some service when cleaning up large VMs.

Signed-off-by: Steven J. Magnani <steve@digidescorp.com>
---
diff -uprN a/mm/nommu.c b/mm/nommu.c
--- a/mm/nommu.c	2010-10-21 07:42:23.000000000 -0500
+++ b/mm/nommu.c	2010-10-21 07:46:50.000000000 -0500
@@ -1656,6 +1656,7 @@ SYSCALL_DEFINE2(munmap, unsigned long, a
 void exit_mmap(struct mm_struct *mm)
 {
 	struct vm_area_struct *vma;
+	unsigned long next_yield = jiffies + HZ;
 
 	if (!mm)
 		return;
@@ -1668,6 +1669,11 @@ void exit_mmap(struct mm_struct *mm)
 		mm->mmap = vma->vm_next;
 		delete_vma_from_mm(vma);
 		delete_vma(mm, vma);
+		/* Yield periodically to prevent watchdog timeout */
+		if (time_after(jiffies, next_yield)) {
+			cond_resched();
+			next_yield = jiffies + HZ;
+		}
 	}
 
 	kleave("");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
