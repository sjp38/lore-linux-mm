Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 059B06B02AF
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 15:52:01 -0400 (EDT)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id o6NJpwhH018010
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 12:51:59 -0700
Received: from pxi14 (pxi14.prod.google.com [10.243.27.14])
	by hpaq14.eem.corp.google.com with ESMTP id o6NJpufn029942
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 12:51:57 -0700
Received: by pxi14 with SMTP id 14so3775448pxi.19
        for <linux-mm@kvack.org>; Fri, 23 Jul 2010 12:51:56 -0700 (PDT)
Date: Fri, 23 Jul 2010 12:51:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 3/6] fs: remove dependency on __GFP_NOFAIL
In-Reply-To: <20100723123618.3b2b8824.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1007231244440.5317@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1007201936210.8728@chino.kir.corp.google.com> <alpine.DEB.2.00.1007201939430.8728@chino.kir.corp.google.com> <20100723123618.3b2b8824.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 23 Jul 2010, Andrew Morton wrote:

> > The kmalloc() in bio_integrity_prep() is failable, so remove __GFP_NOFAIL
> > from its mask.
> > 
> > Cc: Jens Axboe <jens.axboe@oracle.com>
> > Signed-off-by: David Rientjes <rientjes@google.com>
> > ---
> >  fs/bio-integrity.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/fs/bio-integrity.c b/fs/bio-integrity.c
> > --- a/fs/bio-integrity.c
> > +++ b/fs/bio-integrity.c
> > @@ -413,7 +413,7 @@ int bio_integrity_prep(struct bio *bio)
> >  
> >  	/* Allocate kernel buffer for protection data */
> >  	len = sectors * blk_integrity_tuple_size(bi);
> > -	buf = kmalloc(len, GFP_NOIO | __GFP_NOFAIL | q->bounce_gfp);
> > +	buf = kmalloc(len, GFP_NOIO | q->bounce_gfp);
> >  	if (unlikely(buf == NULL)) {
> >  		printk(KERN_ERR "could not allocate integrity buffer\n");
> >  		return -EIO;
> 
>                         ^^^  what?
> 

Right, I'm not sure why that decision was made, but it looks like it can 
be changed over to -ENOMEM without harming anything.  I'm concerned that 
the printk will spam the kernel log endlessly, though, if we're really oom 
and GFP_NOIO has no hope of freeing memory.  This code has never been 
active, so I'd like to wait for some feedback from Al and Jens (now with a 
corrected email address, jens.axboe@oracle.com bounced) to see if we want 
to return -ENOMEM, if the printk is really necessary, and if it would be 
better to just convert this to a loop with a congestion_wait() instead of 
returning from bio_integrity_prep().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
