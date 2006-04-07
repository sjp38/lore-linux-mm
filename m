Received: from smtp1.fc.hp.com (smtp1.fc.hp.com [15.15.136.127])
	by atlrel7.hp.com (Postfix) with ESMTP id C88DC3449B
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 16:24:40 -0400 (EDT)
Received: from ldl.fc.hp.com (linux-bugs.fc.hp.com [15.11.146.30])
	by smtp1.fc.hp.com (Postfix) with ESMTP id A59BA109BD
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 20:24:40 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
	by ldl.fc.hp.com (Postfix) with ESMTP id 81697134250
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 14:24:40 -0600 (MDT)
Received: from ldl.fc.hp.com ([127.0.0.1])
	by localhost (ldl [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
	id 21502-02 for <linux-mm@kvack.org>;
	Fri, 7 Apr 2006 14:24:38 -0600 (MDT)
Received: from [16.116.101.121] (unknown [16.116.101.121])
	by ldl.fc.hp.com (Postfix) with ESMTP id 32218134225
	for <linux-mm@kvack.org>; Fri,  7 Apr 2006 14:24:38 -0600 (MDT)
Subject: Re: [PATCH 2.6.17-rc1-mm1 5/6] Migrate-on-fault - add MPOL_MF_LAZY
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <1144441108.5198.36.camel@localhost.localdomain>
References: <1144441108.5198.36.camel@localhost.localdomain>
Content-Type: text/plain
Date: Fri, 07 Apr 2006 16:26:02 -0400
Message-Id: <1144441563.5198.47.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Migrate-on-fault prototype 5/6 V0.2 - add MPOL_MF_LAZY

V0.2 - reworked against 2.6.17-rc1 with Christoph's migration code
       reorg.  Moved migrate_pages_unmap_only() to mm/migrate.c

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

Index: linux-2.6.17-rc1/include/linux/mempolicy.h
===================================================================
--- linux-2.6.17-rc1.orig/include/linux/mempolicy.h	2006-04-03 12:10:45.000000000 -0400
+++ linux-2.6.17-rc1/include/linux/mempolicy.h	2006-04-03 12:12:30.000000000 -0400
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
 
@@ -180,7 +185,7 @@ int do_migrate_pages(struct mm_struct *m
  */
 #define MPOL_MIGRATE_NONINTERLEAVED 1
 #define MPOL_MIGRATE_INTERLEAVED 2
-#define misplaced_is_interleaved(pol) (MPOL_MIGRATE_INTERLEAVED - 1)
+#define misplaced_is_interleaved(pol) (pol == MPOL_MIGRATE_INTERLEAVED)
 
 int mpol_misplaced(struct page *, struct vm_area_struct *,
 		unsigned long, int *);
Index: linux-2.6.17-rc1/mm/mempolicy.c
===================================================================
--- linux-2.6.17-rc1.orig/mm/mempolicy.c	2006-04-03 12:10:45.000000000 -0400
+++ linux-2.6.17-rc1/mm/mempolicy.c	2006-04-03 12:12:30.000000000 -0400
@@ -718,9 +718,7 @@ long do_mbind(unsigned long start, unsig
 	int err;
 	LIST_HEAD(pagelist);
 
-	if ((flags & ~(unsigned long)(MPOL_MF_STRICT |
-				      MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
-	    || mode > MPOL_MAX)
+	if ((flags & ~(unsigned long)MPOL_MF_VALID) || mode > MPOL_MAX)
 		return -EINVAL;
 	if ((flags & MPOL_MF_MOVE_ALL) && !capable(CAP_SYS_NICE))
 		return -EPERM;
@@ -766,8 +764,13 @@ long do_mbind(unsigned long start, unsig
 
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
Index: linux-2.6.17-rc1/include/linux/migrate.h
===================================================================
--- linux-2.6.17-rc1.orig/include/linux/migrate.h	2006-04-03 12:10:45.000000000 -0400
+++ linux-2.6.17-rc1/include/linux/migrate.h	2006-04-03 12:12:30.000000000 -0400
@@ -17,6 +17,7 @@ extern int migrate_pages(struct list_hea
 extern int migrate_pages_to(struct list_head *pagelist,
 			struct vm_area_struct *vma, int dest);
 struct page *migrate_misplaced_page(struct page *, int, int);
+extern int migrate_pages_unmap_only(struct list_head *);
 extern int fail_migrate_page(struct page *, struct page *, int);
 
 extern int migrate_prep(void);
Index: linux-2.6.17-rc1/mm/migrate.c
===================================================================
--- linux-2.6.17-rc1.orig/mm/migrate.c	2006-04-03 12:10:45.000000000 -0400
+++ linux-2.6.17-rc1/mm/migrate.c	2006-04-03 12:12:30.000000000 -0400
@@ -567,6 +567,66 @@ next:
 
 	return nr_failed + retry;
 }
+/*
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
 
 /*
  * Migration function for pages with buffers. This function can only be used


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
