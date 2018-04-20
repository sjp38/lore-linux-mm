Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id F0BA16B000C
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 08:16:58 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id v187so5628318qka.5
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 05:16:58 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id x67si1533723qkd.1.2018.04.20.05.16.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Apr 2018 05:16:57 -0700 (PDT)
Date: Fri, 20 Apr 2018 08:16:52 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] kvmalloc: always use vmalloc if CONFIG_DEBUG_VM
In-Reply-To: <20180419162250.00bf82e2c40b4960a7e23cdc@linux-foundation.org>
Message-ID: <alpine.LRH.2.02.1804200805200.22382@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1804181029270.19294@file01.intranet.prod.int.rdu2.redhat.com> <3e65977e-53cd-bf09-bc4b-0ce40e9091fe@gmail.com> <alpine.LRH.2.02.1804181218270.19136@file01.intranet.prod.int.rdu2.redhat.com> <20180418.134651.2225112489265654270.davem@davemloft.net>
 <alpine.LRH.2.02.1804181350050.17942@file01.intranet.prod.int.rdu2.redhat.com> <alpine.LRH.2.02.1804191207380.31175@file01.intranet.prod.int.rdu2.redhat.com> <20180419124751.8884e516e99825d83da3d87a@linux-foundation.org>
 <alpine.LRH.2.02.1804191716100.10099@file01.intranet.prod.int.rdu2.redhat.com> <20180419162250.00bf82e2c40b4960a7e23cdc@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Miller <davem@davemloft.net>, linux-mm@kvack.org, eric.dumazet@gmail.com, edumazet@google.com, bhutchings@solarflare.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, mst@redhat.com, jasowang@redhat.com, virtualization@lists.linux-foundation.org, dm-devel@redhat.com, Vlastimil Babka <vbabka@suse.cz>



On Thu, 19 Apr 2018, Andrew Morton wrote:

> On Thu, 19 Apr 2018 17:19:20 -0400 (EDT) Mikulas Patocka <mpatocka@redhat.com> wrote:
> 
> > > > In order to detect these bugs reliably I submit this patch that changes
> > > > kvmalloc to always use vmalloc if CONFIG_DEBUG_VM is turned on.
> > > > 
> > > > ...
> > > >
> > > > --- linux-2.6.orig/mm/util.c	2018-04-18 15:46:23.000000000 +0200
> > > > +++ linux-2.6/mm/util.c	2018-04-18 16:00:43.000000000 +0200
> > > > @@ -395,6 +395,7 @@ EXPORT_SYMBOL(vm_mmap);
> > > >   */
> > > >  void *kvmalloc_node(size_t size, gfp_t flags, int node)
> > > >  {
> > > > +#ifndef CONFIG_DEBUG_VM
> > > >  	gfp_t kmalloc_flags = flags;
> > > >  	void *ret;
> > > >  
> > > > @@ -426,6 +427,7 @@ void *kvmalloc_node(size_t size, gfp_t f
> > > >  	 */
> > > >  	if (ret || size <= PAGE_SIZE)
> > > >  		return ret;
> > > > +#endif
> > > >  
> > > >  	return __vmalloc_node_flags_caller(size, node, flags,
> > > >  			__builtin_return_address(0));
> > > 
> > > Well, it doesn't have to be done at compile-time, does it?  We could
> > > add a knob (in debugfs, presumably) which enables this at runtime. 
> > > That's far more user-friendly.
> > 
> > But who will turn it on in debugfs?
> 
> But who will turn it on in Kconfig?  Just a handful of developers.  We

So, it won't receive much testing.

I've never played with those debugfs files (because I didn't need it), and 
most users also won't play with it. Having a debugfs option is like having 
no option at all.

> could add SONFIG_DEBUG_SG to the list in
> Documentation/process/submit-checklist.rst, but nobody reads that.
> 
> Also, a whole bunch of defconfigs set CONFIG_DEBUG_SG=y and some
> googling indicates that they aren't the only ones...
> 
> > It should be default for debugging 
> > kernels, so that users using them would report the error.
> 
> Well.  This isn't the first time we've wanted to enable expensive (or
> noisy) debugging things in debug kernels, by any means.
> 
> So how could we define a debug kernel in which it's OK to enable such
> things?

Debug kernel is what distributions distribute as debug kernel - i.e. RHEL 
or Fedora have debugging kernels. So it needs to be bound to an option 
that is turned on in these kernels - so that any user who boots the 
debugging kernel triggers the bug.

> - Could be "it's an -rc kernel".  But then we'd be enabling a bunch of
>   untested code when Linus cuts a release.
> 
> - Could be "it's an -rc kernel with SUBLEVEL <= 5".  But then we risk
>   unexpected things happening when Linux cuts -rc6, which still isn't
>   good.
> 
> - How about "it's an -rc kernel with odd-numbered SUBLEVEL and
>   SUBLEVEL <= 5".  That way everybody who runs -rc1, -rc3 and -rc5 will
>   have kvmalloc debugging enabled.  That's potentially nasty because
>   vmalloc is much slower than kmalloc.  But kvmalloc() is only used for
>   large and probably infrequent allocations, so it's probably OK.
> 
> I wonder how we get at SUBLEVEL from within .c.  

Don't bind it to rc level, bind it to some debugging configuration option.

Mikulas
