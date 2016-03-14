Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 18B846B0005
	for <linux-mm@kvack.org>; Mon, 14 Mar 2016 00:54:24 -0400 (EDT)
Received: by mail-io0-f171.google.com with SMTP id n190so209836199iof.0
        for <linux-mm@kvack.org>; Sun, 13 Mar 2016 21:54:24 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id f5si23833137ioj.36.2016.03.13.21.54.22
        for <linux-mm@kvack.org>;
        Sun, 13 Mar 2016 21:54:23 -0700 (PDT)
Date: Mon, 14 Mar 2016 13:55:11 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 09/19] zsmalloc: keep max_object in size_class
Message-ID: <20160314045511.GA6159@bbox>
References: <1457681423-26664-1-git-send-email-minchan@kernel.org>
 <1457681423-26664-10-git-send-email-minchan@kernel.org>
 <56E37490.7060606@hisilicon.com>
MIME-Version: 1.0
In-Reply-To: <56E37490.7060606@hisilicon.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xuyiping <xuyiping@hisilicon.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, rknize@motorola.com, Rik van Riel <riel@redhat.com>, Gioh Kim <gurugio@hanmail.net>

On Sat, Mar 12, 2016 at 09:44:48AM +0800, xuyiping wrote:
> 
> 
> On 2016/3/11 15:30, Minchan Kim wrote:
> >Every zspage in a size_class has same number of max objects so
> >we could move it to a size_class.
> >
> >Signed-off-by: Minchan Kim <minchan@kernel.org>
> >---
> >  mm/zsmalloc.c | 29 ++++++++++++++---------------
> >  1 file changed, 14 insertions(+), 15 deletions(-)
> >
> >diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> >index b4fb11831acb..ca663c82c1fc 100644
> >--- a/mm/zsmalloc.c
> >+++ b/mm/zsmalloc.c
> >@@ -32,8 +32,6 @@
> >   *	page->freelist: points to the first free object in zspage.
> >   *		Free objects are linked together using in-place
> >   *		metadata.
> >- *	page->objects: maximum number of objects we can store in this
> >- *		zspage (class->zspage_order * PAGE_SIZE / class->size)
> >   *	page->lru: links together first pages of various zspages.
> >   *		Basically forming list of zspages in a fullness group.
> >   *	page->mapping: class index and fullness group of the zspage
> >@@ -211,6 +209,7 @@ struct size_class {
> >  	 * of ZS_ALIGN.
> >  	 */
> >  	int size;
> >+	int objs_per_zspage;
> >  	unsigned int index;
> >
> >  	struct zs_size_stat stats;
> >@@ -622,21 +621,22 @@ static inline void zs_pool_stat_destroy(struct zs_pool *pool)
> >   * the pool (not yet implemented). This function returns fullness
> >   * status of the given page.
> >   */
> >-static enum fullness_group get_fullness_group(struct page *first_page)
> >+static enum fullness_group get_fullness_group(struct size_class *class,
> >+						struct page *first_page)
> >  {
> >-	int inuse, max_objects;
> >+	int inuse, objs_per_zspage;
> >  	enum fullness_group fg;
> >
> >  	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
> >
> >  	inuse = first_page->inuse;
> >-	max_objects = first_page->objects;
> >+	objs_per_zspage = class->objs_per_zspage;
> >
> >  	if (inuse == 0)
> >  		fg = ZS_EMPTY;
> >-	else if (inuse == max_objects)
> >+	else if (inuse == objs_per_zspage)
> >  		fg = ZS_FULL;
> >-	else if (inuse <= 3 * max_objects / fullness_threshold_frac)
> >+	else if (inuse <= 3 * objs_per_zspage / fullness_threshold_frac)
> >  		fg = ZS_ALMOST_EMPTY;
> >  	else
> >  		fg = ZS_ALMOST_FULL;
> >@@ -723,7 +723,7 @@ static enum fullness_group fix_fullness_group(struct size_class *class,
> >  	enum fullness_group currfg, newfg;
> >
> >  	get_zspage_mapping(first_page, &class_idx, &currfg);
> >-	newfg = get_fullness_group(first_page);
> >+	newfg = get_fullness_group(class, first_page);
> >  	if (newfg == currfg)
> >  		goto out;
> >
> >@@ -1003,9 +1003,6 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
> >  	init_zspage(class, first_page);
> >
> >  	first_page->freelist = location_to_obj(first_page, 0);
> >-	/* Maximum number of objects we can store in this zspage */
> >-	first_page->objects = class->pages_per_zspage * PAGE_SIZE / class->size;
> >-
> >  	error = 0; /* Success */
> >
> >  cleanup:
> >@@ -1235,11 +1232,11 @@ static bool can_merge(struct size_class *prev, int size, int pages_per_zspage)
> >  	return true;
> >  }
> >
> >-static bool zspage_full(struct page *first_page)
> >+static bool zspage_full(struct size_class *class, struct page *first_page)
> >  {
> >  	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
> >
> >-	return first_page->inuse == first_page->objects;
> >+	return first_page->inuse == class->objs_per_zspage;
> >  }
> >
> >  unsigned long zs_get_total_pages(struct zs_pool *pool)
> >@@ -1625,7 +1622,7 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
> >  		}
> >
> >  		/* Stop if there is no more space */
> >-		if (zspage_full(d_page)) {
> >+		if (zspage_full(class, d_page)) {
> >  			unpin_tag(handle);
> >  			ret = -ENOMEM;
> >  			break;
> >@@ -1684,7 +1681,7 @@ static enum fullness_group putback_zspage(struct zs_pool *pool,
> >  {
> >  	enum fullness_group fullness;
> >
> >-	fullness = get_fullness_group(first_page);
> >+	fullness = get_fullness_group(class, first_page);
> >  	insert_zspage(class, fullness, first_page);
> >  	set_zspage_mapping(first_page, class->index, fullness);
> >
> >@@ -1933,6 +1930,8 @@ struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
> >  		class->size = size;
> >  		class->index = i;
> >  		class->pages_per_zspage = pages_per_zspage;
> >+		class->objs_per_zspage = class->pages_per_zspage *
> >+						PAGE_SIZE / class->size;
> >  		if (pages_per_zspage == 1 &&
> >  			get_maxobj_per_zspage(size, pages_per_zspage) == 1)
> >  			class->huge = true;
> 
> 		computes the "objs_per_zspage" twice here.
> 
> 		class->objs_per_zspage = get_maxobj_per_zspage(size,
> 						pages_per_zspage);
> 		if (pages_per_zspage == 1 && class->objs_per_zspage ==1)
> 			class->huge = true;

Yeb. I will do.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
