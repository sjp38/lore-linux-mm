Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id DC8CA6B0297
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 09:40:48 -0400 (EDT)
Received: by qkbi190 with SMTP id i190so22379368qkb.1
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 06:40:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f47si10317454qge.78.2015.10.02.06.40.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Oct 2015 06:40:47 -0700 (PDT)
Date: Fri, 2 Oct 2015 15:40:39 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [MM PATCH V4.1 5/6] slub: support for bulk free with SLUB
 freelists
Message-ID: <20151002154039.69f82bdc@redhat.com>
In-Reply-To: <20151002114118.75aae2f9@redhat.com>
References: <560ABE86.9050508@gmail.com>
	<20150930114255.13505.2618.stgit@canyon>
	<20151001151015.c59a1360c7720a257f655578@linux-foundation.org>
	<20151002114118.75aae2f9@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Alexander Duyck <alexander.duyck@gmail.com>, Pekka Enberg <penberg@kernel.org>, netdev@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, brouer@redhat.com, Hannes Frederic Sowa <hannes@redhat.com>

On Fri, 2 Oct 2015 11:41:18 +0200
Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> On Thu, 1 Oct 2015 15:10:15 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > On Wed, 30 Sep 2015 13:44:19 +0200 Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> > 
> > > Make it possible to free a freelist with several objects by adjusting
> > > API of slab_free() and __slab_free() to have head, tail and an objects
> > > counter (cnt).
> > > 
> > > Tail being NULL indicate single object free of head object.  This
> > > allow compiler inline constant propagation in slab_free() and
> > > slab_free_freelist_hook() to avoid adding any overhead in case of
> > > single object free.
> > > 
> > > This allows a freelist with several objects (all within the same
> > > slab-page) to be free'ed using a single locked cmpxchg_double in
> > > __slab_free() and with an unlocked cmpxchg_double in slab_free().
> > > 
> > > Object debugging on the free path is also extended to handle these
> > > freelists.  When CONFIG_SLUB_DEBUG is enabled it will also detect if
> > > objects don't belong to the same slab-page.
> > > 
> > > These changes are needed for the next patch to bulk free the detached
> > > freelists it introduces and constructs.
> > > 
> > > Micro benchmarking showed no performance reduction due to this change,
> > > when debugging is turned off (compiled with CONFIG_SLUB_DEBUG).
> > > 
> > 
> > checkpatch says
> > 
> > WARNING: Avoid crashing the kernel - try using WARN_ON & recovery code rather than BUG() or BUG_ON()
> > #205: FILE: mm/slub.c:2888:
> > +       BUG_ON(!size);
> > 
> > 
> > Linus will get mad at you if he finds out, and we wouldn't want that.
> > 
> > --- a/mm/slub.c~slub-optimize-bulk-slowpath-free-by-detached-freelist-fix
> > +++ a/mm/slub.c
> > @@ -2885,7 +2885,8 @@ static int build_detached_freelist(struc
> >  /* Note that interrupts must be enabled when calling this function. */
> >  void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
> >  {
> > -	BUG_ON(!size);
> > +	if (WARN_ON(!size))
> > +		return;
> >  
> >  	do {
> >  		struct detached_freelist df;
> > _
> 
> My problem with this change is that WARN_ON generates (slightly) larger
> code size, which is critical for instruction-cache usage...
> 
>  [net-next-mm]$ ./scripts/bloat-o-meter vmlinux-with_BUG_ON vmlinux-with_WARN_ON 
>  add/remove: 0/0 grow/shrink: 1/0 up/down: 17/0 (17)
>  function                                     old     new   delta
>  kmem_cache_free_bulk                         438     455     +17
> 
> My IP-forwarding benchmark is actually a very challenging use-case,
> because the code path "size" a packet have to travel is larger than the
> instruction-cache of the CPU.
> 
> Thus, I need introducing new code like this patch and at the same time
> have to reduce the number of instruction-cache misses/usage.  In this
> case we solve the problem by kmem_cache_free_bulk() not getting called
> too often. Thus, +17 bytes will hopefully not matter too much... but on
> the other hand we sort-of know that calling kmem_cache_free_bulk() will
> cause icache misses.

I just tested this change on top of my net-use-case patchset... and for
some strange reason the code with this WARN_ON is faster and have much
less icache-misses (1,278,276 vs 2,719,158 L1-icache-load-misses).

Thus, I think we should keep your fix.

I cannot explain why using WARN_ON() is better and cause less icache
misses.  And I hate when I don't understand every detail.

 My theory is, after reading the assembler code, that the UD2
instruction (from BUG_ON) cause some kind of icache decoder stall
(Intel experts???).  Now that should not be a problem, as UD2 is
obviously placed as an unlikely branch and left at the end of the asm
function call.  But the call to __slab_free() is also placed at the end
of the asm function (gets inlined from slab_free() as unlikely).  And
it is actually fairly likely that bulking is calling __slab_free (slub
slowpath call).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
