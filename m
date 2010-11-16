Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CCD1B8D0080
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 08:06:58 -0500 (EST)
Received: from localhost.localdomain by digidescorp.com (Cipher TLSv1:RC4-MD5:128) (MDaemon PRO v10.1.1)
	with ESMTP id md50001484967.msg
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 07:06:54 -0600
From: "Steven J. Magnani" <steve@digidescorp.com>
Subject: [PATCH][V2] nommu: yield CPU while disposing VM
Date: Tue, 16 Nov 2010 07:06:45 -0600
Message-Id: <1289912805-4143-1-git-send-email-steve@digidescorp.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: stable@kernel.org, linux-kernel@vger.kernel.org, gerg@snapgear.com, kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, "Steven J. Magnani" <steve@digidescorp.com>
List-ID: <linux-mm.kvack.org>

Depending on processor speed, page size, and the amount of memory a process
is allowed to amass, cleanup of a large VM may freeze the system for many
seconds. This can result in a watchdog timeout.

Make sure other tasks receive some service when cleaning up large VMs.

Signed-off-by: Steven J. Magnani <steve@digidescorp.com>
---
diff -uprN a/mm/nommu.c b/mm/nommu.c
--- a/mm/nommu.c	2010-11-15 07:53:45.000000000 -0600
+++ b/mm/nommu.c	2010-11-15 07:57:13.000000000 -0600
@@ -1668,6 +1668,7 @@ void exit_mmap(struct mm_struct *mm)
 		mm->mmap = vma->vm_next;
 		delete_vma_from_mm(vma);
 		delete_vma(mm, vma);
+		cond_resched();
 	}
 
 	kleave("");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
