Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 455A66B3206
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 12:36:57 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id e89so5420435pfb.17
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 09:36:57 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 27sor47693837pft.32.2018.11.23.09.36.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 23 Nov 2018 09:36:56 -0800 (PST)
Date: Fri, 23 Nov 2018 20:36:51 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 2/2] page cache: Store only head pages in i_pages
Message-ID: <20181123173650.eteuc44bppvxwbcd@kshutemo-mobl1>
References: <20181122213224.12793-1-willy@infradead.org>
 <20181122213224.12793-3-willy@infradead.org>
 <20181123105643.fxqk7l57rdurdubx@kshutemo-mobl1>
 <20181123171900.GU3065@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181123171900.GU3065@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>

On Fri, Nov 23, 2018 at 09:19:00AM -0800, Matthew Wilcox wrote:
> On Fri, Nov 23, 2018 at 01:56:44PM +0300, Kirill A. Shutemov wrote:
> > On Thu, Nov 22, 2018 at 01:32:24PM -0800, Matthew Wilcox wrote:
> > > Transparent Huge Pages are currently stored in i_pages as pointers to
> > > consecutive subpages.  This patch changes that to storing consecutive
> > > pointers to the head page in preparation for storing huge pages more
> > > efficiently in i_pages.
> > 
> > I probably miss something, I don't see how it wouldn't break
> > split_huge_page().
> > 
> > I don't see what would replace head pages in i_pages with
> > formerly-tail-pages?
> 
> You're quite right.  Where's your test-suite?  ;-)

Yeah-yeah...

> I think this should do the job:
> 
> +++ b/mm/huge_memory.c
> @@ -2464,6 +2464,9 @@ static void __split_huge_page(struct page *page, struct list_head *list,
>                         if (IS_ENABLED(CONFIG_SHMEM) && PageSwapBacked(head))
>                                 shmem_uncharge(head->mapping->host, 1);
>                         put_page(head + i);
> +               } else if (!PageAnon(page)) {
> +                       __xa_store(&head->mapping->i_pages, head[i].index,
> +                                       head + i, 0);
>                 }
>         }

Looks good to me. But I still need to look into the rest of the patch.

> Having looked at this area, I think there was actually a bug in the patch
> you wrote that I'm cribbing from.  You inserted the tail pages before
> calling __split_huge_page_tail(), so a racing lookup would have found
> a tail page before it got transformed into a non-tail page.

I don't think so.

The page still has refcount==0 and any lookup of the page suppose to fail
due to !page_cache_get_speculative() or block on tree lock.

-- 
 Kirill A. Shutemov
