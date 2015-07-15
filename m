Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id B32BF2802C4
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 19:38:31 -0400 (EDT)
Received: by padck2 with SMTP id ck2so31788257pad.0
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 16:38:31 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id pt2si9858143pbb.51.2015.07.15.16.38.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 16:38:31 -0700 (PDT)
Received: by padck2 with SMTP id ck2so31788114pad.0
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 16:38:30 -0700 (PDT)
Date: Thu, 16 Jul 2015 08:38:34 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 3/3] zsmalloc: do not take class lock in
 zs_pages_to_compact()
Message-ID: <20150715233834.GA988@bgram>
References: <1436607932-7116-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1436607932-7116-4-git-send-email-sergey.senozhatsky@gmail.com>
 <20150715040703.GA545@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150715040703.GA545@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hi Sergey,

On Wed, Jul 15, 2015 at 01:07:03PM +0900, Sergey Senozhatsky wrote:
> On (07/11/15 18:45), Sergey Senozhatsky wrote:
> [..]
> > We re-do this calculations during compaction on a per class basis
> > anyway.
> > 
> > zs_unregister_shrinker() will not return until we have an active
> > shrinker, so classes won't unexpectedly disappear while
> > zs_pages_to_compact(), invoked by zs_shrinker_count(), iterates
> > them.
> > 
> > When called from zram, we are protected by zram's ->init_lock,
> > so, again, classes will be there until zs_pages_to_compact()
> > iterates them.
> > 
> > Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > ---
> >  mm/zsmalloc.c | 2 --
> >  1 file changed, 2 deletions(-)
> > 
> > diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> > index b10a228..824c182 100644
> > --- a/mm/zsmalloc.c
> > +++ b/mm/zsmalloc.c
> > @@ -1811,9 +1811,7 @@ unsigned long zs_pages_to_compact(struct zs_pool *pool)
> >  		if (class->index != i)
> >  			continue;
> >  
> > -		spin_lock(&class->lock);
> >  		pages_to_free += zs_can_compact(class);
> > -		spin_unlock(&class->lock);
> >  	}
> >  
> >  	return pages_to_free;
> 
> This patch still makes sense. Agree?

There is already race window between shrink_count and shrink_slab so
it would be okay if we return stale stat with removing the lock if
the difference is not huge.

Even, now we don't obey nr_to_scan of shrinker in zs_shrinker_scan
so the such accuracy would be pointless.

Please resend the patch and correct zs_can_compact's comment.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
