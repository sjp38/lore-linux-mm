Date: Mon, 24 Apr 2006 15:04:30 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2.6.17-rc1-mm3] add migratepage addresss space op to
 shmem
In-Reply-To: <Pine.LNX.4.64.0604242046120.24647@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0604241447520.8904@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0604242046120.24647@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 24 Apr 2006, Hugh Dickins wrote:

> > In 2.6.16 through 2.6.17-rc1, shared memory mappings do not
> > have a migratepage address space op.  Therefore, migrate_pages()
> > falls back to default processing.  In this path, it will try to
> > pageout() dirty pages.  Once a shared memory page has been migrated
> > it becomes dirty, so migrate_pages() will try to page it out.  
> > However, because the page count is 3 [cache + current + pte],
> > pageout() will return PAGE_KEEP because is_page_cache_freeable()
> > returns false.  This will abort all subsequent migrations.
> 
> So far as I can see, this problem is not at all peculiar to shmem
> (aside from its greater likelihood of being found PageDirty): won't
> that PageDirty pageout in migrate_pages always return PAGE_KEEP?
> so as it stands, is pointless and misleading?

Yes, this wont work if we do not remove the ptes before calling 
pageout. A call to try_to_umap() is missing.

> > This patch adds a migratepage address space op to shared memory
> > segments to avoid taking the default path.  We use the "migrate_page()"
> > function because it knows how to migrate dirty pages.  This allows
> > shared memory segment pages to migrate, subject to other conditions
> > such as # pte's referencing the page [page_mapcount(page)], when
> > requested.  
> 
> While that's not wrong, wouldn't the right fix be something else?

His patch avoids going through the fallback functions and allows 
migrating dirty shmem pages without pageout. That is good.



Index: linux-2.6/mm/migrate.c
===================================================================
--- linux-2.6.orig/mm/migrate.c	2006-04-18 12:51:31.000000000 -0700
+++ linux-2.6/mm/migrate.c	2006-04-24 15:03:10.000000000 -0700
@@ -439,6 +439,11 @@ redo:
 			goto unlock_both;
                 }
 
+		if (try_to_unmap(page, 1) == SWAP_FAIL) {
+			rc = -EPERM;
+			goto unlock_both;
+		}
+
 		/*
 		 * Default handling if a filesystem does not provide
 		 * a migration function. We can only migrate clean

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
