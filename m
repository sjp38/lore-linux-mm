Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 458BE6B00DA
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 12:27:27 -0400 (EDT)
Date: Tue, 2 Jun 2009 14:00:42 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler in the VM v3
Message-ID: <20090602120042.GB1392@wotan.suse.de>
References: <200905271012.668777061@firstfloor.org> <20090527201239.C2C9C1D0294@basil.firstfloor.org> <20090528082616.GG6920@wotan.suse.de> <20090528095934.GA10678@localhost> <20090528122357.GM6920@wotan.suse.de> <20090528135428.GB16528@localhost> <20090601115046.GE5018@wotan.suse.de> <20090601183225.GS1065@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090601183225.GS1065@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, "hugh@veritas.com" <hugh@veritas.com>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 01, 2009 at 08:32:25PM +0200, Andi Kleen wrote:
> On Mon, Jun 01, 2009 at 01:50:46PM +0200, Nick Piggin wrote:
> > > Another major complexity is on calling the isolation routines to
> > > remove references from
> > >         - PTE
> > >         - page cache
> > >         - swap cache
> > >         - LRU list
> > > They more or less made some assumptions on their operating environment
> > > that we have to take care of.  Unfortunately these complexities are
> > > also not easily resolvable.
> > > 
> > > > (and few comments) of all the files in mm/. If you want to get rid
> > > 
> > > I promise I'll add more comments :)
> > 
> > OK, but they should still go in their relevant files. Or as best as
> > possible. Right now it's just silly to have all this here when much
> > of it could be moved out to filemap.c, swap_state.c, page_alloc.c, etc.
> 
> Can you be more specific what that "all this" is? 

The functions which take action in response to a bad page being 
detected. They belong with the subsystem that the page belongs
to. I'm amazed this is causing so much argument or confusion
because it is how the rest of mm/ code is arranged. OK, Hugh has
a point about ifdefs, but OTOH we have lots of ifdefs like this.

 
> > > > of the page and don't care what it's count or dirtyness is, then
> > > > truncate_inode_pages_range is the correct API to use.
> > > >
> > > > (or you could extract out some of it so you can call it directly on
> > > > individual locked pages, if that helps).
> > >  
> > > The patch to move over to truncate_complete_page() would like this.
> > > It's not a big win indeed.
> > 
> > No I don't mean to do this, but to move the truncate_inode_pages
> > code for truncating a single, locked, page into another function
> > in mm/truncate.c and then call that from here.
> 
> I took a look at that.  First there's no direct equivalent of
> me_pagecache_clean/dirty in truncate.c and to be honest I don't
> see a clean way to refactor any of the existing functions to 
> do the same.

With all that writing you could have just done it. It's really
not a big deal and just avoids duplicating code. I attached an
(untested) patch.


> > No, it seems rather insane to do something like this here that no other
> > code in the mm ever does.
> 
> Just because the rest of the VM doesn't do it doesn't mean it might make sense.

It is going to be possible to do it somehow surely, but it is insane
to try to add such constraints to the VM to close a few small windows
if you already have other large ones.

---
 mm/truncate.c |   24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

Index: linux-2.6/mm/truncate.c
===================================================================
--- linux-2.6.orig/mm/truncate.c
+++ linux-2.6/mm/truncate.c
@@ -135,6 +135,16 @@ invalidate_complete_page(struct address_
 	return ret;
 }
 
+void truncate_inode_page(struct address_space *mapping, struct page *page)
+{
+	if (page_mapped(page)) {
+		unmap_mapping_range(mapping,
+		  (loff_t)page->index<<PAGE_CACHE_SHIFT,
+		  PAGE_CACHE_SIZE, 0);
+	}
+	truncate_complete_page(mapping, page);
+}
+
 /**
  * truncate_inode_pages - truncate range of pages specified by start & end byte offsets
  * @mapping: mapping to truncate
@@ -196,12 +206,7 @@ void truncate_inode_pages_range(struct a
 				unlock_page(page);
 				continue;
 			}
-			if (page_mapped(page)) {
-				unmap_mapping_range(mapping,
-				  (loff_t)page_index<<PAGE_CACHE_SHIFT,
-				  PAGE_CACHE_SIZE, 0);
-			}
-			truncate_complete_page(mapping, page);
+			truncate_inode_page(mapping, page);
 			unlock_page(page);
 		}
 		pagevec_release(&pvec);
@@ -238,15 +243,10 @@ void truncate_inode_pages_range(struct a
 				break;
 			lock_page(page);
 			wait_on_page_writeback(page);
-			if (page_mapped(page)) {
-				unmap_mapping_range(mapping,
-				  (loff_t)page->index<<PAGE_CACHE_SHIFT,
-				  PAGE_CACHE_SIZE, 0);
-			}
+			truncate_inode_page(mappng, page);
 			if (page->index > next)
 				next = page->index;
 			next++;
-			truncate_complete_page(mapping, page);
 			unlock_page(page);
 		}
 		pagevec_release(&pvec);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
