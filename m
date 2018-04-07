Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 173876B000C
	for <linux-mm@kvack.org>; Sat,  7 Apr 2018 11:13:12 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id c3-v6so3126990itc.4
        for <linux-mm@kvack.org>; Sat, 07 Apr 2018 08:13:12 -0700 (PDT)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id i2si8221167ioi.54.2018.04.07.08.13.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Apr 2018 08:13:10 -0700 (PDT)
Date: Sat, 7 Apr 2018 10:13:09 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 06/25] slab: make kmem_cache_create() work with 32-bit
 sizes
In-Reply-To: <20180406084048.GA2048@avx2>
Message-ID: <alpine.DEB.2.20.1804071008050.10800@nuc-kabylake>
References: <20180305200730.15812-1-adobriyan@gmail.com> <20180305200730.15812-6-adobriyan@gmail.com> <alpine.DEB.2.20.1803061235260.29393@nuc-kabylake> <20180405144833.41d16216c8c010294664e8ce@linux-foundation.org> <20180406084048.GA2048@avx2>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org

On Fri, 6 Apr 2018, Alexey Dobriyan wrote:

> > > Its not so simple. Please verify that the edge cases of all object size /
> > > alignment etc calculations are doable with 32 bit entities first.
> > >
> > > And size_t makes sense as a parameter.
> >
> > Alexey, please don't let this stuff dangle on.
> >
> > I think I'll merge this as-is but some fixups might be needed as a
> > result of Christoph's suggestion?
>
> I see this email in public archives, but not in my mailbox :-\

Oh gosh. More email trouble with routing via comcast.

> 1)
> "int size" proves that 4GB+ caches were always broken both on SLUB
> and SLAB. I could audit calculate_sizes() and friends but why bother
> if create_cache() already truncated everything.

The problem is that intermediate results in calculations may exceed the
int range. Please look at that.

> You're writing:
>
> 	that the edge cases of all object size ...
> 	... are doable with 32 bit entities
>
> AS IF they were doable with 64-bit. They weren't.

That was not the issue. No one ever claimed that slabs of more than 4GB
were supported.

> kmalloc is limited to 64MB, after that it fallbacks to page allocator.
> Which means that some huge structure cache must be created by cache or
> not affected by conversion as it still falls back to page allocator.

That is not accurate: kmalloc falls back after PAGE_SIZE << 1 to the page
allocator.

> > And size_t makes sense as a parameter.
>
> size_t doesn't make sense for kernel as 4GB+ objects are few and far
> between.

Again not the issue. Please stop fighting straw men and issues that you
come up with in your imagination. size_t makes sense because the type is
designed to represent the size of an object.
