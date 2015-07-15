Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id EA72C2802C4
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 19:59:13 -0400 (EDT)
Received: by pachj5 with SMTP id hj5so32187489pac.3
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 16:59:13 -0700 (PDT)
Received: from mail-pd0-x236.google.com (mail-pd0-x236.google.com. [2607:f8b0:400e:c02::236])
        by mx.google.com with ESMTPS id m3si9948904pdh.67.2015.07.15.16.59.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 16:59:13 -0700 (PDT)
Received: by pdbep18 with SMTP id ep18so34426162pdb.1
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 16:59:12 -0700 (PDT)
Date: Thu, 16 Jul 2015 08:59:44 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 3/3] zsmalloc: do not take class lock in
 zs_pages_to_compact()
Message-ID: <20150715235944.GA3970@swordfish>
References: <1436607932-7116-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1436607932-7116-4-git-send-email-sergey.senozhatsky@gmail.com>
 <20150715040703.GA545@swordfish>
 <20150715233834.GA988@bgram>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150715233834.GA988@bgram>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hi,

On (07/16/15 08:38), Minchan Kim wrote:
> > > diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> > > index b10a228..824c182 100644
> > > --- a/mm/zsmalloc.c
> > > +++ b/mm/zsmalloc.c
> > > @@ -1811,9 +1811,7 @@ unsigned long zs_pages_to_compact(struct zs_pool *pool)
> > >  		if (class->index != i)
> > >  			continue;
> > >  
> > > -		spin_lock(&class->lock);
> > >  		pages_to_free += zs_can_compact(class);
> > > -		spin_unlock(&class->lock);
> > >  	}
> > >  
> > >  	return pages_to_free;
> > 
> > This patch still makes sense. Agree?
> 
> There is already race window between shrink_count and shrink_slab so
> it would be okay if we return stale stat with removing the lock if
> the difference is not huge.
> 
> Even, now we don't obey nr_to_scan of shrinker in zs_shrinker_scan
> so the such accuracy would be pointless.

Yeah, automatic shrinker may work concurrently with the user triggered
one, so it may be hard (time consuming) to release the exact amount of
pages that we returned from _count(). We can look at `sc->nr_to_reclaim'
to avoid releasing more pages than shrinker wants us to release, but
I'd probably prefer to keep the existing behaviour if we were called by
the shrinker.

OK, will resend later today.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
