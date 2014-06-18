Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 526D56B0038
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 20:27:37 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so101185pab.1
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 17:27:37 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id ff3si219450pbd.167.2014.06.17.17.27.35
        for <linux-mm@kvack.org>;
        Tue, 17 Jun 2014 17:27:36 -0700 (PDT)
Date: Wed, 18 Jun 2014 09:31:52 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] slab: fix oops when reading /proc/slab_allocators
Message-ID: <20140618003152.GA13917@js1304-P5Q-DELUXE>
References: <1402967392-7003-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20140617072933.GA26418@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140617072933.GA26418@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org

On Tue, Jun 17, 2014 at 11:29:33AM +0400, Vladimir Davydov wrote:
> Hi,
> 
> On Tue, Jun 17, 2014 at 10:09:52AM +0900, Joonsoo Kim wrote:
> [...]
> > To fix the problem, I introduces object status buffer on each slab.
> > With this, we can track object status precisely, so slab leak detector
> > would not access active object and no kernel oops would occur.
> > Memory overhead caused by this fix is only imposed to
> > CONFIG_DEBUG_SLAB_LEAK which is mainly used for debugging, so memory
> > overhead isn't big problem.
> [...]
> >  
> > +static size_t calculate_freelist_size(int nr_objs, size_t align)
> > +{
> > +	size_t freelist_size;
> > +
> > +	freelist_size = nr_objs * sizeof(freelist_idx_t);
> > +	if (IS_ENABLED(CONFIG_DEBUG_SLAB_LEAK))
> > +		freelist_size += nr_objs * sizeof(char);
> > +
> > +	if (align)
> > +		freelist_size = ALIGN(freelist_size, align);
> > +
> > +	return freelist_size;
> > +}
> > +
> >  static int calculate_nr_objs(size_t slab_size, size_t buffer_size,
> >  				size_t idx_size, size_t align)
> >  {
> >  	int nr_objs;
> > +	size_t remained_size;
> >  	size_t freelist_size;
> > +	int extra_space = 0;
> >  
> > +	if (IS_ENABLED(CONFIG_DEBUG_SLAB_LEAK))
> > +		extra_space = sizeof(char);
> >  	/*
> >  	 * Ignore padding for the initial guess. The padding
> >  	 * is at most @align-1 bytes, and @buffer_size is at
> > @@ -590,14 +641,15 @@ static int calculate_nr_objs(size_t slab_size, size_t buffer_size,
> >  	 * into the memory allocation when taking the padding
> >  	 * into account.
> >  	 */
> > -	nr_objs = slab_size / (buffer_size + idx_size);
> > +	nr_objs = slab_size / (buffer_size + idx_size + extra_space);
> 
> There is one more function that wants to know how much space per object
> is spent for management. It's calculate_slab_order():
> 
> 	if (flags & CFLGS_OFF_SLAB) {
> 		/*
> 		 * Max number of objs-per-slab for caches which
> 		 * use off-slab slabs. Needed to avoid a possible
> 		 * looping condition in cache_grow().
> 		 */
> 		offslab_limit = size;
> 		offslab_limit /= sizeof(freelist_idx_t);
> 
> 		if (num > offslab_limit)
> 			break;
> 	}
> 
> May be, we should update it too?

Hello, Vladimir.

Yes, you are right! I sent v2 with this update. :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
