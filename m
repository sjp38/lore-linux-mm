From: Nikita Danilov <nikita@clusterfs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16979.53442.695822.909010@gargle.gargle.HOWL>
Date: Wed, 6 Apr 2005 16:06:26 +0400
Subject: Re: "orphaned pagecache memleak fix" question.
In-Reply-To: <20050406005804.0045faf9.akpm@osdl.org>
References: <16978.46735.644387.570159@gargle.gargle.HOWL>
	<20050406005804.0045faf9.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Andrea@Suse.DE, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton writes:

[...]

 > 
 > The assumption that the thing at ->private is buffers should be viewed
 > as a performance hack for buffer-backed address_spaces only.

Yes, I was mainly concerned that this is gross layering violation that
silently adds new constraint all file systems have to follow. Were
non-buffer-head based in-tree file systems checked to never fail
->invalidatepage()?

 > 
 > Note that the patch to which you refer doesn't add this hack - it's already
 > been there for a long time, in a different place:
 > 
 > 		if (PagePrivate(page)) {
 > 			if (!try_to_release_page(page, sc->gfp_mask))
 > 				goto activate_locked;
 > 			if (!mapping && page_count(page) == 1)
 > 				goto free_it;
 > 		}

Ugh.. right.

 > To which reiserfs do you refer?  reiser4, I assume?

No, reiserfs v3. From bk revtool:

----------------------------------------------------------------------
ChangeSet 1.2028 2005/03/13 16:15:58 andrea@suse.de
  [PATCH] orphaned pagecache memleak fix
  
  Chris found that with data journaling a reiserfs pagecache may be truncate
  while still pinned.  The truncation removes the page->mapping, but the page
  is still listed in the VM queues because it still has buffers.  Then during
  the journaling process, a buffer is marked dirty and that sets the PG_dirty
  bitflag as well (in mark_buffer_dirty).  After that the page is leaked
  because it's both dirty and without a mapping.
  
  So we must allow pages without mapping and dirty to reach the PagePrivate
  check.  The page->mapping will be checked again right after the PagePrivate
  check.
  
  Signed-off-by: Andrea Arcangeli <andrea@suse.de>
  Signed-off-by: Andrew Morton <akpm@osdl.org>
  Signed-off-by: Linus Torvalds <torvalds@osdl.org>
mm/vmscan.c 1.247 2005/03/13 15:29:39 andrea@suse.de
  orphaned pagecache memleak fix
----------------------------------------------------------------------

But as I just checked, reiser4 also may return error from
->invalidatepage(), with page pinned by transaction, so there is a
problem indeed.

[...]

 > 
 > I think it would be better to make ->invalidatepage always succeed though. 
 > The situation is probably rare.

What about the following:
----------------------------------------------------------------------
diff -u bk-linux-2.5/Documentation/filesystems/Locking bk-linux/Documentation/filesystems/Locking
--- bk-linux-2.5/Documentation/filesystems/Locking	2005-04-04 19:40:53.000000000 +0400
+++ bk-linux/Documentation/filesystems/Locking	2005-04-06 15:57:46.000000000 +0400
@@ -266,10 +266,13 @@
 instances do not actually need the BKL. Please, keep it that way and don't
 breed new callers.
 
-	->invalidatepage() is called when the filesystem must attempt to drop
-some or all of the buffers from the page when it is being truncated.  It
-returns zero on success.  If ->invalidatepage is zero, the kernel uses
-block_invalidatepage() instead.
+    ->invalidatepage() is called when whole page or its portion is invalidated
+during truncate. PG_locked and PG_writeback bits of the page are acquired by
+the current thread before calling ->invalidatepage(), so it is guaranteed that
+no IO against this page is going on. Result of ->invalidatepage() is ignored
+and page is unconditionally removed from the mapping. File system has to
+either release all additional references to the page or to remove the page
+from ->lru list and to track its lifetime.
 
 	->releasepage() is called when the kernel is about to try to drop the
 buffers from the page in preparation for freeing it.  It returns zero to
----------------------------------------------------------------------

Nikita.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
