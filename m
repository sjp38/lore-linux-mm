Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4200A6B0269
	for <linux-mm@kvack.org>; Fri,  4 May 2018 21:08:26 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id x85-v6so4584550vke.11
        for <linux-mm@kvack.org>; Fri, 04 May 2018 18:08:26 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c4sor7115910uaf.159.2018.05.04.18.08.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 04 May 2018 18:08:25 -0700 (PDT)
MIME-Version: 1.0
From: Kees Cook <keescook@google.com>
Date: Fri, 4 May 2018 18:08:23 -0700
Message-ID: <CAGXu5j++1TLqGGiTLrU7OvECfBAR6irWNke9u7Rr2i8g6_30QQ@mail.gmail.com>
Subject: *alloc API changes
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>

Hi,

After writing up this email, I think I don't like this idea, but I'm
still curious to see what people think of the general observations...


The number of permutations for our various allocation function is
rather huge. Currently, it is:

system or wrapper:
kmem_cache_alloc, kmalloc, vmalloc, kvmalloc, devm_kmalloc,
dma_alloc_coherent, pci_alloc_consistent, kmem_alloc, f2fs_kvalloc,
and probably others I haven't found yet.

allocation method (not all available in all APIs):
regular (kmalloc), zeroed (kzalloc), array (kmalloc_array), zeroed
array (kcalloc)

with or without node argument:
+_node

so, for example, we have things like: kmalloc_array_node() or
pci_zalloc_consistent()

Using some attempts at static analysis with git grep and coccinelle,
nearly all of these take GFP flags, but something near 80% of
functions are using GFP_KERNEL. Roughly half of the callers are
including a sizeof(). Only 20% are using zeroing, 15% are using
products as a size, and 3% are using ..._node, etc.

I wonder if we might be able to rearrange our APIs for the general
case and include a common "kitchen sink" API for the less common
options. I.e. why do we have an entire set of _node() APIs, 2 sets for
zeroing (kzalloc, kcalloc), etc.

kmalloc()-family was meant to be a simplification of
kmem_cache_alloc(). vmalloc() duplicated the kmalloc()-family, and
kvmalloc() does too. Then we have "specialty" allocators (devm, dma,
pci, f2fs, xfs's kmem) that have subsets and want to perform other
actions around the base allocators or have their own entirely (e.g.
dma).

Instead of all the variations, it seems like we just want a per-family
alloc() and alloc_attrs(), where alloc_attrs() could handle the less
common stuff (e.g. gfp, zero, node).

kmalloc(size, GFP_KERNEL)
becomes a nice:
kmalloc(size)

However, then
kzalloc(size, GFP_KERNEL)
becomes the ugly:
kmalloc_attrs(size, GFP_KERNEL, ALLOC_ZERO, NUMA_NO_NODE);

(But I guess we could make macro wrappers for zeroing, or node?)

But this doesn't solve the multiplication overflow case at all, which
is my real goal. Trying to incorporate some of the ideas from other
threads, maybe we could have a multiplication helper that would
saturate and the allocator would see that as a signal to return NULL?
e.g.:

inline size_t mult(size_t a, size_t b)
{
    if (b != 0 && a >= SIZE_MAX / b)
        return SIZE_MAX;
    return a * b;
}
(really, this kind of helper should be based on Rasmus's helpers which
do correct type handling)

void *kmalloc(size_t size)
{
    if (size == SIZE_MAX)
        return NULL;
    kmalloc_attrs(size, GFP_KERNEL, ALLOC_NOZERO, NUMA_NO_NODE);
}

then we get:
var = kmalloc(mult(num, sizeof(*var)));

we could drop the *calloc(), *zalloc(), and *_array(), leaving only
*alloc() and *alloc_attrs() for all the allocator families.

I honestly can't tell if this is worse than doing all the family
conversions to *calloc() and *_array() for the 1000ish instances of
2-factor products used for size arguments in the *alloc() functions.
We could still nest them for the 3-factor ones?
var = kmalloc(multi(row, mult(column, sizeof(*var))));

But now we're just pretending to be LISP.

And really, I'd like to keep the nicer *alloc_struct() with all its
type checking. But then do we do *zalloc_struct(),
*alloc_struct_node(), etc, etc?

Bleh. C sucks for this.

-Kees

-- 
Kees Cook
Pixel Security
