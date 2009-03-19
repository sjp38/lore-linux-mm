Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B3A156B003D
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 12:27:29 -0400 (EDT)
Date: Thu, 19 Mar 2009 09:20:57 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: ftruncate-mmap: pages are lost after writing to mmaped file.
In-Reply-To: <200903200248.22623.nickpiggin@yahoo.com.au>
Message-ID: <alpine.LFD.2.00.0903190902000.17240@localhost.localdomain>
References: <604427e00903181244w360c5519k9179d5c3e5cd6ab3@mail.gmail.com> <alpine.LFD.2.00.0903181634500.17240@localhost.localdomain> <604427e00903181654y308d57d8w2cb32eab831cf45a@mail.gmail.com> <200903200248.22623.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Ying Han <yinghan@google.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, guichaz@gmail.com, Alex Khesin <alexk@google.com>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>



On Fri, 20 Mar 2009, Nick Piggin wrote:
> 
> But I think we do have a race in __set_page_dirty_buffers():
> 
> The page may not have buffers between the mapping->private_lock
> critical section and the __set_page_dirty call there. So between
> them, another thread might do a create_empty_buffers which can
> see !PageDirty and thus it will create clean buffers.

Hmm.

Creating clean buffers is locked by the page lock, nothing else.  And not 
all page dirtiers hold the page lock (in fact, most try to avoid it - the 
rule is that you either have to hold the page lock _or_ hold a reference 
to the 'mapping', and the latter is what the mmap code does, I think).

So yeah, the page lock isn't sufficient.

> Holding mapping->private_lock over the __set_page_dirty should
> fix it, although I guess you'd want to release it before calling
> __mark_inode_dirty so as not to put inode_lock under there. I
> have a patch for this if it sounds reasonable.

That would seem to make sense. Maybe moving the "TestSetPageDirty()" from 
inside __set_page_dirty() to the caller? Something like the appended?

This is TOTALLY untested. Of course.

			Linus

---
 fs/buffer.c |   23 +++++++++++------------
 1 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 9f69741..891e1c7 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -760,15 +760,9 @@ EXPORT_SYMBOL(mark_buffer_dirty_inode);
  * If warn is true, then emit a warning if the page is not uptodate and has
  * not been truncated.
  */
-static int __set_page_dirty(struct page *page,
+static void __set_page_dirty(struct page *page,
 		struct address_space *mapping, int warn)
 {
-	if (unlikely(!mapping))
-		return !TestSetPageDirty(page);
-
-	if (TestSetPageDirty(page))
-		return 0;
-
 	spin_lock_irq(&mapping->tree_lock);
 	if (page->mapping) {	/* Race with truncate? */
 		WARN_ON_ONCE(warn && !PageUptodate(page));
@@ -785,8 +779,6 @@ static int __set_page_dirty(struct page *page,
 	}
 	spin_unlock_irq(&mapping->tree_lock);
 	__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
-
-	return 1;
 }
 
 /*
@@ -816,6 +808,7 @@ static int __set_page_dirty(struct page *page,
  */
 int __set_page_dirty_buffers(struct page *page)
 {
+	int newly_dirty;
 	struct address_space *mapping = page_mapping(page);
 
 	if (unlikely(!mapping))
@@ -831,9 +824,12 @@ int __set_page_dirty_buffers(struct page *page)
 			bh = bh->b_this_page;
 		} while (bh != head);
 	}
+	newly_dirty = !TestSetPageDirty(page);
 	spin_unlock(&mapping->private_lock);
 
-	return __set_page_dirty(page, mapping, 1);
+	if (newly_dirty)
+		__set_page_dirty(page, mapping, 1);
+	return newly_dirty;
 }
 EXPORT_SYMBOL(__set_page_dirty_buffers);
 
@@ -1262,8 +1258,11 @@ void mark_buffer_dirty(struct buffer_head *bh)
 			return;
 	}
 
-	if (!test_set_buffer_dirty(bh))
-		__set_page_dirty(bh->b_page, page_mapping(bh->b_page), 0);
+	if (!test_set_buffer_dirty(bh)) {
+		struct page *page = bh->b_page;
+		if (!TestSetPageDirty(page))
+			__set_page_dirty(page, page_mapping(page), 0);
+	}
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
