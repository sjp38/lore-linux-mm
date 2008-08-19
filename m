From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Tue, 19 Aug 2008 17:05:45 -0400
Message-Id: <20080819210545.27199.5276.sendpatchset@lts-notebook>
In-Reply-To: <20080819210509.27199.6626.sendpatchset@lts-notebook>
References: <20080819210509.27199.6626.sendpatchset@lts-notebook>
Subject: [PATCH 6/6] Mlock:  make mlock error return Posixly Correct
Sender: owner-linux-mm@kvack.org
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: riel@redhat.com, linux-mm <linux-mm@kvack.org>, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Against:  2.6.27-rc3-mmotm-080816-0202

Rework Posix error return for mlock().

Translate get_user_pages() error to posix specified error codes.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/memory.c |    2 +-
 mm/mlock.c  |   27 ++++++++++++++++++++++++---
 2 files changed, 25 insertions(+), 4 deletions(-)

Index: linux-2.6.27-rc3-mmotm/mm/mlock.c
===================================================================
--- linux-2.6.27-rc3-mmotm.orig/mm/mlock.c	2008-08-18 15:57:11.000000000 -0400
+++ linux-2.6.27-rc3-mmotm/mm/mlock.c	2008-08-18 15:57:39.000000000 -0400
@@ -143,6 +143,18 @@ static void munlock_vma_page(struct page
 	}
 }
 
+/*
+ * convert get_user_pages() return value to posix mlock() error
+ */
+static int __mlock_posix_error_return(long retval)
+{
+	if (retval == -EFAULT)
+		retval = -ENOMEM;
+	else if (retval == -ENOMEM)
+		retval = -EAGAIN;
+	return retval;
+}
+
 /**
  * __mlock_vma_pages_range() -  mlock/munlock a range of pages in the vma.
  * @vma:   target vma
@@ -209,8 +221,13 @@ static long __mlock_vma_pages_range(stru
 		 * or for addresses that map beyond end of a file.
 		 * We'll mlock the the pages if/when they get faulted in.
 		 */
-		if (ret < 0)
+		if (ret < 0) {
+			if (vma->vm_flags & VM_NONLINEAR)
+				ret = 0;
+			else
+				ret = __mlock_posix_error_return(ret);
 			break;
+		}
 		if (ret == 0) {
 			/*
 			 * We know the vma is there, so the only time
@@ -248,6 +265,7 @@ static long __mlock_vma_pages_range(stru
 			addr += PAGE_SIZE;	/* for next get_user_pages() */
 			nr_pages--;
 		}
+		ret = 0;
 	}
 
 	lru_add_drain_all();	/* to update stats */
@@ -264,8 +282,11 @@ static long __mlock_vma_pages_range(stru
 				   unsigned long start, unsigned long end,
 				   int mlock)
 {
-	if (mlock && (vma->vm_flags & VM_LOCKED))
-		make_pages_present(start, end);
+	if (mlock && (vma->vm_flags & VM_LOCKED)) {
+		long retval = make_pages_present(start, end);
+		if (retval < 0)
+			return  __mlock_posix_error_return(retval);
+	}
 	return 0;
 }
 #endif /* CONFIG_UNEVICTABLE_LRU */
Index: linux-2.6.27-rc3-mmotm/mm/memory.c
===================================================================
--- linux-2.6.27-rc3-mmotm.orig/mm/memory.c	2008-08-18 15:57:11.000000000 -0400
+++ linux-2.6.27-rc3-mmotm/mm/memory.c	2008-08-18 15:57:39.000000000 -0400
@@ -2821,7 +2821,7 @@ int make_pages_present(unsigned long add
 			len, write, 0, NULL, NULL);
 	if (ret < 0)
 		return ret;
-	return ret == len ? 0 : -1;
+	return ret == len ? 0 : -EFAULT;
 }
 
 #if !defined(__HAVE_ARCH_GATE_AREA)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
