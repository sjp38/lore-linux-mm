Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 121996B0083
	for <linux-mm@kvack.org>; Wed, 23 May 2012 21:01:54 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so14991074pbb.14
        for <linux-mm@kvack.org>; Wed, 23 May 2012 18:01:53 -0700 (PDT)
Date: Wed, 23 May 2012 18:01:51 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] slab+slob: dup name string
In-Reply-To: <alpine.DEB.2.00.1205230849410.29893@router.home>
Message-ID: <alpine.DEB.2.00.1205231759460.28167@chino.kir.corp.google.com>
References: <1337680298-11929-1-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1205220857380.17600@router.home> <alpine.DEB.2.00.1205222048380.28165@chino.kir.corp.google.com> <alpine.DEB.2.00.1205230849410.29893@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Glauber Costa <glommer@parallels.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>

On Wed, 23 May 2012, Christoph Lameter wrote:

> > No, it's not, there's no reason to prevent caches created before
> > g_cpucache_up <= EARLY to be destroyed because it makes a patch easier to
> > implement and then leave that little gotcha as an undocumented treasure
> > for someone to find when they try it later on.
> 
> g_cpucache_up <= EARLY is slab bootstrap code and the system is in a
> pretty fragile state. Plus the the kmalloc logic *depends* on these
> caches being present. Removing those is not a good idea. The other caches
> that are created at that point are needed to create more caches.
> 
> There is no reason to remove these caches.
> 

Yes, we know that we don't want to remove the caches that are currently 
created in kmem_cache_init(), it would be a pretty stupid thing to do.  
I'm talking about the possibility of creating additional caches while 
g_cpucache_up <= EARLY in the future and then finding that you can't 
destroy them because of this string allocation.  I don't think it's too 
difficult to statically allocate space for these names and then test for 
it before doing kfree() in kmem_cache_destroy(), it's not performance 
critical.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
