Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id CCEAA6B0083
	for <linux-mm@kvack.org>; Fri, 13 Feb 2015 16:20:12 -0500 (EST)
Received: by iebtr6 with SMTP id tr6so11999463ieb.10
        for <linux-mm@kvack.org>; Fri, 13 Feb 2015 13:20:12 -0800 (PST)
Received: from mail-ig0-x22a.google.com (mail-ig0-x22a.google.com. [2607:f8b0:4001:c05::22a])
        by mx.google.com with ESMTPS id i84si6426248ioo.79.2015.02.13.13.20.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Feb 2015 13:20:12 -0800 (PST)
Received: by mail-ig0-f170.google.com with SMTP id l13so18348373iga.1
        for <linux-mm@kvack.org>; Fri, 13 Feb 2015 13:20:12 -0800 (PST)
Date: Fri, 13 Feb 2015 13:20:10 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/3] Slab infrastructure for array operations
In-Reply-To: <alpine.DEB.2.11.1502130941360.9442@gentwo.org>
Message-ID: <alpine.DEB.2.10.1502131315500.24226@chino.kir.corp.google.com>
References: <20150210194804.288708936@linux.com> <20150210194811.787556326@linux.com> <alpine.DEB.2.10.1502101542030.15535@chino.kir.corp.google.com> <alpine.DEB.2.11.1502111243380.3887@gentwo.org> <alpine.DEB.2.10.1502111213151.16711@chino.kir.corp.google.com>
 <20150213023534.GA6592@js1304-P5Q-DELUXE> <alpine.DEB.2.11.1502130941360.9442@gentwo.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, akpm@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com, Jesper Dangaard Brouer <brouer@redhat.com>

On Fri, 13 Feb 2015, Christoph Lameter wrote:

> > I also think that this implementation is slub-specific. For example,
> > in slab case, it is always better to access local cpu cache first than
> > page allocator since slab doesn't use list to manage free objects and
> > there is no cache line overhead like as slub. I think that,
> > in kmem_cache_alloc_array(), just call to allocator-defined
> > __kmem_cache_alloc_array() is better approach.
> 
> What do you mean by "better"? Please be specific as to where you would see
> a difference. And slab definititely manages free objects although
> differently than slub. SLAB manages per cpu (local) objects, per node
> partial lists etc. Same as SLUB. The cache line overhead is there but no
> that big a difference in terms of choosing objects to get first.
> 

I think because we currently lack a non-fallback implementation for slab 
that it may be premature to discuss what would be unified if such an 
implementation were to exist.  That unification can always happen later 
if/when the slab implementation is proposed, but I don't think we should 
be unifying an implementation that doesn't exist.  

In other words, I think it would be much cleaner to do just define the 
generic array alloc and array free functions in mm/slab_common.c along 
with their EXPORT_SYMBOL()'s as simple callbacks to per-allocator 
__kmem_cache_{alloc,free}_array() implementations.  I think it's also 
better from a source code perspective to avoid reading two different 
functions and then realizing that nothing is actually unified between them 
(and the absence of an unnecessary #ifdef is currently helpful).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
