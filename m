Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 99C176B01F4
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 12:59:51 -0400 (EDT)
Date: Mon, 26 Apr 2010 12:33:03 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH] mmap: check ->vm_ops before dereferencing
Message-ID: <20100426123303.5ef4ac01@annuminas.surriel.com>
In-Reply-To: <20100426100305.GP29093@bicker>
References: <20100426100305.GP29093@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Carpenter <error27@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Check whether the VMA has a vm_ops before calling close, just
like we check vm_ops before calling open a few dozen lines
higher up in the function.

Signed-off-by: Rik van Riel <riel@redhat.com>
Reported-by: Dan Carpenter <error27@gmail.com>

diff --git a/mm/mmap.c b/mm/mmap.c
index f90ea92..456ec6f 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1977,7 +1977,8 @@ static int __split_vma(struct mm_struct * mm, struct vm_area_struct * vma,
 		return 0;
 
 	/* Clean everything up if vma_adjust failed. */
-	new->vm_ops->close(new);
+	if (new->vm_ops && new->vm_ops->close)
+		new->vm_ops->close(new);
 	if (new->vm_file) {
 		if (vma->vm_flags & VM_EXECUTABLE)
 			removed_exe_file_vma(mm);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
