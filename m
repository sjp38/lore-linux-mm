Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com [209.85.217.170])
	by kanga.kvack.org (Postfix) with ESMTP id 23E616B0036
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 01:05:45 -0400 (EDT)
Received: by mail-lb0-f170.google.com with SMTP id u10so3535834lbd.1
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 22:05:44 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o6si20076064lbc.99.2014.09.09.22.05.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Sep 2014 22:05:43 -0700 (PDT)
Date: Wed, 10 Sep 2014 07:05:40 +0200 (CEST)
From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH] mm/sl[aou]b: make kfree() aware of error pointers
In-Reply-To: <20140909162114.44b3e98cf925f125e84a8a06@linux-foundation.org>
Message-ID: <alpine.LNX.2.00.1409100702190.5523@pobox.suse.cz>
References: <alpine.LNX.2.00.1409092319370.5523@pobox.suse.cz> <20140909162114.44b3e98cf925f125e84a8a06@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Carpenter <dan.carpenter@oracle.com>, Theodore Ts'o <tytso@mit.edu>

On Tue, 9 Sep 2014, Andrew Morton wrote:

> > kfree() is happy to accept NULL pointer and does nothing in such case. 
> > It's reasonable to expect it to behave the same if ERR_PTR is passed to 
> > it.
> > 
> > Inspired by a9cfcd63e8d ("ext4: avoid trying to kfree an ERR_PTR 
> > pointer").
> > 
> > ...
> >
> > --- a/mm/slab.c
> > +++ b/mm/slab.c
> > @@ -3612,7 +3612,7 @@ void kfree(const void *objp)
> >  
> >  	trace_kfree(_RET_IP_, objp);
> >  
> > -	if (unlikely(ZERO_OR_NULL_PTR(objp)))
> > +	if (unlikely(ZERO_OR_NULL_PTR(objp) || IS_ERR(objp)))
> >  		return;
> 
> kfree() is quite a hot path to which this will add overhead.  And we
> have (as far as we know) no code which will actually use this at
> present.

We obviously don't, as such code will be causing explosions. This is meant 
as a prevention of problems such as the one that has just been fixed in 
ext4.

> How about a new
> 
> kfree_safe(...)
> {
> 	if (IS_ERR(...))
> 		return;
> 	if (other-stuff-when-we-think-of-it)
> 		return;
> 	kfree(...);
> }

I think this unfortunately undermines the whole point of the patch ... if 
the caller knows that he might potentially be feeding ERR_PTR() to 
kfree(), he can as well check the pointer himself.

-- 
Jiri Kosina
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
