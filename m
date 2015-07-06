Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0B13828029D
	for <linux-mm@kvack.org>; Mon,  6 Jul 2015 03:52:51 -0400 (EDT)
Received: by pacgz10 with SMTP id gz10so17586762pac.3
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 00:52:50 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id pd1si27722892pdb.79.2015.07.06.00.52.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jul 2015 00:52:50 -0700 (PDT)
Received: by pacws9 with SMTP id ws9so92777656pac.0
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 00:52:50 -0700 (PDT)
Date: Mon, 6 Jul 2015 16:52:41 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC][PATCHv4 6/7] zsmalloc: account the number of compacted
 pages
Message-ID: <20150706075241.GA6514@blaptop>
References: <1435667758-14075-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1435667758-14075-7-git-send-email-sergey.senozhatsky@gmail.com>
 <20150701072952.GA537@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150701072952.GA537@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hi Sergey,

On Wed, Jul 01, 2015 at 04:29:52PM +0900, Sergey Senozhatsky wrote:
> On (06/30/15 21:35), Sergey Senozhatsky wrote:
> [..]
> >  	if (src_page)
> >  		putback_zspage(pool, class, src_page);
> >  
> > -	pool->num_migrated += cc.nr_migrated;
> > +	cc.nr_migrated /= get_maxobj_per_zspage(class->size,
> > +			class->pages_per_zspage);
> > +
> > +	pool->num_migrated += cc.nr_migrated *
> > +		get_pages_per_zspage(class->size);
> >  
> >  	spin_unlock(&class->lock);
> 
> Oh, well. This is bloody wrong, sorry. We don't pick up src_page-s that we
> can completely drain. Thus, the fact that we can't compact (!zs_can_compact())
> anymore doesn't mean that we actually have released any zspages.
> 
> So...
> 
> (a) we can isolate_source_page() more accurately -- iterate list and
> look for pages that have ->inuse less or equal to the amount of unused
> objects. So we can guarantee that this particular zspage will be released
> at the end. It adds O(n) every time we isolate_source_page(), because
> the number of unused objects changes. But it's sort of worth it, I
> think. Otherwise we still can move M objects w/o releasing any pages
> after all. If we consider compaction as a slow path (and I think we do)
> then this option doesn't look so bad.
> 
> 
> 
> (b) if (a) is not an option, then we need to know that we have drained the
> src_page. And it seems that the easiest way to do it is to change
> 'void putback_zspage(...)' to 'bool putback_zspage(...)' and return `true'
> from putback_zspage() when putback resulted in free_zspage() (IOW, the page
> was ZS_EMPTY). And in __zs_compact() do something like

Just nit:

putback_zspage is not related to "free zspage" so I want to handle it in
caller. For it, putback_zspage could return fullness type page is added.
Something like that.

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 99133e8..32e3bb9 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1653,7 +1653,17 @@ static struct page *isolate_target_page(struct size_class *class)
 	return page;
 }
 
-static void putback_zspage(struct zs_pool *pool, struct size_class *class,
+/*
+ * putback_zspage - add @first_page into right class's fullness list
+ * @pool: target pool
+ * @class: destination class
+ * @first_page: target page
+ *
+ * Return:
+ * The fullness_group @fist_page is added
+ */
+static enum fullness_group putback_zspage(struct zs_pool *pool,
+				struct size_class *class,
 				struct page *first_page)
 {
 	enum fullness_group fullness;
@@ -1672,6 +1682,8 @@ static void putback_zspage(struct zs_pool *pool, struct size_class *class,
 
 		free_zspage(first_page);
 	}
+
+	return fullness;
 }
 
 static struct page *isolate_source_page(struct size_class *class)
@@ -1707,11 +1719,13 @@ static unsigned long zs_can_compact(struct size_class *class)
 	return obj_wasted * get_pages_per_zspage(class->size);
 }
 
-static void __zs_compact(struct zs_pool *pool, struct size_class *class)
+static unsigned long __zs_compact(struct zs_pool *pool,
+				struct size_class *class)
 {
 	struct zs_compact_control cc;
 	struct page *src_page;
 	struct page *dst_page = NULL;
+	unsigned long nr_freed = 0;
 
 	cc.nr_migrated = 0;
 	spin_lock(&class->lock);
@@ -1742,7 +1756,8 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 			break;
 
 		putback_zspage(pool, class, dst_page);
-		putback_zspage(pool, class, src_page);
+		if (ZS_EMPTY == putback_zspage(pool, class, src_page))
+			nr_freed += get_pages_per_zspage(class->size);
 		spin_unlock(&class->lock);
 		cond_resched();
 		spin_lock(&class->lock);
@@ -1758,22 +1773,36 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 		get_pages_per_zspage(class->size);
 
 	spin_unlock(&class->lock);
+
+	return nr_freed;
 }
 
+/*
+ * zs_compact - migrate objects and free empty zspage in the @pool
+ * @pool: target pool for compaction
+ *
+ * Return:
+ * The number of freed pages by compaction
+ */
 unsigned long zs_compact(struct zs_pool *pool)
 {
 	int i;
 	struct size_class *class;
+	unsigned long nr_freed = 0;
 
 	for (i = zs_size_classes - 1; i >= 0; i--) {
+
 		class = pool->size_class[i];
 		if (!class)
 			continue;
+
 		if (class->index != i)
 			continue;
-		__zs_compact(pool, class);
+
+		nr_freed += __zs_compact(pool, class);
 	}
-	return pool->num_migrated;
+
+	return nr_freed;
 }
 EXPORT_SYMBOL_GPL(zs_compact);
 
-- 
1.9.3



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
