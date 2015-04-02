Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 12A606B006E
	for <linux-mm@kvack.org>; Thu,  2 Apr 2015 16:42:42 -0400 (EDT)
Received: by patj18 with SMTP id j18so94870379pat.2
        for <linux-mm@kvack.org>; Thu, 02 Apr 2015 13:42:41 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id fl1si9007310pad.47.2015.04.02.13.42.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Apr 2015 13:42:41 -0700 (PDT)
Date: Thu, 2 Apr 2015 13:42:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Slab infrastructure for bulk object allocation and freeing V2
Message-Id: <20150402134239.8e8c538103640d697246ba6a@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.11.1504020922120.28416@gentwo.org>
References: <alpine.DEB.2.11.1503300927290.6646@gentwo.org>
	<20150331142025.63249f2f0189aee231a6e0c8@linux-foundation.org>
	<alpine.DEB.2.11.1504020922120.28416@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linuxfoundation.org, Pekka Enberg <penberg@kernel.org>, iamjoonsoo@lge.com

On Thu, 2 Apr 2015 09:25:37 -0500 (CDT) Christoph Lameter <cl@linux.com> wrote:

> > What's the reason for returning a partial result when ENOMEM?  Some
> > callers will throw away the partial result and simply fail out.  If a
> > caller attempts to go ahead and use the partial result then great, but
> > you can bet that nobody will actually runtime test this situation, so
> > the interface is an invitation for us to release partially-tested code
> > into the wild.
> 
> Just rely on the fact that small allocations never fail? The caller get
> all the requested objects if the function returns?

I'd suggest the latter: either the callee successfully allocates all
the requested objects or it fails.

> > Instead of the above, did you consider doing
> >
> > int __weak kmem_cache_alloc_array(struct kmem_cache *s, gfp_t flags, size_t nr,
> >
> > ?
> >
> > This way we save a level of function call and all that wrapper code in
> > the allocators simply disappears.
> 
> I think we will need the auxiliary function in the common code later
> because that allows the allocations to only do the allocations that
> can be optimized and for the rest just fall back to the generic
> implementations. There may be situations in which the optimizations wont
> work. For SLUB this may be the case f.e. if debug options are enabled.

hm, OK.  The per-allocator wrappers could be made static inline in .h
if that makes sense.


With the current code, gcc should be able to convert the call into a
tailcall.

<checks>

nope.

kmem_cache_free_array:
	pushq	%rbp	#
	movq	%rsp, %rbp	#,
	call	__kmem_cache_free_array	#
	leave
	ret

stupid gcc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
