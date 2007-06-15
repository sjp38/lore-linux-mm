Date: Fri, 15 Jun 2007 11:20:31 -0400 (EDT)
From: Jason Baron <jbaron@redhat.com>
Subject: [PATCH] madvise_need_mmap_write() usage
Message-ID: <Pine.LNX.4.64.0706151118150.11498@dhcp83-20.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, nickpiggin@yahoo.com.au, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

hi,

i was just looking at the new madvise_need_mmap_write() call...can we
avoid an extra case statement and function call as follows?

thanks,

-Jason


Signed-off-by: Jason Baron <jbaron@redhat.com>

diff --git a/mm/madvise.c b/mm/madvise.c
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -287,9 +287,10 @@ asmlinkage long sys_madvise(unsigned long start, size_t len_in, int behavior)
 	struct vm_area_struct * vma, *prev;
 	int unmapped_error = 0;
 	int error = -EINVAL;
+	int write;
 	size_t len;
 
-	if (madvise_need_mmap_write(behavior))
+	if (write = madvise_need_mmap_write(behavior))
 		down_write(&current->mm->mmap_sem);
 	else
 		down_read(&current->mm->mmap_sem);
@@ -354,7 +355,7 @@ asmlinkage long sys_madvise(unsigned long start, size_t len_in, int behavior)
 			vma = find_vma(current->mm, start);
 	}
 out:
-	if (madvise_need_mmap_write(behavior))
+	if (write)
 		up_write(&current->mm->mmap_sem);
 	else
 		up_read(&current->mm->mmap_sem);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
