Date: Mon, 11 Aug 2008 16:08:47 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC PATCH for -mm 5/5] fix mlock return value for mm
In-Reply-To: <20080811151313.9456.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080811151313.9456.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080811160751.9465.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Now, __mlock_vma_pages_range() ignore return value of __get_user_pages().
We shouldn't do that.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 mm/mlock.c |   25 +++++++++++++++++++++----
 1 file changed, 21 insertions(+), 4 deletions(-)

Index: b/mm/mlock.c
===================================================================
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -165,8 +165,9 @@ static int __mlock_vma_pages_range(struc
 	unsigned long addr = start;
 	struct page *pages[16]; /* 16 gives a reasonable batch */
 	int nr_pages = (end - start) / PAGE_SIZE;
-	int ret;
+	int ret = 0;
 	int gup_flags = 0;
+	int ret2 = 0;
 
 	VM_BUG_ON(start & ~PAGE_MASK);
 	VM_BUG_ON(end   & ~PAGE_MASK);
@@ -249,9 +250,23 @@ static int __mlock_vma_pages_range(struc
 		}
 	}
 
+	/*
+	  SUSv3 require following return value to mlock
+	  - invalid addr generate to ENOMEM.
+	  - out of memory generate EAGAIN.
+	*/
+	if (ret < 0) {
+		if (ret == -EFAULT)
+			ret2 = -ENOMEM;
+		else if (ret == -ENOMEM)
+			ret2 = -EAGAIN;
+		else
+			ret2 = ret;
+	}
+
 	lru_add_drain_all();	/* to update stats */
 
-	return 0;	/* count entire vma as locked_vm */
+	return ret2;	/* count entire vma as locked_vm */
 }
 
 #else /* CONFIG_UNEVICTABLE_LRU */
@@ -263,9 +278,11 @@ static int __mlock_vma_pages_range(struc
 				   unsigned long start, unsigned long end,
 				   int mlock)
 {
+	int ret = 0;
+
 	if (mlock && (vma->vm_flags & VM_LOCKED))
-		make_pages_present(start, end);
-	return 0;
+		ret = make_pages_present(start, end);
+	return ret;
 }
 #endif /* CONFIG_UNEVICTABLE_LRU */
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
