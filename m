Date: Thu, 30 Nov 2006 15:41:48 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 0/1] Node-based reclaim/migration
In-Reply-To: <6599ad830611301333v48f2da03g747c088ed3b4ad60@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0611301540390.13297@schroedinger.engr.sgi.com>
References: <20061129030655.941148000@menage.corp.google.com>
 <Pine.LNX.4.64.0611301027340.23649@schroedinger.engr.sgi.com>
 <6599ad830611301035u36a111dfye8c9414d257ebe07@mail.gmail.com>
 <Pine.LNX.4.64.0611301037590.23732@schroedinger.engr.sgi.com>
 <6599ad830611301109n8c4637ei338ecb4395c3702b@mail.gmail.com>
 <Pine.LNX.4.64.0611301139420.24215@schroedinger.engr.sgi.com>
 <6599ad830611301153i231765a0ke46846bcb73258d6@mail.gmail.com>
 <Pine.LNX.4.64.0611301158560.24331@schroedinger.engr.sgi.com>
 <6599ad830611301207q4e4ab485lb0d3c99680db5a2a@mail.gmail.com>
 <Pine.LNX.4.64.0611301211270.24331@schroedinger.engr.sgi.com>
 <6599ad830611301333v48f2da03g747c088ed3b4ad60@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

I think you initial suggestion of adding a counter to the anon_vma may 
work. Here is a patch that may allow us to keep the anon_vma around
without holding mmap_sem. Seems to be simple.

Hugh?

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
+++ linux-2.6.19-rc6-mm2/mm/migrate.c	2006-11-30 17:39:48.429639786 -0600
@@ -218,6 +218,7 @@ static void remove_anon_migration_ptes(s
 	struct anon_vma *anon_vma;
 	struct vm_area_struct *vma;
 	unsigned long mapping;
+	int empty;
 
 	mapping = (unsigned long)new->mapping;
 
@@ -229,11 +230,15 @@ static void remove_anon_migration_ptes(s
 	 */
 	anon_vma = (struct anon_vma *) (mapping - PAGE_MAPPING_ANON);
 	spin_lock(&anon_vma->lock);
+	anon_vma->migration_count--;
 
 	list_for_each_entry(vma, &anon_vma->head, anon_vma_node)
 		remove_migration_pte(vma, old, new);
 
+	empty = list_empty(&anon_vma->head);
 	spin_unlock(&anon_vma->lock);
+	if (empty)
+		anon_vma_free(anon_vma);
 }
 
 /*
Index: linux-2.6.19-rc6-mm2/mm/rmap.c
===================================================================
--- linux-2.6.19-rc6-mm2.orig/mm/rmap.c	2006-11-15 22:03:40.000000000 -0600
+++ linux-2.6.19-rc6-mm2/mm/rmap.c	2006-11-30 17:39:17.795109159 -0600
@@ -151,7 +151,7 @@ void anon_vma_unlink(struct vm_area_stru
 	list_del(&vma->anon_vma_node);
 
 	/* We must garbage collect the anon_vma if it's empty */
-	empty = list_empty(&anon_vma->head);
+	empty = list_empty(&anon_vma->head) && !anon_vma->migration_count;
 	spin_unlock(&anon_vma->lock);
 
 	if (empty)
@@ -787,6 +787,9 @@ static int try_to_unmap_anon(struct page
 	if (!anon_vma)
 		return ret;
 
+	if (migration)
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
