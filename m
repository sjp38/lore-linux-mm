Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id AE7226B0037
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 10:42:10 -0400 (EDT)
Received: by mail-la0-f43.google.com with SMTP id gi9so10000744lab.30
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 07:42:09 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id mk4si8757131lbc.48.2014.09.10.07.42.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 07:42:08 -0700 (PDT)
Date: Wed, 10 Sep 2014 16:42:06 +0200 (CEST)
From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH] mm/sl[aou]b: make kfree() aware of error pointers
In-Reply-To: <CAPAsAGyYoPjThA1EV46jYiGX2UzqF1oD4JJueNKh9V1XvAXjcA@mail.gmail.com>
Message-ID: <alpine.LNX.2.00.1409101640350.5523@pobox.suse.cz>
References: <alpine.LNX.2.00.1409092319370.5523@pobox.suse.cz> <20140909162114.44b3e98cf925f125e84a8a06@linux-foundation.org> <alpine.LNX.2.00.1409100702190.5523@pobox.suse.cz> <20140910140759.GC31903@thunk.org> <alpine.LNX.2.00.1409101613500.5523@pobox.suse.cz>
 <CAPAsAGyYoPjThA1EV46jYiGX2UzqF1oD4JJueNKh9V1XvAXjcA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dan Carpenter <dan.carpenter@oracle.com>

On Wed, 10 Sep 2014, Andrey Ryabinin wrote:

> > I of course have no objections to this check being added to whatever
> > static checker, that would be very welcome improvement.
> >
> > Still, I believe that kernel shouldn't be just ignoring kfree(ERR_PTR)
> > happening. Would something like the below be more acceptable?
> >
> >
> >
> > From: Jiri Kosina <jkosina@suse.cz>
> > Subject: [PATCH] mm/sl[aou]b: make kfree() aware of error pointers
> >
> > Freeing if ERR_PTR is not covered by ZERO_OR_NULL_PTR() check already
> > present in kfree(), but it happens in the wild and has disastrous effects.
> >
> > Issue a warning and don't proceed trying to free the memory if
> > CONFIG_DEBUG_SLAB is set.
> >
> 
> This won't work cause CONFIG_DEBUG_SLAB  is only for CONFIG_SLAB=y
> 
> How about just VM_BUG_ON(IS_ERR(ptr)); ?

VM_BUG_ON() makes very little sense to me, as we are going to oops anyway 
later, so it's a lose-lose situation.

VM_WARN_ON() + return seems like much more reasonable choice.

-- 
Jiri Kosina
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
