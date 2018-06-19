Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 683F26B0003
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 10:06:01 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id w23-v6so5019868pgv.1
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 07:06:01 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q6-v6si18118228plr.134.2018.06.19.07.05.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Jun 2018 07:05:58 -0700 (PDT)
Date: Tue, 19 Jun 2018 07:05:57 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [bug report] mm: Convert collapse_shmem to XArray
Message-ID: <20180619140557.GB1438@bombadil.infradead.org>
References: <20180619112944.f2fokthjunzavgcw@kili.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180619112944.f2fokthjunzavgcw@kili.mountain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: linux-mm@kvack.org

On Tue, Jun 19, 2018 at 02:29:44PM +0300, Dan Carpenter wrote:
> Hello Matthew Wilcox,
> 
> The patch d31429cb560d: "mm: Convert collapse_shmem to XArray" from
> Dec 4, 2017, leads to the following static checker warning:
> 
> 	mm/khugepaged.c:1435 collapse_shmem()
> 	error: double unlock 'irq:'
> 
> mm/khugepaged.c
>   1398                  xas_unlock_irq(&xas);
>   1399  
>   1400                  if (isolate_lru_page(page)) {
>   1401                          result = SCAN_DEL_PAGE_LRU;
>   1402                          goto out_isolate_failed;
>   1403                  }
>   1404  
>   1405                  if (page_mapped(page))
>   1406                          unmap_mapping_pages(mapping, index, 1, false);
>   1407  
>   1408                  xas_lock(&xas);
>                         ^^^^^^^^^^^^^^
> This used to disable IRQs.

*headdesk*.  Thanks, fix pushed.

>   1434  out_lru:
>   1435                  xas_unlock_irq(&xas);
>                         ^^^^^^^^^^^^^^^^^^^
> So I guess we should change this to xas_unlock(&xas);?

Nah, other way around.  No idea why I had xas_lock() there instead of
xas_lock_irq().
