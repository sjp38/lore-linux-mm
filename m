Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id F10426B0003
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 04:40:53 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id p18so431095wmh.2
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 01:40:53 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c4sor4333281wre.45.2018.04.06.01.40.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 06 Apr 2018 01:40:52 -0700 (PDT)
Date: Fri, 6 Apr 2018 11:40:48 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 06/25] slab: make kmem_cache_create() work with 32-bit
 sizes
Message-ID: <20180406084048.GA2048@avx2>
References: <20180305200730.15812-1-adobriyan@gmail.com>
 <20180305200730.15812-6-adobriyan@gmail.com>
 <alpine.DEB.2.20.1803061235260.29393@nuc-kabylake>
 <20180405144833.41d16216c8c010294664e8ce@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180405144833.41d16216c8c010294664e8ce@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christopher Lameter <cl@linux.com>, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org

On Thu, Apr 05, 2018 at 02:48:33PM -0700, Andrew Morton wrote:
> On Tue, 6 Mar 2018 12:37:49 -0600 (CST) Christopher Lameter <cl@linux.com> wrote:
> 
> > On Mon, 5 Mar 2018, Alexey Dobriyan wrote:
> > 
> > > struct kmem_cache::size and ::align were always 32-bit.
> > >
> > > Out of curiosity I created 4GB kmem_cache, it oopsed with division by 0.
> > > kmem_cache_create(1UL<<32+1) created 1-byte cache as expected.
> > 
> > Could you add a check to avoid that in the future?
> > 
> > > size_t doesn't work and never did.
> > 
> > Its not so simple. Please verify that the edge cases of all object size /
> > alignment etc calculations are doable with 32 bit entities first.
> > 
> > And size_t makes sense as a parameter.
> 
> Alexey, please don't let this stuff dangle on.
> 
> I think I'll merge this as-is but some fixups might be needed as a
> result of Christoph's suggestion?

I see this email in public archives, but not in my mailbox :-\

Anyway,

I think the answer is in fact simple.

1)
"int size" proves that 4GB+ caches were always broken both on SLUB
and SLAB. I could audit calculate_sizes() and friends but why bother
if create_cache() already truncated everything.

You're writing:

	that the edge cases of all object size ...
	... are doable with 32 bit entities

AS IF they were doable with 64-bit. They weren't.

2)
Dynamically allocated kernel data structures are in fact small.
I know of "struct kvm_vcpu", it is 20KB on my machine and it's
the biggest.

kmalloc is limited to 64MB, after that it fallbacks to page allocator.
Which means that some huge structure cache must be created by cache or
not affected by conversion as it still falls back to page allocator.

3)
->size and ->align were signed ints, making them unsigned makes
overflows twice as unlikely :^)

> And size_t makes sense as a parameter.

size_t doesn't make sense for kernel as 4GB+ objects are few and far
between.

I remember such patches could shrink SLUB by ~1KB. SLUB is 30KB total.
So it is 2-3% reduction simply by not using "unsigned long" and "size_t"
and using 32-bit arithmetic.

Userspace shifted to size_t, people copy, it bloats kernel for no reason.
