Date: Thu, 18 May 2006 11:21:37 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060518182137.20734.98683.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060518182111.20734.5489.sendpatchset@schroedinger.engr.sgi.com>
References: <20060518182111.20734.5489.sendpatchset@schroedinger.engr.sgi.com>
Subject: [RFC 5/5] page migration: Detailed status for moving of individual pages
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@osdl.org, bls@sgi.com, jes@sgi.com, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <clameter@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Detailed results for sys_move_pages()

Pass a pointer to an integer to get_new_page() that may be used
to indicate where the completion status of a migration operation should
be placed. This allows sys_move_pags() to report back exactly what
happened to each page.

Wish there would be a better way to do this. Looks a bit hacky.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc4-mm1/mm/migrate.c
===================================================================
--- linux-2.6.17-rc4-mm1.orig/mm/migrate.c	2006-05-18 10:02:04.586936931 -0700
+++ linux-2.6.17-rc4-mm1/mm/migrate.c	2006-05-18 10:06:17.159186880 -0700
@@ -589,7 +589,8 @@ static int unmap_and_move(new_page_t get
 			struct page *page, int force)
 {
 	int rc = 0;
-	struct page *newpage = get_new_page(page, private);
+	int *result = NULL;
+	struct page *newpage = get_new_page(page, private, &result);
 
 	if (!newpage)
 		return -ENOMEM;
@@ -643,6 +644,12 @@ move_newpage:
 	 * then this will free the page.
 	 */
 	move_to_lru(newpage);
+	if (result) {
+		if (rc)
+			*result = rc;
+		else
+			*result = page_to_nid(newpage);
+	}
 	return rc;
 }
 
@@ -721,7 +728,8 @@ struct page_to_node {
 	int status;
 };
 
-static struct page *new_page_node(struct page *p, unsigned long private)
+static struct page *new_page_node(struct page *p, unsigned long private,
+		int **result)
 {
 	struct page_to_node *pm = (struct page_to_node *)private;
 
@@ -731,6 +739,8 @@ static struct page *new_page_node(struct
 	if (!pm->page)
 		return NULL;
 
+	*result = &pm->status;
+
 	return alloc_pages_node(pm->node, GFP_HIGHUSER, 0);
 }
 
@@ -847,7 +857,7 @@ asmlinkage long sys_move_pages(int pid, 
 			goto remove;
 
 		pm[i].node = node;
-		err = 0;
+		err = -EAGAIN;
 		if (node != page_to_nid(page))
 			goto set_status;
 
Index: linux-2.6.17-rc4-mm1/mm/mempolicy.c
===================================================================
--- linux-2.6.17-rc4-mm1.orig/mm/mempolicy.c	2006-05-18 09:48:12.491970088 -0700
+++ linux-2.6.17-rc4-mm1/mm/mempolicy.c	2006-05-18 10:05:00.079975821 -0700
@@ -588,7 +588,7 @@ static void migrate_page_add(struct page
 		isolate_lru_page(page, pagelist);
 }
 
-static struct page *new_node_page(struct page *page, unsigned long node)
+static struct page *new_node_page(struct page *page, unsigned long node, int **x)
 {
 	return alloc_pages_node(node, GFP_HIGHUSER, 0);
 }
@@ -698,7 +698,7 @@ int do_migrate_pages(struct mm_struct *m
 
 }
 
-static struct page *new_vma_page(struct page *page, unsigned long private)
+static struct page *new_vma_page(struct page *page, unsigned long private, int **x)
 {
 	struct vm_area_struct *vma = (struct vm_area_struct *)private;
 
Index: linux-2.6.17-rc4-mm1/include/linux/migrate.h
===================================================================
--- linux-2.6.17-rc4-mm1.orig/include/linux/migrate.h	2006-05-18 09:48:12.493923092 -0700
+++ linux-2.6.17-rc4-mm1/include/linux/migrate.h	2006-05-18 10:05:00.080952323 -0700
@@ -3,7 +3,7 @@
 
 #include <linux/mm.h>
 
-typedef struct page *new_page_t(struct page *, unsigned long private);
+typedef struct page *new_page_t(struct page *, unsigned long private, int **);
 
 #ifdef CONFIG_MIGRATION
 extern int isolate_lru_page(struct page *p, struct list_head *pagelist);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
