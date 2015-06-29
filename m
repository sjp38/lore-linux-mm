Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 783FB6B006E
	for <linux-mm@kvack.org>; Mon, 29 Jun 2015 02:52:09 -0400 (EDT)
Received: by pabvl15 with SMTP id vl15so100693725pab.1
        for <linux-mm@kvack.org>; Sun, 28 Jun 2015 23:52:09 -0700 (PDT)
Received: from mail-pd0-x22d.google.com (mail-pd0-x22d.google.com. [2607:f8b0:400e:c02::22d])
        by mx.google.com with ESMTPS id rt15si62884906pab.240.2015.06.28.23.52.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Jun 2015 23:52:08 -0700 (PDT)
Received: by pdjn11 with SMTP id n11so111718296pdj.0
        for <linux-mm@kvack.org>; Sun, 28 Jun 2015 23:52:08 -0700 (PDT)
Date: Mon, 29 Jun 2015 15:52:18 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC][PATCHv3 2/7] zsmalloc: partial page ordering within a
 fullness_list
Message-ID: <20150629065218.GC13179@bbox>
References: <1434628004-11144-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1434628004-11144-3-git-send-email-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1434628004-11144-3-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Thu, Jun 18, 2015 at 08:46:39PM +0900, Sergey Senozhatsky wrote:
> We want to see more ZS_FULL pages and less ZS_ALMOST_{FULL, EMPTY}
> pages. Put a page with higher ->inuse count first within its
> ->fullness_list, which will give us better chances to fill up this
> page with new objects (find_get_zspage() return ->fullness_list head
> for new object allocation), so some zspages will become
> ZS_ALMOST_FULL/ZS_FULL quicker.
> 
> It performs a trivial and cheap ->inuse compare which does not slow
> down zsmalloc, and in the worst case it keeps the list pages not in
> any particular order, just like we do it now.
> 
> A more expensive solution could sort fullness_list by ->inuse count.
> 
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> ---
>  mm/zsmalloc.c | 12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 7d816c2..6e2ebb6 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -659,8 +659,16 @@ static void insert_zspage(struct page *page, struct size_class *class,
>  		return;
>  
>  	head = &class->fullness_list[fullness];
> -	if (*head)
> -		list_add_tail(&page->lru, &(*head)->lru);
> +	if (*head) {
> +		/*
> +		 * We want to see more ZS_FULL pages and less almost
> +		 * empty/full. Put pages with higher ->inuse first.
> +		 */
> +		if (page->inuse < (*head)->inuse)
> +			list_add_tail(&page->lru, &(*head)->lru);
> +		else
> +			list_add(&page->lru, &(*head)->lru);
> +	}

>  
>  	*head = page;

Why do you want to always put @page in the head?
How about this?

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index e8cb31c..1c5fde9 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -658,21 +658,25 @@ static void insert_zspage(struct page *page, struct size_class *class,
        if (fullness >= _ZS_NR_FULLNESS_GROUPS)
                return;

+       zs_stat_inc(class, fullness == ZS_ALMOST_EMPTY ?
+                       CLASS_ALMOST_EMPTY : CLASS_ALMOST_FULL, 1);
+
        head = &class->fullness_list[fullness];
-       if (*head) {
-               /*
-                * We want to see more ZS_FULL pages and less almost
-                * empty/full. Put pages with higher ->inuse first.
-                */
-               if (page->inuse < (*head)->inuse)
-                       list_add_tail(&page->lru, &(*head)->lru);
-               else
-                       list_add(&page->lru, &(*head)->lru);
+       if (!*head) {
+               *head = page;
+               return;
        }

-       *head = page;
-       zs_stat_inc(class, fullness == ZS_ALMOST_EMPTY ?
-                       CLASS_ALMOST_EMPTY : CLASS_ALMOST_FULL, 1);
+       /*
+        * We want to see more ZS_FULL pages and less almost
+        * empty/full. Put pages with higher ->inuse first.
+        */
+       list_add_tail(&page->lru, &(*head)->lru);
+       if (page->inuse >= (*head)->inuse)
+               *head = page;
 }

 /*
-- 
1.7.9.5




>  	zs_stat_inc(class, fullness == ZS_ALMOST_EMPTY ?
> -- 
> 2.4.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
