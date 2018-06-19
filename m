Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 098846B0007
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 11:48:47 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id x6-v6so45671pgp.9
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 08:48:47 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e6-v6si14325192pgf.670.2018.06.19.08.48.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Jun 2018 08:48:45 -0700 (PDT)
Date: Tue, 19 Jun 2018 08:48:44 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [bug report] page cache: Convert filemap_range_has_page to XArray
Message-ID: <20180619154844.GD1438@bombadil.infradead.org>
References: <20180619144705.oqjmli6l7f7j2mgx@kili.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180619144705.oqjmli6l7f7j2mgx@kili.mountain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: linux-mm@kvack.org

On Tue, Jun 19, 2018 at 05:47:05PM +0300, Dan Carpenter wrote:
>    455  bool filemap_range_has_page(struct address_space *mapping,
>    456                             loff_t start_byte, loff_t end_byte)
>    457  {
>    458          struct page *page;
>    459          XA_STATE(xas, &mapping->i_pages, start_byte >> PAGE_SHIFT);
>    460          pgoff_t max = end_byte >> PAGE_SHIFT;
>    461  
>    462          if (end_byte < start_byte)
>    463                  return false;
>    464  
>    465          rcu_read_lock();
>    466          do {
>    467                  page = xas_find(&xas, max);
>    468                  if (xas_retry(&xas, page))
>    469                          continue;
>                                 ^^^^^^^^
>    470                  /* Shadow entries don't count */
>    471                  if (xa_is_value(page))
>    472                          continue;
>                                 ^^^^^^^^
> This is the same as a break because it's a while(0) loop.

Good catch.  Fix pushed.
