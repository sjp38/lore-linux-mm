Date: Mon, 11 Aug 2008 16:04:21 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC PATCH for -mm 1/5]  mlock() fix return values for mainline
In-Reply-To: <20080811151313.9456.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080811151313.9456.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080811160128.9459.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

following patch is the same to http://marc.info/?l=linux-kernel&m=121750892930775&w=2
and it already stay in linus-tree.

but it is not merged in 2.6.27-rc1-mm1.

So, please apply it first.



-----------------------------------------------

---
 mm/memory.c |   16 +++++++++++++---
 mm/mlock.c  |    2 --
 2 files changed, 13 insertions(+), 5 deletions(-)

Index: b/mm/memory.c
===================================================================
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2814,16 +2814,26 @@ int make_pages_present(unsigned long add
 
 	vma = find_vma(current->mm, addr);
 	if (!vma)
-		return -1;
+		return -ENOMEM;
 	write = (vma->vm_flags & VM_WRITE) != 0;
 	BUG_ON(addr >= end);
 	BUG_ON(end > vma->vm_end);
 	len = DIV_ROUND_UP(end, PAGE_SIZE) - addr/PAGE_SIZE;
 	ret = get_user_pages(current, current->mm, addr,
 			len, write, 0, NULL, NULL);
-	if (ret < 0)
+	if (ret < 0) {
+		/*
+		   SUS require strange return value to mlock
+		    - invalid addr generate to ENOMEM.
+		    - out of memory should generate EAGAIN.
+		*/
+		if (ret == -EFAULT)
+			ret = -ENOMEM;
+		else if (ret == -ENOMEM)
+			ret = -EAGAIN;
 		return ret;
-	return ret == len ? 0 : -1;
+	}
+	return ret == len ? 0 : -ENOMEM;
 }
 
 #if !defined(__HAVE_ARCH_GATE_AREA)
Index: b/mm/mlock.c
===================================================================
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -425,8 +425,6 @@ success:
 
 out:
 	*prev = vma;
-	if (ret == -ENOMEM)
-		ret = -EAGAIN;
 	return ret;
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
