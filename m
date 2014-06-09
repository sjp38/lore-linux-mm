Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id DEACC6B0093
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 14:53:47 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id v10so5119816pde.23
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 11:53:47 -0700 (PDT)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id sn4si98349pab.203.2014.06.09.11.53.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 09 Jun 2014 11:53:46 -0700 (PDT)
Received: by mail-pd0-f174.google.com with SMTP id r10so5128368pdi.19
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 11:53:46 -0700 (PDT)
Date: Mon, 9 Jun 2014 11:52:19 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: 3.15-rc8 mm/filemap.c:202 BUG
In-Reply-To: <013901cf83da$9b8d4670$d2a7d350$@alibaba-inc.com>
Message-ID: <alpine.LSU.2.11.1406091150100.5896@eggly.anvils>
References: <013901cf83da$9b8d4670$d2a7d350$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hillf.zj@alibaba-inc.com
Cc: Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Dave Jones <davej@redhat.com>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On Mon, 9 Jun 2014, hillf wrote:
> On Fri, Jun 6, 2014 at 4:05 PM, Hugh Dickins <hughd@google.com> wrote:
> >
> > Though I'd wanted to see the remove_migration_pte oops as a key to the
> > page_mapped bug, my guess is that they're actually independent.
> > 
> 
> In the 3.15-rc8 tree, along the migration path
> 
>    /*
>     * Corner case handling:
>     * 1. When a new swap-cache page is read into, it is added to the LRU
>     * and treated as swapcache but it has no rmap yet.
>     * Calling try_to_unmap() against a page->mapping==NULL page will
>     * trigger a BUG.  So handle it here.
>     * 2. An orphaned page (see truncate_complete_page) might have
>     * fs-private metadata. The page can be picked up due to memory
>     * offlining.  Everywhere else except page reclaim, the page is
>     * invisible to the vm, so the page can not be migrated.  So try to
>     * free the metadata, so the page can be freed.

I don't think I'd say that an orphaned page cannot be migrated; but
I do agree that it's better just to try free the page than migrate it.

>     */
>     if (!page->mapping) {
>        VM_BUG_ON_PAGE(PageAnon(page), page);
>        if (page_has_private(page)) {
>            try_to_free_buffers(page);
>            goto uncharge;
>        }
>        goto skip_unmap;
>     }
> 
>     /* Establish migration ptes or remove ptes */
>     try_to_unmap(page, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);

(There is an inefficiency here: it would better check page_mapped(page)
before calling try_to_unmap(), which would save getting i_mmap_mutex
unnecessarily.  But that's an aside, it's not wrong as it stands.)

> 
> skip_unmap:
>     if (!page_mapped(page))
>        rc = move_to_new_page(newpage, page, remap_swapcache, mode);
> 
> Here a page is migrated even not mapped and with no mapping! 

Why the exclamation mark?  We have just tried to unmap it, so no
surprise that the page is now not mapped.  As to "no mapping": we
hold the page lock, so it's a bug if the state of "page->mapping"
has changed since we tested it above.

> 
>     mapping = page_mapping(page);
>     if (!mapping)
>        rc = migrate_page(mapping, newpage, page, mode);

You need to check the way page_mapping(page) works: it doesn't
simply return page->mapping, but supplies swap_address_space if
PageSwapCache is set, or otherwise NULL on an anonymous page.
I think your "no mapping" above amounts to swapless anonymous.

> 
> 
>     if (!mapping) {
>        /* Anonymous page without mapping */
>        if (page_count(page) != expected_count)
>            return -EAGAIN;
>        return MIGRATEPAGE_SUCCESS;
>     }
> 
> And seems a file cache page is treated in the way of Anon.
> 
> Is that right?

Nothing wrong with it that I see: the truncated file !page->mapping
case has already been skipped in the "Corner case handling" block,
though it would not worry me if an orphan page did reach here - the
page count check will still refuse to migrate "unexplainable" pages.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
