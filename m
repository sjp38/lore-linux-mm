Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id A3EF96B00A3
	for <linux-mm@kvack.org>; Fri, 13 Mar 2015 20:06:12 -0400 (EDT)
Received: by iecsl2 with SMTP id sl2so131458030iec.1
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 17:06:12 -0700 (PDT)
Received: from mail-ie0-x234.google.com (mail-ie0-x234.google.com. [2607:f8b0:4001:c03::234])
        by mx.google.com with ESMTPS id h1si3815929igh.3.2015.03.13.17.06.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Mar 2015 17:06:12 -0700 (PDT)
Received: by ieclw3 with SMTP id lw3so132490563iec.2
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 17:06:12 -0700 (PDT)
Date: Fri, 13 Mar 2015 17:06:09 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] mm, mempool: poison elements backed by slab
 allocator
In-Reply-To: <20150312132832.87c85af5a1bc1978c0d7c049@linux-foundation.org>
Message-ID: <alpine.DEB.2.10.1503131649080.19521@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1503090021380.19148@chino.kir.corp.google.com> <20150312132832.87c85af5a1bc1978c0d7c049@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sebastian Ott <sebott@linux.vnet.ibm.com>, Mikulas Patocka <mpatocka@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 12 Mar 2015, Andrew Morton wrote:

> > Mempools keep elements in a reserved pool for contexts in which
> > allocation may not be possible.  When an element is allocated from the
> > reserved pool, its memory contents is the same as when it was added to
> > the reserved pool.
> > 
> > Because of this, elements lack any free poisoning to detect
> > use-after-free errors.
> > 
> > This patch adds free poisoning for elements backed by the slab allocator.
> > This is possible because the mempool layer knows the object size of each
> > element.
> > 
> > When an element is added to the reserved pool, it is poisoned with
> > POISON_FREE.  When it is removed from the reserved pool, the contents are
> > checked for POISON_FREE.  If there is a mismatch, a warning is emitted to
> > the kernel log.
> > 
> > This is only effective for configs with CONFIG_DEBUG_VM.
> 
> At present CONFIG_DEBUG_VM is pretty lightweight (I hope) and using it
> for mempool poisoning might be inappropriately costly.  Would it be
> better to tie this to something else?  Either standalone or reuse some
> slab debug option, perhaps.
> 

Ok, I agree.  I'll use CONFIG_DEBUG_SLAB and CONFIG_SLUB_DEBUG_ON and 
allow it to be enabled by slub debugging when that is enabled.  It 
probably doesn't make a lot of sense to do mempool poisoning without slab 
poisoning.

> Did you measure the overhead btw?  It might be significant with fast
> devices.
> 

It's certainly costly: with a new 128-byte slab cache, allocating 64 
objects took about 480 cycles longer per object to do the poison checking 
and in-use poisoning on one of my 2.2GHz machines (~90 cycles/object 
without CONFIG_DEBUG_VM).  To do the free poisoning, it was about ~130 
cycles longer per object (~140 cycles/object without CONFIG_DEBUG_VM).

For cache cold pages from the page allocator, it's more expensive, 
allocating and freeing 64 pages, it's ~620 cycles longer per page and 
freeing is an additional ~60 cycles/page.

Keep in mind that overhead is only incurred when the mempool alloc 
function fails to allocate memory directly from the slab allocator or page 
allocator in the given context and on mempool_create() to create the new 
mempool.

I didn't benchmark high-order page poisoning, but that's only used by 
bcache and I'm looking at that separately: allocating high-order pages 
from a mempool sucks.

> > --- a/mm/mempool.c
> > +++ b/mm/mempool.c
> > @@ -16,16 +16,77 @@
> >  #include <linux/blkdev.h>
> >  #include <linux/writeback.h>
> >  
> > +#ifdef CONFIG_DEBUG_VM
> > +static void poison_error(mempool_t *pool, void *element, size_t size,
> > +			 size_t byte)
> > +{
> > +	const int nr = pool->curr_nr;
> > +	const int start = max_t(int, byte - (BITS_PER_LONG / 8), 0);
> > +	const int end = min_t(int, byte + (BITS_PER_LONG / 8), size);
> > +	int i;
> > +
> > +	pr_err("BUG: mempool element poison mismatch\n");
> > +	pr_err("Mempool %p size %ld\n", pool, size);
> > +	pr_err(" nr=%d @ %p: %s0x", nr, element, start > 0 ? "... " : "");
> > +	for (i = start; i < end; i++)
> > +		pr_cont("%x ", *(u8 *)(element + i));
> > +	pr_cont("%s\n", end < size ? "..." : "");
> > +	dump_stack();
> > +}
> 
> "byte" wasn't a very useful identifier, and it's called "i" in
> check_slab_element().  Rename it to "offset" in both places?
> 
> > +static void check_slab_element(mempool_t *pool, void *element)
> > +{
> > +	if (pool->free == mempool_free_slab || pool->free == mempool_kfree) {
> > +		size_t size = ksize(element);
> > +		u8 *obj = element;
> > +		size_t i;
> > +
> > +		for (i = 0; i < size; i++) {
> > +			u8 exp = (i < size - 1) ? POISON_FREE : POISON_END;
> > +
> > +			if (obj[i] != exp) {
> > +				poison_error(pool, element, size, i);
> > +				return;
> > +			}
> > +		}
> > +		memset(obj, POISON_INUSE, size);
> > +	}
> > +}
> 
> I question the reuse of POISON_FREE/POISON_INUSE.  If this thing
> triggers, it may be hard to tell if it was due to a slab thing or to a
> mempool thing.  Using a distinct poison pattern for mempool would clear
> that up?
> 

Hmm, I think it would actually make it more confusing: mempools only 
allocate from the reserved pool (those poisoned by this patchset) when 
doing kmalloc() or kmem_cache_free() in context fails.  Normally, the 
reserved pool isn't used because there are free objects sitting on slab 
free or partial slabs and the context is irrelevant.  If slab poisoning is 
enabled, they are already POISON_FREE as anticipated.  We only fallback to 
the reserved pool when new slab needs to be allocated and fails in the 
given context, so the poison value would differ depending on where the 
objects came from.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
