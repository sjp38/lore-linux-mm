Date: Thu, 18 May 2006 11:21:21 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060518182121.20734.23985.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060518182111.20734.5489.sendpatchset@schroedinger.engr.sgi.com>
References: <20060518182111.20734.5489.sendpatchset@schroedinger.engr.sgi.com>
Subject: [RFC 2/5] page migration: handle freeing of pages in migrate_pages()
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@osdl.org, bls@sgi.com, jes@sgi.com, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <clameter@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Dispose of pages in migrate_pages()

Do not leave pages on the lists passed to migrate_pages(). Seems
that we will not need any postprocessing of pages. This will simplify
the handling of pages by the callers of migrate_pages().

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc4-mm1/mm/migrate.c
===================================================================
--- linux-2.6.17-rc4-mm1.orig/mm/migrate.c	2006-05-18 09:41:59.814842493 -0700
+++ linux-2.6.17-rc4-mm1/mm/migrate.c	2006-05-18 09:44:09.438655508 -0700
@@ -624,6 +624,15 @@ unlock:
 	unlock_page(page);
 ret:
 	if (rc != -EAGAIN) {
+ 		/*
+ 		 * A page that has been migrated has all references
+ 		 * removed and will be freed. A page that has not been
+ 		 * migrated will have kepts its references and be
+ 		 * restored.
+ 		 */
+ 		list_del(&page->lru);
+ 		move_to_lru(page);
+
 		list_del(&newpage->lru);
 		move_to_lru(newpage);
 	}
@@ -640,12 +649,12 @@ ret:
  *
  * The function returns after 10 attempts or if no pages
  * are movable anymore because to has become empty
- * or no retryable pages exist anymore.
+ * or no retryable pages exist anymore. All pages will be
+ * retruned to the LRU or freed.
  *
- * Return: Number of pages not migrated when "to" ran empty.
+ * Return: Number of pages not migrated.
  */
-int migrate_pages(struct list_head *from, struct list_head *to,
-		  struct list_head *moved, struct list_head *failed)
+int migrate_pages(struct list_head *from, struct list_head *to)
 {
 	int retry = 1;
 	int nr_failed = 0;
@@ -675,11 +684,9 @@ int migrate_pages(struct list_head *from
 				retry++;
 				break;
 			case 0:
-				list_move(&page->lru, moved);
 				break;
 			default:
 				/* Permanent failure */
-				list_move(&page->lru, failed);
 				nr_failed++;
 				break;
 			}
@@ -689,6 +696,7 @@ int migrate_pages(struct list_head *from
 	if (!swapwrite)
 		current->flags &= ~PF_SWAPWRITE;
 
+	putback_lru_pages(from);
 	return nr_failed + retry;
 }
 
@@ -702,11 +710,10 @@ int migrate_pages_to(struct list_head *p
 			struct vm_area_struct *vma, int dest)
 {
 	LIST_HEAD(newlist);
-	LIST_HEAD(moved);
-	LIST_HEAD(failed);
 	int err = 0;
 	unsigned long offset = 0;
 	int nr_pages;
+	int nr_failed = 0;
 	struct page *page;
 	struct list_head *p;
 
@@ -740,26 +747,17 @@ redo:
 		if (nr_pages > MIGRATE_CHUNK_SIZE)
 			break;
 	}
-	err = migrate_pages(pagelist, &newlist, &moved, &failed);
+	err = migrate_pages(pagelist, &newlist);
 
-	putback_lru_pages(&moved);	/* Call release pages instead ?? */
-
-	if (err >= 0 && list_empty(&newlist) && !list_empty(pagelist))
-		goto redo;
-out:
-	/* Return leftover allocated pages */
-	while (!list_empty(&newlist)) {
-		page = list_entry(newlist.next, struct page, lru);
-		list_del(&page->lru);
-		__free_page(page);
+	if (err >= 0) {
+		nr_failed += err;
+		if (list_empty(&newlist) && !list_empty(pagelist))
+			goto redo;
 	}
-	list_splice(&failed, pagelist);
-	if (err < 0)
-		return err;
+out:
 
 	/* Calculate number of leftover pages */
-	nr_pages = 0;
 	list_for_each(p, pagelist)
-		nr_pages++;
-	return nr_pages;
+		nr_failed++;
+	return nr_failed;
 }
Index: linux-2.6.17-rc4-mm1/include/linux/migrate.h
===================================================================
--- linux-2.6.17-rc4-mm1.orig/include/linux/migrate.h	2006-05-15 15:40:12.349655322 -0700
+++ linux-2.6.17-rc4-mm1/include/linux/migrate.h	2006-05-18 09:42:45.070830541 -0700
@@ -8,8 +8,7 @@ extern int isolate_lru_page(struct page 
 extern int putback_lru_pages(struct list_head *l);
 extern int migrate_page(struct address_space *,
 			struct page *, struct page *);
-extern int migrate_pages(struct list_head *l, struct list_head *t,
-		struct list_head *moved, struct list_head *failed);
+extern int migrate_pages(struct list_head *l, struct list_head *t);
 extern int migrate_pages_to(struct list_head *pagelist,
 			struct vm_area_struct *vma, int dest);
 extern int fail_migrate_page(struct address_space *,
@@ -22,8 +21,8 @@ extern int migrate_prep(void);
 static inline int isolate_lru_page(struct page *p, struct list_head *list)
 					{ return -ENOSYS; }
 static inline int putback_lru_pages(struct list_head *l) { return 0; }
-static inline int migrate_pages(struct list_head *l, struct list_head *t,
-	struct list_head *moved, struct list_head *failed) { return -ENOSYS; }
+static inline int migrate_pages(struct list_head *l, struct list_head *t)
+					{ return -ENOSYS; }
 
 static inline int migrate_pages_to(struct list_head *pagelist,
 			struct vm_area_struct *vma, int dest) { return 0; }
Index: linux-2.6.17-rc4-mm1/mm/mempolicy.c
===================================================================
--- linux-2.6.17-rc4-mm1.orig/mm/mempolicy.c	2006-05-15 15:40:13.211906469 -0700
+++ linux-2.6.17-rc4-mm1/mm/mempolicy.c	2006-05-18 09:42:45.071807043 -0700
@@ -603,11 +603,8 @@ int migrate_to_node(struct mm_struct *mm
 	check_range(mm, mm->mmap->vm_start, TASK_SIZE, &nmask,
 			flags | MPOL_MF_DISCONTIG_OK, &pagelist);
 
-	if (!list_empty(&pagelist)) {
+	if (!list_empty(&pagelist))
 		err = migrate_pages_to(&pagelist, NULL, dest);
-		if (!list_empty(&pagelist))
-			putback_lru_pages(&pagelist);
-	}
 	return err;
 }
 
@@ -773,9 +770,6 @@ long do_mbind(unsigned long start, unsig
 			err = -EIO;
 	}
 
-	if (!list_empty(&pagelist))
-		putback_lru_pages(&pagelist);
-
 	up_write(&mm->mmap_sem);
 	mpol_free(new);
 	return err;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
