Date: Mon, 11 Aug 2008 16:07:48 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC PATCH for -mm 4/5] fix mlock return value at munmap race
In-Reply-To: <20080811151313.9456.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080811151313.9456.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080811160642.9462.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Now, We call downgrade_write(&mm->mmap_sem) at begin of mlock.
It increase mlock scalability.

But if mlock and munmap conflict happend, We can find vma gone.
At that time, kernel should return ENOMEM because mlock after munmap return ENOMEM.
(in addition, EAGAIN indicate "please try again", but mlock() called again cause error again)

This problem is theoretical issue.
I can't reproduce that vma gone on my box, but fixes is better.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 mm/mlock.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: b/mm/mlock.c
===================================================================
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -296,7 +296,7 @@ int mlock_vma_pages_range(struct vm_area
 		vma = find_vma(mm, start);
 		/* non-NULL vma must contain @start, but need to check @end */
 		if (!vma ||  end > vma->vm_end)
-			return -EAGAIN;
+			return -ENOMEM;
 		return error;
 	}
 
@@ -410,7 +410,7 @@ success:
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
