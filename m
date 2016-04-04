Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 78C3B828E5
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 16:40:20 -0400 (EDT)
Received: by mail-pf0-f171.google.com with SMTP id 184so51585458pff.0
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 13:40:20 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id r13si239670pfb.82.2016.04.04.13.40.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Apr 2016 13:40:07 -0700 (PDT)
Date: Mon, 4 Apr 2016 23:39:52 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: zsmalloc: zs_compact refactoring
Message-ID: <20160404203952.GA8379@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org

Hello Minchan Kim,

The patch 9a0346061ab8: "zsmalloc: zs_compact refactoring" from Apr
2, 2016, leads to the following static checker warning:

	mm/zsmalloc.c:1851 handle_from_obj()
	warn: bit shifter 'OBJ_ALLOCATED_TAG' used for logical '&'

mm/zsmalloc.c
  1622  static unsigned long obj_malloc(struct size_class *class,
  1623                                  struct page *first_page, unsigned long handle)
  1624  {
  1625          unsigned long obj;
  1626          struct link_free *link;
  1627  
  1628          struct page *m_page;
  1629          unsigned long m_offset;
  1630          void *vaddr;
  1631  
  1632          obj = get_freeobj(first_page);
  1633          objidx_to_page_and_offset(class, first_page, obj,
  1634                                  &m_page, &m_offset);
  1635  
  1636          vaddr = kmap_atomic(m_page);
  1637          link = (struct link_free *)vaddr + m_offset / sizeof(*link);
  1638          set_freeobj(first_page, link->next >> OBJ_ALLOCATED_TAG);
                                        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
OBJ_ALLOCATED_TAG is 1.  Here it's used as a shifter.

  1639          if (!class->huge)
  1640                  /* record handle in the header of allocated chunk */
  1641                  link->handle = handle | OBJ_ALLOCATED_TAG;

Here it's a bit mask.  It's sort of confusing to re-use it like this.
It's done through out the file.

  1642          else
  1643                  /* record handle in first_page->private */
  1644                  set_page_private(first_page, handle | OBJ_ALLOCATED_TAG);
  1645          kunmap_atomic(vaddr);
  1646          mod_zspage_inuse(first_page, 1);
  1647  
  1648          obj = location_to_obj(m_page, obj);
  1649  
  1650          return obj;
  1651  }

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
