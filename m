Subject: Re: Documentation/vm/locking: why not hold two PT locks?
From: Ed L Cashin <ecashin@uga.edu>
Date: Mon, 09 Feb 2004 16:17:34 -0500
In-Reply-To: <20040209182013.59140.qmail@web14302.mail.yahoo.com> (Kanoj
 Sarcar's message of "Mon, 9 Feb 2004 10:20:13 -0800 (PST)")
Message-ID: <871xp49clt.fsf@uga.edu>
References: <20040209182013.59140.qmail@web14302.mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanojsarcar@yahoo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Kanoj Sarcar <kanojsarcar@yahoo.com> writes:

...
> When "locking" came into being, vmscan was the only
> page stealer.

I tried to start a patch to the file, but I realize that I don't
really know how 2.6 is ensuring the existance of the backing store, so
I couldn't put that in.


--- Documentation/vm/locking.orig	Wed Nov 26 15:43:30 2003
+++ Documentation/vm/locking	Mon Feb  9 16:07:45 2004
@@ -7,19 +7,17 @@
 page_table_lock & mmap_sem
 --------------------------------------
 
-Page stealers pick processes out of the process pool and scan for 
-the best process to steal pages from. To guarantee the existence 
-of the victim mm, a mm_count inc and a mmdrop are done in swap_out().
-Page stealers hold kernel_lock to protect against a bunch of races.
-The vma list of the victim mm is also scanned by the stealer, 
-and the page_table_lock is used to preserve list sanity against the
-process adding/deleting to the list. This also guarantees existence
-of the vma. Vma existence is not guaranteed once try_to_swap_out() 
-drops the page_table_lock. To guarantee the existence of the underlying 
-file structure, a get_file is done before the swapout() method is 
-invoked. The page passed into swapout() is guaranteed not to be reused
-for a different purpose because the page reference count due to being
-present in the user's pte is not released till after swapout() returns.
+The page stealer in mm/vmscan.c picks pages out of the page cache and
+scans for the best pages to reclaim.  The mm/rmap.c:try_to_unmap
+function uses trylock to get the page_table_lock for each page table
+that has a mapping to the victim page.  Trylocks are used to avoid the
+deadlock that might otherwise occur, because the mmap_sem is not
+acquired first.
+
+The vma list of the victim mm is also scanned by the stealer, and the
+page_table_lock is used to preserve list sanity against the process
+adding/deleting to the list. This also guarantees existence of the
+vma.
 
 Any code that modifies the vmlist, or the vm_start/vm_end/
 vm_flags:VM_LOCKED/vm_next of any vma *in the list* must prevent 


-- 
--Ed L Cashin            |   PGP public key:
  ecashin@uga.edu        |   http://noserose.net/e/pgp/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
