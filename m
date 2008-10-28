From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: vm_unmap_aliases and Xen
Date: Tue, 28 Oct 2008 16:19:10 +1100
References: <49010D41.1080305@goop.org>
In-Reply-To: <49010D41.1080305@goop.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200810281619.10388.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Friday 24 October 2008 10:48, Jeremy Fitzhardinge wrote:
> I've been having a few problems with Xen, I suspect as a result of the
> lazy unmapping in vmalloc.c.
>
> One immediate one is that vm_unmap_aliases() will oops if you call it
> before vmalloc_init() is called, which can happen in the Xen case.  RFC
> patch below.

Sure, we could do that. If you add an unlikely, and a __read_mostly,
I'd ack it. Thanks for picking this up.


> But the bigger problem I'm seeing is that despite calling
> vm_unmap_aliases() at the pertinent places, I'm still seeing errors
> resulting from stray aliases.  Is it possible that vm_unmap_aliases()
> could be missing some, or not completely synchronous?

It's possible, but of course that would not be by design ;)

I've had another look over it, and nothing obvious comes to
mind.

Actually, there may be a slight problem with the per-cpu KVA
flushing (it doesn't clear the dirty map after flushing, so
it would be possible to see the warning in vunmap_pte_range
trigger, I'll have to fix that). But I can't see your problem
yet.

It would be nice to narrow it down... Could you replace
lazy_max_pages call with 0, then change the 3rd and 4th
parameters of __purge_vmap_area_lazy in purge_vmap_area_lazy
with 1 and 1 rather than 0 and 0?


> Subject: vmap: cope with vm_unmap_aliases before vmalloc_init()
>
> Xen can end up calling vm_unmap_aliases() before vmalloc_init() has
> been called.  In this case its safe to make it a simple no-op.
>
> Signed-off-by: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
> diff -r 42c8b29f7ccf mm/vmalloc.c
> --- a/mm/vmalloc.c	Wed Oct 22 12:43:39 2008 -0700
> +++ b/mm/vmalloc.c	Wed Oct 22 21:39:00 2008 -0700
> @@ -591,6 +591,8 @@
>
>  #define VMAP_BLOCK_SIZE		(VMAP_BBMAP_BITS * PAGE_SIZE)
>
> +static bool vmap_initialized = false;
> +
>  struct vmap_block_queue {
>  	spinlock_t lock;
>  	struct list_head free;
> @@ -827,6 +829,9 @@
>  	int cpu;
>  	int flush = 0;
>
> +	if (!vmap_initialized)
> +		return;
> +
>  	for_each_possible_cpu(cpu) {
>  		struct vmap_block_queue *vbq = &per_cpu(vmap_block_queue, cpu);
>  		struct vmap_block *vb;
> @@ -940,6 +945,8 @@
>  		INIT_LIST_HEAD(&vbq->dirty);
>  		vbq->nr_dirty = 0;
>  	}
> +
> +	vmap_initialized = true;
>  }
>
>  void unmap_kernel_range(unsigned long addr, unsigned long size)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
