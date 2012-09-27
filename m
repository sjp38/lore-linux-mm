Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 313796B0044
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 21:16:15 -0400 (EDT)
Received: by pbbrq2 with SMTP id rq2so3072320pbb.14
        for <linux-mm@kvack.org>; Wed, 26 Sep 2012 18:16:14 -0700 (PDT)
Date: Wed, 26 Sep 2012 18:16:11 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slab: Ignore internal flags in cache creation
In-Reply-To: <5062C029.308@parallels.com>
Message-ID: <alpine.DEB.2.00.1209261813300.7072@chino.kir.corp.google.com>
References: <1348571866-31738-1-git-send-email-glommer@parallels.com> <00000139fe408877-40bc98e3-322c-4ba2-be72-e298ff28e694-000000@email.amazonses.com> <alpine.DEB.2.00.1209251744580.22521@chino.kir.corp.google.com> <5062C029.308@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@cs.helsinki.fi>

On Wed, 26 Sep 2012, Glauber Costa wrote:

> So the problem I am facing here is that when I am creating caches from
> memcg, I would very much like to reuse their flags fields. They are
> stored in the cache itself, so this is not a problem. But slab also
> stores that flag, leading to the precise BUG_ON() on CREATE_MASK that
> you quoted.
> 
> In this context, passing this flag becomes completely valid, I just need
> that to be explicitly masked out.
> 
> What is your suggestion to handle this ?
> 

I would suggest cachep->flags being used solely for the flags passed to 
kmem_cache_create() and seperating out all "internal flags" based on the 
individual slab allocator's implementation into a different field.  There 
should be no problem with moving CFLGS_OFF_SLAB elsewhere, in fact, I just 
removed a "dflags" field from mm/slab.c's kmem_cache that turned out never 
to be used.  You could simply reintroduce a new "internal_flags" field and 
use it at your discretion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
