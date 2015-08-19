Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 045E56B0038
	for <linux-mm@kvack.org>; Wed, 19 Aug 2015 10:25:49 -0400 (EDT)
Received: by pabyb7 with SMTP id yb7so4399616pab.0
        for <linux-mm@kvack.org>; Wed, 19 Aug 2015 07:25:48 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id wh10si1462514pbc.172.2015.08.19.07.25.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Aug 2015 07:25:48 -0700 (PDT)
Date: Wed, 19 Aug 2015 17:25:36 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH] list_lru: don't call list_lru_from_kmem if the list_head
 is empty
Message-ID: <20150819142536.GP21209@esperanza>
References: <1439993140-13362-1-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1439993140-13362-1-git-send-email-jeff.layton@primarydata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Aug 19, 2015 at 10:05:40AM -0400, Jeff Layton wrote:
> If the list_head is empty then we'll have called list_lru_from_kmem
> for nothing. Move that call inside of the list_empty if block.
> 
> Cc: Vladimir Davydov <vdavydov@parallels.com>
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>

Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>

> ---
>  mm/list_lru.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/list_lru.c b/mm/list_lru.c
> index 909eca2c820e..e1da19fac1b3 100644
> --- a/mm/list_lru.c
> +++ b/mm/list_lru.c
> @@ -99,8 +99,8 @@ bool list_lru_add(struct list_lru *lru, struct list_head *item)
>  	struct list_lru_one *l;
>  
>  	spin_lock(&nlru->lock);
> -	l = list_lru_from_kmem(nlru, item);
>  	if (list_empty(item)) {
> +		l = list_lru_from_kmem(nlru, item);
>  		list_add_tail(item, &l->list);
>  		l->nr_items++;
>  		spin_unlock(&nlru->lock);
> @@ -118,8 +118,8 @@ bool list_lru_del(struct list_lru *lru, struct list_head *item)
>  	struct list_lru_one *l;
>  
>  	spin_lock(&nlru->lock);
> -	l = list_lru_from_kmem(nlru, item);
>  	if (!list_empty(item)) {
> +		l = list_lru_from_kmem(nlru, item);
>  		list_del_init(item);
>  		l->nr_items--;
>  		spin_unlock(&nlru->lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
