Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id B7FE96B0038
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 09:54:30 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f188so1744811929pgc.1
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 06:54:30 -0800 (PST)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id 63si79711003pgi.211.2017.01.06.06.54.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jan 2017 06:54:29 -0800 (PST)
Received: by mail-pg0-x244.google.com with SMTP id i5so44279008pgh.2
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 06:54:29 -0800 (PST)
Date: Fri, 6 Jan 2017 05:54:23 -0900
From: Kent Overstreet <kent.overstreet@gmail.com>
Subject: Re: [PATCH] mm: introduce kv[mz]alloc helpers
Message-ID: <20170106145423.vat6pdamcdvxuxx4@moria.home.lan>
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
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-bcache@vger.kernel.org

On Thu, Jan 05, 2017 at 07:40:10PM +0900, Tetsuo Handa wrote:
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
> 
> Kent, how do you want to correct this? You want to apply
> a patch that removes gfp argument before applying this patch?
> Or, you want Michal to directly overwrite by this patch?
> 
> Michal, "(fifo)->data = NULL;" line will become redundant
> and "(gfp) & GFP_KERNEL" will become "GFP_KERNEL".

Please just go ahead and replace all that crap with a single call to kvmalloc().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
