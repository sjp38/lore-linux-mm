Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id A3C076B2700
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 13:33:04 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id l9so9537632plt.7
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 10:33:04 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l8si46079541pgr.345.2018.11.21.10.33.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 21 Nov 2018 10:33:03 -0800 (PST)
Date: Wed, 21 Nov 2018 10:33:02 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: find_get_pages_contig
Message-ID: <20181121183302.GJ3065@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Piggin <npiggin@au1.ibm.com>
Cc: linux-mm@kvack.org


Hi Nick,

Sorry to trouble you about a patch from 2011, but even cregit can't find
a mailing list discussion to guide me.  The commit is
9cbb4cb21b19fff46cf1174d0ed699ef710e641c (mm: find_get_pages_contig fixlet)

I understand that checking mapping and index before taking the ref can
lead to false positives & negatives, but here's what the current code
looks like:

                head = compound_head(page);
                if (!page_cache_get_speculative(head))
                        goto retry;

                /* The page was split under us? */
                if (compound_head(page) != head)
                        goto put_page;

                /* Has the page moved? */
                if (unlikely(page != xas_reload(&xas)))
                        goto put_page;

                /*
                 * must check mapping and index after taking the ref.
                 * otherwise we can get both false positives and false
                 * negatives, which is just confusing to the caller.
                 */
                if (!page->mapping || page_to_pgoff(page) != xas.xa_index) {
                        put_page(page);
                        break;
                }

After checking that page is still at the right location (done by the
xas_reload() call up there), does checking mapping and page_to_pgoff
really check anything new?  It's my understanding that after I have a
ref on a page, it can't be moved within the mapping or to a new mapping.
