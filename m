Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 29E106B0099
	for <linux-mm@kvack.org>; Thu, 11 Nov 2010 15:33:44 -0500 (EST)
Received: from localhost.localdomain by digidescorp.com (Cipher TLSv1:RC4-MD5:128) (MDaemon PRO v10.1.1)
	with ESMTP id md50001481032.msg
	for <linux-mm@kvack.org>; Thu, 11 Nov 2010 14:33:31 -0600
From: "Steven J. Magnani" <steve@digidescorp.com>
Subject: [PATCH][RESEND] nommu: yield CPU periodically while disposing large VM
Date: Thu, 11 Nov 2010 14:33:16 -0600
Message-Id: <1289507596-17613-1-git-send-email-steve@digidescorp.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, "Steven J. Magnani" <steve@digidescorp.com>
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
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
