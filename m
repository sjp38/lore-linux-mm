Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 0559C82F67
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 00:45:54 -0400 (EDT)
Received: by igdg1 with SMTP id g1so36534621igd.1
        for <linux-mm@kvack.org>; Sun, 18 Oct 2015 21:45:53 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id 9si24698530ion.14.2015.10.18.21.45.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Oct 2015 21:45:53 -0700 (PDT)
Received: by pasz6 with SMTP id z6so17937464pas.2
        for <linux-mm@kvack.org>; Sun, 18 Oct 2015 21:45:52 -0700 (PDT)
Date: Sun, 18 Oct 2015 21:45:47 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 1/12] mm Documentation: undoc non-linear vmas
In-Reply-To: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1510182144210.2481@eggly.anvils>
References: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org

While updating some mm Documentation, I came across a few straggling
references to the non-linear vmas which were happily removed in v4.0.
Delete them.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 Documentation/filesystems/proc.txt   |    1 
 Documentation/vm/page_migration      |   10 +--
 Documentation/vm/unevictable-lru.txt |   63 +------------------------
 3 files changed, 9 insertions(+), 65 deletions(-)

--- migrat.orig/Documentation/filesystems/proc.txt	2015-09-12 18:30:13.713047477 -0700
+++ migrat/Documentation/filesystems/proc.txt	2015-10-18 17:53:03.715313650 -0700
@@ -474,7 +474,6 @@ manner. The codes are the following:
     ac  - area is accountable
     nr  - swap space is not reserved for the area
     ht  - area uses huge tlb pages
-    nl  - non-linear mapping
     ar  - architecture specific flag
     dd  - do not include area into core dump
     sd  - soft-dirty flag
--- migrat.orig/Documentation/vm/page_migration	2009-06-09 20:05:27.000000000 -0700
+++ migrat/Documentation/vm/page_migration	2015-10-18 17:53:03.715313650 -0700
@@ -99,12 +99,10 @@ Steps:
 4. The new page is prepped with some settings from the old page so that
    accesses to the new page will discover a page with the correct settings.
 
-5. All the page table references to the page are converted
-   to migration entries or dropped (nonlinear vmas).
-   This decrease the mapcount of a page. If the resulting
-   mapcount is not zero then we do not migrate the page.
-   All user space processes that attempt to access the page
-   will now wait on the page lock.
+5. All the page table references to the page are converted to migration
+   entries. This decreases the mapcount of a page. If the resulting
+   mapcount is not zero then we do not migrate the page. All user space
+   processes that attempt to access the page will now wait on the page lock.
 
 6. The radix tree lock is taken. This will cause all processes trying
    to access the page via the mapping to block on the radix tree spinlock.
--- migrat.orig/Documentation/vm/unevictable-lru.txt	2015-08-30 11:34:09.000000000 -0700
+++ migrat/Documentation/vm/unevictable-lru.txt	2015-10-18 17:53:03.716313651 -0700
@@ -552,63 +552,17 @@ different reverse map mechanisms.
      is really unevictable or not.  In this case, try_to_unmap_anon() will
      return SWAP_AGAIN.
 
- (*) try_to_unmap_file() - linear mappings
+ (*) try_to_unmap_file()
 
      Unmapping of a mapped file page works the same as for anonymous mappings,
      except that the scan visits all VMAs that map the page's index/page offset
-     in the page's mapping's reverse map priority search tree.  It also visits
-     each VMA in the page's mapping's non-linear list, if the list is
-     non-empty.
+     in the page's mapping's reverse map interval search tree.
 
      As for anonymous pages, on encountering a VM_LOCKED VMA for a mapped file
      page, try_to_unmap_file() will attempt to acquire the associated
      mm_struct's mmap semaphore to mlock the page, returning SWAP_MLOCK if this
      is successful, and SWAP_AGAIN, if not.
 
- (*) try_to_unmap_file() - non-linear mappings
-
-     If a page's mapping contains a non-empty non-linear mapping VMA list, then
-     try_to_un{map|lock}() must also visit each VMA in that list to determine
-     whether the page is mapped in a VM_LOCKED VMA.  Again, the scan must visit
-     all VMAs in the non-linear list to ensure that the pages is not/should not
-     be mlocked.
-
-     If a VM_LOCKED VMA is found in the list, the scan could terminate.
-     However, there is no easy way to determine whether the page is actually
-     mapped in a given VMA - either for unmapping or testing whether the
-     VM_LOCKED VMA actually pins the page.
-
-     try_to_unmap_file() handles non-linear mappings by scanning a certain
-     number of pages - a "cluster" - in each non-linear VMA associated with the
-     page's mapping, for each file mapped page that vmscan tries to unmap.  If
-     this happens to unmap the page we're trying to unmap, try_to_unmap() will
-     notice this on return (page_mapcount(page) will be 0) and return
-     SWAP_SUCCESS.  Otherwise, it will return SWAP_AGAIN, causing vmscan to
-     recirculate this page.  We take advantage of the cluster scan in
-     try_to_unmap_cluster() as follows:
-
-	For each non-linear VMA, try_to_unmap_cluster() attempts to acquire the
-	mmap semaphore of the associated mm_struct for read without blocking.
-
-	If this attempt is successful and the VMA is VM_LOCKED,
-	try_to_unmap_cluster() will retain the mmap semaphore for the scan;
-	otherwise it drops it here.
-
-	Then, for each page in the cluster, if we're holding the mmap semaphore
-	for a locked VMA, try_to_unmap_cluster() calls mlock_vma_page() to
-	mlock the page.  This call is a no-op if the page is already locked,
-	but will mlock any pages in the non-linear mapping that happen to be
-	unlocked.
-
-	If one of the pages so mlocked is the page passed in to try_to_unmap(),
-	try_to_unmap_cluster() will return SWAP_MLOCK, rather than the default
-	SWAP_AGAIN.  This will allow vmscan to cull the page, rather than
-	recirculating it on the inactive list.
-
-	Again, if try_to_unmap_cluster() cannot acquire the VMA's mmap sem, it
-	returns SWAP_AGAIN, indicating that the page is mapped by a VM_LOCKED
-	VMA, but couldn't be mlocked.
-
 
 try_to_munlock() REVERSE MAP SCAN
 ---------------------------------
@@ -625,10 +579,9 @@ introduced a variant of try_to_unmap() c
 try_to_munlock() calls the same functions as try_to_unmap() for anonymous and
 mapped file pages with an additional argument specifying unlock versus unmap
 processing.  Again, these functions walk the respective reverse maps looking
-for VM_LOCKED VMAs.  When such a VMA is found for anonymous pages and file
-pages mapped in linear VMAs, as in the try_to_unmap() case, the functions
-attempt to acquire the associated mmap semaphore, mlock the page via
-mlock_vma_page() and return SWAP_MLOCK.  This effectively undoes the
+for VM_LOCKED VMAs.  When such a VMA is found, as in the try_to_unmap() case,
+the functions attempt to acquire the associated mmap semaphore, mlock the page
+via mlock_vma_page() and return SWAP_MLOCK.  This effectively undoes the
 pre-clearing of the page's PG_mlocked done by munlock_vma_page.
 
 If try_to_unmap() is unable to acquire a VM_LOCKED VMA's associated mmap
@@ -636,12 +589,6 @@ semaphore, it will return SWAP_AGAIN.  T
 recycle the page on the inactive list and hope that it has better luck with the
 page next time.
 
-For file pages mapped into non-linear VMAs, the try_to_munlock() logic works
-slightly differently.  On encountering a VM_LOCKED non-linear VMA that might
-map the page, try_to_munlock() returns SWAP_AGAIN without actually mlocking the
-page.  munlock_vma_page() will just leave the page unlocked and let vmscan deal
-with it - the usual fallback position.
-
 Note that try_to_munlock()'s reverse map walk must visit every VMA in a page's
 reverse map to determine that a page is NOT mapped into any VM_LOCKED VMA.
 However, the scan can terminate when it encounters a VM_LOCKED VMA and can

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
