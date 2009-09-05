Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 1F4EA6B0083
	for <linux-mm@kvack.org>; Sat,  5 Sep 2009 17:27:22 -0400 (EDT)
Date: Sat, 5 Sep 2009 22:26:48 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH 3/3] ksm: mremap use err from ksm_madvise
In-Reply-To: <Pine.LNX.4.64.0909052219580.7381@sister.anvils>
Message-ID: <Pine.LNX.4.64.0909052225250.7387@sister.anvils>
References: <Pine.LNX.4.64.0909052219580.7381@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

mremap move's use of ksm_madvise() was assuming -ENOMEM on failure,
because ksm_madvise used to say -EAGAIN for that; but ksm_madvise now
says -ENOMEM (letting madvise convert that to -EAGAIN), and can also
say -ERESTARTSYS when signalled: so pass the error from ksm_madvise.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 mm/mremap.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

--- mmotm/mm/mremap.c	2009-09-05 14:40:16.000000000 +0100
+++ linux/mm/mremap.c	2009-09-05 16:41:55.000000000 +0100
@@ -175,6 +175,7 @@ static unsigned long move_vma(struct vm_
 	unsigned long excess = 0;
 	unsigned long hiwater_vm;
 	int split = 0;
+	int err;
 
 	/*
 	 * We'd prefer to avoid failure later on in do_munmap:
@@ -190,9 +191,10 @@ static unsigned long move_vma(struct vm_
 	 * pages recently unmapped.  But leave vma->vm_flags as it was,
 	 * so KSM can come around to merge on vma and new_vma afterwards.
 	 */
-	if (ksm_madvise(vma, old_addr, old_addr + old_len,
-						MADV_UNMERGEABLE, &vm_flags))
-		return -ENOMEM;
+	err = ksm_madvise(vma, old_addr, old_addr + old_len,
+						MADV_UNMERGEABLE, &vm_flags);
+	if (err)
+		return err;
 
 	new_pgoff = vma->vm_pgoff + ((old_addr - vma->vm_start) >> PAGE_SHIFT);
 	new_vma = copy_vma(&vma, new_addr, new_len, new_pgoff);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
