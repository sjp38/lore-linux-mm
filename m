Date: Mon, 24 Apr 2006 21:08:49 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 2.6.17-rc1-mm3] add migratepage addresss space op to
 shmem
Message-ID: <Pine.LNX.4.64.0604242046120.24647@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[Sorry, I seem to have deleted the original, so destroyed threading]

On Thu, 20 Apr 2006, Lee Schermerhorn wrote:
> 
> In 2.6.16 through 2.6.17-rc1, shared memory mappings do not
> have a migratepage address space op.  Therefore, migrate_pages()
> falls back to default processing.  In this path, it will try to
> pageout() dirty pages.  Once a shared memory page has been migrated
> it becomes dirty, so migrate_pages() will try to page it out.  
> However, because the page count is 3 [cache + current + pte],
> pageout() will return PAGE_KEEP because is_page_cache_freeable()
> returns false.  This will abort all subsequent migrations.

So far as I can see, this problem is not at all peculiar to shmem
(aside from its greater likelihood of being found PageDirty): won't
that PageDirty pageout in migrate_pages always return PAGE_KEEP?
so as it stands, is pointless and misleading?

> This patch adds a migratepage address space op to shared memory
> segments to avoid taking the default path.  We use the "migrate_page()"
> function because it knows how to migrate dirty pages.  This allows
> shared memory segment pages to migrate, subject to other conditions
> such as # pte's referencing the page [page_mapcount(page)], when
> requested.  

While that's not wrong, wouldn't the right fix be something else?

> I think this is safe.  If we're migrating a shared memory page,
> then we found the page via a page table, so it must be in
> memory.

Yes, I agree: the isolate_lru_page while holding ptl keeps it sane.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
