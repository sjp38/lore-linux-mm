Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4F1C96B004A
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 13:43:32 -0400 (EDT)
Message-ID: <4CC71345.9050907@kernel.org>
Date: Tue, 26 Oct 2010 20:43:33 +0300
From: Pekka Enberg <penberg@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH] [v2] slub tracing: move trace calls out of always inlined
 functions to reduce kernel code size
References: <1286986178.1901.60.camel@castor.rsk>	 <4CB6ACB7.8060006@kernel.org>  <1287049769.1909.4.camel@castor.rsk> <1287653359.1906.13.camel@castor.rsk>
In-Reply-To: <1287653359.1906.13.camel@castor.rsk>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Richard Kennedy <richard@rsk.demon.co.uk>
Cc: Christoph Lameter <cl@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Steven Rostedt <rostedt@goodmis.org>
List-ID: <linux-mm.kvack.org>

On 21.10.2010 12.29, Richard Kennedy wrote:
> Having the trace calls defined in the always inlined kmalloc functions
> in include/linux/slub_def.h causes a lot of code duplication as the
> trace functions get instantiated for each kamalloc call site. This can
> simply be removed by pushing the trace calls down into the functions in
> slub.c.
>
> On my x86_64 built this patch shrinks the code size of the kernel by
> approx 36K and also shrinks the code size of many modules -- too many to
> list here ;)
>
> size vmlinux (2.6.36) reports
>         text        data     bss     dec     hex filename
>      5410611	 743172	 828928	6982711	 6a8c37	vmlinux
>      5373738	 744244	 828928	6946910	 6a005e	vmlinux + patch
>
> The resulting kernel has had some testing&  kmalloc trace still seems to
> work.
>
> This patch
> - moves trace_kmalloc out of the inlined kmalloc() and pushes it down
> into kmem_cache_alloc_trace() so this it only get instantiated once.
>
> - rename kmem_cache_alloc_notrace()  to kmem_cache_alloc_trace() to
> indicate that now is does have tracing. (maybe this would better being
> called something like kmalloc_kmem_cache ?)
>
> - adds a new function kmalloc_order() to handle allocation and tracing
> of large allocations of page order.
>
> - removes tracing from the inlined kmalloc_large() replacing them with a
> call to kmalloc_order();
>
> - move tracing out of inlined kmalloc_node() and pushing it down into
> kmem_cache_alloc_node_trace
>
> - rename kmem_cache_alloc_node_notrace() to
> kmem_cache_alloc_node_trace()
>
> - removes the include of trace/events/kmem.h from slub_def.h.
>
> v2
> - keep kmalloc_order_trace inline when !CONFIG_TRACE
>
> Signed-off-by: Richard Kennedy<richard@rsk.demon.co.uk>

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
