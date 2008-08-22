From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 22 Aug 2008 17:11:13 -0400
Message-Id: <20080822211113.29898.30218.sendpatchset@murky.usa.hp.com>
In-Reply-To: <20080822211028.29898.82599.sendpatchset@murky.usa.hp.com>
References: <20080822211028.29898.82599.sendpatchset@murky.usa.hp.com>
Subject: [PATCH 7/7] Mlock:  make mlock error return Posixly Correct
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: riel@redhat.com, linux-mm <linux-mm@kvack.org>, kosaki.motohiro@jp.fujitsu.com, Eric.Whitney@hp.com
List-ID: <linux-mm.kvack.org>

Rework Posix error return for mlock().

Posix requires error code for mlock*() system calls for
some conditions that differ from what kernel low level
functions, such as get_user_pages(), return for those
conditions.  For more info, see:

http://marc.info/?l=linux-kernel&m=121750892930775&w=2

This patch provides the same translation of get_user_pages()
error codes to posix specified error codes in the context
of the mlock rework for unevictable lru.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/memory.c |    2 +-
 mm/mlock.c  |   27 +++++++++++++++++++++------
 2 files changed, 22 insertions(+), 7 deletions(-)

Index: linux-2.6.27-rc4-mmotm/mm/mlock.c
===================================================================
--- linux-2.6.27-rc4-mmotm.orig/mm/mlock.c	2008-08-21 12:06:04.000000000 -0400
+++ linux-2.6.27-rc4-mmotm/mm/mlock.c	2008-08-21 12:06:08.000000000 -0400
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
@@ -248,11 +260,12 @@ static long __mlock_vma_pages_range(stru
 			addr += PAGE_SIZE;	/* for next get_user_pages() */
 			nr_pages--;
 		}
+		ret = 0;
 	}
 
 	lru_add_drain_all();	/* to update stats */
 
-	return 0;	/* count entire vma as locked_vm */
+	return ret;	/* count entire vma as locked_vm */
 }
 
 #else /* CONFIG_UNEVICTABLE_LRU */
@@ -265,7 +278,7 @@ static long __mlock_vma_pages_range(stru
 				   int mlock)
 {
 	if (mlock && (vma->vm_flags & VM_LOCKED))
-		make_pages_present(start, end);
+		return make_pages_present(start, end);
 	return 0;
 }
 #endif /* CONFIG_UNEVICTABLE_LRU */
@@ -423,10 +436,7 @@ success:
 		downgrade_write(&mm->mmap_sem);
 
 		ret = __mlock_vma_pages_range(vma, start, end, 1);
-		if (ret > 0) {
-			mm->locked_vm -= ret;
-			ret = 0;
-		}
+
 		/*
 		 * Need to reacquire mmap sem in write mode, as our callers
 		 * expect this.  We have no support for atomically upgrading
@@ -440,6 +450,11 @@ success:
 		/* non-NULL *prev must contain @start, but need to check @end */
 		if (!(*prev) || end > (*prev)->vm_end)
 			ret = -ENOMEM;
+		else if (ret > 0) {
+			mm->locked_vm -= ret;
+			ret = 0;
+		} else
+			ret = __mlock_posix_error_return(ret); /* translate if needed */
 	} else {
 		/*
 		 * TODO:  for unlocking, pages will already be resident, so
Index: linux-2.6.27-rc4-mmotm/mm/memory.c
===================================================================
--- linux-2.6.27-rc4-mmotm.orig/mm/memory.c	2008-08-21 12:06:04.000000000 -0400
+++ linux-2.6.27-rc4-mmotm/mm/memory.c	2008-08-21 12:06:08.000000000 -0400
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
