Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 579F26B0055
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 01:19:54 -0400 (EDT)
From: Neil Brown <neilb@suse.de>
Date: Mon, 27 Apr 2009 15:20:22 +1000
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <18933.16534.862316.787808@notabene.brown>
Subject: [PATCH] Fix race between callers of read_cache_page_async and invalidate_inode_pages.
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, David Woodhouse <dwmw2@infradead.org>
List-ID: <linux-mm.kvack.org>




Callers of read_cache_page_async typically wait for the page to become
unlocked (wait_on_page_locked) and then test PageUptodate to see if
the read was successful, or if there was an error.

This is wrong.

invalidate_inode_pages can cause an unlocked page to lose its
PageUptodate flag at any time without implying a read error.

As any read error will cause PageError to be set, it is much safer,
and more idiomatic to test "PageError" than to test "!PageUptodate".
Hence this patch.

An actual failure that has been seen (on a 2.6.5 based kernel)
involves symlinks.  Symlinks are more suseptible as the 'open' and
'read' phases can be very close together, and so can both overlap with
invalidate_inode_pages.

The sequence goes something like:

  high memory pressure prunes dentry
  continuing memory pressure cause prune
    of inode to start.  Start invaliding
    page(s).
                                             Lookup of path containing symlink
                                              causes inode (inode is found in
                                              cache).
                                             page_getlink calls
                                               read_cache_page
                                                read_cache_page_async
                                                finds that page is Uptodate
   __invalidate_mapping_pages finds page
   and locks it
                                                read_cache_page waits for lock
                                                to be released.
   invalidate_complete_page clears
   PageUptodate
                                                read_cache_page finds Uptodate
                                                is clear and assumes an error.

As we can see, finding !PageUptodate is not an error.  Possibly in
this case we could try an read again, but really there is no point.
After calling read_cache_page_async and waiting for the page to be
unlocked, then either the page has been read, or there was an error.
The simplest way to check, is to tests PageError.

Note the "typically" in the first sentence refers to fs/jffs2/fs.c
which uses read_cache_page_async, but never checks for an error, or
even waits for the page to be unlocked.  This seems wrong, though
maybe there is some justification for it.

Signed-off-by: NeilBrown <neilb@suse.de>
cc: Nick Piggin <npiggin@suse.de>
Cc: David Woodhouse <dwmw2@infradead.org>
---
 fs/cramfs/inode.c |    2 +-
 mm/filemap.c      |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/cramfs/inode.c b/fs/cramfs/inode.c
index dd3634e..573d582 100644
--- a/fs/cramfs/inode.c
+++ b/fs/cramfs/inode.c
@@ -180,7 +180,7 @@ static void *cramfs_read(struct super_block *sb, unsigned int offset, unsigned i
 		struct page *page = pages[i];
 		if (page) {
 			wait_on_page_locked(page);
-			if (!PageUptodate(page)) {
+			if (PageError(page)) {
 				/* asynchronous error */
 				page_cache_release(page);
 				pages[i] = NULL;
diff --git a/mm/filemap.c b/mm/filemap.c
index 379ff0b..9ff8093 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1770,7 +1770,7 @@ struct page *read_cache_page(struct address_space *mapping,
 	if (IS_ERR(page))
 		goto out;
 	wait_on_page_locked(page);
-	if (!PageUptodate(page)) {
+	if (!PageError(page)) {
 		page_cache_release(page);
 		page = ERR_PTR(-EIO);
 	}
-- 
1.6.2.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
