Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 8D18E9003C7
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 22:13:27 -0400 (EDT)
Received: by paceq1 with SMTP id eq1so31893207pac.3
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 19:13:27 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id aa8si6279735pbd.223.2015.07.01.19.13.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jul 2015 19:13:26 -0700 (PDT)
Received: by paceq1 with SMTP id eq1so31892959pac.3
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 19:13:26 -0700 (PDT)
Date: Thu, 2 Jul 2015 11:13:54 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCHv4 6/7] zsmalloc: account the number of compacted
 pages
Message-ID: <20150702021354.GA637@swordfish>
References: <1435667758-14075-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1435667758-14075-7-git-send-email-sergey.senozhatsky@gmail.com>
 <20150701072952.GA537@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150701072952.GA537@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (07/01/15 16:29), Sergey Senozhatsky wrote:
> 	if (putback_zspage(.. src_page))
> 		pool->num_migrated++;

      pool->num_migrated += class->pages_per_zspage;
Of course.

> (c) or we can check src_page fullness (or simply if src_page->inuse == 0)
> in __zs_compact() and increment ->num_migrated for ZS_EMPTY page. But this
> is what free_zspage() already does.

In other words, something like this (and we don't need nr_migrated in
zs_compact_control anymore). Not a real patch, just to demonstrate the
idea.

---

@@ -1596,8 +1596,6 @@ struct zs_compact_control {
 	 /* Starting object index within @s_page which used for live object
 	  * in the subpage. */
 	int index;
-	/* How many of objects were migrated */
-	int nr_migrated;
 };
 
 static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
@@ -1634,7 +1632,6 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
 		record_obj(handle, free_obj);
 		unpin_tag(handle);
 		obj_free(pool, class, used_obj);
-		cc->nr_migrated++;
 	}
 
 	/* Remember last position in this iteration */
@@ -1720,7 +1717,6 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 	struct page *src_page;
 	struct page *dst_page = NULL;
 
-	cc.nr_migrated = 0;
 	spin_lock(&class->lock);
 	while ((src_page = isolate_source_page(class))) {
 
@@ -1748,6 +1744,9 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 		if (dst_page == NULL)
 			break;
 
+		if (!src_page->inuse)
+			pool->num_migrated += class->pages_per_zspage;
+
 		putback_zspage(pool, class, dst_page);
 		putback_zspage(pool, class, src_page);
 		spin_unlock(&class->lock);
@@ -1758,8 +1757,6 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 	if (src_page)
 		putback_zspage(pool, class, src_page);
 
-	pool->num_migrated += cc.nr_migrated;
-
 	spin_unlock(&class->lock);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
