Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9EDA56B0261
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 16:12:12 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id w9so101608479oia.3
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 13:12:12 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id wj5si1586019pab.33.2016.06.06.13.12.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 13:12:12 -0700 (PDT)
Date: Mon, 6 Jun 2016 23:11:51 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: zsmalloc: support compaction
Message-ID: <20160606201151.GA26398@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org

Hello Minchan Kim,

The patch 312fcae22703: "zsmalloc: support compaction" from Apr 15,
2015, leads to the following static checker warning:

	mm/zsmalloc.c:1521 obj_malloc()
	warn: 'OBJ_ALLOCATED_TAG' is a shifter (not for '|=').

mm/zsmalloc.c
  1510  static unsigned long obj_malloc(struct size_class *class,
  1511                                  struct zspage *zspage, unsigned long handle)
  1512  {
  1513          int i, nr_page, offset;
  1514          unsigned long obj;
  1515          struct link_free *link;
  1516  
  1517          struct page *m_page;
  1518          unsigned long m_offset;
  1519          void *vaddr;
  1520  
  1521          handle |= OBJ_ALLOCATED_TAG;
                          ^^^^^^^^^^^^^^^^^
It's weird to use the same define for a bit number

  1522          obj = get_freeobj(zspage);
  1523  
  1524          offset = obj * class->size;
  1525          nr_page = offset >> PAGE_SHIFT;
  1526          m_offset = offset & ~PAGE_MASK;
  1527          m_page = get_first_page(zspage);
  1528  
  1529          for (i = 0; i < nr_page; i++)
  1530                  m_page = get_next_page(m_page);
  1531  
  1532          vaddr = kmap_atomic(m_page);
  1533          link = (struct link_free *)vaddr + m_offset / sizeof(*link);
  1534          set_freeobj(zspage, link->next >> OBJ_ALLOCATED_TAG);
                                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
And also a bit shifter.  TAG normally implies it is a bit and not a
shift?

  1535          if (likely(!PageHugeObject(m_page)))
  1536                  /* record handle in the header of allocated chunk */
  1537                  link->handle = handle;
  1538          else
  1539                  /* record handle to page->index */
  1540                  zspage->first_page->index = handle;
  1541  
  1542          kunmap_atomic(vaddr);
  1543          mod_zspage_inuse(zspage, 1);
  1544          zs_stat_inc(class, OBJ_USED, 1);
  1545  
  1546          obj = location_to_obj(m_page, obj);
  1547  
  1548          return obj;
  1549  }

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
