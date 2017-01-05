Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8BC166B0069
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 05:59:38 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id k184so49968901wme.4
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 02:59:38 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w69si81304855wmd.78.2017.01.05.02.59.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Jan 2017 02:59:37 -0800 (PST)
Date: Thu, 5 Jan 2017 11:59:36 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: introduce kv[mz]alloc helpers
Message-ID: <20170105105936.GL21618@dhcp22.suse.cz>
References: <20170102133700.1734-1-mhocko@kernel.org>
 <20170104142022.GL25453@dhcp22.suse.cz>
 <05308767-7f1b-6c4d-12d7-3dfcb94376c5@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <05308767-7f1b-6c4d-12d7-3dfcb94376c5@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-bcache@vger.kernel.org, kent.overstreet@gmail.com

On Thu 05-01-17 19:40:10, Tetsuo Handa wrote:
> On 2017/01/04 23:20, Michal Hocko wrote:
> > OK, so I've checked the open coded implementations and converted most of
> > them. There are few which are either confused and need some special
> > handling or need double checking.
> > 
> > diff --git a/drivers/md/bcache/util.h b/drivers/md/bcache/util.h
> > index cf2cbc211d83..9dc0f0ff0321 100644
> > --- a/drivers/md/bcache/util.h
> > +++ b/drivers/md/bcache/util.h
> > @@ -44,10 +44,7 @@ struct closure;
> >  	(heap)->size = (_size);						\
> >  	_bytes = (heap)->size * sizeof(*(heap)->data);			\
> >  	(heap)->data = NULL;						\
> > -	if (_bytes < KMALLOC_MAX_SIZE)					\
> > -		(heap)->data = kmalloc(_bytes, (gfp));			\
> > -	if ((!(heap)->data) && ((gfp) & GFP_KERNEL))			\
> > -		(heap)->data = vmalloc(_bytes);				\
> > +	(heap)->data = kvmalloc(_bytes, (gfp) & GFP_KERNEL);		\
> >  	(heap)->data;							\
> >  })
> >  
> > @@ -138,10 +135,7 @@ do {									\
> >  	(fifo)->front = (fifo)->back = 0;				\
> >  	(fifo)->data = NULL;						\
> >  									\
> > -	if (_bytes < KMALLOC_MAX_SIZE)					\
> > -		(fifo)->data = kmalloc(_bytes, (gfp));			\
> > -	if ((!(fifo)->data) && ((gfp) & GFP_KERNEL))			\
> > -		(fifo)->data = vmalloc(_bytes);				\
> > +	(fifo)->data = kvmalloc(_bytes, (gfp) & GFP_KERNEL);		\
> >  	(fifo)->data;							\
> >  })
> 
> These macros are doing strange checks.
> ((gfp) & GFP_KERNEL) means any bit in GFP_KERNEL is set.
> ((gfp) & GFP_KERNEL) == GFP_KERNEL might make sense. Actually,
> all callers seems to be passing GFP_KERNEL to these macros.

Yes the code is confused. I've seen worse when going through the drivers
code...

> Kent, how do you want to correct this? You want to apply
> a patch that removes gfp argument before applying this patch?
> Or, you want Michal to directly overwrite by this patch?

I would just get rid of it here as init_heap has just one caller with
GFP_KERNEL and __init_fifo has GFP_KERNEL users as well. But if it is
preferable to clean up this first then I can do that.
 
> Michal, "(fifo)->data = NULL;" line will become redundant
> and "(gfp) & GFP_KERNEL" will become "GFP_KERNEL".

true. will remove it.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
