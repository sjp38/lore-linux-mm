Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id E8E526B0038
	for <linux-mm@kvack.org>; Tue, 12 May 2015 21:21:15 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so32668503pac.1
        for <linux-mm@kvack.org>; Tue, 12 May 2015 18:21:15 -0700 (PDT)
Received: from mail-pd0-x229.google.com (mail-pd0-x229.google.com. [2607:f8b0:400e:c02::229])
        by mx.google.com with ESMTPS id by4si19973109pdb.96.2015.05.12.18.21.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 May 2015 18:21:15 -0700 (PDT)
Received: by pdea3 with SMTP id a3so33378469pde.3
        for <linux-mm@kvack.org>; Tue, 12 May 2015 18:21:14 -0700 (PDT)
Date: Wed, 13 May 2015 10:21:07 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] rmap: fix theoretical race between do_wp_page and
 shrink_active_list
Message-ID: <20150513012106.GB8267@blaptop>
References: <1431425919-28057-1-git-send-email-vdavydov@parallels.com>
 <20150512152840.20805775ae82c69b9a8f3028@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150512152840.20805775ae82c69b9a8f3028@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

Hello Andrew,

On Tue, May 12, 2015 at 03:28:40PM -0700, Andrew Morton wrote:
> On Tue, 12 May 2015 13:18:39 +0300 Vladimir Davydov <vdavydov@parallels.com> wrote:
> 
> > As noted by Paul the compiler is free to store a temporary result in a
> > variable on stack, heap or global unless it is explicitly marked as
> > volatile, see:
> > 
> >   http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2015/n4455.html#sample-optimizations
> > 
> > This can result in a race between do_wp_page() and shrink_active_list()
> > as follows.
> > 
> > In do_wp_page() we can call page_move_anon_rmap(), which sets
> > page->mapping as follows:
> > 
> >   anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
> >   page->mapping = (struct address_space *) anon_vma;
> > 
> > The page in question may be on an LRU list, because nowhere in
> > do_wp_page() we remove it from the list, neither do we take any LRU
> > related locks. Although the page is locked, shrink_active_list() can
> > still call page_referenced() on it concurrently, because the latter does
> > not require an anonymous page to be locked:
> > 
> >   CPU0                          CPU1
> >   ----                          ----
> >   do_wp_page                    shrink_active_list
> >    lock_page                     page_referenced
> >                                   PageAnon->yes, so skip trylock_page
> >    page_move_anon_rmap
> >     page->mapping = anon_vma
> >                                   rmap_walk
> >                                    PageAnon->no
> >                                    rmap_walk_file
> >                                     BUG
> >     page->mapping += PAGE_MAPPING_ANON
> > 
> > This patch fixes this race by explicitly forbidding the compiler to
> > split page->mapping store in page_move_anon_rmap() with the aid of
> > WRITE_ONCE.
> > 
> > ...
> >
> > --- a/mm/rmap.c
> > +++ b/mm/rmap.c
> > @@ -950,7 +950,7 @@ void page_move_anon_rmap(struct page *page,
> >  	VM_BUG_ON_PAGE(page->index != linear_page_index(vma, address), page);
> >  
> >  	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
> > -	page->mapping = (struct address_space *) anon_vma;
> > +	WRITE_ONCE(page->mapping, (struct address_space *) anon_vma);
> 
> Please let's not put things like WRITE_ONCE() in there without
> documenting them - otherwise it's terribly hard for readers to work out
> why it was added.
> 
> How's this look?
> 
> --- a/mm/rmap.c~rmap-fix-theoretical-race-between-do_wp_page-and-shrink_active_list-fix
> +++ a/mm/rmap.c
> @@ -950,6 +950,11 @@ void page_move_anon_rmap(struct page *pa
>  	VM_BUG_ON_PAGE(page->index != linear_page_index(vma, address), page);
>  
>  	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
> +	/*
> +	 * Ensure that anon_vma and the PAGE_MAPPING_ANON bit are written
> +	 * simultaneously, so a concurrent reader (eg shrink_active_list) will

IMHO, rather than shrink_active_list, PageAnon in page_referenced is better to me.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
