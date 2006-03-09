Subject: [PATCH/RFC] Migrate-on-fault prototype 5/5 V0.1 - add MPOL_MF_LAZY
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reply-To: lee.schermerhorn@hp.com
Content-Type: text/plain
Date: Thu, 09 Mar 2006 16:54:42 -0500
Message-Id: <1141941282.8326.11.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

I never saw this one hit the list.

Migrate-on-fault prototype 5/5 V0.1 - add MPOL_MF_LAZY

This patch adds another mbind() flag to request "lazy migration".
The flag, MPOL_MF_LAZY, modifies MPOL_MF_MOVE* such that the selected
pages are simply unmapped from the calling task's page table ['_MOVE]
or from all referencing page tables [_MOVE_ALL].  Anon pages will first
be added to the swap [or migration?] cache, if necessary.  The pages
will be migrated in the fault path on "first touch", if the policy
dictates at that time.

"Lazy Migration" will allow testing of migrate-on-fault.  If useful to
applications, it could become a permanent part of the mbind() interface. 
Yes, it does duplicate some of the code in migrate_pages().  However,
lazy migration doesn't need to do all that migrate_pages() does, nor
does it need to try as hard.  Trying to weave both functions into
migrate_pages() could probably be done, but that could  result in fairly
ugly code. 

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: linux-2.6.16-rc5-git8/include/linux/mempolicy.h
===================================================================
--- linux-2.6.16-rc5-git8.orig/include/linux/mempolicy.h	2006-03-08 14:51:40.000000000 -0500
+++ linux-2.6.16-rc5-git8/include/linux/mempolicy.h	2006-03-08 14:52:56.000000000 -0500
@@ -22,9 +22,14 @@
 
 /* Flags for mbind */
 #define MPOL_MF_STRICT	(1<<0)	/* Verify existing pages in the mapping */
-#define MPOL_MF_MOVE	(1<<1)	/* Move pages owned by this process to conform to mapping */
-#define MPOL_MF_MOVE_ALL (1<<2)	/* Move every page to conform to mapping */
-#define MPOL_MF_INTERNAL (1<<3)	/* Internal flags start here */
+#define MPOL_MF_MOVE	(1<<1)	/* Move pages owned by this process to conform
+				   to policy */
+#define MPOL_MF_MOVE_ALL (1<<2)	/* Move every page to conform to policy */
+#define MPOL_MF_LAZY	(1<<3)	/* Modifies '_MOVE:  lazy migrate on fault */
+#define MPOL_MF_INTERNAL (1<<4)	/* Internal flags start here */
+
+#define MPOL_MF_VALID \
+	(MPOL_MF_STRICT | MPOL_MF_MOVE | MPOL_MF_MOVE_ALL | MPOL_MF_LAZY)
 
 #ifdef __KERNEL__
 
@@ -179,7 +184,7 @@ int do_migrate_pages(struct mm_struct *m
  */
 #define MPOL_MIGRATE_NONINTERLEAVED 1
 #define MPOL_MIGRATE_INTERLEAVED 2
-#define misplaced_is_interleaved(pol) (MPOL_MIGRATE_INTERLEAVED - 1)
+#define misplaced_is_interleaved(pol) (pol == MPOL_MIGRATE_INTERLEAVED)
 
 int mpol_misplaced(struct page *, struct vm_area_struct *,
 		unsigned long, int *);
Index: linux-2.6.16-rc5-git8/mm/vmscan.c
===================================================================
--- linux-2.6.16-rc5-git8.orig/mm/vmscan.c	2006-03-08 14:52:38.000000000 -0500
+++ linux-2.6.16-rc5-git8/mm/vmscan.c	2006-03-08 14:52:56.000000000 -0500
@@ -1073,6 +1073,67 @@ next:
 }
 
 /*
+ * Lazy migration:  just unmap pages, moving anon pages to swap cache, if
+ * necessary.  Migration will occur, if policy dictates, when a task faults
+ * an unmapped page back into its page table--i.e., on "first touch" after
+ * unmapping.
+ *
+ * Successfully unmapped pages will be put back on the LRU.  Failed pages
+ * will be left on the argument pagelist for the caller to handle, like
+ * migrate_pages[_to]().
+ */
+int migrate_pages_unmap_only(struct list_head *pagelist)
+{
+	struct page *page;
+	struct page *page2;
+	int nr_failed = 0, nr_unmapped = 0;
+
+	list_for_each_entry_safe(page, page2, pagelist, lru) {
+		int nr_refs;
+
+		/*
+		 * Give up easily.  We are being lazy.
+		 */
+		if (page_count(page) == 1 || TestSetPageLocked(page))
+			continue;
+
+		if (PageWriteback(page))
+			goto unlock_page;
+
+		if (PageAnon(page) && !PageSwapCache(page)) {
+			if (!add_to_swap(page, GFP_KERNEL)) {
+				goto unlock_page;
+			}
+		}
+
+		if (page_has_buffers(page))
+			nr_refs = 3;	/* cache, bufs and current */
+		else
+			nr_refs = 2;	/* cache and current */
+
+		if (migrate_page_try_to_unmap(page, nr_refs)) {
+			++nr_failed;
+			goto unlock_page;
+		}
+
+		++nr_unmapped;
+		move_to_lru(page);
+
+	unlock_page:
+		unlock_page(page);
+
+	}
+
+	/*
+	 * so fault path can find them on lru
+	 */
+	if (nr_unmapped)
+		lru_add_drain_all();
+
+	return nr_failed;
+}
+
+/*
  * Isolate one page from the LRU lists.
  * Adds a reference count for caller.
  *
Index: linux-2.6.16-rc5-git8/mm/mempolicy.c
===================================================================
--- linux-2.6.16-rc5-git8.orig/mm/mempolicy.c	2006-03-08 14:51:40.000000000 -0500
+++ linux-2.6.16-rc5-git8/mm/mempolicy.c	2006-03-08 14:52:56.000000000 -0500
@@ -744,9 +744,7 @@ long do_mbind(unsigned long start, unsig
 	int err;
 	LIST_HEAD(pagelist);
 
-	if ((flags & ~(unsigned long)(MPOL_MF_STRICT |
-				      MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
-	    || mode > MPOL_MAX)
+	if ((flags & ~(unsigned long)MPOL_MF_VALID) || mode > MPOL_MAX)
 		return -EINVAL;
 	if ((flags & MPOL_MF_MOVE_ALL) && !capable(CAP_SYS_RESOURCE))
 		return -EPERM;
@@ -792,8 +790,13 @@ long do_mbind(unsigned long start, unsig
 
 		err = mbind_range(vma, start, end, new);
 
-		if (!list_empty(&pagelist))
-			nr_failed = migrate_pages_to(&pagelist, vma, -1);
+		if (!list_empty(&pagelist)) {
+			if (!(flags & MPOL_MF_LAZY))
+				nr_failed = migrate_pages_to(&pagelist,
+								 vma, -1);
+			else
+				nr_failed = migrate_pages_unmap_only(&pagelist);
+		}
 
 		if (!err && nr_failed && (flags & MPOL_MF_STRICT))
 			err = -EIO;
Index: linux-2.6.16-rc5-git8/include/linux/swap.h
===================================================================
--- linux-2.6.16-rc5-git8.orig/include/linux/swap.h	2006-03-08 14:51:40.000000000 -0500
+++ linux-2.6.16-rc5-git8/include/linux/swap.h	2006-03-08 14:52:56.000000000 -0500
@@ -199,6 +199,7 @@ extern int migrate_page_unmap_and_replac
 extern int migrate_pages(struct list_head *l, struct list_head *t,
 		struct list_head *moved, struct list_head *failed);
 struct page *migrate_misplaced_page(struct page *, int, int);
+extern int migrate_pages_unmap_only(struct list_head *);
 extern int fail_migrate_page(struct page *, struct page *, int);
 #else
 static inline int isolate_lru_page(struct page *p) { return -ENOSYS; }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
