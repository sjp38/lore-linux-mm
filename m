Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7587D6B0260
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 16:05:58 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id r4so52702932oib.1
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 13:05:58 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id r63si9720617oia.180.2016.06.06.13.05.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 13:05:57 -0700 (PDT)
Date: Mon, 6 Jun 2016 23:05:38 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: mm: add NR_ZSMALLOC to vmstat
Message-ID: <20160606200538.GA31983@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org

Hello Minchan Kim,

The patch b37284200b39: "mm: add NR_ZSMALLOC to vmstat" from Jun 5,
2016, leads to the following static checker warning:

	mm/zsmalloc.c:1155 alloc_zspage()
	error: we previously assumed 'page' could be null (see line 1152)

mm/zsmalloc.c
  1130  /*
  1131   * Allocate a zspage for the given size class
  1132   */
  1133  static struct zspage *alloc_zspage(struct zs_pool *pool,
  1134                                          struct size_class *class,
  1135                                          gfp_t gfp)
  1136  {
  1137          int i;
  1138          struct page *pages[ZS_MAX_PAGES_PER_ZSPAGE];
  1139          struct zspage *zspage = cache_alloc_zspage(pool, gfp);
  1140  
  1141          if (!zspage)
  1142                  return NULL;
  1143  
  1144          memset(zspage, 0, sizeof(struct zspage));
  1145          zspage->magic = ZSPAGE_MAGIC;
  1146          migrate_lock_init(zspage);
  1147  
  1148          for (i = 0; i < class->pages_per_zspage; i++) {
  1149                  struct page *page;
  1150  
  1151                  page = alloc_page(gfp);
  1152                  if (!page) {
                             ^^^^
  1153                          while (--i >= 0) {
  1154                                  __free_page(pages[i]);
  1155                                  dec_zone_page_state(page, NR_ZSMALLOC);
                                                            ^^^^
Potential NULL deref inside function call.

  1156                          }
  1157                          cache_free_zspage(pool, zspage);
  1158                          return NULL;
  1159                  }
  1160  
  1161                  inc_zone_page_state(page, NR_ZSMALLOC);
  1162                  pages[i] = page;
  1163          }
  1164  
  1165          create_page_chain(class, zspage, pages);
  1166          init_zspage(class, zspage);
  1167  
  1168          return zspage;
  1169  }


regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
