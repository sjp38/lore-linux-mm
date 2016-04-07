Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 1BA9D6B0005
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 22:39:24 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id fe3so45086430pab.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 19:39:24 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id g29si8333506pfj.135.2016.04.06.19.39.22
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 19:39:23 -0700 (PDT)
Date: Thu, 7 Apr 2016 11:39:37 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: zsmalloc: zs_compact refactoring
Message-ID: <20160407023937.GE15178@bbox>
References: <20160404203952.GA8379@mwanda>
MIME-Version: 1.0
In-Reply-To: <20160404203952.GA8379@mwanda>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org

Hello Dan,

On Mon, Apr 04, 2016 at 11:39:52PM +0300, Dan Carpenter wrote:
> Hello Minchan Kim,
> 
> The patch 9a0346061ab8: "zsmalloc: zs_compact refactoring" from Apr
> 2, 2016, leads to the following static checker warning:
> 
> 	mm/zsmalloc.c:1851 handle_from_obj()
> 	warn: bit shifter 'OBJ_ALLOCATED_TAG' used for logical '&'
> 
> mm/zsmalloc.c
>   1622  static unsigned long obj_malloc(struct size_class *class,
>   1623                                  struct page *first_page, unsigned long handle)
>   1624  {
>   1625          unsigned long obj;
>   1626          struct link_free *link;
>   1627  
>   1628          struct page *m_page;
>   1629          unsigned long m_offset;
>   1630          void *vaddr;
>   1631  
>   1632          obj = get_freeobj(first_page);
>   1633          objidx_to_page_and_offset(class, first_page, obj,
>   1634                                  &m_page, &m_offset);
>   1635  
>   1636          vaddr = kmap_atomic(m_page);
>   1637          link = (struct link_free *)vaddr + m_offset / sizeof(*link);
>   1638          set_freeobj(first_page, link->next >> OBJ_ALLOCATED_TAG);
>                                         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> OBJ_ALLOCATED_TAG is 1.  Here it's used as a shifter.
> 
>   1639          if (!class->huge)
>   1640                  /* record handle in the header of allocated chunk */
>   1641                  link->handle = handle | OBJ_ALLOCATED_TAG;
> 
> Here it's a bit mask.  It's sort of confusing to re-use it like this.
> It's done through out the file.

I will send clean up patch.
Thanks.

> 
>   1642          else
>   1643                  /* record handle in first_page->private */
>   1644                  set_page_private(first_page, handle | OBJ_ALLOCATED_TAG);
>   1645          kunmap_atomic(vaddr);
>   1646          mod_zspage_inuse(first_page, 1);
>   1647  
>   1648          obj = location_to_obj(m_page, obj);
>   1649  
>   1650          return obj;
>   1651  }
> 
> regards,
> dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
