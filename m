Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1E3926B0005
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 10:47:30 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id n15-v6so301596ioc.17
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 07:47:30 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id o130-v6si154664ith.71.2018.06.19.07.47.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jun 2018 07:47:29 -0700 (PDT)
Date: Tue, 19 Jun 2018 17:47:05 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [bug report] page cache: Convert filemap_range_has_page to XArray
Message-ID: <20180619144705.oqjmli6l7f7j2mgx@kili.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org
Cc: linux-mm@kvack.org

Hello Matthew Wilcox,

The patch 87345c6b1aa8: "page cache: Convert filemap_range_has_page
to XArray" from Jan 16, 2018, leads to the following static checker
warning:

	mm/filemap.c:469 filemap_range_has_page()
	warn: continue to end of do { ... } while(0); loop

mm/filemap.c
   455  bool filemap_range_has_page(struct address_space *mapping,
   456                             loff_t start_byte, loff_t end_byte)
   457  {
   458          struct page *page;
   459          XA_STATE(xas, &mapping->i_pages, start_byte >> PAGE_SHIFT);
   460          pgoff_t max = end_byte >> PAGE_SHIFT;
   461  
   462          if (end_byte < start_byte)
   463                  return false;
   464  
   465          rcu_read_lock();
   466          do {
   467                  page = xas_find(&xas, max);
   468                  if (xas_retry(&xas, page))
   469                          continue;
                                ^^^^^^^^
   470                  /* Shadow entries don't count */
   471                  if (xa_is_value(page))
   472                          continue;
                                ^^^^^^^^
This is the same as a break because it's a while(0) loop.

   473                  /*
   474                   * We don't need to try to pin this page; we're about to
   475                   * release the RCU lock anyway.  It is enough to know that
   476                   * there was a page here recently.
   477                   */
   478          } while (0);
   479          rcu_read_unlock();
   480  
   481          return page != NULL;
   482  }

regards,
dan carpenter
