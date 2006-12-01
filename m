Date: Thu, 30 Nov 2006 18:44:30 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 0/1] Node-based reclaim/migration
In-Reply-To: <20061201114414.0c90f649.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0611301843440.14268@schroedinger.engr.sgi.com>
References: <20061129030655.941148000@menage.corp.google.com>
 <Pine.LNX.4.64.0611301037590.23732@schroedinger.engr.sgi.com>
 <6599ad830611301109n8c4637ei338ecb4395c3702b@mail.gmail.com>
 <Pine.LNX.4.64.0611301139420.24215@schroedinger.engr.sgi.com>
 <6599ad830611301153i231765a0ke46846bcb73258d6@mail.gmail.com>
 <Pine.LNX.4.64.0611301158560.24331@schroedinger.engr.sgi.com>
 <6599ad830611301207q4e4ab485lb0d3c99680db5a2a@mail.gmail.com>
 <Pine.LNX.4.64.0611301211270.24331@schroedinger.engr.sgi.com>
 <6599ad830611301333v48f2da03g747c088ed3b4ad60@mail.gmail.com>
 <Pine.LNX.4.64.0611301540390.13297@schroedinger.engr.sgi.com>
 <6599ad830611301548y66e5e66eo2f61df940a66711a@mail.gmail.com>
 <20061201114414.0c90f649.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Paul Menage <menage@google.com>, hugh@veritas.com, linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

Fixed up patch with more comments and a check that the migration_count is
zero before freeing.

Index: linux-2.6.19-rc6-mm2/include/linux/rmap.h
===================================================================
--- linux-2.6.19-rc6-mm2.orig/include/linux/rmap.h	2006-11-15 22:03:40.000000000 -0600
+++ linux-2.6.19-rc6-mm2/include/linux/rmap.h	2006-11-30 17:39:17.643728656 -0600
@@ -26,6 +26,7 @@
 struct anon_vma {
 	spinlock_t lock;	/* Serialize access to vma list */
 	struct list_head head;	/* List of private "related" vmas */
+	int migration_count;	/* # processes migrating pages */
 };
 
 #ifdef CONFIG_MMU
Index: linux-2.6.19-rc6-mm2/mm/migrate.c
===================================================================
--- linux-2.6.19-rc6-mm2.orig/mm/migrate.c	2006-11-29 18:37:17.797934398 -0600
+++ linux-2.6.19-rc6-mm2/mm/migrate.c	2006-11-30 20:41:13.810836561 -0600
@@ -209,15 +209,12 @@ static void remove_file_migration_ptes(s
 	spin_unlock(&mapping->i_mmap_lock);
 }
 
-/*
- * Must hold mmap_sem lock on at least one of the vmas containing
- * the page so that the anon_vma cannot vanish.
- */
 static void remove_anon_migration_ptes(struct page *old, struct page *new)
 {
 	struct anon_vma *anon_vma;
 	struct vm_area_struct *vma;
 	unsigned long mapping;
+	int empty;
 
 	mapping = (unsigned long)new->mapping;
 
@@ -225,15 +222,20 @@ static void remove_anon_migration_ptes(s
 		return;
 
 	/*
-	 * We hold the mmap_sem lock. So no need to call page_lock_anon_vma.
+	 * We have increased migration_count So no need to call
+	 * page_lock_anon_vma.
 	 */
 	anon_vma = (struct anon_vma *) (mapping - PAGE_MAPPING_ANON);
 	spin_lock(&anon_vma->lock);
+	anon_vma->migration_count--;
 
 	list_for_each_entry(vma, &anon_vma->head, anon_vma_node)
 		remove_migration_pte(vma, old, new);
 
+	empty = list_empty(&anon_vma->head) && !anon_vma->migration_count;
 	spin_unlock(&anon_vma->lock);
+	if (empty)
+		anon_vma_free(anon_vma);
 }
 
 /*
Index: linux-2.6.19-rc6-mm2/mm/rmap.c
===================================================================
--- linux-2.6.19-rc6-mm2.orig/mm/rmap.c	2006-11-15 22:03:40.000000000 -0600
+++ linux-2.6.19-rc6-mm2/mm/rmap.c	2006-11-30 20:39:52.266554217 -0600
@@ -150,8 +150,8 @@ void anon_vma_unlink(struct vm_area_stru
 	validate_anon_vma(vma);
 	list_del(&vma->anon_vma_node);
 
-	/* We must garbage collect the anon_vma if it's empty */
-	empty = list_empty(&anon_vma->head);
+	/* We must garbage collect the anon_vma if it's unused  */
+	empty = list_empty(&anon_vma->head) && !anon_vma->migration_count;
 	spin_unlock(&anon_vma->lock);
 
 	if (empty)
@@ -787,6 +787,10 @@ static int try_to_unmap_anon(struct page
 	if (!anon_vma)
 		return ret;
 
+	if (migration)
+		/* Prevent freeing while migrating pages */
+		anon_vma->migration_count++;
+
 	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
 		ret = try_to_unmap_one(page, vma, migration);
 		if (ret == SWAP_FAIL || !page_mapped(page))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
