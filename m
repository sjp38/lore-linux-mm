From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 22 Aug 2008 17:10:53 -0400
Message-Id: <20080822211053.29898.60401.sendpatchset@murky.usa.hp.com>
In-Reply-To: <20080822211028.29898.82599.sendpatchset@murky.usa.hp.com>
References: <20080822211028.29898.82599.sendpatchset@murky.usa.hp.com>
Subject: [PATCH 4/7] Mlock:  fix return value for munmap/mlock vma race
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: riel@redhat.com, linux-mm <linux-mm@kvack.org>, kosaki.motohiro@jp.fujitsu.com, Eric.Whitney@hp.com
List-ID: <linux-mm.kvack.org>

atop patch:
	mmap-handle-mlocked-pages-during-map-remap-unmap.patch
with locked_vm adjustment backout patch.

Now, We call downgrade_write(&mm->mmap_sem) at begin of mlock.
It increase mlock scalability.

But if mlock and munmap conflict happend, We can find vma gone.
At that time, kernel should return ENOMEM because mlock after munmap return ENOMEM.
(in addition, EAGAIN indicate "please try again", but mlock() called again cause error again)

This problem is theoretical issue.
I can't reproduce that vma gone on my box, but fixes is better.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

 mm/mlock.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6.27-rc4-mmotm/mm/mlock.c
===================================================================
--- linux-2.6.27-rc4-mmotm.orig/mm/mlock.c	2008-08-21 11:37:45.000000000 -0400
+++ linux-2.6.27-rc4-mmotm/mm/mlock.c	2008-08-21 11:58:05.000000000 -0400
@@ -283,7 +283,7 @@ long mlock_vma_pages_range(struct vm_are
 		vma = find_vma(mm, start);
 		/* non-NULL vma must contain @start, but need to check @end */
 		if (!vma ||  end > vma->vm_end)
-			return -EAGAIN;
+			return -ENOMEM;
 
 		return 0;	/* hide other errors from mmap(), et al */
 	}
@@ -405,7 +405,7 @@ success:
 		*prev = find_vma(mm, start);
 		/* non-NULL *prev must contain @start, but need to check @end */
 		if (!(*prev) || end > (*prev)->vm_end)
-			ret = -EAGAIN;
+			ret = -ENOMEM;
 	} else {
 		/*
 		 * TODO:  for unlocking, pages will already be resident, so

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
