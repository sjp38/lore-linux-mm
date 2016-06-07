Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 07C8F6B0005
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 22:20:22 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id w9so111930050oia.3
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 19:20:22 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 8si14468742iob.70.2016.06.06.19.20.20
        for <linux-mm@kvack.org>;
        Mon, 06 Jun 2016 19:20:21 -0700 (PDT)
Date: Tue, 7 Jun 2016 11:21:23 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: mm: add NR_ZSMALLOC to vmstat
Message-ID: <20160607022123.GD26230@bbox>
References: <20160606200538.GA31983@mwanda>
MIME-Version: 1.0
In-Reply-To: <20160606200538.GA31983@mwanda>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org

Hello Dan,

On Mon, Jun 06, 2016 at 11:05:38PM +0300, Dan Carpenter wrote:
> Hello Minchan Kim,
> 
> The patch b37284200b39: "mm: add NR_ZSMALLOC to vmstat" from Jun 5,
> 2016, leads to the following static checker warning:
> 
> 	mm/zsmalloc.c:1155 alloc_zspage()
> 	error: we previously assumed 'page' could be null (see line 1152)
> 
> mm/zsmalloc.c
>   1130  /*
>   1131   * Allocate a zspage for the given size class
>   1132   */
>   1133  static struct zspage *alloc_zspage(struct zs_pool *pool,
>   1134                                          struct size_class *class,
>   1135                                          gfp_t gfp)
>   1136  {
>   1137          int i;
>   1138          struct page *pages[ZS_MAX_PAGES_PER_ZSPAGE];
>   1139          struct zspage *zspage = cache_alloc_zspage(pool, gfp);
>   1140  
>   1141          if (!zspage)
>   1142                  return NULL;
>   1143  
>   1144          memset(zspage, 0, sizeof(struct zspage));
>   1145          zspage->magic = ZSPAGE_MAGIC;
>   1146          migrate_lock_init(zspage);
>   1147  
>   1148          for (i = 0; i < class->pages_per_zspage; i++) {
>   1149                  struct page *page;
>   1150  
>   1151                  page = alloc_page(gfp);
>   1152                  if (!page) {
>                              ^^^^
>   1153                          while (--i >= 0) {
>   1154                                  __free_page(pages[i]);
>   1155                                  dec_zone_page_state(page, NR_ZSMALLOC);
>                                                             ^^^^
> Potential NULL deref inside function call.

Strictly speaking, it shouldn't be a problem because zone bit encoded
in page->flags is never changed although it is freed but I admit its'
not good pracice. I will send fix.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
