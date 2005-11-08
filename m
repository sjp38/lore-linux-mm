Date: Tue, 8 Nov 2005 13:03:26 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20051108210316.31330.32255.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20051108210246.31330.61756.sendpatchset@schroedinger.engr.sgi.com>
References: <20051108210246.31330.61756.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 2/8] Direct Migration V2: PageSwapCache checks
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Mike Kravetz <kravetz@us.ibm.com>, linux-kernel@vger.kernel.org, Dave Hansen <haveblue@us.ibm.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, torvalds@osdl.org, Christoph Lameter <clameter@sgi.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Magnus Damm <magnus.damm@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Jackson <pj@sgi.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

Check for PageSwapCache after looking up and locking a swap page.

The page migration code may change a swap pte to point to a different page
under lock_page().

If that happens then the vm must retry the lookup operation in the swap
space to find the correct page number. There are a couple of locations
in the VM where a lock_page() is done on a swap page. In these locations
we need to check afterwards if the page was migrated. If the page was migrated
then the old page that was looked up before was freed and no longer has the
PageSwapCache bit set.

Signed-off-by: Hirokazu Takahashi <taka@valinux.co.jp>
Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
Signed-off-by: Christoph Lameter <clameter@@sgi.com>

Index: linux-2.6.14-mm1/mm/memory.c
===================================================================
--- linux-2.6.14-mm1.orig/mm/memory.c	2005-11-07 11:48:19.000000000 -0800
+++ linux-2.6.14-mm1/mm/memory.c	2005-11-07 11:55:08.000000000 -0800
@@ -1720,6 +1720,7 @@ static int do_swap_page(struct mm_struct
 		goto out;
 
 	entry = pte_to_swp_entry(orig_pte);
+again:
 	page = lookup_swap_cache(entry);
 	if (!page) {
  		swapin_readahead(entry, address, vma);
@@ -1743,6 +1744,12 @@ static int do_swap_page(struct mm_struct
 
 	mark_page_accessed(page);
 	lock_page(page);
+	if (!PageSwapCache(page)) {
+		/* Page migration has occured */
+		unlock_page(page);
+		page_cache_release(page);
+		goto again;
+	}
 
 	/*
 	 * Back out if somebody else already faulted in this pte.
Index: linux-2.6.14-mm1/mm/shmem.c
===================================================================
--- linux-2.6.14-mm1.orig/mm/shmem.c	2005-11-07 11:48:08.000000000 -0800
+++ linux-2.6.14-mm1/mm/shmem.c	2005-11-07 11:55:08.000000000 -0800
@@ -1013,6 +1013,14 @@ repeat:
 			page_cache_release(swappage);
 			goto repeat;
 		}
+		if (!PageSwapCache(swappage)) {
+			/* Page migration has occured */
+			shmem_swp_unmap(entry);
+			spin_unlock(&info->lock);
+			unlock_page(swappage);
+			page_cache_release(swappage);
+			goto repeat;
+		}
 		if (PageWriteback(swappage)) {
 			shmem_swp_unmap(entry);
 			spin_unlock(&info->lock);
Index: linux-2.6.14-mm1/mm/swapfile.c
===================================================================
--- linux-2.6.14-mm1.orig/mm/swapfile.c	2005-11-07 11:48:49.000000000 -0800
+++ linux-2.6.14-mm1/mm/swapfile.c	2005-11-07 11:55:08.000000000 -0800
@@ -624,6 +624,7 @@ static int try_to_unuse(unsigned int typ
 		 */
 		swap_map = &si->swap_map[i];
 		entry = swp_entry(type, i);
+again:
 		page = read_swap_cache_async(entry, NULL, 0);
 		if (!page) {
 			/*
@@ -658,6 +659,12 @@ static int try_to_unuse(unsigned int typ
 		wait_on_page_locked(page);
 		wait_on_page_writeback(page);
 		lock_page(page);
+		if (!PageSwapCache(page)) {
+			/* Page migration has occured */
+			unlock_page(page);
+			page_cache_release(page);
+			goto again;
+		}
 		wait_on_page_writeback(page);
 
 		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
