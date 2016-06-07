Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f199.google.com (mail-ig0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3919D6B0005
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 00:50:46 -0400 (EDT)
Received: by mail-ig0-f199.google.com with SMTP id lp2so135463611igb.3
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 21:50:46 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id z127si16041995itc.9.2016.06.06.21.50.44
        for <linux-mm@kvack.org>;
        Mon, 06 Jun 2016 21:50:45 -0700 (PDT)
Date: Tue, 7 Jun 2016 13:51:46 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: zsmalloc: support compaction
Message-ID: <20160607045146.GF26230@bbox>
References: <20160606201151.GA26398@mwanda>
MIME-Version: 1.0
In-Reply-To: <20160606201151.GA26398@mwanda>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org

On Mon, Jun 06, 2016 at 11:11:51PM +0300, Dan Carpenter wrote:
> Hello Minchan Kim,
> 
> The patch 312fcae22703: "zsmalloc: support compaction" from Apr 15,
> 2015, leads to the following static checker warning:
> 
> 	mm/zsmalloc.c:1521 obj_malloc()
> 	warn: 'OBJ_ALLOCATED_TAG' is a shifter (not for '|=').
> 
> mm/zsmalloc.c
>   1510  static unsigned long obj_malloc(struct size_class *class,
>   1511                                  struct zspage *zspage, unsigned long handle)
>   1512  {
>   1513          int i, nr_page, offset;
>   1514          unsigned long obj;
>   1515          struct link_free *link;
>   1516  
>   1517          struct page *m_page;
>   1518          unsigned long m_offset;
>   1519          void *vaddr;
>   1520  
>   1521          handle |= OBJ_ALLOCATED_TAG;
>                           ^^^^^^^^^^^^^^^^^
> It's weird to use the same define for a bit number
> 
>   1522          obj = get_freeobj(zspage);
>   1523  
>   1524          offset = obj * class->size;
>   1525          nr_page = offset >> PAGE_SHIFT;
>   1526          m_offset = offset & ~PAGE_MASK;
>   1527          m_page = get_first_page(zspage);
>   1528  
>   1529          for (i = 0; i < nr_page; i++)
>   1530                  m_page = get_next_page(m_page);
>   1531  
>   1532          vaddr = kmap_atomic(m_page);
>   1533          link = (struct link_free *)vaddr + m_offset / sizeof(*link);
>   1534          set_freeobj(zspage, link->next >> OBJ_ALLOCATED_TAG);
>                                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> And also a bit shifter.  TAG normally implies it is a bit and not a
> shift?

Thanks for the report, Dan!
