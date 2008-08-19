From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Tue, 19 Aug 2008 17:05:33 -0400
Message-Id: <20080819210533.27199.32744.sendpatchset@lts-notebook>
In-Reply-To: <20080819210509.27199.6626.sendpatchset@lts-notebook>
References: <20080819210509.27199.6626.sendpatchset@lts-notebook>
Subject: [PATCH 4/6] Mlock:  fix return value for munmap/mlock vma race
Sender: owner-linux-mm@kvack.org
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: riel@redhat.com, linux-mm <linux-mm@kvack.org>, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Against 2.6.27-rc3-mmotm-080819-0259

Now, We call downgrade_write(&mm->mmap_sem) at begin of mlock.
It increase mlock scalability.

But if mlock and munmap conflict happend, We can find vma gone.
At that time, kernel should return ENOMEM because mlock after munmap return ENOMEM.
(in addition, EAGAIN indicate "please try again", but mlock() called again cause error again)

This problem is theoretical issue.
I can't reproduce that vma gone on my box, but fixes is better.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/mlock.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6.27-rc3-mmotm/mm/mlock.c
===================================================================
--- linux-2.6.27-rc3-mmotm.orig/mm/mlock.c	2008-08-18 14:50:05.000000000 -0400
+++ linux-2.6.27-rc3-mmotm/mm/mlock.c	2008-08-18 14:50:26.000000000 -0400
@@ -268,7 +268,7 @@ long mlock_vma_pages_range(struct vm_are
 		vma = find_vma(mm, start);
 		/* non-NULL vma must contain @start, but need to check @end */
 		if (!vma ||  end > vma->vm_end)
-			return -EAGAIN;
+			return -ENOMEM;
 		return nr_pages;
 	}
 
@@ -389,7 +389,7 @@ success:
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
