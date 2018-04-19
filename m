Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id B06B86B0005
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 17:19:26 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id n5-v6so4441092qtl.13
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 14:19:26 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id o5si5770575qkb.160.2018.04.19.14.19.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Apr 2018 14:19:25 -0700 (PDT)
Date: Thu, 19 Apr 2018 17:19:20 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] kvmalloc: always use vmalloc if CONFIG_DEBUG_VM
In-Reply-To: <20180419124751.8884e516e99825d83da3d87a@linux-foundation.org>
Message-ID: <alpine.LRH.2.02.1804191716100.10099@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1804181029270.19294@file01.intranet.prod.int.rdu2.redhat.com> <3e65977e-53cd-bf09-bc4b-0ce40e9091fe@gmail.com> <alpine.LRH.2.02.1804181218270.19136@file01.intranet.prod.int.rdu2.redhat.com> <20180418.134651.2225112489265654270.davem@davemloft.net>
 <alpine.LRH.2.02.1804181350050.17942@file01.intranet.prod.int.rdu2.redhat.com> <alpine.LRH.2.02.1804191207380.31175@file01.intranet.prod.int.rdu2.redhat.com> <20180419124751.8884e516e99825d83da3d87a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Miller <davem@davemloft.net>, linux-mm@kvack.org, eric.dumazet@gmail.com, edumazet@google.com, bhutchings@solarflare.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, mst@redhat.com, jasowang@redhat.com, virtualization@lists.linux-foundation.org, dm-devel@redhat.com, Vlastimil Babka <vbabka@suse.cz>



On Thu, 19 Apr 2018, Andrew Morton wrote:

> On Thu, 19 Apr 2018 12:12:38 -0400 (EDT) Mikulas Patocka <mpatocka@redhat.com> wrote:
> 
> > The kvmalloc function tries to use kmalloc and falls back to vmalloc if
> > kmalloc fails.
> > 
> > Unfortunatelly, some kernel code has bugs - it uses kvmalloc and then
> > uses DMA-API on the returned memory or frees it with kfree. Such bugs were
> > found in the virtio-net driver, dm-integrity or RHEL7 powerpc-specific
> > code.
> > 
> > These bugs are hard to reproduce because vmalloc falls back to kmalloc
> > only if memory is fragmented.
> 
> Yes, that's nasty.
> 
> > In order to detect these bugs reliably I submit this patch that changes
> > kvmalloc to always use vmalloc if CONFIG_DEBUG_VM is turned on.
> > 
> > ...
> >
> > --- linux-2.6.orig/mm/util.c	2018-04-18 15:46:23.000000000 +0200
> > +++ linux-2.6/mm/util.c	2018-04-18 16:00:43.000000000 +0200
> > @@ -395,6 +395,7 @@ EXPORT_SYMBOL(vm_mmap);
> >   */
> >  void *kvmalloc_node(size_t size, gfp_t flags, int node)
> >  {
> > +#ifndef CONFIG_DEBUG_VM
> >  	gfp_t kmalloc_flags = flags;
> >  	void *ret;
> >  
> > @@ -426,6 +427,7 @@ void *kvmalloc_node(size_t size, gfp_t f
> >  	 */
> >  	if (ret || size <= PAGE_SIZE)
> >  		return ret;
> > +#endif
> >  
> >  	return __vmalloc_node_flags_caller(size, node, flags,
> >  			__builtin_return_address(0));
> 
> Well, it doesn't have to be done at compile-time, does it?  We could
> add a knob (in debugfs, presumably) which enables this at runtime. 
> That's far more user-friendly.

But who will turn it on in debugfs? It should be default for debugging 
kernels, so that users using them would report the error.

Conditioning it on CONFIG_DEBUG_SG is better than CONFIG_DEBUG_VM, it will 
print a stacktrace where the incorrect use happened.

Mikulas
