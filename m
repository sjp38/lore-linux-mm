Subject: Re: [PATCH] Make invalidate_inode_pages2() work again
From: Trond Myklebust <Trond.Myklebust@netapp.com>
In-Reply-To: <45186D4A.70009@yahoo.com.au>
References: <20060925231557.32226.66866.stgit@ingres.dsl.sfldmi.ameritech.net>
	 <45186D4A.70009@yahoo.com.au>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Mon, 25 Sep 2006 21:20:13 -0400
Message-Id: <1159233613.5442.61.camel@lade.trondhjem.org>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Chuck Lever <chucklever@gmail.com>, apkm@osdl.org, linux-mm@kvack.org, steved@redhat.com
List-ID: <linux-mm.kvack.org>

On Tue, 2006-09-26 at 09:59 +1000, Nick Piggin wrote:
> Chuck Lever wrote:
> 
> >A recent change to fix a problem with invalidate_inode_pages() has weakened
> >the behavior of invalidate_inode_pages2() inadvertently.  Add a flag to
> >tell the helper routines when stronger invalidation semantics are desired.
> >
> 
> Question: if invalidate_inode_pages2 cares about not invalidating dirty
> pages, how can one avoid the page_count check and it still be correct
> (ie. not randomly lose dirty bits in some situations)?

Tests of page_count _suck_ 'cos they are 100% non-specific. Is there no
way to set a page flag or something to indicate that the page may have
been remapped while we were sleeping?

Cheers,
  Trond


> >Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> >---
> >
> > mm/truncate.c |    8 ++++----
> > 1 files changed, 4 insertions(+), 4 deletions(-)
> >
> >diff --git a/mm/truncate.c b/mm/truncate.c
> >index c6ab55e..b3097a2 100644
> >--- a/mm/truncate.c
> >+++ b/mm/truncate.c
> >@@ -59,7 +59,7 @@ truncate_complete_page(struct address_sp
> >  * Returns non-zero if the page was successfully invalidated.
> >  */
> > static int
> >-invalidate_complete_page(struct address_space *mapping, struct page *page)
> >+invalidate_complete_page(struct address_space *mapping, struct page *page, int try_harder)
> > {
> > 	if (page->mapping != mapping)
> > 		return 0;
> >@@ -70,7 +70,7 @@ invalidate_complete_page(struct address_
> > 	write_lock_irq(&mapping->tree_lock);
> > 	if (PageDirty(page))
> > 		goto failed;
> >-	if (page_count(page) != 2)	/* caller's ref + pagecache ref */
> >+	if (!try_harder && page_count(page) != 2)	/* caller's ref + pagecache ref */
> > 		goto failed;
> > 
> > 	BUG_ON(PagePrivate(page));
> >@@ -255,7 +255,7 @@ unsigned long invalidate_mapping_pages(s
> > 				goto unlock;
> > 			if (page_mapped(page))
> > 				goto unlock;
> >-			ret += invalidate_complete_page(mapping, page);
> >+			ret += invalidate_complete_page(mapping, page, 0);
> > unlock:
> > 			unlock_page(page);
> > 			if (next > end)
> >@@ -339,7 +339,7 @@ int invalidate_inode_pages2_range(struct
> > 				}
> > 			}
> > 			was_dirty = test_clear_page_dirty(page);
> >-			if (!invalidate_complete_page(mapping, page)) {
> >+			if (!invalidate_complete_page(mapping, page, 1)) {
> > 				if (was_dirty)
> > 					set_page_dirty(page);
> > 				ret = -EIO;
> >
> >--
> >  
> >
> 
> Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
