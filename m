Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id F0BC96B31F1
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 12:19:02 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id g188so4420311pgc.22
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 09:19:02 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 16-v6si41607749pfm.51.2018.11.23.09.19.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 23 Nov 2018 09:19:01 -0800 (PST)
Date: Fri, 23 Nov 2018 09:19:00 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 2/2] page cache: Store only head pages in i_pages
Message-ID: <20181123171900.GU3065@bombadil.infradead.org>
References: <20181122213224.12793-1-willy@infradead.org>
 <20181122213224.12793-3-willy@infradead.org>
 <20181123105643.fxqk7l57rdurdubx@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181123105643.fxqk7l57rdurdubx@kshutemo-mobl1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>

On Fri, Nov 23, 2018 at 01:56:44PM +0300, Kirill A. Shutemov wrote:
> On Thu, Nov 22, 2018 at 01:32:24PM -0800, Matthew Wilcox wrote:
> > Transparent Huge Pages are currently stored in i_pages as pointers to
> > consecutive subpages.  This patch changes that to storing consecutive
> > pointers to the head page in preparation for storing huge pages more
> > efficiently in i_pages.
> 
> I probably miss something, I don't see how it wouldn't break
> split_huge_page().
> 
> I don't see what would replace head pages in i_pages with
> formerly-tail-pages?

You're quite right.  Where's your test-suite?  ;-)

I think this should do the job:

+++ b/mm/huge_memory.c
@@ -2464,6 +2464,9 @@ static void __split_huge_page(struct page *page, struct list_head *list,
                        if (IS_ENABLED(CONFIG_SHMEM) && PageSwapBacked(head))
                                shmem_uncharge(head->mapping->host, 1);
                        put_page(head + i);
+               } else if (!PageAnon(page)) {
+                       __xa_store(&head->mapping->i_pages, head[i].index,
+                                       head + i, 0);
                }
        }
 

Having looked at this area, I think there was actually a bug in the patch
you wrote that I'm cribbing from.  You inserted the tail pages before
calling __split_huge_page_tail(), so a racing lookup would have found
a tail page before it got transformed into a non-tail page.
