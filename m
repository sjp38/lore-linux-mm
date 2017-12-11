Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id DC3476B0033
	for <linux-mm@kvack.org>; Mon, 11 Dec 2017 09:45:25 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id o2so4538493wmf.2
        for <linux-mm@kvack.org>; Mon, 11 Dec 2017 06:45:25 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g12sor6306039edm.37.2017.12.11.06.45.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Dec 2017 06:45:19 -0800 (PST)
Date: Mon, 11 Dec 2017 17:45:17 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: New layout for struct page
Message-ID: <20171211144517.qy5g5sdcvha2nlru@node.shutemov.name>
References: <20171208013139.GG26792@bombadil.infradead.org>
 <20171211063753.GB25236@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171211063753.GB25236@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org

On Sun, Dec 10, 2017 at 10:37:53PM -0800, Matthew Wilcox wrote:
> On Thu, Dec 07, 2017 at 05:31:39PM -0800, Matthew Wilcox wrote:
> > Dave Hansen and I talked about this a while ago.  I was trying to
> > understand something in the slab allocator today and thought I'd have
> > another crack at it.  I also documented my understanding of what the
> > rules are for using struct page.
> 
> I kept going with this and ended up with something that's maybe more
> interesting -- a new layout for struct page.
> 
> Advantages:
>  - Simpler struct definitions
>  - Compound pages may now be allocated of order 1 (currently, tail pages
>    1 and 2 both contain information).

That's neat. Except it doesn't work. See below. :-/

>  - page_deferred_list is now really defined in the struct instead of only
>    in comments and code.
>  - page_deferred_list doesn't conflict with tail2->index, which would
>    cause problems putting it in the page cache.  Actually, I don't see
>    how shmem_add_to_page_cache of a transhuge page doesn't provoke a
>    BUG in filemap_fault()?  VM_BUG_ON_PAGE(page->index != offset, page)
>    ought to trigger.

filemap_fault() doesn't see THP yet. shmem/tmpfs uses own ->fault handler.

> Disadvantages
>  - If adding a new variation to struct page, harder to tell where refcount
>    and compound_head land in your struct.

Yeah, that's a bummer.

It was tricky to find right spot for compound_head. And it would be even
more harder if we had struct page from proposed format.

>  - Need to remember that 'flags' is defined in the top level 'struct page'
>    and not in any of the layouts.
>    - Can do a variant of this with flags explicitly in each layout if
>      preferred.
>  - Need to explicitly define padding in layouts.
> 
> I haven't changed any code yet.  I wanted to get feedback from Christoph
> and Kirill before going further.
> 
> The new layout keeps struct page the same size as it is currently.  Mostly
> the only things that have changed are compound pages.  slab has not changed
> layout at all.
> 
> In the two tables below, the first column is the starting byte of the
> named element.  The next three columns are after the patch, and the last
> two are before the patch.  The annotation (1) means this field only has
> that meaning in the first tail page; the other fields are used in all
> tail pages.  The head page of a compound page uses all the fields the
> same way as a non-compound page.
> 
> ---+------------+------------------------------------+-------------------+
>  B | slab       | page cache | tail pages            | old tail          |
> ---+------------+------------------------------------+-------------------+
>  0 |                flags                            |                   |
>  4 |                  "                              |                   |
>  8 | s_mem      |          index                     | compound_mapcount |
> 12 | "          |            "                       | --                |
> 16 | freelist   | mapping    | dtor / order (1)      |                   |
> 20 | "          | "          | --                    |                   |
> 24 | counters   | mapcount   | compound_mapcount (1) | --                |

Sorry, this is not going to work: we need mapcount in all subpages of THP
as they can be mapped with PTE individually. So in first tail pages we
need find a spot form both compound_mapcount and mapcount.

> 28 | "          | refcount   | --                    | --                |
> 32 | next       | lru        | compound_head         | compound_head     |
> 36 | "          | "          | "                     | "                 |
> 40 | pages      | "          | deferred_list (1)     | dtor              |
> 44 | pobjects   | "          | "                     | order             |
> 48 | slab_cache | private    | "                     | --                |
> 52 | "          | "          | "                     | --                |
> ---+------------+------------+-----------------------+-------------------+
> 
> ---+------------+--------------------------------+
>  B | slab       | page cache | compound tail     |
> ---+------------+--------------------------------+
>  0 |                flags                        |
>  4 | s_mem      |          index                 |
>  8 | freelist   | mapping    | dtor/ order       |
> 12 | counters   | mapcount   | compound_mapcount |
> 16 | --         | refcount   | --                |
> 20 | next       | lru        | compound_head     |
> 24 | pg/pobj    | "          | deferred_list     |
> 28 | slab_cache | private    | "                 |
> ---+------------+------------+-------------------+

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
