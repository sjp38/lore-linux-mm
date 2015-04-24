Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id 727466B0032
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 09:52:40 -0400 (EDT)
Received: by qkhg7 with SMTP id g7so29983724qkh.2
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 06:52:40 -0700 (PDT)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id d191si11433280qka.74.2015.04.24.06.52.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 24 Apr 2015 06:52:39 -0700 (PDT)
Date: Fri, 24 Apr 2015 08:52:37 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3] mm/slab_common: Support the slub_debug boot option
 on specific object size
In-Reply-To: <20150423135106.1411031c362de2a5ef75fd50@linux-foundation.org>
Message-ID: <alpine.DEB.2.11.1504240847270.7582@gentwo.org>
References: <1429795560-29131-1-git-send-email-gavin.guo@canonical.com> <20150423135106.1411031c362de2a5ef75fd50@linux-foundation.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Gavin Guo <gavin.guo@canonical.com>, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux@rasmusvillemoes.dk

On Thu, 23 Apr 2015, Andrew Morton wrote:
> >
> > +		if (i == 2)
> > +			i = (KMALLOC_SHIFT_LOW - 1);
>
> Can we get rid of this by using something like

Nope index is a ilog2 value of the size. The table changes would not
preserve the mapping of the index to the power of two sizes.

> static struct {
> 	const char *name;
> 	unsigned long size;
> } const kmalloc_names[] __initconst = {
> //	{NULL,                      0},
> 	{"kmalloc-96",             96},
> 	{"kmalloc-192",           192},
> #if KMALLOC_MIN_SIZE <= 8
> 	{"kmalloc-8",               8},
> #endif
> #if KMALLOC_MIN_SIZE <= 16
> 	{"kmalloc-16",             16},
> #endif
> #if KMALLOC_MIN_SIZE <= 32
> 	{"kmalloc-32",             32},
> #endif
> 	{"kmalloc-64",             64},
> 	{"kmalloc-128",           128},
> 	{"kmalloc-256",           256},
> 	{"kmalloc-512",           512},
> 	{"kmalloc-1024",         1024},
> 	{"kmalloc-2048",         2048},
> 	{"kmalloc-4096",         4096},
> 	{"kmalloc-8192",         8192},
> 	...
> };
>

> Why does the initialization code do the
>
> 	if (!kmalloc_caches[i]) {
>
> test?  Can any of these really be initialized?  If so, why is it
> legitimate for create_kmalloc_caches() to go altering size_index[]
> after some caches have already been set up?

Because we know what sizes we need during bootstrap and the initial
caches that are needed to create others are first populated. If they are
already handled by the earliest bootstrap code then we should not
repopulate them later.

> Finally, why does create_kmalloc_caches() use GFP_NOWAIT?  We're in
> __init code!  Makes no sense.  Or if it *does* make sense, the reason
> should be clearly commented.

Well I was told by Pekka to use it exactly because it was init code at
some point. The slab system is not really that functional so I doubt
it makes much of a difference.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
