Date: Thu, 3 Mar 2005 11:07:34 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: no page_cache_get in do_wp_page?
Message-ID: <Pine.LNX.4.58.0503031104500.9773@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@osdl.org
List-ID: <linux-mm.kvack.org>

We do a page_cache_get in do_wp_page but we check the pte for changes later.

So why do a page_cache_get at all? Do the copy and maybe copy garbage and
if the pte was changed forget about it. This avoids having to keep state
for the page copied from.

Nick and I discussed this a few weeks ago and there were no further comments.
Andrew thought that this need to be discussed in more detail.

So maybe there is a situation in which the pte
can go away and then be restored to exactly the
same value it had before?

The first action that would need to happen is that the swapper(?)
clears the pte (and puts the page on the free lists?).

Then the same page with the same pte flags would have to be mapped to
the same virtual address again but something significant about the page
must have changed.

mmap and related stuff is all not possible because mmap_sem semaphore
is held but the page_table_lock is dropped for for the allocation and
the copy.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.11/mm/memory.c
===================================================================
--- linux-2.6.11.orig/mm/memory.c	2005-03-03 10:20:57.000000000 -0800
+++ linux-2.6.11/mm/memory.c	2005-03-03 10:43:11.000000000 -0800
@@ -1318,8 +1318,6 @@ static int do_wp_page(struct mm_struct *
 	/*
 	 * Ok, we need to copy. Oh, well..
 	 */
-	if (!PageReserved(old_page))
-		page_cache_get(old_page);
 	spin_unlock(&mm->page_table_lock);

 	if (unlikely(anon_vma_prepare(vma)))
@@ -1358,12 +1356,10 @@ static int do_wp_page(struct mm_struct *
 	}
 	pte_unmap(page_table);
 	page_cache_release(new_page);
-	page_cache_release(old_page);
 	spin_unlock(&mm->page_table_lock);
 	return VM_FAULT_MINOR;

 no_new_page:
-	page_cache_release(old_page);
 	return VM_FAULT_OOM;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
