Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 245BE5F0001
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 09:27:25 -0500 (EST)
Subject: Re: [patch 2/2] slqb: dynamic array allocations
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <20090203140712.GB8723@wotan.suse.de>
References: <20090203135559.GA8723@wotan.suse.de>
	 <20090203140712.GB8723@wotan.suse.de>
Date: Tue, 03 Feb 2009 16:27:20 +0200
Message-Id: <1233671240.22926.60.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Hi Nick,

On Tue, 2009-02-03 at 15:07 +0100, Nick Piggin wrote:
> It would be nice to keep this changeset in history if it gets merged upstream.
> I don't know for sure if there won't be a performance impact.

The 'topic/slqb/core' branch in slab.git is append-only so when you want
to merge this with Linus, we can always just ask him to pull. I don't
see much reason to fiddle with the history. After all, it's hidden under
a new config option so it's not like it's going to break git bisect or
anything.

On Tue, 2009-02-03 at 15:07 +0100, Nick Piggin wrote:
> Implement dynamic allocation for SLQB per-cpu and per-node arrays. This
> should hopefully have minimal runtime performance impact, because although
> there is an extra level of indirection to do allocations, the pointer should
> be in the cache hot area of the struct kmem_cache.
> 
> It's not quite possible to use dynamic percpu allocator for this: firstly,
> that subsystem uses the slab allocator. Secondly, it doesn't have good
> support for per-node data. If those problems were improved, we could use it.
> For now, just implement a very very simple allocator until the kmalloc
> caches are up.
> 
> On x86-64 with a NUMA MAXCPUS config, sizes look like this:
>    text    data     bss     dec     hex filename
>   29960  259565     100  289625   46b59 mm/slab.o
>   34130  497130     696  531956   81df4 mm/slub.o
>   24575 1634267  111136 1769978  1b01fa mm/slqb.o
>   24845   13959     712   39516    9a5c mm/slqb.o + this patch
> 
> SLQB is now 2 orders of magnitude smaller than it was, and an order of
> magnitude smaller than SLAB or SLUB (in total size -- text size has
> always been smaller). So it should now be very suitable for distro-type
> configs in this respect.

I think Christoph's percpu allocator is supposed to fix it up for SLUB.
We can probably switch SLQB over as well when that work hits mainline.

On Tue, 2009-02-03 at 15:07 +0100, Nick Piggin wrote:
> As a side-effect the UP version of cpu_slab (which is embedded directly
> in the kmem_cache struct) moves up to the hot cachelines, so it need no
> longer be cacheline aligned on UP. The overall result should be a
> reduction in cacheline footprint on UP kernels.
> 
> Signed-off-by: Nick Piggin <npiggin@suse.de>

Applied, thanks!

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
