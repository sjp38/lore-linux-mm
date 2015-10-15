Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 53E246B0038
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 23:52:27 -0400 (EDT)
Received: by payp3 with SMTP id p3so26012188pay.1
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 20:52:27 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id tb8si18332281pab.225.2015.10.14.20.52.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Oct 2015 20:52:26 -0700 (PDT)
Received: by payp3 with SMTP id p3so26012016pay.1
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 20:52:26 -0700 (PDT)
Date: Thu, 15 Oct 2015 12:53:17 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] zsmalloc: don't test shrinker_enabled in
 zs_shrinker_count()
Message-ID: <20151015035317.GF1735@swordfish>
References: <1444787879-5428-1-git-send-email-sergey.senozhatsky@gmail.com>
 <20151015022928.GB2840@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151015022928.GB2840@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (10/15/15 11:29), Minchan Kim wrote:
[..]
> I'm in favor of removing shrinker disable feature with this patch(
> although we didn't implement it yet) because if there is some problem
> of compaction, we should reveal and fix it without hiding with the
> feature.
> 

sure.

> One thing I want is if we decide it, let's remove all things
> about shrinker_enabled(ie, variable).
> If we might need it later, we could introduce it easily.

well, do we really want to make the shrinker a vital part of zsmalloc?

it's not that we will tighten the dependency between zsmalloc and
shrinker, we will introduce it instead. in a sense that, at the moment,
zsmalloc is, let's say, ignorant to shrinker registration errors
(shrinker registration implementation is internal to shrinker), because
there is no direct impact on zsmalloc functionality -- zsmalloc will not
be able to release some pages (there are if-s here: first, zsmalloc
shrinker callback may even not be called; second, zsmalloc may not be
albe to migrate objects and release objects).

no really strong opinion against, but at the same time zsmalloc will
have another point of failure (again, zsmalloc should not be aware of
shrinker registration implementation and why it may fail).

so... I can prepare a new patch later today.

	-ss

> 
> > 
> > Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > ---
> >  mm/zsmalloc.c | 3 ---
> >  1 file changed, 3 deletions(-)
> > 
> > diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> > index 7ad5e54..8ba247d 100644
> > --- a/mm/zsmalloc.c
> > +++ b/mm/zsmalloc.c
> > @@ -1822,9 +1822,6 @@ static unsigned long zs_shrinker_count(struct shrinker *shrinker,
> >  	struct zs_pool *pool = container_of(shrinker, struct zs_pool,
> >  			shrinker);
> >  
> > -	if (!pool->shrinker_enabled)
> > -		return 0;
> > -
> >  	for (i = zs_size_classes - 1; i >= 0; i--) {
> >  		class = pool->size_class[i];
> >  		if (!class)
> > -- 
> > 2.6.1.134.g4b1fd35
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
